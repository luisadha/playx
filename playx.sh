#
#!/bin/bash

# Usage : bash playx FILE 
#               bash -xv playx FILE 
# dependencies :
#                    - mpv
#                    - bc package 
#    

# Fitur :
# Program akan berhenti secara bersih ketika pengguna selesai menonton/mendengarkan musik
# program tidak membutuhkan root murni hanya termux 
#
# bug: saya menyadari bahwa waktu menit dengan detik tidaklah singkron
# kami akan berupaya untuk memperbaiki masalah ini 
# Copyright (c) 2023 @luisadha
# MIT License 

# version 1.0

nohup mpv $0 "$1" & 2>/dev/null;
 kill -TERM $!
clear
# set -xv

# Belum ada kondisi jika 3 angka berarti yang munjukan menit sedangkan 2 angka menunjukkan detik

# ini mengakibatkan program hanya bisa berjalan di lagu berdusi menit hingga 9 menit, belum support video detik

DURASI=$(cat nohup.out | grep '(' | awk '{print $4}' | tail -n 2 | sed 's/[:]//g' | sed 's/d/*24*3600 +/g; s/h/*3600 +/g; s/m/*60 +/g; s/s/\+/g; s/+[ ]*$//g' )

DURASI="$(echo "${DURASI}" | bc | sed 's/\(\b[0-9]\)/\(\1\)/g' )"

DURASI="${DURASI#*\(}";

DURASI="${DURASI%% *}"

SISA="${DURASI##*5}"

SISA="${SISA#*\)}"

DURASI="${DURASI%\)*}"

# 60s setara dengan 1m

DURASI="$(echo "$DURASI * 60" | bc )"

#echo $DURASI
#echo $SISA


TIDUR=$(echo "$DURASI" + "$SISA" | bc )


FILE="$1"
EXT="$(echo "$FILE" |awk -F. '{print (NF>1?$NF:"no extension")}' )"

VAR=""
if [ "$EXT" == "mp3" ]; then
 VAR="audio/${EXT}";
elif [ "$EXT" == "mp4" ]; then
VAR="video/${EXT}";
else
   echo "Unsupport format!"
    exit 1
fi


TMPFILE="/sdcard/download/$1.tmp" 

cp -f "$FILE" "$TMPFILE"

cd /sdcard/download/

  am start -a android.intent.action.VIEW -d file://"$TMPFILE" -t "$VAR" > /dev/null 2>&1 
echo "Sedang memutar : $(basename "${TMPFILE%%.*}")"
sleep $TIDUR &
process_id=$!
wait -f $process_id

echo -e "Waktu dihabiskan : Sekitar $(echo "${DURASI} / 60" | bc):$SISA";

rm -f "$TMPFILE"
echo "Track dibersihkan..."
cd - >/dev/null 2>&1;
