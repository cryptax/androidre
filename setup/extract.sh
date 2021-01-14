#!/bin/sh
# taken from: https://gist.githubusercontent.com/PaulSec/39245428eb74577c5234/raw/4ff2c87fbe35c0cfdb55af063a6fee072622f292/extract.sh
# replaced 7z by unzip

jdgui="/opt/jd-gui"
dex2jar="/opt/dex-tools-2.1-SNAPSHOT/d2j-dex2jar.sh"

if [ $# -eq 0 ]
  then
    echo "Usage: extract.sh <test.apk>"
    exit 1
fi

# extracting the apk 
echo "apk file: $1"
DIRECTORY=$(dirname ${1})
FILE=$(basename ${1})

echo "Creating directory $FILE.files"
# echo "mkdir $1.files"
mkdir $1.files

echo "Extracting apk to $1.files/"
# echo "7z x $1 -o$1.files/"
unzip $1 -d $1.files/

echo "Finding .dex file in $1.files/"
# echo "$dexfile={find ${1}.files/ -name '*.dex'}"
dexfile=`find ${1}.files/ -name '*.dex'`

echo "Generating $FILE.jar in $1.files/"
# echo "$dex2jar $dexfile -o $1.files/$FILE.jar"
$dex2jar $dexfile -o $1.files/$FILE.jar

echo "Opening jd-gui with .jar file"
# echo "$jdgui $1.files/$FILE.jar"
$jdgui $1.files/$FILE.jar 2> /dev/null
