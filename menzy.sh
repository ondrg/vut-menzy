#!/bin/sh

#
# Vypise nabidku otevrenych menz VUT Brno
#
# Autor:    Ondra Gersl, ondra.gersl@gmail.com
# Licence:  GNU GPL v3 - http://www.gnu.org/licenses/gpl-3.0.txt
#


#
# Globalni promenne
#
STH_URL="http://www.kam.vutbr.cz"  # URL webu s udaji



#
# Vypise napovedu k pouziti skriptu
#
print_help()
{
  echo "Skript vypise otevrene menzy nebo jejich jidelnicky v ramci VUT Brno
pouziti: $0 [parametr1 [...]]
parametry:
  -h, --help  Vypise tuto napovedu
  -j ID       Vypise jidelnicek menzy s identifikatorem ID"
}


#
# Vypise seznam otevrenych menz
#
print_students_halls()
{
  result=`wget -O - -q "$STH_URL/?p=jide" \
  | grep "^<a name=\"menza\(.*\)</a></p>" \
  | sed 's/^[ \t]*//;s/[ \t]*$//;s/<a name="menza//;s/"><\/a><h2>/\t/;
         s/<span\(.*\)<small> (/\t(/;s/&#8211;/-/;s/) /)\t/;
         s/<\/small><\/span><\/h2><p>\(.*\)$//;'`
  #| awk -F "\t" '{ printf("%3s | %-30s %16s %-40s\n", $1, $2, $3, $4) }'

  # pokud je pocet vracenych znaku prilis maly
  if [ `echo "$result" | wc -c` -gt 10 ]; then
    echo "$result"
  else
    echo "Seznam otevrenych menz je prazdny."
    return 1
  fi
}


#
# Vypise obsah jidelniho listku dane menzy
# @param $1 ID menzy
#
print_menu()
{
  wget -O - -q "$STH_URL/?p=menu&provoz=$1" \
  | grep '^<tr id="r[0-9]' \
  | sed 's/^[ \t]*//;s/[ \t]*$//;s/<tr\(.*\)<br\/><\/span>//;s/<span class="gram"\(.*\) onClick="slo([0-9]\+)">/\t/;s/<\/td><td class="pravy slcen[0-9]\?">/\t/g;s/,-&nbsp;//g;s/<\/td><\/tr>\(.*\)//' \
  #| awk -F "\t" '{ printf("%15s | %-50s | %5s %5s %5s\n", $1, $2, $3, $4, $5) }'
}



####### ZACATEK VYKONAVANI SKRIPTU #######


## Zpracovani argumentu

while [ "$#" -gt "0" ]; do
  case $1 in
    # vypsani napovedy
    '-h' | '--help')
      print_help
      exit 0
      ;;
    # zobrazeni jidelniho listku
    '-j')
      shift
      if [ "$1" -eq "$1" 2> /dev/null ]; then  # overeni numericke hodnoty
        menza_id="$1"
      else
        echo "Chybna hodnota parametru -j. Je treba zadat kladne cislo." >&2
        exit 1
      fi
      break;
      ;;
    # spatny prikaz
    *)
      echo "Chybne zadani prikazu." \
           "Pro napovedu pouzijte parametr -h nebo --help." >&2
      exit 1
      ;;
   esac
done



## Vetveni programu dle parametru

if [ "$menza_id" ]; then  # bylo zadano ID menzy
  print_menu "$menza_id"
else  # nebylo zadano ID menzy
  print_students_halls

  if [ "$?" -ne "1" ]; then  # byl vypsan seznam menz
    echo -n "Zadejte ID menzy: "
    read menza_id

    print_menu "$menza_id"
  fi
fi



## konec

exit 0

