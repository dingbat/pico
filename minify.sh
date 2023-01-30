tab () {
 sed -i -E "s/function $1\(/-->8\n--$2\n\nfunction $1(/" rts_sh.p8
}

header="\n--age of ants\n--eeooty\n\n--for source with whitespace\n--and credits visit:\n--\n"
python3 ~/shrinko8-main/shrinko8.py ./rts.p8 ./rts_sh.p8 -m --no-minify-rename --no-minify-lines
sed -i -E "s/^function /\nfunction /" rts_sh.p8
sed -i -E "s/^__lua__/__lua__$header/" rts_sh.p8
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
tab mode options