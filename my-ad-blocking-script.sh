#!/bin/sh
## Tomato AD-Blocking script
## https://github.com/SilentBob999/adblock

ADB="/tmp/ADBLOCK.sh"
{
cat <<'ENDF' >$ADB
#!/bin/sh

REDIRECTIP="0.0.0.0"
CIFS="/cifs1/dnsmasq" # adapt to your need
CIFSRequire="N" # "Y"/"N"

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
dUcvLWrpIv89hxD/AZbTg7bKEwAA 
ENDF
}

chmod 775 $ADB
$ADB $1
