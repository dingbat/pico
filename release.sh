#!/bin/bash

set -e

tab () {
 sed -i -E "s/function $1\(/-->8\n--$2\n\nfunction $1(/" rts_sh.p8
}

cp rts.p8 rts_print.p8
sed -i -E "s/\+=\?(.*)/+=print(\1)/" rts_print.p8
sed -i -E "s/\?(.*q\.qty)/print(\1)/" rts_print.p8
sed -i -E "s/\?(split.*)/print(\1)/" rts_print.p8
sed -i -E "s/tostr\[\[\[\[\]\]/--[[/" rts_print.p8

echo "shrinking..."
python3 ~/shrinko8-main/shrinko8.py ./rts_print.p8 ./rts_sh.p8 -m --no-minify-rename --no-minify-lines

header="\n--age of ants\n--eeooty\n\n--credits \& code with spaces\n--on bbs!\n"
sed -i -E "s/print\((.*)\)/?\1/" rts_sh.p8
sed -i -E "s/^function /\nfunction /" rts_sh.p8
sed -i -E "s/^__lua__/__lua__$header/" rts_sh.p8
# sed -i -E "s/=240$/=0xf0/" rts_sh.p8
sed -i -E "s/~=/!=/" rts_sh.p8
sed -i -E "s/24365/0x5f2d/" rts_sh.p8
sed -i -E "s/13480/0x34a8/" rts_sh.p8
# sed -i -E "s/61440/0xf000/" rts_sh.p8
sed -i -E "s/36868/0x9004/" rts_sh.p8
tab start init
tab rest tick
tab cam input
tab draw_unit unit
tab p utils
tab dpath paths
tab pres menu
tab comp const
tab save save
tab ai_frame ai
tab mode mode

rm rts_print.p8

python3 ~/shrinko8-main/shrinko8.py ./rts_sh.p8 --count
echo

rm -rf out
~/pico-8/pico8_64 -export "age_of_ants.bin" ./rts_sh.p8
~/pico-8/pico8_64 -export itch/index.js ./rts_sh.p8

mv age_of_ants.bin out
~/pico-8/pico8_64 -export "out/age_of_ants.p8.png" ./rts_sh.p8
mv out/age_of_ants.p8.png "out/age of ants.p8.png"

rm -rf out/windows out/raspi out/linux out/age_of_ants.app

version=v1.0
mv out/age_of_ants_raspi.zip out/age_of_ants_${version}_raspi.zip
mv out/age_of_ants_osx.zip out/age_of_ants_${version}_osx.zip
mv out/age_of_ants_windows.zip out/age_of_ants_${version}_windows.zip
mv out/age_of_ants_linux.zip out/age_of_ants_${version}_linux.zip

zip out/web.zip itch/*