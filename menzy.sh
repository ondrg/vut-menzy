#!/bin/sh

#
# Vypise nabidku otevrenych menz VUT Brno
#
# Autor: Ondra Gersl, ondra.gersl@gmail.com
# Licence: GNU GPL v3 - http://www.gnu.org/licenses/gpl-3.0.txt
#


####### ZACATEK VYKONAVANI SKRIPTU #######

#cat jide.html \
wget -O - -q http://www.kam.vutbr.cz/?p=jide \
| grep "^<a name=\"menza\(.*\)</a></p>" \
| sed 's/^[ \t]*//;s/[ \t]*$//;s/<a name="menza//;s/"><\/a><h2>/\t/;s/<span\(.*\)<small> (/\t(/;s/&#8211;/-/;s/) /)\t/;s/<\/small><\/span><\/h2><p>\(.*\)$//;' \
#| awk -F "\t" '{ printf("%3s | %-30s %16s %-40s\n", $1, $2, $3, $4) }'

read ID_menzy

wget -O - -q http://www.kam.vutbr.cz/?p=menu\&provoz=$ID_menzy \
| grep '^<tr id="r[0-9]' \
| sed 's/^[ \t]*//;s/[ \t]*$//;s/<tr\(.*\)<br\/><\/span>//;s/<span class="gram"\(.*\) onClick="slo([0-9]\+)">/\t/;s/<\/td><td class="pravy slcen[0-9]\?">/\t/g;s/,-&nbsp;//g;s/<\/td><\/tr>\(.*\)//' \
#| awk -F "\t" '{ printf("%15s | %-50s | %5s %5s %5s\n", $1, $2, $3, $4, $5) }'

exit 0
