#!/bin/sh
{
cat <<'ENDF'|gzip|openssl enc -base64

alias elog='logger -t ADBLOCK -s'
Running="/tmp/adblock" #leave in /tmp

# PID, exit if the process is already running
pidfile=/var/run/adblock.pid
kill -0 $(cat $pidfile 2>/dev/null) &>/dev/null && {
	elog "Another instance found ($pidfile), exiting!"
	exit 1
}
echo $$ > $pidfile

# Restart dnsmasq without the config file.  Stop blocking domain.  Free RAM
stop() {
	rm "$Running" &>/dev/null
	elog "STOP"
	#service dnsmasq restart
}

pexit() {
	elog "Exiting"
	rm $pidfile
	exit $@
}

# Catch argument passed to the script
case "$1" in
	restart) stop;;
	stop) stop; pexit 0;;
	toggle)	[ -e "$Running" ] && { stop; pexit 0; };;
	force) rm "$Running" &>/dev/null ;;
esac

# Remove whitelisted site from the file
# Yeah this can be inside the generate function
Whitelist() {
for w in $WHITELIST; do
sed -i -e "/\.$w/d /\/$w/d" $TMP
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
cat $TMP >> $GEN
cat $GEN | sort -u > $TMP
mv -f $TMP $GEN
}

# This function Download / Or select the file to generate
# Need to be call after CheckUpdate
DL() {
# Call stop to free ram if a config file will be generated	
[ -n "$DLList" -o -n "$GenOnly" ] && stop 2>&1
# Download
[ -n "$DLList" ] && {
	for i in $DLList; do
		eval url="\$S$i"
		eval LocalFile="$LocalHost"
		if wget $url -U "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)" -O - > $TMP ; then
		elog "S$i downloaded $url"
		[ -d $CIFS ] && cp $TMP $LocalFile
		Generate
		else
		[ -f $LocalFile ] && {
		elog "S$i update failed: load $LocalFile"
		cat $LocalFile > $TMP
		Generate
		} || elog "S$i failed $url"
		fi
		wait
	done
	wait
}
# Generate from local (if up to date or only local)
[ -n "$GenOnly" ] && {
	for i in $GenOnly; do
		eval LocalFile="$LocalHost"
		[ -f $LocalFile ] && {
			elog "Loading $LocalFile"
			cat $LocalFile > $TMP
			Generate
		}
		wait
	done
	wait
}
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
[ -f "$CIFS/$LAST" ] && LASTF=$CIFS/$LAST  # Use the last modified time in CIFS in priority to help keep the local file up to date
P1=$(echo $url| sed 's|^http[s]*://[^/]*\(/.*\)$|\1|')
H1=$(echo $url| sed 's|^http[s]*://\([^/]*\)/.*$|\1|')
time=$(echo -e "HEAD $P1 HTTP/1.1\r\nHost: $H1\r\nConnection: close\r\n"|
nc -w 5 $H1 80|grep -i Last-Modified:|tr -d "\r")
[ -n "$time" ] && {
	[ "$time" != "$(cat "$LASTF")" ] && {
		# Need update
		elog "S$i outdated"
		DLList="$DLList $i"
		} || {
			# UpToDate	
			elog "S$i UpToDate"
			[ -f "$LocalFile" ] && UpToDateLocal="$UpToDateLocal $i" || UpToDate="$UpToDate $i"
		}
	# Write modified time to RAM and in CIFS
	echo "$time" >$CIFS/$LAST
	echo "$time" >/tmp/$LAST
	} || {
	# Mark remote source that do not provide "last modified" to be downloaded
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
[ -n "$UpToDate" ] && ( [ -n "$DLList" -o ! -f "$Running" ] ) && DLList="$DLList $UpToDate"
[ -n "$UpToDateLocal" ] && ( [ -n "$DLList" -o ! -f "$Running" ] ) && GenOnly="$GenOnly $UpToDateLocal"
}

# BEGIN
eval START=$(date +%s)
rm $GEN 
CheckUpdate
DL

[ -f $GEN ] && {
	# Stop and kill dnsmasq to be sure we can start it with the config
	#service dnsmasq stop
	#killall -9 dnsmasq
	wait
	# Add the original config file
	cat /etc/dnsmasq.conf >> $GEN
	# Start dnsmasq with the generated config file
	#dnsmasq --conf-file=$GEN
	# Failsafe - in case the GEN file his somehow problematic
	dnsmasq >/dev/null 2>&1
	eval BlockCount=$(grep -c 'address=/' $GEN)
	eval END=$(date +%s)
	eval DIFF=$(($END-$START))
	elog "Blocked $BlockCount unique host in $DIFF seconds"
	# EXTRA 
	[ -d $CIFS ] && echo ADBLOCK blocked $BlockCount unique host in $DIFF seconds > $CIFS/counts.txt
	[ -d $CIFS ] && cp -f $GEN $CIFS/dnsmask.conf
} || elog "No Updates"

## remove the generated files
rm $TMP $GEN
echo Running > $Running

# END
pexit 0


ENDF
}
