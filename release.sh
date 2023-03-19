#!/bin/bash

version=v1_7
pico_path=/Applications/PICO-8.app/Contents/MacOS/pico8
# pico_path=~/pico-8/pico8_64
echo "cutting $version"

set -e

tab () {
 sed -i'.bak' -r -E "s/function $1\(/\n-->8\n--$2\n\nfunction $1(/" rts_sh.p8
}

cp rts.p8 rts_print.p8
sed -i'.bak' -r -E "s/\+=\?(.*)/+=print(\1)/" rts_print.p8
sed -i'.bak' -r -E "s/\?(.*q\.qty)/print(\1)/" rts_print.p8
sed -i'.bak' -r -E "s/\?(split.*)/print(\1)/" rts_print.p8
sed -i'.bak' -r -E "s/tostr\[\[\[\[\]\]/--[[/" rts_print.p8

echo "shrinking..."
python3 ~/shrinko8/shrinko8.py ./rts_print.p8 ./rts_sh.p8 -m --no-minify-rename

header="\n--age of ants\n--eeooty\n\n--commented code on bbs!\n"
sed -i'.bak' -r -E "s/print\(([^)]+)\)/?\1\n/" rts_sh.p8
# sed -i'.bak' -E "s/^function /\nfunction /" rts_sh.p8
sed -i'.bak' -E "s/^__lua__/__lua__$header/" rts_sh.p8
# sed -i'.bak' -E "s/=240$/=0xf0/" rts_sh.p8
sed -i'.bak' -E "s/~=/!=/" rts_sh.p8
# sed -i'.bak' -E "s/24365/0x5f2d/" rts_sh.p8
# sed -i'.bak' -E "s/13480/0x34a8/" rts_sh.p8
# sed -i'.bak' -E "s/61440/0xf000/" rts_sh.p8
# sed -i'.bak' -E "s/36868/0x9004/" rts_sh.p8

for _ in 1 2
do
  sed -i'.bak' -E "s/avail_farm/afarm/" rts_sh.p8
  sed -i'.bak' -E "s/can_renew/cr/" rts_sh.p8
done
for _ in 1 2 3 4
do
  sed -i'.bak' -E "s/renew/ren/" rts_sh.p8
  sed -i'.bak' -E "s/rndspl/rs/" rts_sh.p8
  sed -i'.bak' -E "s/campal/cp/" rts_sh.p8
  sed -i'.bak' -E "s/fmget/fm/" rts_sh.p8
  sed -i'.bak' -E "s/loadgame/lg/" rts_sh.p8
  sed -i'.bak' -E "s/posidx/pi/" rts_sh.p8
  sed -i'.bak' -E "s/maxbop/mb/" rts_sh.p8
  sed -i'.bak' -E "s/avail/av/" rts_sh.p8
  sed -i'.bak' -E "s/fire/f/" rts_sh.p8
  sed -i'.bak' -E "s/seltyp/st/" rts_sh.p8
  sed -i'.bak' -E "s/draw_unit/du/" rts_sh.p8
  sed -i'.bak' -E "s/selbox/sb/" rts_sh.p8
  sed -i'.bak' -E "s/breq/bq/" rts_sh.p8
  sed -i'.bak' -E "s/prj_xo/px/" rts_sh.p8
  sed -i'.bak' -E "s/prj_yo/py/" rts_sh.p8
  sed -i'.bak' -E "s/prj_s/s/" rts_sh.p8
  sed -i'.bak' -E "s/portx/ptx/" rts_sh.p8
  sed -i'.bak' -E "s/porty/pty/" rts_sh.p8
  sed -i'.bak' -E "s/produce/pr/" rts_sh.p8
  sed -i'.bak' -E "s/dropu/dr/" rts_sh.p8
  sed -i'.bak' -E "s/nearest/nr/" rts_sh.p8
  sed -i'.bak' -E "s/upcycle/z/" rts_sh.p8
  sed -i'.bak' -E "s/wander/w/" rts_sh.p8
  sed -i'.bak' -E "s/lady/l/" rts_sh.p8
  sed -i'.bak' -E "s/vcache/vc/" rts_sh.p8
  sed -i'.bak' -E "s/mine_nxt/mn/" rts_sh.p8
  sed -i'.bak' -E "s/tile_unit/tu/" rts_sh.p8
done

sed -i'.bak' -E "s/fball:/fireball:/" rts_sh.p8

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
