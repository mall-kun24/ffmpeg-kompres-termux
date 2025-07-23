#!/data/data/com.termux/files/usr/bin/bash

echo "==============================================="
echo " Skrip FFmpeg Kompres Video by MARU け TEMPEST"
echo " Dibuat oleh   : MARU け TEMPEST"
echo " Versi Saat Ini: 5.1"
echo "==============================================="
echo " Akun Sosial Media:"
echo " TikTok   : @marutempesto / MARU け TEMPEST"
echo " Instagram: mall_kun24"
echo " Facebook : ikmal"
echo

# Fungsi: Mainkan suara notifikasi dari Termux, fallback ke penyimpanan internal
play_sfx() {
    local filename="$1"
    if [ -f ~/.ffmpeg/sfx/"$filename" ]; then
        termux-media-player play ~/.ffmpeg/sfx/"$filename"
    elif [ -f /storage/emulated/0/ffmpeg/sfx/"$filename" ]; then
        termux-media-player play /storage/emulated/0/ffmpeg/sfx/"$filename"
    fi
}

# Pilih Mode Kompresi
echo
echo "Pilih mode kompresi:"
echo "1. Single File Mode (kompres 1 video)"
echo "2. Batch Mode (input beberapa video satu per satu)"
read -p "Masukkan pilihan [1/2]: " mode

if [[ "$mode" == "1" ]]; then
    echo "=== MODE: SINGLE FILE ==="
    while true; do
        read -p "Masukkan path video input (contoh: /sdcard/video.mp4): " input
        if [ -f "$input" ]; then
            break
        else
            echo "❌ File tidak ditemukan: $input"
            play_sfx "Ara_Ara_Anime_Ara_Ara_Kurumi_Message.mp3"
        fi
    done
    video_list=("$input")

elif [[ "$mode" == "2" ]]; then
    echo "=== MODE: BATCH ==="
    read -p "Berapa jumlah video yang ingin dikompres? " jumlah
    for ((i=1; i<=jumlah; i++)); do
        while true; do
            read -p "Masukkan path video ke-$i: " path
            if [ -f "$path" ]; then
                video_list+=("$path")
                break
            else
                echo "❌ File tidak ditemukan: $path"
                play_sfx "Ara_Ara_Anime_Ara_Ara_Kurumi_Message.mp3"
            fi
        done
    done

else
    echo "Mode tidak dikenali. Keluar skrip."
    play_sfx "Ara_Ara_Anime_Ara_Ara_Kurumi_Message.mp3"
    exit 1
fi

output_dir="/storage/emulated/0/ffmpeg/kompresi"
backup_dir="/storage/emulated/0/ffmpeg/backup"
mkdir -p "$output_dir" "$backup_dir"

for input in "${video_list[@]}"; do
    if [ ! -f "$input" ]; then
        echo "File tidak ditemukan: $input"
        continue
    fi

    filename=$(basename "$input")
    extension="${filename##*.}"
    name_only="${filename%.*}"
    output="$output_dir/[kompres] $filename"

    count=1
    while [[ -e "$output" ]]; do
        output="$output_dir/[kompres] $name_only ($count).$extension"
        ((count++))
    done

    # Input resolusi & bitrate
    read -p "Masukkan resolusi (contoh: 1280x720): " resolusi
    read -p "Masukkan bitrate video (contoh: 4000k): " bitrate

    # FPS
    echo "Pilih FPS (Frame per Second) yang diinginkan:"
    echo "1. 120 fps - Untuk slow-motion atau hasil sangat halus"
    echo "2. 60 fps  - Umum digunakan untuk video modern"
    echo "3. 30 fps  - Standar video biasa"
    echo "4. 24 fps  - Gaya sinematik (seperti film)"
    echo "5. 15 fps  - Kualitas sangat rendah, hemat ukuran"
    read -p "Masukkan pilihan (1-5): " fps_opt
    case $fps_opt in
        1) fps=120 ;;
        2) fps=60 ;;
        3) fps=30 ;;
        4) fps=24 ;;
        5) fps=15 ;;
        *) fps=30 ;;
    esac

    # Pilih Codec
    echo "Pilih codec video:"
    echo "1. H.264 (libx264) - Kompatibel, kualitas baik, ukuran standar"
    echo "2. H.265 8-bit     - Ukuran lebih kecil, kualitas sama"
    echo "3. H.265 10-bit    - Kualitas maksimal (butuh device mendukung)"
    read -p "Masukkan angka (1-3): " codec_choice
    pix_fmt=""
    case "$codec_choice" in
        1)
            codec="libx264"
            echo "Pilih profile untuk H.264:"
            echo "1. baseline - Kualitas rendah, kompatibel device lama"
            echo "2. main     - Standar umum, cukup baik"
            echo "3. high     - Kualitas tinggi (direkomendasikan)"
            read -p "Masukkan angka (1-3): " profile_choice
            case "$profile_choice" in
                1) profile="baseline" ;;
                2) profile="main" ;;
                3) profile="high" ;;
                *) profile="high" ;;
            esac
            read -p "Masukkan level (contoh: 3.1, 4.0, 4.2) [default: 4.2]: " level_input
            level="${level_input:-4.2}"
            ;;
        2)
            codec="libx265"
            profile=""
            level=""
            ;;
        3)
            codec="libx265"
            profile=""
            level=""
            pix_fmt="-pix_fmt yuv420p10le"
            ;;
        *)
            codec="libx264"
            profile="high"
            level="4.2"
            ;;
    esac

    # Pilih preset
    echo "Pilih preset (kecepatan kompresi vs kualitas):"
    echo "1. ultrafast   - Sangat cepat, ukuran besar, kualitas rendah"
    echo "2. superfast   - Cepat, kualitas agak rendah"
    echo "3. veryfast    - Cepat, kualitas cukup baik (direkomendasikan)"
    echo "4. faster      - Agak cepat, kualitas menengah"
    echo "5. fast        - Seimbang"
    echo "6. medium      - Lebih lambat, kualitas lebih baik"
    echo "7. slow        - Lambat, kualitas tinggi"
    echo "8. slower      - Sangat lambat, kualitas maksimal"
    echo "9. veryslow    - Paling lambat, kualitas paling bagus"
    read -p "Masukkan angka (1-9): " preset_choice
    case $preset_choice in
        1) preset="ultrafast" ;;
        2) preset="superfast" ;;
        3) preset="veryfast" ;;
        4) preset="faster" ;;
        5) preset="fast" ;;
        6) preset="medium" ;;
        7) preset="slow" ;;
        8) preset="slower" ;;
        9) preset="veryslow" ;;
        *) preset="veryfast" ;;
    esac

    # Siapkan log file
    log_name="[log] ${name_only}.txt"
    log_file="/storage/emulated/0/ffmpeg/logs/$log_name"
    mkdir -p "/storage/emulated/0/ffmpeg/logs"
    echo "Menyimpan log ke: $log_file"
    echo "Video       : $filename" > "$log_file"
    echo "Resolusi    : $resolusi" >> "$log_file"
    echo "Bitrate     : $bitrate" >> "$log_file"
    echo "FPS         : $fps" >> "$log_file"
    echo "Codec       : $codec" >> "$log_file"
    echo "Profile     : ${profile:-N/A}" >> "$log_file"
    echo "Level       : ${level:-N/A}" >> "$log_file"
    echo "Preset      : $preset" >> "$log_file"
    echo "Waktu mulai : $(date '+%Y-%m-%d %H:%M:%S')" >> "$log_file"
    echo "======================================" >> "$log_file"

# Tampilkan estimasi encode dan ukuran file
video_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input")
video_duration=${video_duration%.*} # buletin ke detik

if [[ "$video_duration" =~ ^[0-9]+$ ]]; then
    echo "Estimasi durasi encoding..."
    echo "Durasi video: ${video_duration}s → Estimasi waktu encode: ~${video_duration}s"
fi

file_before=$(du -h "$input" | cut -f1)
echo "Ukuran sebelum: $file_before"

    echo
echo "Memulai kompresi... (CTRL + C untuk batalkan)"
echo -e "\n▶️ Memulai kompresi..."
echo "⏳ Tunggu sebentar..."
start_time=$(date +%s)


    ffmpeg -i "$input" -vf scale="$resolusi" -r "$fps" -c:v $codec -preset "$preset" \
    ${profile:+-profile:v $profile} ${level:+-level:v $level} \
    ${bitrate:+-b:v $bitrate} $pix_fmt \
    -c:a aac -b:a 128k -ar 44100 "$output" >> "$log_file" 2>&1

    end_time=$(date +%s)
    dur=$((end_time - start_time))
    menit=$((dur / 60))
    detik=$((dur % 60))

echo -e "⏱️ Kompres selesai dalam ${menit} menit ${detik} detik"
play_sfx "MATTA_MATTA_SUOU_YUKI.mp3"

file_after=$(du -h "$output" | cut -f1)
echo "📦 Ukuran sesudah kompresi: $file_after"

    echo
    read -p "Ingin timpa file asli dengan hasil ini? [y/n]: " timpa
    if [[ "$timpa" == "y" || "$timpa" == "Y" ]]; then
        mv "$input" "$backup_dir/"
        mv "$output" "$input"
        echo "File asli berhasil ditimpa. Backup disimpan di: $backup_dir"
    else
        echo "File hasil disimpan di: $output"
    fi

done  # ← Tambahkan ini untuk menutup loop

echo
echo "Semua proses kompresi selesai!"
read -p "Tekan ENTER untuk keluar..."