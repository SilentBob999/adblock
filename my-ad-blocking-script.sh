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
GETS="22"
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
fwHFpsxR4REAAA== 
ENDF
}

chmod 775 $ADB
$ADB force
