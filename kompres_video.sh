#!/data/data/com.termux/files/usr/bin/bash

========================

1. PILIH VIDEO

========================

echo "\n=============================" echo "     KOMPRESI VIDEO HD     " echo "=============================\n"

Ganti file picker dengan input manual

read -p "Masukkan path video (contoh: /storage/emulated/0/Download/video.mp4): " VIDEO_PATH

if [ ! -f "$VIDEO_PATH" ]; then echo "\n❌ File tidak ditemukan. Pastikan path benar." termux-media-player play "/storage/emulated/0/ffmpeg/sfx/Ara Ara Anime  Ara-Ara Kurumi  Message.mp3" exit 1 fi

========================

2. PILIH RESOLUSI OUTPUT

========================

echo "\nPilih resolusi output:" echo "1: 1080p" echo "2: 720p" echo "3: 480p" read -p "Masukkan angka [1-3]: " res_choice

case $res_choice in

1. scale="1920:1080";;


2. scale="1280:720";;


3. scale="854:480";; *) echo "Pilihan tidak valid, default ke 1080p"; scale="1920:1080";; esac



========================

3. PILIH FPS (30 / 60)

========================

echo "\nPilih frame rate (FPS):" echo "1: 30 fps" echo "2: 60 fps" read -p "Masukkan angka [1-2]: " fps_choice

case $fps_choice in

1. fps="30";;


2. fps="60";; *) echo "Tidak valid. Default ke 30 fps."; fps="30";; esac



========================

4. PILIH BITRATE (dalam kbps)

========================

read -p "\nMasukkan target bitrate (contoh: 6000 untuk 6Mbps): " bitrate

========================

5. PILIH CODEC

========================

echo "\nPilih codec video:" echo "1: H.264 (libx264)" echo "2: H.265 (libx265)" read -p "Masukkan angka [1-2]: " codec_choice

if [ "$codec_choice" = "1" ]; then vcodec="libx264" echo "\nPilih profile H.264:" echo "1: baseline" echo "2: main" echo "3: high" read -p "Masukkan angka [1-3]: " profile_choice case $profile_choice in 1) profile="baseline";; 2) profile="main";; 3) profile="high";; *) echo "Tidak valid. Gunakan 'main'."; profile="main";; esac

echo "\nPilih level (misal: 3.1, 4.0, 4.1, 4.2):" read -p "Masukkan level (contoh: 4.2): " level [ -z "$level" ] && level="4.2"

codec_extra="-profile:v $profile -level $level"

elif [ "$codec_choice" = "2" ]; then vcodec="libx265" codec_extra="" else echo "Pilihan tidak valid. Gunakan H.264 (main)." vcodec="libx264" codec_extra="-profile:v main -level 4.2" fi

========================

6. SIAPKAN OUTPUT

========================

filename=$(basename -- "$VIDEO_PATH") name="${filename%.*}" output_folder="/storage/emulated/0/hasil_encode" mkdir -p "$output_folder" output_path="$output_folder/${name}_kompres.mp4"

========================

7. PROSES KOMPRESI

========================

echo "\n▶️ Mulai kompresi..." ffmpeg -i "$VIDEO_PATH" -c:v $vcodec -b:v ${bitrate}k -vf "scale=$scale,fps=$fps" 
$codec_extra -preset fast -c:a copy -y "$output_path" -progress pipe:1 2>&1 | while IFS== read -r key value; do if [ "$key" = "progress" ] && [ "$value" = "end" ]; then echo "\n✅ Kompresi selesai!" termux-media-player play "/storage/emulated/0/ffmpeg/sfx/MATTA MATTA SUOU YUKI.mp3" echo "Video tersimpan di: $output_path" fi done

========================

8. OPSI TIMPA FILE

========================

echo "\nIngin timpa video asli? (y/n)" read -p "Jawaban: " overwrite_choice if [ "$overwrite_choice" = "y" ]; then mv -f "$output_path" "$VIDEO_PATH" echo "Video lama berhasil ditimpa." fi

