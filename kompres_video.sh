#!/data/data/com.termux/files/usr/bin/bash

clear
termux-setup-storage

SFX_OK="/storage/emulated/0/ffmpeg/sfx/MATTA MATTA SUOU YUKI.mp3"
SFX_ERR="/storage/emulated/0/ffmpeg/sfx/Ara Ara Anime  Ara-Ara Kurumi  Message.mp3"
OUTPUT_DIR="/storage/emulated/0/ffmpeg/kompresi/outputnya"

mkdir -p "$OUTPUT_DIR"

# 1. PILIH FILE
echo "📁 Pilih file video dari file manager..."
pick=$(termux-dialog file)
VIDEO_PATH=$(echo "$pick" | sed -n 's/.*"value":"\([^"]*\)".*/\1/p')

if [ ! -f "$VIDEO_PATH" ]; then
  echo "❌ File tidak ditemukan!"
  termux-media-player play "$SFX_ERR"
  exit 1
fi

VIDEO_NAME=$(basename "$VIDEO_PATH")
OUTPUT_PATH="$OUTPUT_DIR/[KOMPRES]$VIDEO_NAME"

# 2. PILIH RESOLUSI
echo ""
echo "Pilih resolusi:"
echo "1: 1080x1920"
echo "2: 720x1280"
echo "3: 540x960"
echo "4: 480x854"
echo "5: Custom"
read -p "Pilihan [1‑5]: " res_choice
case $res_choice in
  1) scale="1080:1920" ;;
  2) scale="720:1280" ;;
  3) scale="540:960" ;;
  4) scale="480:854" ;;
  5)
    read -p "Masukkan width: " cw
    read -p "Masukkan height: " ch
    scale="${cw}:${ch}"
    ;;
  *) echo "Default ke 720x1280"; scale="720:1280" ;;
esac

# 3. PILIH FPS
echo ""
echo "Pilih FPS:"
echo "1: 15"  
echo "2: 30"
echo "3: 60"
echo "4: 120"
read -p "Pilihan [1‑4]: " fpsc
case $fpsc in
  1) fps=15 ;;
  2) fps=30 ;;
  3) fps=60 ;;
  4) fps=120 ;;
  *) fps=30 ;;
esac

# 4. BITRATE
echo ""
read -p "Target bitrate (e.g. 5000 untuk 5000k): " br
brr="${br}k"

# 5. PILIH CODEC
echo ""
echo "Pilih codec:"
echo "1: H.264 (libx264)"
echo "2: H.265 (libx265)"
read -p "Pilihan [1‑2]: " cc
if [ "$cc" = "1" ]; then
  vcodec="libx264"
  echo "Pilih profil:"
  echo "1: baseline"  
  echo "2: main"
  echo "3: high"
  read -p "Pilihan [1‑3]: " pc
  case $pc in
    1) prof="baseline";;
    2) prof="main";;
    3) prof="high";;
    *) prof="high";;
  esac
  echo "Pilih level H.264:"
  echo "1: 3.1"  
  echo "2: 4.0"
  echo "3: 4.1"
  echo "4: 4.2"
  read -p "Pilihan [1‑4]: " lc
  case $lc in
    1) lvl="3.1" ;;
    2) lvl="4.0" ;;
    3) lvl="4.1" ;;
    4) lvl="4.2" ;;
    *) lvl="4.2" ;;
  esac
  codec_opts="-profile:v $prof -level $lvl -pix_fmt yuv420p"
elif [ "$cc" = "2" ]; then
  vcodec="libx265"
  echo "Pilih bit depth:"
  echo "1: 8-bit"
  echo "2: 10-bit"
  read -p "Pilihan [1‑2]: " bd
  if [ "$bd" = "2" ]; then
    codec_opts="-pix_fmt yuv420p10le"
  else
    codec_opts=""
  fi
else
  vcodec="libx264"
  codec_opts="-profile:v high -level 4.2 -pix_fmt yuv420p"
fi

# 6. MULAI KOMPRES
echo ""
echo "🚀 Mulai kompres..."
ffmpeg -i "$VIDEO_PATH" -c:v $vcodec $codec_opts -b:v "$brr" -preset veryfast -r $fps -vf scale=$scale -c:a copy "$OUTPUT_PATH"
ec=$?

# 7. CEK STATUS
if [ $ec -eq 0 ]; then
  echo "✅ Selesai!"
  termux-media-player play "$SFX_OK"

  sb=$(stat -c%s "$VIDEO_PATH")
  sa=$(stat -c%s "$OUTPUT_PATH")
  perc=$(( (sb-sa)*100/sb ))
  echo "📉 Dikompres sekitar $perc%"

  echo ""
  echo "Timpa file asli? 1=Ya / 2=Tidak"
  read -p "Choice [1‑2]: " rep
  if [ "$rep" = "1" ]; then
    mv -f "$OUTPUT_PATH" "$VIDEO_PATH"
    echo "✅ Asli sudah ditimpa."
  fi

else
  echo "❌ Gagal!"
  termux-media-player play "$SFX_ERR"
fi
