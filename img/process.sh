Xo=168
Yo=144

ORIG_WD=`pwd`

# Butterflies
rm -rf butterflies
mkdir butterflies
Xc=$((Xo + 250))
Yc=$((Yo + 150))
L=200
X=$((Xc - L/2))
Y=$((Yc - L/2))
for i in ../img-raw/蜜蜂元件/蜜蜂元件/*; do (
  dir=$ORIG_WD/butterflies/`basename $i`
  echo $i $dir
  mkdir -p $dir
  cd $i
  for j in {1..20}; do
    if [ -e *-$j.png ]; then
      convert *-$j.png -crop ${L}x${L}+${X}+${Y} +repage $dir/`printf "%02d" $j`.png
    fi
  done
); done
(
  cd butterflies
  mv 待机-侧面 idle-side
  mv 待机-正面 idle-front
  mv 待机-背面 idle-back
  mv 转体-侧转正 turn-side-front
  mv 转体-侧转背 turn-side-back
  mv 转体-正转侧 turn-front-side
  mv 转体-背转侧 turn-back-side
)
