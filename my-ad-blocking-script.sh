#!/bin/sh
## Tomato AD-Blocking script
## https://github.com/SilentBob999/adblock

ADB="/tmp/ADBLOCK.sh"
{
cat <<'ENDF' >$ADB
#!/bin/sh

REDIRECTIP="0.0.0.0"
CIFS="/cifs1/dnsmasq" # adapt to your need
LocalHost="$CIFS/HOST-S\$i"
CIFSRequire="N" # "Y"/"N"

[ -d $CIFS ] && TMP="$CIFS/tmp" || TMP="/tmp/tmp"
[ -d $CIFS ] && GEN="$CIFS/gen" || GEN="/tmp/gen"

WHITELIST="facebook.com dropbox.com"

## Sources
## Warning ( ( HUGE : S5 , S8 ) ( BIG : S6 ) CIFSRequire to "Y"
GETS="1 2 3 4"
S1="http://pgl.yoyo.org/as/serverlist.php?hostformat=nohtml"  ##44K - 2,539 hosts
S2="http://mirror1.malwaredomains.com/files/justdomains" ##474K - 23,972 hosts
S3="http://www.malwaredomainlist.com/hostslist/hosts.txt" ##52K - 1,661 hosts
S4="http://winhelp2002.mvps.org/hosts.txt" ##560K - approx 15,350 hosts
S5="http://hosts-file.net/download/hosts.txt" #7,873K - 246,284 hosts
S6="http://hosts-file.net/hphosts-partial.asp" #2,719K - 77,661 hosts
S7="http://someonewhocares.org/hosts/hosts" #321K - approx 10,100 hosts
S8="http://adblock.mahakala.is/hosts" ##10,528K  330,332 hosts

ENDF
}

b64="openssl enc -base64 -d"
{
cat <<'ENDF'| $b64 |gunzip >>$ADB
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 
ENDF
}

chmod 775 $ADB
[ -n "$1" ] && $ADB $1 || $ADB force
