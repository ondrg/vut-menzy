#!/bin/sh

#
# Vypise nabidku otevrenych menz VUT Brno
#



####### ZACATEK VYKONAVANI SKRIPTU #######


wget -O - -q http://www.kam.vutbr.cz/?p=jide | grep "^<a name=\(.*\)</a></p>" | sed 's/^[ \t]*//;s/[ \t]*$//;s/<a name="menza//;s/"><\/a><h2>/\t/;s/<span\(.*\)<small>/\t/;s/&#8211;/-/;s/<\/small><\/span><\/h2><p>\(.*\)$//;' | awk -F "\t" '{ printf("%5s | %-30s %-40s\n", $1, $2, $3) }'

read ID_menzy

wget -O - -q http://www.kam.vutbr.cz/?p=menu\&provoz=$ID_menzy | grep '<tr id=' | sed 's/^[ \t]*//;s/[ \t]*$//;s/<tr\(.*\)<br\/><\/span>//;s/<span class="gram"\(.*\) onClick="slo(.\?.\?)">/\t/;s/<\/td><td class="pravy slcen.\?">/\t/g;s/&nbsp;//g;s/<\/td><\/tr>\(.*\)//' | awk -F "\t" '{ printf("%15s | %-50s | %5s %5s %5s\n", $1, $2, $3, $4, $5) }'

exit 0

