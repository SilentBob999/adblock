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
RdwRAAA= 
ENDF
}

chmod 775 $ADB
$ADB
