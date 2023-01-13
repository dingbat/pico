pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
mapw=48
maph=32

function _init()
	cls()
	flip()
-- reset_to_rts()

	prep_for_chain()
--	chain()

--	printa(pos1)
--	render(pos1)
--	write_bo_to_rts()
 write_self()
--	write_map_to_rts()
end

function reset_to_rts()
	print("loading from rts")
	reload(0x2000,0x2000,0x1000,
		"rts.p8")
end

function chain()
	memcpy(0x8000,0x2000,0x1000)
	load("rts.p8",nil,"custom")
end

function render(a)
	--renders over some fog area
	--and bo area to not
	--clobber the map.
	--first copy map over
	for y=0,31 do
		memcpy(
			0x2050+y*128,
			0x2000+y*128,
			48)
	end
	
	local units={
		{194,1,1}, --1: mound
		{242,1,1}, --2: farm
		{226,1,1}, --3: barracks
		{210,1,1}, --4: den
		{197,1,2}, --5: tower
		{238,2,2}, --6: castle
	}
	for i,pos in inext,a do
		local x,y=unpack(pos)
		local _,b=unpack(bo[i])
		if b==10 then
			mset(x+80,y,140)
		elseif x<64 and y<64 and
			x>0 and y>0 then
			x+=mapw+32
			local s,w,h=unpack(units[b])
			mset(x,y,s)
			if w==2 then
				mset(x+1,y,s+1)
				if h==2 then
					mset(x+1,y+1,s+17)
				end
			end
			if h==2 then
				mset(x,y+1,s+16)
			end
		end
	end
	write_self()
end

function prep_for_chain()
	local data={
		bo,pos1,pos2,pos3,pos4
	}
	
	for y=0,31 do
		--clear out bo section
		memset(0x2060+y*128,0,32)
		--fill fog
		memset(0x2030+y*128,67,48)
	end
	
	for i,a in inext,data do
		i-=1
		encode(a,0x2060+i*128*5)
	end
end

function write_self()
	--write to own cart
	cstore()
	print("wrote to own cart")
end

function write_bo_to_rts()
	for y=0,31 do
		cstore(
			0x2060+y*128,
			0x2060+y*128,
			32,
			"rts.p8")
	end
	
	print("wrote bo to rts.p8 map")
end

function write_map_to_rts()
	for y=0,31 do
		cstore(
			0x2000+y*128,
			0x2000+y*128,
			48,
			"rts.p8")
	end
	
	print("wrote map to rts.p8")
end

function encode(a,o)
	for i,v in inext,a do
		i-=1
		i*=2
		local off=o+i%32+i\32*128
		poke(off,v[1],v[2])
	end
end

function loada(str)
	local a={}
	foreach(split(str,"\n"),
		function(l)
			local v=split(l)
			if (v[1]!="") add(a,v)
		end
	)
	return a
end

l2n={
	m=1,
	f=2,
	b=3,
	d=4,
	t=5,
	c=6,
}
function loadbo(str)
	local a=loada(str)
	foreach(a,
		function(p)
			if l2n[p[2]] then
				--convert letter to num
				p[2]=l2n[p[2]]
			else
				--tech
				p[2]=deli(split(p[2],"_"))
			end
		end
	)
	return a
end

function loadp(str)
	local a=loada(str)
	foreach(a,
		function(p)
			--remove letter
			deli(p,1)
			--tech
			if (#p==0) p[1],p[2]=0,0
		end
	)
	return a
end

function printa(a)
	local str=""
	for i,v in inext,a do
		local x,y=unpack(v)
--		local bld=bo[i][2]
--		local val=("mfbdtc")[bld]
--		str..=val..","..x..","..y.."\n"
		str..=x..","..y.."\n"
	end
	printh(str,"@clip")
end
-->8
bo=loadbo[[
4,b_98
4,b_98
4,b_98
4,g_103
4,g_103
4,g_103
4,lady_10
4,lady_10
4,lady_10
4,lady_10
4,lady_10
2,tech_basket_15
3,tech_basket_15
2,tech_archer_range_19
3,tech_heal_22
3,tech_warant_20
3,tech_archer_21
3,tech_beetle_16
3,tech_spider_17
2,tech_farm_18
3,tech_farm_18
1,tech_bldg_range_23
3,tech_bldg_range_23
5,m
8,m
8,b
11,m
12,t
15,f
16,m
16,f
16,f
16,f
16,f
21,m
22,d
23,m
23,f
24,f
25,m
26,c
27,f
29,f
30,f
31,f
31,m
2,tech_warant_21
2,tech_archer_22
32,d
34,b
36,m
39,t
40,m
41,f
41,f
42,f
42,f
43,m
43,c
2,tech_heal_23
2,tech_beetle_17
2,tech_spider_18
45,t
48,m
49,b
50,t
52,d
53,m
53,f
53,b
53,t
54,f
54,f
57,m
60,t
65,f
65,f
65,m
65,c
150,m
]]
-->8
pos1=loadp[[
b_pos,43,26
b_pos,44,8
b_pos,35,8
g_pos,43,26
g_pos,44,8
g_pos,35,8
lady,8,18
lady,21,17
lady,11,30
lady,31,4
lady,17,2
tech_basket_15
tech_basket_15
tech_archer_range_20
tech_heal_23
tech_warant_21
tech_archer_22
tech_beetle_17
tech_spider_18
tech_farm_19
tech_farm_19
tech_bldg_range_24
tech_bldg_range_24
m,43,27
m,37,26
b,40,18
m,43,21
t,38,16
f,41,24
m,45,25
f,42,24
f,43,24
f,43,23
f,43,22
m,42,20
d,38,21
m,43,16
f,42,22
f,41,22
m,39,28
c,34,17
f,40,22
f,40,23
f,40,24
f,44,24
m,38,19
tech_warant_21
tech_archer_22
d,40,20
b,40,16
m,45,9
t,40,7
m,47,22
f,45,24
f,46,24
f,44,25
f,44,26
m,44,12
c,34,11
tech_heal_23
tech_beetle_17
tech_spider_18
t,37,20
m,33,28
b,41,8
t,32,30
d,42,8
m,42,28
f,43,26
b,35,28
t,38,23
f,42,26
f,42,27
m,43,5
t,34,29
f,41,27
f,41,28
m,34,8
c,35,4
m,64,64
]]
-->8
pos2=loadp[[
b_pos,43,26
b_pos,44,8
b_pos,35,8
g_pos,43,26
g_pos,44,8
g_pos,35,8
lady,8,18
lady,21,17
lady,11,30
lady,31,4
lady,17,2
tech_basket_15
tech_basket_15
tech_archer_range_20
tech_heal_23
tech_warant_21
tech_archer_22
tech_beetle_17
tech_spider_18
tech_farm_19
tech_farm_19
tech_bldg_range_24
tech_bldg_range_24
m,43,27
m,37,26
b,40,18
m,43,21
t,38,16
f,41,24
m,45,25
f,42,24
f,43,24
f,43,23
f,43,22
m,42,20
d,38,21
m,43,16
f,42,22
f,41,22
m,39,28
c,34,17
f,40,22
f,40,23
f,40,24
f,44,24
m,38,19
tech_warant_21
tech_archer_22
d,40,20
b,40,16
m,45,9
t,40,7
m,47,22
f,45,24
f,46,24
f,44,25
f,44,26
m,44,12
c,34,11
tech_heal_23
tech_beetle_17
tech_spider_18
t,37,20
m,33,28
b,41,8
t,32,30
d,42,8
m,42,28
f,43,26
b,35,28
t,38,23
f,42,26
f,42,27
m,43,5
t,34,29
f,41,27
f,41,28
m,34,8
c,35,4
m,64,64
]]
-->8
pos3=loadp[[
b_pos,43,26
b_pos,44,8
b_pos,35,8
g_pos,43,26
g_pos,44,8
g_pos,35,8
lady,8,18
lady,21,17
lady,11,30
lady,31,4
lady,17,2
tech_basket_15
tech_basket_15
tech_archer_range_20
tech_heal_23
tech_warant_21
tech_archer_22
tech_beetle_17
tech_spider_18
tech_farm_19
tech_farm_19
tech_bldg_range_24
tech_bldg_range_24
m,43,27
m,37,26
b,40,18
m,43,21
t,38,16
f,41,24
m,45,25
f,42,24
f,43,24
f,43,23
f,43,22
m,42,20
d,38,21
m,43,16
f,42,22
f,41,22
m,39,28
c,34,17
f,40,22
f,40,23
f,40,24
f,44,24
m,38,19
tech_warant_21
tech_archer_22
d,40,20
b,40,16
m,45,9
t,40,7
m,47,22
f,45,24
f,46,24
f,44,25
f,44,26
m,44,12
c,34,11
tech_heal_23
tech_beetle_17
tech_spider_18
t,37,20
m,33,28
b,41,8
t,32,30
d,42,8
m,42,28
f,43,26
b,35,28
t,38,23
f,42,26
f,42,27
m,43,5
t,34,29
f,41,27
f,41,28
m,34,8
c,35,4
m,64,64
]]
-->8
pos4=loadp[[
b_pos,43,26
b_pos,44,8
b_pos,35,8
g_pos,43,26
g_pos,44,8
g_pos,35,8
lady,8,18
lady,21,17
lady,11,30
lady,31,4
lady,17,2
tech_basket_15
tech_basket_15
tech_archer_range_20
tech_heal_23
tech_warant_21
tech_archer_22
tech_beetle_17
tech_spider_18
tech_farm_19
tech_farm_19
tech_bldg_range_24
tech_bldg_range_24
m,43,27
m,37,26
b,40,18
m,43,21
t,38,16
f,41,24
m,45,25
f,42,24
f,43,24
f,43,23
f,43,22
m,42,20
d,38,21
m,43,16
f,42,22
f,41,22
m,39,28
c,34,17
f,40,22
f,40,23
f,40,24
f,44,24
m,38,19
tech_warant_21
tech_archer_22
d,40,20
b,40,16
m,45,9
t,40,7
m,47,22
f,45,24
f,46,24
f,44,25
f,44,26
m,44,12
c,34,11
tech_heal_23
tech_beetle_17
tech_spider_18
t,37,20
m,33,28
b,41,8
t,32,30
d,42,8
m,42,28
f,43,26
b,35,28
t,38,23
f,42,26
f,42,27
m,43,5
t,34,29
f,41,27
f,41,28
m,34,8
c,35,4
m,64,64
]]
-->8
--old ideas

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

function des(s)
	local a={}
	foreach(split(s,2),function(b)
		add(a,pack(ord(b,1,2)))
	end)
	return a
end
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
000000000000000000000000eeeeeeeeffffffffffffffffffffffffffffffff1dd11111dd1111dd1133311111333311ffffffffffffffffffffffffffffffff
004880000048008000400880eeeeeeeeffff6fffffff6ffffffffffffffffdff1511151111121211133831111b333b31ffffffffffffffffffffffffffffffff
004888800048888000488880eeeeeeeefffffffffffff5ffff2fffffffffd6df11545111115141513bfbfb1133bbbf33ffffffffffffffffffffffffffffffff
004888800048888000488880eeeeeeeef6fffffff6f5fffff292fffffffffd3f111411111115451133bbb33333bbbb83ffffffffffffffffffffafffffffffff
004008800040880000488000eeeeeeeeffffff6ffffff5fff32fffffffffff3f115451111111411133bbb33333bbbf33ffafffffff7fffffffffffffffffffff
004000000040000000400000eeeeeeeeffffffffff5fff6ff3ffffffffafffff151415111115451133bbb3333b333b11ffffffffffffffffffffffffffffffff
014100000141000001410000eeeeeeeefff6fffffff6ffffffffafffffffffff11212111115111511b333b3113333111ffffffffffffffffffffffff7fffffff
011100000111000001110000eeeeeeeeffffffffffffffffffffffffffffffffdd1111dd11111dd11133331111333111ffffffffffffffffffffffffffffffff
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
0000000000000000080000000bb0000004000000101000000000000000000000000000000000000000000000dd000000ffffffff008880000000000000000000
000770000077770088800000bbb0000044000000101000000d000000000000000000000000000000dd60000006000000f888ffff08e88ee00088800000000000
000770000744447088800000bb00000004000000c1c00000600006600d0000000dd000000000000000510061051000168818811f888e87e0088e880000000000
0007700074444447060000000b00000004400000c1c000005100016060000660600006600000000005d100665d1000668181871f8e8850000888e8ee00000000
0007700044444444060000000b00000004000000111000000d16610051166160511661600d000660505d661000d1661088885fff885000000505887e00000000
000000004444444400000000000000000000000000000000001d1d000d1d1d0001d1d1d061d6d1600000d1d005001d105f5fffff500000000000050000000000
000770004444444400000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffff000000000000000000000000
000000004444444400000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffff000000000000000000000000
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
0000000000000000ffffffff0000000000000000fff0ffff00400000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000fff0ffff0000000000000000ff0b0fff00440044000000000000000000000000000000000000000000000060000000000000000000000000
0000000000000000ff040fff0000000000000000f0b350ff04444044400000000000000000000000000000000000000000000000000006000000000000000000
0004000000000000f04220ff00000000000000000b33350f40440000400000000000000000000000000006000006000000000000000000000000000000000000
00411000000400000452240f0000000000000000b444445040400040400000000000000000000000000000000000000000000005000000000000000000000000
04511400004110000554454000000000000000000422d40f40000440400000000000000000000000000050000000050000000060000000500000000000000000
45544540045114000454545005000500000000000422d40f44404444000000000000000000000000000000600000000000000000000000000000000000000000
00000000000000000000000004444400000000000444440f04400440000000000000000000000000000600000000000000000000000000000000000000000000
0000000000000000f000000f04222400000000000422d40f00000040000000000000006000060060000506000005605000000605000005000000000000000000
00000000000000000044440004444400005050000444440f00000000055555500006060000056506005605000000056500006060000000060000000000000000
00744070000000000442244000424000004140000042400f00200200552552550005656000505050000056500060600000000000000000000000000000000000
0741140000000000442222440044400000414000f04440ff00200200552552550050555000a00500006060000000000000000000000000000000000000000000
0415114000047000472552240042400000414000f04240ff00d44d0055d44d5500a0aa000aaa0aa000a00a0000a0050000000500000000000000000000000000
0411114000414400742552460042400000404000f04240ff00444400554444550a9aa9a50a99a9950a95a9a5059a59a505a65a65007505000075050000750500
0741140000444400074224400000000000000000f00000ff00000000055555505989989559899895598998955a89a895569a69a5057657600576576005765760
0000000000000000f000000f0000000000000000ffffffff00000000000000002822282228828822228282822522852255285252565765755657657556576575
0000000000000000f0fff0ff500030b050550000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffff
0000000000000000050f050f00000000550500000007000000000000000000000000000007000000000000000000000000000000000000000f0f0fffff0f0f0f
0000000000000000575057500000000005555550007700000000000000000000000000000770000000000000000000000000000000000000505050fff0505050
0500050000000000747074700070070055655655077700000000000000000000000000000777000000000000000000000000000000000000404040f0f0404040
04000400000000000400040f07d77d70565665650e770000000000000000000000000000077e00000050000000000000000000000000000004440f0b0f04440f
011111000011100042222240004114005541145500e7000000000000000000000000000007e0000005150000000000000000000000000000042400b35004240f
44111440501110504d222d400044440055444455000e00000000000000000000000000000e0000000414000300000000000000000000000004240b333504240f
40404040404040404d404d4000000000055555500000000000000000000000000000000000000000044403313300000000000000000000000444b3323354440f
0000000000000000045334533413341334133413341334130303341000050600000000000006006004140511150500000000000000000000042405222504240f
434b4043434040b0053345334133413341387133413341334343434100060000000605000005000604145555555405000000000000000000042455555554240f
554355b343b30000033453341334133418788784133873341143113300000600000560600000605004445454545444000000050505000000044454545454440f
34435343044043b00345334533478841388888813388884134431340000060000050500000a0000004444444444445000000044444400500044444454444450f
3b0b40550300b0b4045334533418881334377413341374130334431100a00a0000a0a000000a0a0004544441444444000000544144405500045444525444440f
455b3453b0b0044005334533413371334137713341377133411334130099a0000a9aa9000099a90004444411144454000500441114404400044445222544540f
454445b3b04b400003345334133473341357753413577534414441330a889000098890000a89900004454411144444000440441114404400044545222544440f
05335540030033b0000000003341334133555541335555410103114000920000002900000028000000000000000000000000000000000000000000000000000f
__map__
54545454545454555253525352525352525151545454545454555454535353525353555554546c4f4c4d4e4f47525252434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343046204620462046704670467040a040a040a040a040a020f030f021303160314
545454545554545f47525353535253524c4d545455545554545454555352525353545455546c5e5f5c5352535c53535243434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434303150310031102120312011703170501080108030b010c050f02100110021002
5454515454546e6f6c535050535252525c5d5e55545454555455545455535352545455546c6d4c575859535050525352434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343100210021501160417011702180219011a061b021d021e021f021f0102150216
545455547c7d7e507c5352525352537f6c6d6e6f555454545454557c7d7e7f7c7d7e7f7c7c7d576b686a59535353525443434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434320042203240127052801290229022a022a022b012b060217021102122d053001
5454554f4c4d4e4f4c4d52536e4d4c4f7c7d7e7f5f51525253524f4c4d4e4f4c4d4e4f4c4c4d67684a6869525255545443434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434331033205340435013502350335053602360239013c0541024102410141069601
54546e5f5c5d7e5f5c5d5e5f5c5d5e5f5c6c6d6e6f5e5253525e5f5c5d5e5f5c5d5e5f5f5c5d6768685a795f535455554343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343432b1a2c0823082b1a2c082308081215110b1e1f04110200000000000000000000
54546e51516d6e6f6c6d6e6f6c6d6e6f6c7c7d7e7f6e6e52526e6f6c6d54545454556f6f6c6d777878796e6f6c55545443434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434300000000000000000000000000002b1b251a28122b15261029182d192a182b18
54557e7f7c7d7e7f517e7f7d7e7f575858597c467e7e7f7c7d7e7f47555454555554547f7c7d7e7f7c7d7e7f7c7d55554343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343432b172b162a1426152b102a162916271c22112816281728182c18261300000000
5452534f4c4d4e4f4c4e4f4d4e466768686a594d4e4e4f4c4d4e4f525254555154544f4f4c4d4e4f4c4d4e4f4c4d5455434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343281428102d0928072f162d182e182c192c1a2c0c220b0000000000002514211c
525253525c5d5e5f5c5e5f5d57586b684868695d7b5e5f5c5d5e52535352545555555f5f5c475e5f5c5d5e5f5c5e55544343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343432908201e2a082a1c2b1a231c26172a1a2a1b2b05221d291b291c220823044040
5253525253526e6f6c6e6f6d676868686868697a6e6e6f6c6d6e535253525254544c6c6d6e6f6c5758594e7f6c5554544343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343432b1a2c0823082b1a2c082308081215110b1e1f04110200000000000000000000
5252505252527e7f7c7e7f7d67684b68685a797d7e7e7f7c7d7e5353505253534c6f7c7d7e57586b68695e4f7c52535343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434300000000000000000000000000002b1b251a28122b15261029182d192a182b18
52535352524d4e4f4c4e4f47676868686869474d4e4e4f4c4d4e4752535352524d7f4c4d576b686849696e5f4c5352524343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343432b172b162a1426152b102a162916271c22112816281728182c18261300000000
525253535c5d5e5f5c5e5f7a67685a7878795c5d5e5e5f5c5d5e5f5c5252535c5d4f5c4667684b685a797e6f52525353434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343281428102d0928072f162d182e182c192c1a2c0c220b0000000000002514211c
526d6e6f6c6d6e6f6c6e6f6d7778797b526f6c6d6e7a6f6c6d6e6f6c6d6e6f6c6d5f6c6d6768685a796f4e7f525352534343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343432908201e2a082a1c2b1a231c26172a1a2a1b2b05221d291b291c220823044040
7c7d5346527d7e7f7c7e7f7d7e7f7c7d7a7f7c7d7e7e7f7c467e7f7c7d7e7f7c7d6f7c7b77787879537f5e4f535253534343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343432b1a2c0823082b1a2c082308081215110b1e1f04110200000000000000000000
4c52575858594e4f4c4d4e4f4c4d4e4f4c4d4e4c464e4f4c4d4e4f7a4d4e4f4c4d7f7f7f7c7d7e4c7c7d7e5f5352525343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434300000000000000000000000000002b1b251a28122b15261029182d192a182b18
505167486869475f5c5d5e5f5c5d5e5f5c5d5e5c5d5e5f5c5d5e5f5c5d5e5f5c5d4f4c4d4e4f4c4d4e4f5e53535353534343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343432b172b162a1426152b102a162916271c22112816281728182c18261300000000
515067685a794c4d4e4f4c4d4e4f4c4d4e4f474d4e4f477c7d7e7f7c7d7e527c467e7f7f7c7d6e6f6c6d6e5252505353434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343281428102d0928072f162d182e182c192c1a2c0c220b0000000000002514211c
7c52777879515c5d5e5f53525352535d5e5f5c5d5e5f7f4f4c6d6e5257585858585858597b4d7e7f7c7d5253525350534343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343432908201e2a082a1c2b1a231c26172a1a2a1b2b05221d291b291c220823044040
4c545452524d6c6d6e525252535252527a6f6c6d7a6f4e5f5c467b576b6868685a785b6a596d4e4f4c4d4e53535352524343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343432b1a2c0823082b1a2c082308081215110b1e1f04110200000000000000000000
5c5d55535c5d7c7d53525352525253527b7f7c7d7e7f5e6f6c7b576b68684a68694d6768696d5e5f5c5d515f5252535243434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434300000000000000000000000000002b1b251a28122b15261029182d192a182b18
476d6e6f6c6d4c4d525252535253525252534c4d4e4f6e7f7c576b68486868686a586b5a797d6e6f6c6d6e6f6c6d6e6f4343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343432b172b162a1426152b102a162916271c22112816281728182c18261300000000
527d7e7f7c7d5c5d50535253525252545454535d5e5f7e4f4c676868684968684b6868696c4d7e7f7c7d7e7f7c507e7f434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343281428102d0928072f162d182e182c192c1a2c0c220b0000000000002514211c
5252534f4c4d6c6d6e525252525353535454546d6e6f4e5f52775b686868686868686869535d4e4f4c4d4e4f4c4d4e544343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343432908201e2a082a1c2b1a231c26172a1a2a1b2b05221d291b291c220823044040
5353525f5c5d7c7d7e535252535454545454557d7e7f5e5250537778785b685a7878787953535e5f5c5d5e5f5c5d55544343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000
5252516f6c6d4c4d4e505455545455545454554d4e4f6e7f505253535377787953505253527d6e6f51516e6f6c5554544343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000
525251547c7d5c5d5e5f5454545454545554545d5e5f7e4e4f4d53525353525353525353534d7e7f7c7d7e7f545554544343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000
5253555554546c6d6e6f6c545554545554546c4c4d4e4f5e5f5d5e5f53525353525d5e5f5c5d4e4f4c4d4e54555455544343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000
535454545554557d7e7f7c7d7e467c7d7e7f7c5c575858595d5e5f5c5d5e5f5c5d4f4c4d4e4f5e5455545455545454544343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000
54555455555454556c6d6e6f6c6d6e6f6c6d6e576b68686a596e6f4c4d4c6e6f4d4c4d4c4d6d545454545554545455544343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000
5454545454545454547d7e7f7c7d7e7f7c7d5d67686849686a597f5c5d5c7e7f5d5c5d5c5d55555455545454555454544343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000
