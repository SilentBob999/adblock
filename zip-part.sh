#!/bin/sh
{
cat <<'ENDF'|gzip|openssl enc -base64

alias elog='logger -t ADBLOCK -s'
LocalHost="$CIFS/HOST-S\$i"

[ -d "$CIFS" ] && TMP="$CIFS/tmp" || TMP="/tmp/tmp"
[ -d "$CIFS" ] && GEN="$CIFS/gen" || GEN="/tmp/gen"
[ -d "$CIFS" ] && GENHOST="$CIFS/genHost" || GEN="/tmp/genHost"

pidfile=/var/run/adblock.pid
kill -0 $(cat $pidfile 2>/dev/null) &>/dev/null && {
	elog "Another instance found ($pidfile, $(cat $pidfile)), exiting!"
	exit 1
}
echo $$ > $pidfile

[ "$(ps | grep -v grep | grep 'dnsmasq --conf-file=')" ] && Running="yes" || unset Running

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

case "$1" in
	restart) stop;;
	stop) stop; pexit 0;;
	toggle)	[ -n "$Running" ] && { stop; pexit 0; };;
	force) stop; force="1";;
esac

Whitelist() {
for w in $WHITELIST; do
sed -i -e "/\.$w/d" -e "/\/$w/d" "$TMP"
done
}
WhitelistAll(){ 
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
[ ! -f "$Result" ] && echo "" > "$Result"
if [ -d "$CIFS" ]; then sort -o "$TMP" -T "$CIFS" "$TMP" && sort -m -u -o "$Result" -T "$CIFS" "$TMP" "$Result" || elog "ERROR ; sort failed"
else sort -o "$TMP" "$TMP" && sort -m -u -o "$Result" "$TMP" "$Result" || elog "ERROR ; sort failed"; fi
rm "$TMP" &>/dev/null
wait
}

DL() {
[ -n "$DLList" -o -n "$GenOnly" ] && stop
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
		elog "S$i outdated"
		DLList="$DLList $i"
		} || {
			elog "S$i UpToDate"
			[ -f "$LocalFile" ] && UpToDateLocal="$UpToDateLocal $i" || UpToDate="$UpToDate $i"
		}
	[ -d "$CIFS" ] && echo "$time" >"$CIFS/$LAST"
	echo "$time" >"/tmp/$LAST"
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
		cat /etc/dnsmasq.conf >> "$GEN"
		[ -f "$GENHOST" ] && {
			echo "addn-hosts=$GENHOST" >>"$GEN"
			sed -i '1s/^/#<localhost>\n127.0.0.1\tlocalhost\n127.0.0.1\tlocalhost.localdomain\n255.255.255.255\tbroadcasthost\n::1\tlocalhost\n127.0.0.1\tlocal\nfe80::1%lo0\tlocalhost\n#<\/localhost>\n/' "$GENHOST"
			}
		SIZE=$(du -sh $GEN | awk '{ print $1 }')
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
		# EXTRA
		[ -d "$CIFS" -a -f "$GEN" ] && cp -f "$GEN" "$CIFS/dnsmask.conf"
		[ -d "$CIFS" -a -f "$GENHOST" ] && cp -f "$GENHOST" "$CIFS/addHost.conf"
		wait
	} || elog "No Updates"
} || {
	elog "Update skip because CIFS is required but offline. Will check again every 4 hour"
	cru a ADBTmpCheck "0 0,4,8,12,16,20 * * * /tmp/script_wanup.sh"
	}

pexit 0

ENDF
}
