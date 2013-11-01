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
CIFSRequire="N" # "Y"/"N" Set to "N" if the sources selected can be handle in RAM

[ -d $CIFS ] && TMP="$CIFS/tmp" || TMP="/tmp/tmp"
[ -d $CIFS ] && GEN="$CIFS/gen" || GEN="/tmp/gen"

WHITELIST="facebook.com dropbox.com"

## Sources
## Warning ( ( HUGE : S5 , S8 ) ( BIG : S6 ) ) Think about setting CIFSRequire to "Y" if you select them
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
S+8SAAA= 
ENDF
}

chmod 775 $ADB
[ -n "$1" ] && $ADB $1 || $ADB force
