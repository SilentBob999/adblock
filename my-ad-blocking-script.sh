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
[ -d $CIFS ] && TMP="$CIFS/tmp" || TMP="/tmp/tmp"
[ -d $CIFS ] && GEN="$CIFS/gen" || GEN="/tmp/gen"

WHITELIST="facebook.com dropbox.com"

## Sources
## Warning ( ( HUGE : S5 , S8 ) ( BIG : S6 ) )
GETS="1 2 3 4"
S1="http://pgl.yoyo.org/as/serverlist.php?hostformat=nohtml"  ##44K - 2,539 hosts
S2="http://mirror1.malwaredomains.com/files/justdomains" ##474K - 23,972 hosts
S3="http://www.malwaredomainlist.com/hostslist/hosts.txt" ##52K - 1,661 hosts
S4="http://winhelp2002.mvps.org/hosts.txt" ##560K - approx 15,350 hosts
S5="http://hosts-file.net/download/hosts.txt" #7,873K - 246,284 hosts - by Malwarebytes Corp
S6="http://hosts-file.net/hphosts-partial.asp" #2,719K - 77,661 hosts - by Malwarebytes Corp
S7="http://someonewhocares.org/hosts/hosts" #321K - approx 10,100 hosts
S8="http://adblock.mahakala.is/hosts" ##10,528K  330,332 hosts

ENDF
}

b64="openssl enc -base64 -d"
{
cat <<'ENDF'| $b64 |gunzip >>$ADB
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 
xSMlCrpPFHO4EOK/bP527vsRAAA= 
ENDF
}

chmod 775 $ADB
$ADB force
