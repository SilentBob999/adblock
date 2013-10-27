#!/bin/sh
## Tomato AD-Blocking script
## https://github.com/SilentBob999/adblock

alias elog='logger -t ADBLOCK -s'
Running="/tmp/adblock" #leave in /tmp

REDIRECTIP="0.0.0.0"
CIFS="/cifs1/dnsmasq" # adapt to your need
LocalHost="$CIFS/HOST-S\$i"
[ -d $CIFS ] && TMP="$CIFS/tmp" || TMP="/tmp/tmp"
[ -d $CIFS ] && GEN="$CIFS/gen" || GEN="/tmp/gen"

WHITELIST="facebook.com dropbox.com"

GETS="1 2 3 4"
S1="http://pgl.yoyo.org/as/serverlist.php?hostformat=nohtml"  #44K - 2,539 hosts
S2="http://mirror1.malwaredomains.com/files/justdomains" #474K - 23,972 hosts
S3="http://www.malwaredomainlist.com/hostslist/hosts.txt" #52K - 1,661 hosts
S4="http://winhelp2002.mvps.org/hosts.txt" #560K - approx 15,350 hosts
S5="http://hosts-file.net/download/hosts.txt" #7,873K - 246,284 hosts
S6="http://hosts-file.net/hphosts-partial.asp" #2,719K - 77,661 hosts
S8="http://adblock.mahakala.is/hosts" #10,528K  330,332 hosts

pidfile=/var/run/adblock.pid
kill -0 $(cat $pidfile 2>/dev/null) &>/dev/null && {
	elog "Another instance found ($pidfile), exiting!"
	exit 1
}
echo $$ > $pidfile

stop() {
	rm "$Running" &>/dev/null
	elog "STOP"
	service dnsmasq restart
}

pexit() {
	elog "Exiting"
	rm $pidfile
	exit $@
}

case "$1" in
	restart) stop;;
	stop) stop; pexit 0;;
	toggle)	[ -e "$Running" ] && { stop; pexit 0; };;
	force) rm "$Running" &>/dev/null;;
esac

Whitelist() {
for w in $WHITELIST; do
sed -i -e "/\.$w/d /\/$w/d" $TMP
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
cat $GEN | sort -u > $TMP
mv -f $TMP $GEN
}

DL() {
[ -n "$DLList" -o -n "$GenOnly" ] && stop 2>&1
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
	[ "$time" != "$(cat "$LASTF")" ] && {
		elog "S$i outdated"
		DLList="$DLList $i"
		} || {
			elog "S$i UpToDate"
			[ -f "$LocalFile" ] && UpToDateLocal="$UpToDateLocal $i" || UpToDate="$UpToDate $i"
		}
	echo "$time" >$CIFS/$LAST
	echo "$time" >/tmp/$LAST
	} || {
	[ "$(eval "echo \${S$i}")" == "" -a -f "$LocalFile" ] && UpToDateLocal="$UpToDateLocal $i" || {
		elog "S$i unknown 'Last Modified'"
		DLList="$DLList $i"
		}
	}
done
[ -n "$UpToDate" ] && ( [ -n "$DLList" -o ! -f "$Running" ] ) && DLList="$DLList $UpToDate"
[ -n "$UpToDateLocal" ] && ( [ -n "$DLList" -o ! -f "$Running" ] ) && GenOnly="$GenOnly $UpToDateLocal"
}

eval START=$(date +%s)
rm $GEN
CheckUpdate
DL

[ -f $GEN ] && {
	service dnsmasq stop
	killall -9 dnsmasq
	wait
	cat /etc/dnsmasq.conf >> $GEN
	dnsmasq --conf-file=$GEN
	dnsmasq >/dev/null 2>&1

	eval BlockCount=$(grep -c 'address=/' $GEN)
	eval END=$(date +%s)
	eval DIFF=$(($END-$START))
	elog "Blocked $BlockCount : $DIFF seconds"
} || elog "No Updates"

rm $TMP $GEN
echo Running > $Running
pexit 0
