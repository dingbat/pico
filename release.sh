#!/bin/bash

version=v1_7
pico_path=/Applications/PICO-8.app/Contents/MacOS/pico8
# pico_path=~/pico-8/pico8_64
echo "cutting $version"

set -e

tab () {
 sed -i'.bak' -r -E "s/function $1\(/\n-->8\n--$2\n\nfunction $1(/" rts_sh.p8
}

repl () {
  sed -i'.bak' -E '/txt=/!s/'"$1"'/'"$2"'/g' rts_sh.p8
  # grep -E -i 'txt=.*'"$1"'' rts_sh.p8 || true
}

cp rts.p8 rts_print.p8
sed -i'.bak' -r -E "s/\+=\?(.*)/+=print(\1)/" rts_print.p8
sed -i'.bak' -r -E "s/\?(.*q\.qty)/print(\1)/" rts_print.p8
sed -i'.bak' -r -E "s/\?(split.*)/print(\1)/" rts_print.p8
sed -i'.bak' -r -E "s/and	\?(.*)/and print(\1)/" rts_print.p8
# sed -i'.bak' -r -E "s/\?(.*)/print(\1)/g" rts_print.p8
sed -i'.bak' -r -E "s/tostr\[\[\[\[\]\]/--[[/g" rts_print.p8

echo "shrinking..."
python3 ~/shrinko8/shrinko8.py ./rts_print.p8 ./rts_sh.p8 -m --no-minify-rename

header="\n--age of ants\n--eeooty\n\n--commented code on bbs!\n"
sed -i'.bak' -r -E "s/print\(([^)]+)\)/?\1\n/g" rts_sh.p8
# sed -i'.bak' -E "s/^function /\nfunction /" rts_sh.p8
sed -i'.bak' -E "s/^__lua__/__lua__$header/" rts_sh.p8
# sed -i'.bak' -E "s/=240$/=0xf0/" rts_sh.p8
sed -i'.bak' -E "s/~=/!=/g" rts_sh.p8
# sed -i'.bak' -E "s/24365/0x5f2d/" rts_sh.p8
# sed -i'.bak' -E "s/13480/0x34a8/" rts_sh.p8
# sed -i'.bak' -E "s/61440/0xf000/" rts_sh.p8
# sed -i'.bak' -E "s/36868/0x9004/" rts_sh.p8

repl avail_farm afarm
repl farmer fmr
repl rndspl rs
repl unspl us
repl campal cp
repl fmget fm
repl loadgame lg
repl posidx pi
repl maxbop mb
repl avail av
repl fire f
repl seltyp st
repl draw_unit du
repl selbox sb
repl breq bq
repl prj_xo px
repl prj_yo py
repl prj_s s
repl portx ptx
repl porty pty
repl produce pr
repl dropu dr
repl nearest nr
repl upcycle z
repl wander w
repl lady l
repl vcache vc
repl mine_nxt mn
repl range rng
repl tile_unit tu
repl const ct
repl move mv
repl rest rt
repl input ip
repl hilite hi
repl can_drop cdr
repl can_atk ctk
repl can_bld cbl
repl can_gth cgt
repl can_pay cpy
repl can_renew cr
repl renew ren
repl reg_bldg rb
repl dmap_st dms
repl qdmaps qdm
repl bldable bd
repl dmg_mult dmt
repl max_hp mh
repl gofarm gf
repl gobld gb
repl goatk ga
repl godrop gd
repl resqty rq
repl sel_ports sp
repl draw_port dp
repl draw_menu dm
repl resbar br
repl antprod ap
repl comp co
repl pcol pc
repl ai_frame aif
repl loser ls
repl surr sr
repl rescol rc
repl alive a
repl active ac
repl onscr on
repl dsfx ds

sed -i'.bak' -E "s/version 41/version 39/" rts_sh.p8
# tab start init
# tab rest tick
# tab cam input
# tab draw_unit unit
# tab p utils
# tab dpath paths
# tab pres menu
# tab save save
# tab ai_frame ai
# tab mode mode

rm rts_print.p8 rts_print.p8.bak rts_sh.p8.bak

python3 ~/shrinko8/shrinko8.py ./rts_sh.p8 --count
echo

# exit 1

rm -rf out
$pico_path -export "age_of_ants.bin" ./rts_sh.p8
$pico_path -export itch/index.js ./rts_sh.p8

mv age_of_ants.bin out
$pico_path -export "out/age_of_ants.p8.png" ./rts_sh.p8
mv out/age_of_ants.p8.png "out/age of ants.p8.png"

rm -rf out/windows out/raspi out/linux out/age_of_ants.app

cp age_of_ants_ost.mp3 out/
mv out/age_of_ants_raspi.zip out/age_of_ants_${version}_raspi.zip
mv out/age_of_ants_osx.zip out/age_of_ants_${version}_osx.zip
mv out/age_of_ants_windows.zip out/age_of_ants_${version}_windows.zip
mv out/age_of_ants_linux.zip out/age_of_ants_${version}_linux.zip

zip out/web.zip itch/*
