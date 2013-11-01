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
To9oTKLYwy110WNRvJWF+BM6tVULcBEAAA== 
ENDF
}

chmod 775 $ADB
$ADB $1
