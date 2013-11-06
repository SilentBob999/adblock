#!/bin/sh
{
cat <<'ENDF'|gzip|openssl enc -base64

alias elog='logger -t ADBLOCK -s'
LocalHost="$CIFS/HOST-S\$i"

[ -d $CIFS ] && TMP="$CIFS/tmp" || TMP="/tmp/tmp"
[ -d $CIFS ] && GEN="$CIFS/gen" || GEN="/tmp/gen"

# Check if already running
pidfile=/var/run/adblock.pid
kill -0 $(cat $pidfile 2>/dev/null) &>/dev/null && {
	elog "Another instance found ($pidfile, $(cat $pidfile)), exiting!"
	exit 1
}
echo $$ > $pidfile

# Check if blocking
[ "$(ps | grep -v grep | grep 'dnsmasq --conf-file=')" ] && Running="yes" || unset Running

# Stop blocking.  Free RAM
stop() {
	elog "STOP"
	unset Running
	service dnsmasq restart &>/dev/null
}

pexit() {
	elog "Exiting"
	rm $TMP $GEN $pidfile &>/dev/null
	exit $@
}

# Catch argument passed to the script
case "$1" in
	restart) stop;;
	stop) stop; pexit 0;;
	toggle)	[ -n "$Running" ] && { stop; pexit 0; };;
	force) stop; force="1";;
esac

# Remove whitelisted site from the file
Whitelist() {
for w in $WHITELIST; do
sed -i -e "/\.$w/d" -e "/\/$w/d" $TMP
done
}

# Format the file for dnsmasq
Generate() {
sed -i -e '
/%/d
s/[[:cntrl:][:blank:]]//g
s/^[ \t]*//;s/[ \t]*$//
s/[[:space:]]*\[.*$//
s/[[:space:]]*\].*$//
/[[:space:]]*#.*$/ s/[[:space:]]*#.*$//  
/^$/d
/127\.0\.0\.1/ s/^127\.0\.0\.1[ \t]*//
/^www[0-9]\./ s/^www[0-9]\.//   
/^www\./ s/^www\.//
s|$|/'$REDIRECTIP'|
s|^|address=/|' $TMP
Whitelist
#cat $TMP >> $GEN
#cat $GEN | sort -u > $TMP || elog "ERROR ; sort failed"
#mv -f $TMP $GEN
[ -f $GEN ] || echo "" > $GEN
if [ -d $CIFS ]; then sort -o $TMP -T $CIFS $TMP && sort -m -u -o $GEN -T $CIFS $TMP $GEN || elog "ERROR ; sort failed"
else sort -o $TMP $TMP && sort -m -u -o $GEN $TMP $GEN || elog "ERROR ; sort failed"; fi
rm $TMP &>/dev/null
wait
}

# This function Download / Or select the file to generate
DL() {
# Call stop to free ram if a config file will be generated	
[ -n "$DLList" -o -n "$GenOnly" ] && stop
# Download
[ -n "$DLList" ] && {
	for i in $DLList; do
		eval url="\$S$i"
		eval LocalFile="$LocalHost"
		if wget $url -U "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)" -O - > $TMP ; then
		elog "S$i downloaded $url"
		[ -d $CIFS ] && cp -f $TMP $LocalFile
		Generate
		else
		[ -f $LocalFile ] && {
		elog "S$i update failed: load $LocalFile"
		cp -f $LocalFile $TMP
		Generate
		} || elog "S$i failed $url"
		fi
	done
}
# Generate from local (if up to date or only local)
[ -n "$GenOnly" ] && {
	for i in $GenOnly; do
		eval LocalFile="$LocalHost"
		[ -f $LocalFile ] && {
			elog "Loading $LocalFile"
			cp -f $LocalFile $TMP
			Generate
		}
	done
}
wait
}

# Check for update
CheckUpdate() {
unset UpToDate GenOnly DLList
for i in $GETS; do
local LAST=S$i.last
eval LocalFile="$LocalHost"
eval url="\$S$i"
unset LASTF time
[ -f "/tmp/$LAST" ] && LASTF=/tmp/$LAST
[ -f "$CIFS/$LAST" ] && LASTF=$CIFS/$LAST
P1=$(echo $url| sed 's|^http[s]*://[^/]*\(/.*\)$|\1|')
H1=$(echo $url| sed 's|^http[s]*://\([^/]*\)/.*$|\1|')
time=$(echo -e "HEAD $P1 HTTP/1.1\r\nHost: $H1\r\nConnection: close\r\n"|
nc -w 5 $H1 80|grep -i Last-Modified:|tr -d "\r")
[ -n "$time" ] && {
	[ "$time" != "$(cat "$LASTF")" -o "$force" == "1" ] && {
		# Need update
		elog "S$i outdated"
		DLList="$DLList $i"
		} || {
			# UpToDate	
			elog "S$i UpToDate"
			[ -f "$LocalFile" ] && UpToDateLocal="$UpToDateLocal $i" || UpToDate="$UpToDate $i"
		}
	# Write modified time to RAM and in CIFS
	[ -d $CIFS ] && echo "$time" >$CIFS/$LAST
	echo "$time" >/tmp/$LAST
	} || {
	# No "last modified" then download
	# LocalOnly host file are always up to date
	[ "$(eval "echo \${S$i}")" == "" -a -f "$LocalFile" ] && UpToDateLocal="$UpToDateLocal $i" || {
		elog "S$i unknown 'Last Modified'"
		DLList="$DLList $i"
		}
	}
done
# Will generate or download these UpToDate source only if another source is
# not up-to-date or if it's the first run otherwise dnsmasq do not
# need to be restarted/configure	
[ -n "$UpToDate" ] && ( [ -n "$DLList" -o ! -n "$Running" ] ) && DLList="$DLList $UpToDate"
[ -n "$UpToDateLocal" ] && ( [ -n "$DLList" -o ! -n "$Running" ] ) && GenOnly="$GenOnly $UpToDateLocal"
wait
}


eval START=$(date +%s)
rm $GEN &>/dev/null
cru d ADBTmpCheck &>/dev/null
[ "$CIFSRequire" == "N" -o -d $CIFS ] && {
	CheckUpdate
	DL
	[ -f $GEN ] && {
		SIZE=$(du -sh $GEN | awk '{ print $1 }')
		service dnsmasq stop &>/dev/null
		killall -9 dnsmasq &>/dev/null
		wait
		# Add the original config file
		cat /etc/dnsmasq.conf >> $GEN
		# Start blocking
		dnsmasq --conf-file=$GEN && {
			eval BlockCount=$(grep -c 'address=/' $GEN)
			eval END=$(date +%s)
			eval DIFF=$(($END-$START))
			# EXTRA 
			[ -d $CIFS ] && echo ADBLOCK blocked $BlockCount unique host in $DIFF seconds > $CIFS/counts.txt
			[ -d $CIFS ] && cp -f $GEN $CIFS/dnsmask.conf
			elog "Blocked $BlockCount unique host in $DIFF seconds"
			} || {
			elog "ERROR ; dnsmasq config ($SIZE) failed"
			dnsmasq &>/dev/null && elog "failsafe ; load dnsmasq with default config (block nothing)" || elog "TROUBLE"
			}
		wait
	} || elog "No Updates"
} || {
	elog "Update skip because CIFS is required but offline. Will check again every 4 hour"
	cru a ADBTmpCheck "0 0,4,8,12,16,20 * * * /tmp/script_wanup.sh"
	}

pexit 0

ENDF
}
