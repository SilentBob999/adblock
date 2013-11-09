#!/bin/sh
## Tomato AD-Blocking script
## https://github.com/SilentBob999/adblock

REDIRECTIP="0.0.0.0"
CIFS="/cifs1/dnsmasq" # adapt to your need
CIFSRequire="N" # "Y"/"N"

WHITELIST="facebook.com dropbox.com"

## Sources
## Warning ( ( HUGE : S5 , S8 ) ( BIG : S6 ) CIFSRequire to "Y"
GETS="1 2 3 4 7" # List all source you want here
KeepAsHost="" # Listed here will be merge together in 1 single host (used as "addn-hosts=") 

# Source that are in GETS but are not listed in KeepAsHost will be formated an use directly in the dnsmasq config.
# Duplicate are removed inside each file but not duplicate between them.
# DNSmasq block domain wide, so every www. entry are removed and duplicate cleaned give smaller file.
# Host file seems to use less RAM or at least it is more tolerant to start the service but may crash after a while.

S1="http://pgl.yoyo.org/as/serverlist.php?hostformat=nohtml"  ##44K - 2,539 hosts
S2="http://mirror1.malwaredomains.com/files/justdomains" ##474K - 23,972 hosts
S3="http://www.malwaredomainlist.com/hostslist/hosts.txt" ##52K - 1,661 hosts
S4="http://winhelp2002.mvps.org/hosts.txt" ##560K - approx 15,350 hosts
S5="http://hosts-file.net/download/hosts.txt" #7,873K - 246,284 hosts
S6="http://hosts-file.net/hphosts-partial.asp" #2,719K - 77,661 hosts
S7="http://someonewhocares.org/hosts/hosts" #321K - approx 10,100 hosts
S8="http://adblock.mahakala.is/hosts" ##10,528K  330,332 hosts


alias elog='logger -t ADBLOCK -s'
LocalHost="$CIFS/HOST-S\$i"

[ -d "$CIFS" ] && TMP="$CIFS/tmp" || TMP="/tmp/tmp"
[ -d "$CIFS" ] && GEN="$CIFS/gen" || GEN="/tmp/gen"
[ -d "$CIFS" ] && GENHOST="$CIFS/genHost" || GEN="/tmp/genHost"

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
	rm "$TMP" "$GEN" "$GENHOST" $pidfile &>/dev/null
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
# Work only once dnsmasq formated.
# Remove only listed domain.  eg; whitelist "facebook" will remove nothing.
# eg; whitelist "facebook.com"  will remove ad.facebook.com and facebook.com but will continue to block, facebook.ca, fakefacebook.com, etc..
for w in $WHITELIST; do
sed -i -e "/\.$w/d" -e "/\/$w/d" "$TMP"
done
}
WhitelistAll(){ 
# used with KeepAsHost
# remove every line containing whitelist.  eg; whitelist "facebook" will remove  ad.facebook.com, facebook.com, facebook.ca, fakefacebook.com, etc..
for w in $WHITELIST; do
sed -i -e "/$w/d" "$TMP"
done
}

FormatDnsmasq() {
sed -i -e '/^www[0-9]\./ s/^www[0-9]\.//
/^www\./ s/^www\.//
s|$|/'$REDIRECTIP'|
s|^|address=/|' "$TMP"
}
FormatHost() {
sed -i -e "s|^|$REDIRECTIP\\t|" "$TMP"
}

# Format the file
Generate() {
sed -i -e '/%/d
s/[[:cntrl:][:blank:]]//g
s/^[ \t]*//;s/[ \t]*$//
s/[[:space:]]*\[.*$//
s/[[:space:]]*\].*$//
/[[:space:]]*#.*$/ s/[[:space:]]*#.*$//
/127\.0\.0\.1/ s/^127\.0\.0\.1[ \t]*//
/^$/d
/[a-zA-Z0-9]\{5\}$/d' "$TMP"
[ -n "$KeepAsHost" ] && [ "$KeepAsHost" != "${KeepAsHost/$1/}"  ] && {
	FormatHost
	Result="$GENHOST"
	WhitelistAll
		} || {
			FormatDnsmasq
			Result="$GEN"
			Whitelist
			}
#cat $TMP >> $Result
#cat $Result | sort -u > $TMP || elog "ERROR ; sort failed"
#mv -f $TMP $Result
[ ! -f "$Result" ] && echo "" > "$Result"
if [ -d "$CIFS" ]; then sort -o "$TMP" -T "$CIFS" "$TMP" && sort -m -u -o "$Result" -T "$CIFS" "$TMP" "$Result" || elog "ERROR ; sort failed"
else sort -o "$TMP" "$TMP" && sort -m -u -o "$Result" "$TMP" "$Result" || elog "ERROR ; sort failed"; fi
rm "$TMP" &>/dev/null
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
		if wget $url -O - > $TMP || wget $url -U "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)" -O - > $TMP ; then
		elog "S$i downloaded $url"
		[ -d "$CIFS" ] && cp -f "$TMP" "$LocalFile"
		Generate $i
		else
		[ -f "$LocalFile" ] && {
		elog "S$i update failed: load $LocalFile"
		cp -f "$LocalFile" "$TMP"
		Generate $i
		} || elog "S$i failed $url"
		fi
	done
}
# Generate from local (if up to date or only local)
[ -n "$GenOnly" ] && {
	for i in $GenOnly; do
		eval LocalFile="$LocalHost"
		[ -f "$LocalFile" ] && {
			elog "Loading $LocalFile"
			cp -f "$LocalFile" "$TMP"
			Generate $i
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
[ -f "/tmp/$LAST" ] && LASTF="/tmp/$LAST"
[ -f "$CIFS/$LAST" ] && LASTF="$CIFS/$LAST"
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
	[ -d "$CIFS" ] && echo "$time" >"$CIFS/$LAST"
	echo "$time" >"/tmp/$LAST"
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
rm "$GEN" &>/dev/null
cru d ADBTmpCheck &>/dev/null
[ "$CIFSRequire" == "N" -o -d "$CIFS" ] && {
	CheckUpdate
	DL
	[ -f "$GEN" -o -f "$GENHOST" ] && {
		service dnsmasq stop &>/dev/null
		killall -9 dnsmasq &>/dev/null
		wait
		# Add the original config file
		cat /etc/dnsmasq.conf >> "$GEN"
		# add the additionnal host
		[ -f "$GENHOST" ] && {
			echo "addn-hosts=$GENHOST" >>"$GEN"
			# This adding stuff to the host for it to be valid on a pc if somebody desire to copy it an use it
			sed -i '1s/^/#<localhost>\n127.0.0.1\tlocalhost\n127.0.0.1\tlocalhost.localdomain\n255.255.255.255\tbroadcasthost\n::1\tlocalhost\n127.0.0.1\tlocal\nfe80::1%lo0\tlocalhost\n#<\/localhost>\n/' "$GENHOST"
			}
		SIZE=$(du -sh $GEN | awk '{ print $1 }')
		# Start blocking
		dnsmasq --conf-file="$GEN" && {
			eval BlockCount=$(grep -c 'address=/' "$GEN")
			[ -f "$GENHOST" ] && BlockCount=$(( $BlockCount+$(awk 'END { print NR }' "$GENHOST")))
			eval END=$(date +%s)
			eval DIFF=$(($END-$START))
			# EXTRA 
			[ -d "$CIFS" ] && echo ADBLOCK blocked $BlockCount unique host in $DIFF seconds > "$CIFS/counts.txt"
			elog "Blocked $BlockCount unique host in $DIFF seconds"
			} || {
			elog "ERROR ; dnsmasq config ($SIZE) failed"
			dnsmasq &>/dev/null && elog "failsafe ; load dnsmasq with default config (block nothing)" || elog "TROUBLE"
			}
		[ -d "$CIFS" -a -f "$GEN" ] && cp -f "$GEN" "$CIFS/dnsmask.conf"
		[ -d "$CIFS" -a -f "$GENHOST" ] && cp -f "$GENHOST" "$CIFS/addHost.conf"
		wait
	} || elog "No Updates"
} || {
	elog "Update skip because CIFS is required but offline. Will check again every 4 hour"
	cru a ADBTmpCheck "0 0,4,8,12,16,20 * * * /tmp/script_wanup.sh"
	}

pexit 0
