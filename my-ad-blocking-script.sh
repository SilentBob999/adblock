#!/bin/sh
## Tomato AD-Blocking script
## https://github.com/SilentBob999/adblock
# TESTING IN RAM ONLY
ADB="/tmp/ADBLOCK.sh"
{
cat <<'ENDF' >$ADB
#!/bin/sh

REDIRECTIP="0.0.0.0"
CIFS="/cifs1/dnsmasq" # adapt to your need
LocalHost="$CIFS/HOST-S\$i"
# Testing
TMP="/tmp/tmp"
GEN="/tmp/gen"

WHITELIST="facebook.com dropbox.com"

## Sources
## Warning ( ( HUGE : S5 , S8 ) ( BIG : S6 ) )
GETS="22 23"
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
8NJUEgAA 
ENDF
}

chmod 775 $ADB
$ADB force
