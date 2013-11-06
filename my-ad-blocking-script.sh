#!/bin/sh
## Tomato AD-Blocking script
## https://github.com/SilentBob999/adblock


REDIRECTIP="0.0.0.0"
CIFS="/cifs1/dnsmasq" # adapt to your need

WHITELIST="facebook.com dropbox.com"

## Sources
## Warning ( ( HUGE : S5 , S8 ) ( BIG : S6 )
GETS="1 2 3 4 7"
S1="http://pgl.yoyo.org/as/serverlist.php?hostformat=nohtml"  ##44K - 2,539 hosts
S2="http://mirror1.malwaredomains.com/files/justdomains" ##474K - 23,972 hosts
S3="http://www.malwaredomainlist.com/hostslist/hosts.txt" ##52K - 1,661 hosts
S4="http://winhelp2002.mvps.org/hosts.txt" ##560K - approx 15,350 hosts
S7="http://someonewhocares.org/hosts/hosts" #321K - approx 10,100 hosts

alias elog='logger -t ADBLOCK -s'
LocalHost="$CIFS/HOST-S\$i"

[ -d $CIFS ] && TMP="$CIFS/tmp" || TMP="/tmp/tmp"
[ -d $CIFS ] && GEN="$CIFS/gen" || GEN="/tmp/gen"

pidfile=/var/run/adblock.pid
kill -0 $(cat $pidfile 2>/dev/null) &>/dev/null && {
	elog "Another instance found ($pidfile, $(cat $pidfile)), exiting!"
	exit 1
}
echo $$ > $pidfile

[ "$(ps | grep -v grep | grep 'dnsmasq --conf-file=')" ] && Running="yes" || unset Running

stop() {
	elog "STOP"
	service dnsmasq restart &>/dev/null
}

pexit() {
	elog "Exiting"
	rm $TMP $GEN $pidfile &>/dev/null
	exit $@
}

case "$1" in
	restart) stop;;
	stop) stop; pexit 0;;
	toggle)	[ -n "$Running" ] && { stop; pexit 0; };;
	force) stop; force="1";;
esac

Whitelist() {
for w in $WHITELIST; do
sed -i -e "/\.$w/d" -e "/\/$w/d" $TMP
done
}

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
cat $GEN | sort -u > $TMP || elog "ERROR ; sort failed"
mv -f $TMP $GEN
wait
}

DL() {
[ -n "$DLList" -o -n "$GenOnly" ] && stop
[ -n "$DLList" ] && {
	for i in $DLList; do
		eval url="\$S$i"
		eval LocalFile="$LocalHost"
		if wget $url -O - > $TMP ; then
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
		elog "S$i outdated"
		DLList="$DLList $i"
		} || {
			elog "S$i UpToDate"
			[ -f "$LocalFile" ] && UpToDateLocal="$UpToDateLocal $i" || UpToDate="$UpToDate $i"
		}
	[ -d $CIFS ] && echo "$time" >$CIFS/$LAST
	echo "$time" >/tmp/$LAST
	} || {
	[ "$(eval "echo \${S$i}")" == "" -a -f "$LocalFile" ] && UpToDateLocal="$UpToDateLocal $i" || {
		elog "S$i unknown 'Last Modified'"
		DLList="$DLList $i"
		}
	}
done
[ -n "$UpToDate" ] && ( [ -n "$DLList" -o ! -n "$Running" ] ) && DLList="$DLList $UpToDate"
[ -n "$UpToDateLocal" ] && ( [ -n "$DLList" -o ! -n "$Running" ] ) && GenOnly="$GenOnly $UpToDateLocal"
wait
}

rm $GEN &>/dev/null
CheckUpdate
DL
[ -f $GEN ] && {
	service dnsmasq stop &>/dev/null
	killall -9 dnsmasq &>/dev/null
	wait
	cat /etc/dnsmasq.conf >> $GEN
	dnsmasq --conf-file=$GEN && {
		eval BlockCount=$(grep -c 'address=/' $GEN)
		elog "Blocked $BlockCount unique host"
		} || {
		elog "ERROR ; not enouph RAM"
		dnsmasq &>/dev/null && elog "failsafe ; (block nothing)"
		}
	wait
} || elog "No Updates"
pexit 0
