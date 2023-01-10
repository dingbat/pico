pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
mapw=48
maph=32

function _init()
--	reload(0,0,0x3000,"rts.p8")
--	cstore()

	cls()

--	printa(pos1)
--	make_vars()
	make_map()
end

function make_map()
	local data={
		bo,pos1,pos2,pos3,pos4
	}
	for i,a in inext,data do
		i-=1
		sermap(a,0x2060+i*128*4)
	end
	cstore()
	for y=0,#data*4-1 do
		cstore(
			0x2060+y*128,
			0x2060+y*128,
			32,
			"rts.p8")
	end
end

function make_vars()
	local str=
		"bo,bop1,bop2,bop3,bop4=\n"
	str..=out(bo)
	str..=out(pos1)
	str..=out(pos2)
	str..=out(pos3)
	str..=out(pos4)
	
	--remove comma
	str=sub(str,1,-3).."\n"
	
	printh(str,"@clip")
	print("done")
end

function out(arr)
	return (
		"	\""..ser(arr,1).."\",\n"
	)
end

function escape(n)
	return n=="\"" and "\\\"" or
		n=="\n" and "\\n" or 
		n=="\r" and "\\r" or 
		n=="\\" and "\\\\" or n
end

function ser(a,e)
	local esc=e and escape or
	 tostr
	local s=""
	for b in all(a) do
		foreach(split(b),function(x)
			s..=esc(chr(x))
		end)
	end
	return s
end

function pad(n)
	return n<10 and "0"..n or n
end

function ser2(a)
	local s=""
	for b in all(a) do
		local x,y=unpack(split(b))
		s..=x..","..y.."/"
	end
	return s
end

function sermap(a,o)
	for i,v in inext,a do
		i-=1
		i*=2
		local off=o+i%32+i\32*128
		poke(off,v[1],v[2])
	end
end

function des(s)
	local a={}
	foreach(split(s,2),function(b)
		add(a,pack(ord(b,1,2)))
	end)
	return a
end

function loada(str)
	local a={}
	foreach(split(str,"\n"),
		function(l)
			return add(a,split(l))
		end
	)
	return a
end

function printa(a)
	local str=""
	foreach(a,function(b)
		local x,y=unpack(split(b))
		str..=x..","..y.."\n"
	end)
	printh(str,"@clip")
end
-->8
bo=loada[[5,1
8,1
8,3
11,1
12,5
15,2
16,1
16,2
17,2
20,2
21,2
21,1
22,4
23,1
23,2
24,2
25,1
26,6
27,2
29,2
30,2
31,2
31,1
32,4
34,3
36,1
39,5
40,1
41,2
41,2
42,2
42,2
43,1
43,6
45,5
48,1
49,3
50,5
52,4
53,1
53,2
53,3
53,5
54,2
54,2
57,1
60,5
65,2
65,2
65,1
65,6
150,1]]
-->8
pos1=loada[[43,27
37,26
40,18
43,21
38,16
41,24
45,25
42,24
43,24
43,23
43,22
42,20
38,21
43,16
42,22
41,22
39,28
92,34
17,40
22,40
23,40
24,44
24,38
19,40
20,40
16,45
9,40
7,47
22,45
24,46
24,44
25,44
26,44
12,92
34,11
37,20
33,28
41,8
32,30
42,8
42,28
43,26
35,28
38,23
42,26
42,27
43,5
92,34
29,41
27,41
28,92
34,8
35,4
99,99]]
-->8
pos2=loada[[44,28
38,27
41,19
44,22
39,17
42,25
46,26
43,25
44,25
44,24
44,23
43,21
39,22
44,17
43,23
42,23
40,29
93,35
18,41
23,41
24,41
25,45
25,39
20,41
21,41
17,46
10,41
8,48
23,46
25,47
25,45
26,45
27,45
13,93
35,12
38,21
34,29
42,9
33,31
43,9
43,29
44,27
36,29
39,24
43,27
43,28
44,6
93,35
30,42
28,42
29,93
35,9
36,5
99,99]]
-->8
pos3=loada[[45,29
39,28
42,20
45,23
40,18
43,26
47,27
44,26
45,26
45,25
45,24
44,22
40,23
45,18
44,24
43,24
41,30
94,36
19,42
24,42
25,42
26,46
26,40
21,42
22,42
18,47
11,42
9,49
24,47
26,48
26,46
27,46
28,46
14,94
36,13
39,22
35,30
43,10
34,32
44,10
44,30
45,28
37,30
40,25
44,28
44,29
45,7
94,36
31,43
29,43
30,94
36,10
37,6
99,99]]
-->8
pos4=loada[[46,30
40,29
43,21
46,24
41,19
44,27
48,28
45,27
46,27
46,26
46,25
45,23
41,24
46,19
45,25
44,25
42,31
95,37
20,43
25,43
26,43
27,47
27,41
22,43
23,43
19,48
12,43
10,50
25,48
27,49
27,47
28,47
29,47
15,95
37,14
40,23
36,31
44,11
35,33
45,11
45,31
46,29
38,31
41,26
45,29
45,30
46,8
95,37
32,44
30,44
31,95
37,11
38,7
99,99]]
__gfx__
00000000d000000000000000000000000000000000d0000000000000000000000000000000100010000000000000000000000000011000110000000000000000
000000000d000000d00000000000000000000000000d000000000000000000000011000000010100000000000110001100000000000101000000000000000000
00700700005111000d000000dd00000000000000000051100d011100dd0000000111100000010100001110000001010000111000004444000000000000001010
000770000051111000511100005111000000000000005111d0511110005111000111101110444400011110111044440001111011104242000011000111014441
000770000001111000511110005111100d51110000000d11005d1110005111100110144114424200011014411442420001101441140440000111114411412421
00700700000d1d10000d1d100001d1d0d051d1d00000000d000000d0000d1d100000544005044000011054400504400001105440505005000115054450504400
00000000000000000000000000000000000000000000000000000000000000000005050050500500000505005050050000050500000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000800000008000080000000000000000000000000000000000000000010050000000000000000000000000000000000000000000000000000
000000000000000088000800880008800000000050000000000080000000000000000000115000000000000000000000000000000000000000d0000000000000
11000000110001101100880011000110110001100110511081101100008880000000000003300000000000000000000000d00000000000000d00000000000000
00111111001100110011111100110011801108110011001100110011088e8800000000000011500000d00000000000100d000000000000003310000000000000
0b0000000b0000b004000000040000400000000000000000000000000e88e8ee00000000001300000d0000000001131133100000000000003311310000000000
bb000b00bb000bb044000400440004400000000000001100000000000858586e0dd1311331350000331131131131135033113113113113100011311311311310
1100bb00110001101100440011000110000000000110001011101100000000003311311331105000331131131130500000113113113113110505001311311311
00111111001100110011111100110011015500000011000100010011000000003305005050500000050500505050000000505050505050500000005050505050
00000000000000000000000000000000000000000000000000000000000000000050500000000000000505000888800000000000000000000000000000000000
0505050000000000000000000000000000000000000000000000000000000000050151500050505005501510888e880008888000008888000000000000000000
50151050050505000050505000505050005050500505050005050500000000000501515005015105500d15158e88e8ee888e8800088e88800000000000000000
501510505015105005015105050511050505115050151500501150500050500050d0d005050151050000d50588e8887e8e88e8ee08e8e8ee0000000000000000
50050050501510505001510550051105050511505015150050115050051515000000000505dd000500000005888880008888887e0888887e0000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050500050505000050505000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d11311311311310
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033d1515351515351
0000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d000000000000000000000000000000dd0000000d00000000d0000000000000000000000000000000d000000000000000000000000000000000000000000000
d00001100d0000000dd000000000000000310011003100110d0000000000000000d00000000000000d0000000000000000d00000000000000000000000000000
31000110d0000110d00001100000000005d1001105d1001133000000000000000d0000000000000033100000000000000d000000000000000000000000000000
0d11110031111110311111100d000110505d1110000d111033100000000000013310000000000000331131000000000033100013113000000dd0000000011310
001d1d000d1d1d0001d1d1d0d3d1d1100000d1d00050d1d001113113113113113311311311311310001131131131131033113113113113103311311311311311
00000000000000000000000000000000000000000000000000513113113113500011311311311311050500131131131100113105050113113311311311350505
00000000000000000000000000000000000000000000000005005050505050000050505050505050000000505050505000505000000050500050505050500000
00000000000000000000000000000000ffffffffffffffffffffffffffffffff1dd11111dd1111dd1133311111333311ffffffffffffffffffffffffffffffff
00488000004800800040088000000000ffff6fffffff6ffffffffffffffffdff1511151111121211133831111b333b31ffffffffffffffffffffffffffffffff
00488880004888800048888000000000fffffffffffff5ffff2fffffffffd6df11545111115141513bfbfb1133bbbf33ffffffffffffffffffffffffffffffff
00488880004888800048888000000000f6fffffff6f5fffff292fffffffffd3f111411111115451133bbb33333bbbb83ffffffffffffffffffffafffffffffff
00400880004088000048800000000000ffffff6ffffff5fff32fffffffffff3f115451111111411133bbb33333bbbf33ffafffffff7fffffffffffffffffffff
00400000004000000040000000000000ffffffffff5fff6ff3ffffffffafffff151415111115451133bbb3333b333b11ffffffffffffffffffffffffffffffff
01410000014100000141000000000000fff6fffffff6ffffffffafffffffffff11212111115111511b333b3113333111ffffffffffffffffffffffff7fffffff
01110000011100000111000000000000ffffffffffffffffffffffffffffffffdd1111dd11111dd11133331111333111ffffffffffffffffffffffffffffffff
fff88fffffffff8fffffffffffffbbbfffffffffffffffffffffffffffffffffffffffffffffffff1111d111111d1111ffffffffffffffffffffffffffffffff
f887888ff8fff888f33fff33fffbb3bfff444fffffff44fffffffffffffffff6776fff766fffffff1dd1111111111dd1ffffffffffffffffffffffffffffffff
87887878888ff888f3bff3bbffbb3bbfff444ffff4f4444ffffffffffffff7666cc666cc667fffff1111111cc1111111fffffffffffffff7ffffffffffffffaf
88788788888f8fdfffbbfbffffb3bbbff4494fffff44454fffffffffffff67cccccccccccc76ffff1111cccccccc1111fffff7ffffffffffffffffffffffffff
fff77ffffdf888dffffbbbffffbbbbffff544ffff444544fffaffffffff76ccccc6cc6ccccc67fff111cccccccccc111fffffffffffffffffffffaffffffffff
ff7777fffdd888dfffffbffffffbbfffff9444ff499544fffffffffffff6cccc6ccc6ccccccc6fff1d1cccccccccc1d1ffffffffffffffffffffffffffffffff
fff77fffffdfdfdfffffbffffffbffffff5444ff49944fffffffffffff66cccc7cccc11ccccc66ff111ccc6666ccc111ffffffffffffffffffffffffffffffff
fff77fffffffdfffffffbffffffbffffff445ffff444fffffffffffff6c7ccc1111111111ccc7c6f11ccc667766ccc11fffffffffffffaffffffffffffffffff
fff88ffffffffffffffffffffffffbfffffffffffffffffffffffffff66ccc111111111111ccc66f11ccc667766ccc11ffffffffffffffffffffffffffffffff
f887888ff8fff88fffffffffffffb3fffff4fffffffff4fffffffffff6ccc6111dd11111116ccc6f111ccc6666ccc111fffffffffffffffffffffffff7ffffff
ff8878f8f88ff888f3bfff3fffff3bbffff44ffffff4f44fff8184fff7cccc111166111111cccc7f1d1cccccccccc1d1ffffffffffffffffffffffffffffffff
f8788fff888f8fdffffbfbffffb3fbffff494fffff44454ff288558ff6c6cc111111111111cc6c6f111cccccccccc111ffffffffffffffffff7fffffffffffff
fff77ffffdff88dffffbbbffffbbbbffff544fffff4454fff82518fff66ccc1111111dd111ccc66f1111cccccccc1111fffaffffffffffffffffffffffffffff
ff77ffffffd88fdfffffbffffffbbfffff9444fff495ffffff18818fff6c6cc1111111111cc6c6ff1111111cc1111111ffffffffffffffffffffffffffffffff
fff7ffffffdfdfffffffbffffffbfffffff44fff49944fffffffffffff6cccc111dd11111cccc6ff1dd1111111111dd1fffffffff7ffffffffffffffffffafff
fff77fffffffdfffffffbffffffbfffffffffffff444fffffffffffff76c6c111111111111c6c67f1111d111111d1111ffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffff6c7ccc1111111111ccc7c6fffffff5ffffffff5ffffffffffffffffffffffffffffffff
ffff8ffffffff8ffffffffffffffbfffffffffffffffffffffffffffff66ccccc11cccc7cccc66ff6f555fff6f5555ffffffffffffffffffffffffffffffffff
ff88f8fff8ffff8fffffffffffff3bbffff44ffffff4f4fffffffffffff6ccccccc6ccc6cccc6ffff55555f5f533555fffffffffffffffffffffffffffffffff
f8788ffff88fffdffffffbffffb3fbffff494ffffff4444fff81f8fffff76ccccc6cc6ccccc67ffff555565ff535535ffffffffffffffaffffffffff7fffffff
ffff7ffffdff8ffffffbbfffffffbbfffff44fffff4454fff2885f8fffff67cccccccccccc76fffff565555ff555555ff7ffffffffffffffffffffffffffffff
fff7ffffffd88fdfffffbffffffbfffffff45ffff4944fffff28181ffffff766cc666cc6667ffffff566555ff53555f6ffffffffffffffffffffffffffffffff
fff7ffffffdfdfffffffbffffffbfffffff4ffffff4ffffffffffffffffffff667fff6776fffffffff5555f6ff555fffffffffffffffffffffffffffffffffff
fff77fffffffffffffffbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6ffffff6fffff5fffffffffffffffffffffffffffffffff
0000000000000000080000000bb0000004000000101000000000000000000000000000000000000000000000dd000000000000000088800000000000eeeeeeee
000770000077770088800000bbb0000044000000101000000d000000000000000000000000000000dd600000060000000888000008e88ee000888000eeeeeeee
000770000744447088800000bb00000004000000c1c00000600006600d0000000dd0000000000000005100610510001688e88ee0888e87e0088e8800eeeeeeee
0007700074444447060000000b00000004400000c1c000005100016060000660600006600000000005d100665d1000668e8e87e08e8850000888e8eeeeeeeeee
0007700044444444060000000b00000004000000111000000d16610051166160511661600d000660505d661000d1661088885000885000000505887eeeeeeeee
000000004444444400000000000000000000000000000000001d1d000d1d1d0001d1d1d061d6d1600000d1d005001d10505000005000000000000500eeeeeeee
000770004444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeee
000000004444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeee
00000000000000000005000005000000000000000d0000000000000000000000000000008800550880005555000000005550000000000eeeeeeeeeeeeeeeeeee
00220002202909092050500050500005000500d00d00d220002200000d0000d08e8880000885778800057777500000057750070888800eeeeeeeeeeeeeeeeeee
000020200002999200505555505000005050000d777d00020200000000d00d08888e88000088788500005574750005577f50077000080eeeeeeeeeeeeeeeeeee
000044400404444000055e5e55002222505000075557000444000b0000333308ee888ee5057888500088844775088845f507777788080eeeeeeeeeeeeeeeeeee
440474740444e4e0005055555052622dddd0d0054445044e4e0b000000b33b08ee8e87ee5778884008004845758004845000077088080eeeeeeeeeeeeeeeeeee
4040444004504400005050005052266d5d507d04e4e4040444b0001331333308888887ee0588488408084805758084805000078000080eeeeeeeeeeeeeeeeeee
0505040505050050005005050052222dddd0444044400050b050b01331110005050505000885048858544800508005800000000888800eeeeeeeeeeeeeeeeeee
0000000000000000000500000505050505000505040500000b00000505000000000000008800005880888000000888000000000000000eeeeeeeeeeeeeeeeeee
000b000000000000000000000000000000000000000020002000000000000000000000000800004000440000000800000000000700000eeeeeeeeeeeeeeeeeee
00b3500005000500000000000990990000555000000002020700007070000505050000000880004400444000008880000300000700600eeeeeeeeeeeeeeeeeee
0b33350057505750000000009889889005000500000004440074444700000404040808088888444440004001188888003330006077060eeeeeeeeeeeeeeeeeee
b4444450747074700004000098888890500000500000474747441144000b0044400000000880404400404015551800011311060760700eeeeeeeeeeeeeeeeeee
0411d4000400040000411000988888905d8dbd50004004440441111440b3504140000300080040b0044041d5e5d8000411140007067600000000000000000000
0411d400411111400451140009888900549494500411004004715511473335414004300b000b4bbb444440155518004011104770770000000000000000000000
044444004d111d40455445400098900054949450541140000741551470515044400430000b0044b0044000011100004040404006007000000000000000000000
004440004d404d405454545000090000055555004545440000741144074545444440030000000440004000000000000000000060000700000000000000000000
00000000000005000000050000000000000000d00d00000000000000000000000000000000000000050000005550000000500000005555000000500000555500
000870000500508000505008000000228b00d777d8000000000000000000c0000001c10000000000575000005775000005750000057777500005750005777750
08788780055558880050528880020208880075558880000000000000000c0c00001c0c1000000000577500005677550005755550574755000057775057555575
078888800e5e888880ddd8888804448888805448888800000000000000c000c001c000c100000000577750000565400055757575577440000577775055000055
3437753345555080005d5d68220e4eb080004e4e48000000000000000c00000c1c00000c00000000577775000054440075777775575444005777740054555545
453773345000508000dddd2822044400800004440800000000000000000c0c00001c0c1000000000577550000050445057777775575044400577444054944945
5327724535050080000505080505b05080b050005800000000000000000c0c00001c0c1000000000055750000000050005577750050004450055044554944945
34222253400000000000000000000b00000000000000000000000000000c0c00001c0c1000000000000500000000000000055500000000500000005005555550
00000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000b000000440044000000000000000000000000000000000000000000000060000000000000000000000000
000000000000000000040000000000000000000000b3500004444044400000000000000000000000000000000000000000000000000006000000000000000000
00040000000000000041100000000000000000000b33350040440000400000000000000000000000000006000006000000000000000000000000000000000000
0041100000040000045114000000000000000000b444445040400040400000000000000000000000000000000000000000000005000000000000000000000000
04511400004110004554454000000000000000000411d40040000440400000000000000000000000000050000000050000000060000000500000000000000000
45544540045114005454545005000500000000000411d40044404444000000000000000000000000000000600000000000000000000000000000000000000000
00000000000000000000000004444400000000000444440004400440000000000000000000000000000600000000000000000000000000000000000000000000
00000000000000006000060604111400000000000411d40000000040000000000000006000060060000506000005605000000605000005000000000000000000
00000000000000000744447004444400005050000444440009999990055555500006060000056506005605000000056500006060000000060000000000000000
00744070000000007441144000414000004140000041400099299299552552550005656000505050000056500060600000000000000000000000000000000000
07411400000000004411114400444000004140000044400099299299552552550050555000a00500006060000000000000000000000000000000000000000000
04151140000470004715511400414000004140000041400099d44d9955d44d5500a0aa000aaa0aa000a00a0000a0050000000500000000000000000000000000
04111140004144007415514600414000004040000041400099444499554444550a9aa9a50a99a9950a95a9a5059a59a505a65a65007505000075050000750500
07411400004444000741144000000000000000000000000009999990055555505989989559899895598998955a89a895569a69a5057657600576576005765760
00000000000000000000000000000000000000000000000000000000000000002822282228828822228282822522852255285252565765755657657556576575
000000000000000000000000509030b0505500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000500050000000000550500000007000000000000000000000000000007000000000000000000000000000000000000000000000000000000
00000000000000005750575009999990055555500077000000000000000000000000000007700000000000000000000000000000000000005050500000505050
05000500000000007470747099799799556556550777000000000000000000000000000007770000000000000000000000000000000000004040400000404040
04000400000000000400040097d77d79565665650e770000000000000000000000000000077e0000005000000000000000000000000000000444000b00044400
011111000011100041111140994114995541145500e7000000000000000000000000000007e0000005150000000000000000000000000000041400b350041400
44111440501110504d111d409944449955444455000e00000000000000000000000000000e0000000414000300000000000000000000000004140b3335041400
40404040404040404d404d4009999990055555500000000000000000000000000000000000000000044403313300000000000000000000000444b33133544400
00000000000000003413341334133413341334133413341303033410000506000000000000060060041405111505000000000000000000000414051115041400
434b4043434040b04133413341334133413871334133413343434341000600000006050000050006041455555554050000000000000000000414555555541400
554355b343b300001334133413341334187887841338733411431133000006000005606000006050044454545454440000000505050000000444545454544400
34435343044043b03341334133478841388888813388884134431340000060000050500000a00000044444444444450000000444444005000444444544444500
3b0b40550300b0b4341334133418881334377413341374130334431100a00a0000a0a000000a0a00045444414444440000005441444055000454445154444400
455b3453b0b0044041334133413371334137713341377133411334130099a0000a9aa9000099a900044444111444540005004411144044000444451115445400
454445b3b04b400013341334133473341357753413577534414441330a889000098890000a899000044544111444440004404411144044000445451115444400
05335540030033b03341334133413341335555413355554101031140009200000029000000280000000000000000000000000000000000000000000000000000
__map__
54545454545454555253525352525352525151545454545454555454535353525353555554546c4f4c4d4e4f475252528f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0501080108030b010c050f021001100211021402150215011604170117021802
545454545554545f47525353535253524c4d545455545554545454555352525353545455546c5e5f5c5352535c5353528f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f19011a061b021d021e021f021f0120042203240127052801290229022a022a02
5454515454546e6f6c535253535252525c5d5e55545454555455545455535352545455546c6d4c5758595350505253528f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f2b012b062d05300131033205340435013502350335053602360239013c054102
545455547c7d7e507c5350505352537f6c6d6e6f555454545454557c7d7e7f7c7d7e7f7c7c7d576b686a5953535352548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f4102410141069601000000000000000000000000000000000000000000000000
5454554f4c4d4e4f4c4d52536e4d4c4f7c7d7e7f5f51525253524f4c4d4e4f4c4d4e4f4c4c4d676848686952525554548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f2b1b251a28122b15261029182d192a182b182b172b162a1426152b102a162916
54546e5f5c5d7e5f5c5d5e5f5c5d5e5f5c6c6d6e6f5e5253525e5f5c5d5e5f5c5d5e5f5f5c5d6768685a795f535455558f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f271c5c22112816281728182c182613281428102d0928072f162d182e182c192c
54546e51516d6e6f6c6d6e6f6c6d6e6f6c7c7d7e7f6e6e52526e6f6c6d54545454556f6f6c6d777878796e6f6c5554548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f1a2c0c5c220b2514211c2908201e2a082a1c2b1a231c26172a1a2a1b2b055c22
54557e7f7c7d7e7f517e7f7d7e7f575858597c467e7e7f7c7d7e7f47555454555554547f7c7d7e7f7c7d7e7f7c7d55558f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f1d291b291c5c2208230463630000000000000000000000000000000000000000
5452534f4c4d4e4f4c4e4f4d4e466768686a594d4e4e4f4c4d4e4f525254555154544f4f4c4d4e4f4c4d4e4f4c4d54558f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f2c1c261b29132c1627112a192e1a2b192c192c182c172b1527162c112b172a17
525253525c5d5e5f5c5e5f5d57586b684868695d7b5e5f5c5d5e52535352545555555f5f5c475e5f5c5d5e5f5c5e55548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f281d5d23122917291829192d192714291529112e0a290830172e192f192d1a2d
5253525253526e6f6c6e6f6d676868686868697a6e6e6f6c6d6e535253525254544c6c6d6e6f6c5758594e7f6c5554548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f1b2d0d5d230c2615221d2a09211f2b092b1d2c1b241d27182b1b2b1c2c065d23
5252505252527e7f7c7e7f7d67684b68685a797d7e7e7f7c7d7e5353505253534c6f7c7d7e57586b68695e4f7c5253538f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f1e2a1c2a1d5d2309240563630000000000000000000000000000000000000000
52535352524d4e4f4c4e4f47676868686869474d4e4e4f4c4d4e4752535352524d7f4c4d576b686849696e5f4c5352528f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f2d1d271c2a142d1728122b1a2f1b2c1a2d1a2d192d182c1628172d122c182b18
525253535c5d5e5f5c5e5f7a67685a7878795c5d5e5e5f5c5d5e5f5c5252535c5d4f5c4667684b685a797e6f525253538f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f291e5e24132a182a192a1a2e1a28152a162a122f0b2a0931182f1a301a2e1b2e
526d6e6f6c6d6e6f6c6e6f6d7778797b526f6c6d6e7a6f6c6d6e6f6c6d6e6f6c6d5f6c6d6768685a796f4e7f525352538f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f1c2e0e5e240d2716231e2b0a22202c0a2c1e2d1c251e28192c1c2c1d2d075e24
7c7d5346527d7e7f7c7e7f7d7e7f7c7d7a7f7c7d7e7e7f7c467e7f7c7d7e7f7c7d6f7c7b77787879537f5e4f535253538f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f1f2b1d2b1e5e240a250663630000000000000000000000000000000000000000
4c52575858594e4f4c4d4e4f4c4d4e4f4c4d4e4c464e4f4c4d4e4f7a4d4e4f4c4d7f7f7f7c7d7e4c7c7d7e5f535252538f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f2e1e281d2b152e1829132c1b301c2d1b2e1b2e1a2e192d1729182e132d192c19
505167486869475f5c5d5e5f5c5d5e5f5c5d5e5c5d5e5f5c5d5e5f5c5d5e5f5c5d4f4c4d4e4f4c4d4e4f5e53535353538f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f2a1f5f25142b192b1a2b1b2f1b29162b172b13300c2b0a3219301b311b2f1c2f
515067685a794c4d4e4f4c4d4e4f4c4d4e4f474d4e4f477c7d7e7f7c7d7e527c467e7f7f7c7d6e6f6c6d6e52525053538f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f1d2f0f5f250e2817241f2c0b23212d0b2d1f2e1d261f291a2d1d2d1e2e085f25
7c52777879515c5d5e5f53525352535d5e5f5c5d5e5f7f4f4c6d6e5257585858585858597b4d7e7f7c7d5253525350538f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f202c1e2c1f5f250b260763630000000000000000000000000000000000000000
4c545452524d6c6d6e525252535252527a6f6c6d7a6f4e5f5c467b576b6868685a785b6a596d4e4f4c4d4e53535352528f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
5c5d55535c5d7c7d53525352525253527b7f7c7d7e7f5e6f6c7b576b68684a68694d6768696d5e5f5c5d515f525253528f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
476d6e6f6c6d4c4d525252535253525252534c4d4e4f6e7f7c576b68686848686a586b5a797d6e6f6c6d6e6f6c6d6e6f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
527d7e7f7c7d5c5d50535253525252545454535d5e5f7e4f4c676868684968684b6868696c4d7e7f7c7d7e7f7c507e7f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
5252534f4c4d6c6d6e525252525353535454546d6e6f4e5f52775b686868686868686869535d4e4f4c4d4e4f4c4d4e548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
5353525f5c5d7c7d7e535252535454545454557d7e7f5e5250537778785b685a7878787953535e5f5c5d5e5f5c5d55548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
5252516f6c6d4c4d4e505455545455545454554d4e4f6e7f505253535377787953505253527d6e6f51516e6f6c5554548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
525251547c7d5c5d5e5f5454545454545554545d5e5f7e4e4f4d53525353525353525353534d7e7f7c7d7e7f545554548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
5253555554546c6d6e6f6c545554545554546c4c4d4e4f5e5f5d5e5f53525353525d5e5f5c5d4e4f4c4d4e54555455548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
535454545554557d7e7f7c7d7e467c7d7e7f7c5c575858595d5e5f5c5d5e5f5c5d4f4c4d4e4f5e5455545455545454548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
54555455555454556c6d6e6f6c6d6e6f6c6d6e576b68686a596e6f4c4d4c6e6f4d4c4d4c4d6d545454545554545455548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
5454545454545454547d7e7f7c7d7e7f7c7d5d67686849686a597f5c5d5c7e7f5d5c5d5c5d55555455545454555454548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
