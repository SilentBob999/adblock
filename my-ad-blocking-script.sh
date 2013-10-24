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
RDFrCyH+C7IAJxvfEQAA 
ENDF
}

chmod 775 $ADB
$ADB
