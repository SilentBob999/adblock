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
GETS="1 2 3 4 7"
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
Ixc2gbZlfp1hWf8Bv6kPROATAAA= 
ENDF
}

chmod 775 $ADB
$ADB $1
