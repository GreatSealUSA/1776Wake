#!/bin/bash

#
# requires ImageMagick
#   https://imagemagick.org/script/download.php
#   binary in current directory
#   wget https://imagemagick.org/archive/binaries/magick
#   2026-02-27 got:
#   ImageMagick 7.1.2-15 Q16-HDRI x86_64 818ee6363:20260222
#
#   2027-06-27
#     wget https://github.com/ImageMagick/ImageMagick/releases/download/7.1.2-26/ImageMagick-7.1.2-26-clang-x86_64.AppImage
#     cp ImageMagick-7.1.2-26-clang-x86_64.AppImage magick
#     chmod +x magick
#

GSUSAFILE="great_seal_reverse.svg"
GSUSAFILEOBVERSE="disclosure_day.webp"
THIRDIMAGE="James_Joyce_Eye_Patch.jpeg"

# create a new 1280×640 SVG canvas (GitHub recommended size)


function graphics_work_do_three {
    
./magick -size 1280x640 xc:white \
  \( -density 300 "$GSUSAFILE"        -transparent white -resize x540 \) \
  -gravity center -geometry -434-34 -composite \
  \( -density 300 "$GSUSAFILEOBVERSE" -transparent white -resize x540 \) \
  -gravity center -geometry   +4-50 -composite \
  \( -density 300 "$THIRDIMAGE" -transparent white -resize x540 \) \
  -gravity center -geometry +314-50 -composite \
  \
  -font "Ubuntu-Mono-Bold" -pointsize 28 \
  -fill "#B54700" -stroke "#B54700" -strokewidth 2 \
  -gravity south -annotate -61-10 "#1776Wake" \
  \
  -pointsize 17 \
  -gravity east -annotate 270x270+120-280 "www.1776Wake.com" \
  \
  -pointsize 10.3 \
  -fill "#000000" -stroke "#000000" -strokewidth 1 \
  -gravity east -annotate 270x270+60-280 "James Joyce Wake Symbolism" \
  \
  png8:1776Wake_Left-Eye_Right-Eye_Third-Eye_Disclosure_Day_sized_1280_x_640.png

}





if [ -f "$GSUSAFILEOBVERSE" ]; then
  echo "The file '$GSUSAFILEOBVERSE' exists and is a regular file."
else

  echo "file missing"
  
  echo "Please re-run this bash script if the download worked..."

  exit 0
fi

if [ -f "$GSUSAFILE" ]; then
  echo "The file '$GSUSAFILE' exists and is a regular file."
  graphics_work_do_three
else

  wget -O $GSUSAFILE \
  https://upload.wikimedia.org/wikipedia/commons/4/45/Great_Seal_of_the_United_States_%28reverse%29.svg
  
  echo "Please re-run this bash script if the download worked..."
fi
