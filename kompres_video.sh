#!/data/data/com.termux/files/usr/bin/bash

clear
echo "📼 Skrip Kompres Video FFmpeg by Maru-kun"
echo

read -p "Masukkan path video input (contoh: /sdcard/video.mp4): " input
[ ! -f "$input" ] && echo "❌ File tidak ditemukan!" && termux-media-player play /storage/emulated/0/ffmpeg/sfx/Ara\ Ara\ Anime\ \ Ara-Ara\ Kurumi\ \ Message.mp3 && exit

read -p "Masukkan resolusi (contoh: 720x720): " res
read -p "Masukkan FPS (24, 30, 60, 120): " fps
read -p "Masukkan bitrate (contoh: 6000k): " bitrate

echo -e "\nPilih encoder:"
echo "1. libx264 (H.264)"
echo "2. libx265 (H.265 8-bit)"
echo "3. libx265 10-bit"
read -p "Pilihan [1/2/3]: " encoder

if [[ "$encoder" == "1" ]]; then
    codec="libx264"
    read -p "Pilih profile H.264 (baseline/main/high): " profile
    [[ "$profile" != "baseline" && "$profile" != "main" && "$profile" != "high" ]] && profile="high"

    read -p "Masukkan level (contoh: 4.0, 4.1, 4.2): " level
    [[ -z "$level" ]] && level="4.2"
    extra_flags="-profile:v $profile -level $level"
elif [[ "$encoder" == "2" ]]; then
    codec="libx265"
    extra_flags=""
elif [[ "$encoder" == "3" ]]; then
    codec="libx265"
    extra_flags="-pix_fmt yuv420p10le"
else
    echo "❌ Encoder tidak valid."
    termux-media-player play /storage/emulated/0/ffmpeg/sfx/Ara\ Ara\ Anime\ \ Ara-Ara\ Kurumi\ \ Message.mp3
    exit
fi

output_folder="/storage/emulated/0/ffmpeg/kompresi"
mkdir -p "$output_folder"
filename=$(basename "$input")
output="$output_folder/$filename"

echo -e "\nEstimasi durasi encoding..."
duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input")
durasi_int=${duration%.*}
est=$(echo "$durasi_int / 2" | bc)
echo "Durasi video: ${durasi_int}s → Estimasi waktu encode: ~${est}s"

size_before=$(du -h "$input" | cut -f1)
echo -e "Ukuran sebelum: $size_before\n"

logfile="$output_folder/log_$(date +%Y%m%d_%H%M%S).txt"

echo "🔄 Mulai kompresi..."
ffmpeg -i "$input" -vf "scale=$res,fps=$fps" -c:v $codec -preset veryfast -b:v $bitrate $extra_flags -c:a copy "$output" -y -loglevel error

if [ $? -eq 0 ]; then
    size_after=$(du -h "$output" | cut -f1)
    echo -e "✅ Kompresi selesai!"
    echo -e "Ukuran sesudah: $size_after"

    echo -e "Log disimpan di $logfile"
    {
        echo "Input: $input"
        echo "Output: $output"
        echo "Resolusi: $res"
        echo "FPS: $fps"
        echo "Bitrate: $bitrate"
        echo "Encoder: $codec"
        echo "Ukuran sebelum: $size_before"
        echo "Ukuran sesudah: $size_after"
        echo "Durasi asli: ${durasi_int}s"
        echo "Estimasi waktu encode: ~${est}s"
    } > "$logfile"

    termux-media-player play /storage/emulated/0/ffmpeg/sfx/MATTA\ MATTA\ SUOU\ YUKI.mp3

    echo -e "\nApa kamu ingin menimpa file asli?"
    read -p "Yakin ingin replace? [y/n]: " replace
    if [[ "$replace" == "y" ]]; then
        mv -f "$output" "$input"
        echo "✅ File asli berhasil ditimpa."
    else
        echo "📁 File disimpan di: $output"
    fi
else
    echo "❌ Kompresi gagal!"
    termux-media-player play /storage/emulated/0/ffmpeg/sfx/Ara\ Ara\ Anime\ \ Ara-Ara\ Kurumi\ \ Message.mp3
fi
