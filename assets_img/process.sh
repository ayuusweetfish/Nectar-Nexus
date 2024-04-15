Xo=168
Yo=144

ORIG_WD=`pwd`

if false; then
  # Butterflies
  rm -rf butterflies
  mkdir butterflies
  Xc=$((Xo + 250))
  Yc=$((Yo + 150))
  L=200
  X=$((Xc - L/2))
  Y=$((Yc - L/2))
  for i in ../img/蜜蜂元件/蜜蜂元件/*; do (
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
fi

if true; then
  # Weeds
  rm -rf weeds
  mkdir weeds
  Xc=$((Xo + 800))
  Yc=$((Yo + 550))
  W=300
  H=300
  X=$((Xc - W/2))
  Y=$((Yc - H/2))
  for i in ../img/炸昆虫花原件/炸昆虫花/*; do (
    dir=$ORIG_WD/weeds/`basename $i`
    echo $i $dir
    mkdir -p $dir
    cd $i
    for j in {1..20}; do
      if [ -e *-$j.png ]; then
        convert *-$j.png -crop ${W}x${H}+${X}+${Y} +repage $dir/`printf "%02d" $j`.png
      fi
    done
  ); done
  (
    cd weeds
    mv 蓝-待机 p1-idle
    mv 蓝-触发 p1-trigger
    mv 粉-待机 p2-idle
    mv 粉-触发 p2-trigger
    mv 红-待机 p3-idle
    mv 红-触发 p3-trigger
  )
fi