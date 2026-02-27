#!/bin/bash

#
# requires ImageMagick
#   https://imagemagick.org/script/download.php
#   binary in current directory
#   wget https://imagemagick.org/archive/binaries/magick
#

GSUSAFILE="great_seal_reverse.svg"
GSUSAFILEOBVERSE="great_seal_obverse.svg"

# create a new 1280×640 SVG canvas (GitHub recommended size)


# NOTE: The BRS47 this is based on had problem with
#       transparent background. The eagle needs white
#       background.
#       https://bsky.app/profile/greatsealusa.bsky.social/post/3mcl6yyhi4k2i 
#       2026-02-27 got:
#       ImageMagick 7.1.2-15 Q16-HDRI x86_64 818ee6363:20260222



function graphics_work_do_two {
    
./magick -size 1280x640 xc:white \
  \( -density 300 "$GSUSAFILE"        -transparent white -resize x580 \) \
  -gravity center -geometry -344-27 -composite \
  \( -density 300 "$GSUSAFILEOBVERSE" -transparent white -resize x580 \) \
  -gravity center -geometry +234-27 -composite \
  \
  -font "Ubuntu-Mono-Bold" -pointsize 28 \
  -fill "#B54700" -stroke "#B54700" -strokewidth 2 \
  -gravity south -annotate -61-10 "#1776Wake" \
  \
  -pointsize 17 \
  -gravity east -annotate 270x270+60-280 "www.1776Wake.com" \
  \
  png8:1776Wake_logo_sized_1280_x_640.png

}




if [ -f "$GSUSAFILEOBVERSE" ]; then
  echo "The file '$GSUSAFILEOBVERSE' exists and is a regular file."
else

  wget -O $GSUSAFILEOBVERSE \
  https://upload.wikimedia.org/wikipedia/commons/5/5c/Great_Seal_of_the_United_States_%28obverse%29.svg
  
  echo "Please re-run this bash script if the download worked..."

  exit 0
fi

if [ -f "$GSUSAFILE" ]; then
  echo "The file '$GSUSAFILE' exists and is a regular file."
  graphics_work_do_two
else

  wget -O $GSUSAFILE \
  https://upload.wikimedia.org/wikipedia/commons/4/45/Great_Seal_of_the_United_States_%28reverse%29.svg
  
  echo "Please re-run this bash script if the download worked..."
fi
