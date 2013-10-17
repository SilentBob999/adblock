#!/bin/sh
## Tomato AD-Blocking script
## by SilentBob999 https://github.com/SilentBob999/adblock
##
alias elog='logger -t ADBLOCK -s'
Running="/tmp/adblock" #leave this in /tmp

##
## variables
REDIRECTIP="0.0.0.0"
CIFS="/cifs1/dnsmasq" # adapt to your need - no space - DONT USE JFFS
LocalHost="$CIFS/HOST-S\$i"
[ -d $CIFS ] && TMP="$CIFS/tmp" || TMP="/tmp/tmp"
[ -d $CIFS ] && GEN="$CIFS/gen" || GEN="/tmp/gen"


## remove/whitelist websites
WHITELIST="facebook.com dropbox.com"

## Sources
## Warning ( ( HUGE : S5 , S8 ) ( BIG : S6 , S7 ) )
GETS="1 2 3 4 6 7"
S1="http://pgl.yoyo.org/as/serverlist.php?hostformat=nohtml"  ##44K - 2,539 hosts
S2="http://mirror1.malwaredomains.com/files/justdomains" ##474K - 23,972 hosts
S3="http://www.malwaredomainlist.com/hostslist/hosts.txt" ##52K - 1,661 hosts
S4="http://winhelp2002.mvps.org/hosts.txt" ##560K - approx 15,350 hosts
S5="http://hosts-file.net/download/hosts.txt" #7,873K - 246,284 hosts - by Malwarebytes Corp
S6="http://hosts-file.net/hphosts-partial.asp" #2,719K - 77,661 hosts - by Malwarebytes Corp
S7="http://hostsfile.mine.nu/Hosts" ##2,910K - 94,926 hosts
S8="http://adblock.mahakala.is/hosts" ##10,528K  330,332 hosts

Whitelist() {
for w in $WHITELIST; do
sed -i -e "/\.$w/d /\/$w/d" $TMP
done
}

Generate() {
GOTSOURCE="1"
service dnsmasq stop >/dev/null 2>&1
killall -9 dnsmasq >/dev/null 2>&1
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
[ -n "$DLList" ] && {
	for i in $DLList; do
		eval url="\$S$i"
		eval LocalFile="$LocalHost"
		if wget $url -U "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)" -O - > $TMP ; then
		elog "S$i downloaded $url"
		[ -d $CIFS ] && cp $TMP $LocalFile
		Generate
		else
		[ -f $LocalFile ] {
		elog "S$i update failed - back to $LocalFile"
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
unset LASTF time
[ -f "/tmp/$LAST" ] && LASTF=/tmp/$LAST
[ -f "$CIFS/$LAST" ] && LASTF=$CIFS/$LAST  # priority to CIFS to keep local copy up to date
P1=$(echo $url| sed 's|^http[s]*://[^/]*\(/.*\)$|\1|')
H1=$(echo $url| sed 's|^http[s]*://\([^/]*\)/.*$|\1|')
time=$(echo -e "HEAD $P1 HTTP/1.1\r\nHost: $H1\r\nConnection: close\r\n"|
nc -w 5 $H1 80|grep -i Last-Modified:|tr -d "\r")
[ -n "$time" ] && {
	[ "$time" != "$(cat "$LASTF" 2>/dev/null)" ] && {
		# Need update
		DLList="$DLList $i"
		} || {
			[ -f "$LocalFile" ] && {
			# UpToDate
			GenOnly="$GenOnly $i" 
			} || {
				[ -f "$Running"] && {
					# Will download this source only if another source need to be 
					# downloaded otherwise dnsmasq do not need to be restarted/configure				
					UpToDate="$UpToDate $i"
					} || {
					# First Run and UpToDate with no local file!?!
					DLList="$DLList $i"
					}
			}
		}
	cat "$time" >$CIFS/$LAST
	cat "$time" >/tmp/$LAST
	} || {
	# Always download if cannot know if updated
	elog "Source do not provide time - adding S$i to download"
	DLList="$DLList $i"
	}
done
[ -n "$UpToDate" -a -n "$DLList" ] && DLList="$DLList $UpToDate"
}


eval START=$(date +%s)
CheckUpdate
DL

[ -f $GEN ] && {
	## load values from dnsmasq config
	cat /etc/dnsmasq.conf >> $GEN

	## apply blacklist
	dnsmasq --conf-file=$GEN
	## failsafe added
	dnsmasq >/dev/null 2>&1

	## dev info
	eval END=$(date +%s)
	eval DIFF=$(($END-$START))
	eval BlockCount=$(grep -c 'address=/' $GEN)
	elog "Blocked $BlockCount unique host in $DIFF seconds"
	# EXTRA BACKUP
	[ -d $CIFS ] && echo ADBLOCK blocked $BlockCount unique host in $DIFF seconds > $CIFS/counts.txt
	##  Backup
	[ -d $CIFS ] && cp -f $GEN $CIFS/dnsmask.conf
}
## remove the generated files
rm $TMP $GEN

## This will stay in tmp until router rebooted
echo Running > $Running
