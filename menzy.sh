#!/bin/sh

#
# Vypise nabidku otevrenych menz VUT Brno
#
# Autor:    Ondra Gersl, ondra.gersl@gmail.com
# Licence:  GNU GPL v3 - http://www.gnu.org/licenses/gpl-3.0.txt
# Web:      http://github.com/ondrg/vut-menzy
#


#
# Globalni promenne
#
STH_URL="http://www.kam.vutbr.cz"  # URL webu s udaji
FORMAT=1



#
# Vypise napovedu k pouziti skriptu
#
print_help()
{
  echo "Skript vypise otevrene menzy nebo jejich jidelnicky v ramci VUT Brno.
pouziti: $0 [parametr1 [...]]
parametry:
  -h, --help  Vypise tuto napovedu
  -j ID       Vypise jidelnicek menzy s identifikatorem ID
              Nelze kombinovat s prepinacem '-m'
  -m          Vypise pouze seznam otevrenych menz
              Nelze kombinovat s prepinacem '-j'
  -nf         Vypise data bez formatovani (sloupce odelene tabulatorem)
Bez parametru vypise seznam otevrenych menz (pokud nejake otevrene jsou),
zepta se na ID menzy (stdin) a po zadani vypise jidelnicek dane menzy."
}


#
# Vypise chybovou hlasku na stderr
# @param $1 text, ktery se ma vypsat
#
print_error()
{
  echo "$1" >&2
  echo "Pro napovedu pouzijte parametr -h nebo --help." >&2
}


#
# Vypise seznam otevrenych menz
#
print_students_halls()
{
  result=`wget -q -O - "$STH_URL/?p=jide" \
  | grep "^<a name=\"menza\(.*\)</a></p>" \
  | sed 's/^[ 	]*//;s/[ 	]*$//;s/<a name="menza//;s/"><\/a><h2>/	/;
         s/<span\(.*\)<small> (/	(/;s/&#8211;/-/;s/) /)	/;
         s/<\/small><\/span><\/h2><p>\(.*\)$//;'`

  # pokud je pocet vracenych znaku prilis maly
  if [ `echo "$result" | wc -c` -lt 10 ]; then
    echo "Zadna menza neni momentalne otevrena."
    return 1
  fi

  # naformatovani vystupu, pokud je zapnuto (defaultne ano)
  if [ "$FORMAT" -eq 1 ]; then
    result=`echo "$result" \
    | awk -F "\t" '{ printf("%3s | %-37s %15s  %s\n", $1, $2, $3, $4) }'`
  fi

  # vypsani vysledku na vystup
  echo "$result";
}


#
# Vypise obsah jidelniho listku dane menzy
# @param $1 ID menzy
#
print_menu()
{
  result=`wget -q -O - "$STH_URL/?p=menu&provoz=$1" \
  | grep '^<tr id="r[0-9]' \
  | sed 's/^[ 	]*//;s/[ 	]*$//;s/<tr\(.*\)<br\/><\/span>//;
         s/<span class="gram"\(.*\) onClick="slo([0-9]\{1,3\})">/	/;
         s/<\/td><td class="pravy slcen[123]">/	/g;s/,-&nbsp;//g;
         s/<\/td><\/tr>\(.*\)//'`

  # pokud je pocet vracenych znaku prilis maly
  if [ `echo "$result" | wc -c` -lt 10 ]; then
    echo "Stravovaci provoz nezverejnil aktualni nabidku."
    return 1
  fi

  # naformatovani vystupu, pokud je zapnuto (defaultne ano)
  if [ "$FORMAT" -eq 1 ]; then
    result=`echo "$result" \
    | awk -F "\t" '{
      printf("%10s | %-60s | %4s %4s %4s\n", $1, $2, $3, $4, $5)
    }'`
  fi

  # vypsani vysledku na vystup
  echo "$result";
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
      # overeni numericke hodnoty (musi byt vetsi nez 0)
      if [ "$1" -eq "$1" 2> /dev/null ] && [ "$1" -gt 0 ]; then
        menza_id="$1"
      else
        echo "Chybna hodnota parametru -j. Je treba zadat kladne cislo." >&2
        exit 1
      fi
      ;;
    # zobrazeni vypisu otevrenych menz
    '-m')
      print_only_sth=1
      ;;
    # vystup nebude formatovan do hezkeho formatu
    '-nf')
      FORMAT=0
      ;;
    # spatny prikaz
    *)
      print_error "Chyba v parametru '$1'"
      exit 1
      ;;
   esac

   shift  # presun na dalsi parametr
done


# pokud byly zadany dva kolidujici parametry
if [ "$menza_id" ] && [ "$print_only_sth" ]; then
  print_error "Parametry '-m' a '-j' nelze kominovat."
  exit 1
fi



## Vetveni programu dle parametru

if [ "$menza_id" ]; then  # bylo zadano ID menzy
  print_menu "$menza_id"
elif [ "$print_only_sth" ]; then  # bylo nastaveno vypsani otevrenych menz
  print_students_halls
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

