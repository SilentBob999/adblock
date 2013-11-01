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
CW6Bix6L4qUsxJ8AO3PMbhEAAA== 
ENDF
}

chmod 775 $ADB
$ADB $1
