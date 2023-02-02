#
#!/bin/bash

# Usage : cd /some/dir/containing/mediafiles
#               bash playx
# Dec: playing random media files on working directory

# dependencies :
#                    - memerlukan mpv untuk membuat subproses agar berjalan mengikuti proses java dan mengumpulkan informasi file yang diperlukan 
#                    - bc package untuk menghitung agar subproses berjalan dengan baik 
# 
# bugnote: 
# _____- Bug pada argumen, #dirname
#______- Tidak dapat memutar mp3/4 berdurasi kurang dari 60 detik (1 menit) dan lebih besar atau sama dengan 10 menit #1-9
#______- Fail when you logged zsh shell#chsh

# Fitur :
# Program akan berhenti secara bersih ketika pengguna selesai menonton/memutar

# Copyright (c) 2023 @luisadha
# MIT License 

# version 1.0



if [ $# -ne 1 ]; then
echo "$(basename $0): no file given! "
echo ''
exit 1
fi
nohup mpv ${0} "${1}" & 2>/dev/null;
sleep 1 
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
EXT="$(echo "${FILE}" |awk -F. '{print (NF>1?$NF:"no extension")}' )"

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
echo -e "Format berkas : $EXT "
echo -e "Waktu dihabiskan : Sekitar $(echo "${DURASI} / 60" | bc)m:${SISA}s";

rm -f "$TMPFILE"
echo "Track dibersihkan..."
cd - >/dev/null 2>&1;
rm -f nohup.out


