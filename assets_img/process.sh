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

if false; then
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

if false; then
  # Bloom
  rm -rf bloom
  mkdir bloom
  Xc=$((Xo + 550))
  Yc=$((Yo + 150))
  W=120
  H=120
  X=$((Xc - W/2))
  Y=$((Yc - H/2))
  for i in ../img/吸引花元件/吸引花/*; do (
    dir=$ORIG_WD/bloom/`basename $i`
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
    cd bloom
    mv 待机 idle
    mv 开放 visited
  )
fi

if true; then
  # Chameleon
  rm -rf chameleon
  mkdir chameleon
  Xc=$((Xo + 550))
  Yc=$((Yo + 150))
  W=120
  H=120
  X=$((Xc - W/2))
  Y=$((Yc - H/2))

  p=0
  for n in 蓝 粉 红; do
    p=$((p + 1))
    for i in ../img/变色龙原件/${n}变色龙/*; do (
      bn=`basename $i`
      dir=$ORIG_WD/chameleon/p${p}-${bn}
      echo $i $dir
      mkdir -p $dir
      bn_mapped=$bn
      cd $i
      if [ "$bn" == "眼睛" ]; then
        for j in {1..25}; do
          if [ -e *-$j.png ]; then
            # For reference: only keep a small content region
            # convert *-$j.png -crop 100x100+775+506 +repage $dir/`printf "%02d" $j`.png
            # https://www.imagemagick.org/discourse-server/viewtopic.php?t=19682
            convert \( *-$j.png -crop 1024x400+0+374 +repage \) ../../正片叠底.jpg -gravity east \
              \( -clone 0 -alpha extract \) \( -clone 0 -clone 1 -compose multiply -composite \) \
              -delete 0,1 +swap -alpha off -compose copy_opacity -composite \
              $dir/`printf "%02d" $j`.png
          fi
        done
        bn_mapped=eye
      elif [ "$bn" == "张嘴" ]; then
        for j in {1..25}; do
          if [ -e *-$j.png ]; then
            convert *-$j.png -crop 640x920+1068+78 +repage $dir/`printf "%02d" $j`.png
          fi
        done
        bn_mapped=body
      else
        for j in {1..25}; do
          if [ -e *-$j.png ]; then
            filename=`echo *-$j.png`
            convert *-$j.png -crop 1024x400+0+374 +repage $dir/$filename
          fi
        done
        bn_mapped=tongue
      fi
      if [ "$bn" != "$bn_mapped" ]; then
        mkdir -p $ORIG_WD/chameleon/p${p}-${bn_mapped}
        mv $dir/* $ORIG_WD/chameleon/p${p}-${bn_mapped}
        rm -rf $dir
        echo $i $ORIG_WD/chameleon/p${p}-${bn_mapped}
      fi
    ); done
  done
fi

if false; then
  # Still
  rm -rf still
  mkdir still
  p=0
  for n in 蓝 粉 红; do
    p=$((p + 1))
    dir=$ORIG_WD/still/p$p
    from=../img/${n}静态元件
    echo $n $from $dir
    mkdir -p $dir

    # Tiles
    # The `-trim` operator does not work well for images with
    # irregular boundaries and thin border strokes
    crop=+0+0
    if [ "$p" == "2" ]; then
      crop=1586x+4+3
    elif [ "$p" == "3" ]; then
      crop=1588x+3+0
    fi
    convert $from/*瓷砖.png -crop $crop +repage -resize 1600x800\! -quality 100 $dir-tiles.jpg

    for i in $from/*障碍物*; do
      bn=`basename $i`
      id=${bn:11}
      cp $i $dir-obst-$id
    done

    for i in $from/*碰撞折返*; do
      bn=`basename $i`
      id=${bn:12}
      cp $i $dir-rebound-$id
    done

    for i in $from/*传粉花*; do
      bn=`basename $i`
      id=${bn:11}
      cp $i $dir-pollen-$id
    done
  done
fi
