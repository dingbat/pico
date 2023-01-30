credits:
- morgan mcGuire (morgan3d)'s [a*] https://github.com/morgan3d/misc/tree/master/p8pathfinder
- fres/musurca's [fast dist] https://www.lexaloffle.com/bbs/?pid=90968#p
- gruber's ["explosion 18"] https://www.lexaloffle.com/bbs/?pid=64837
- carlc27843's pxaviz https://carlc27843.itch.io/pico-8-source-compression-visualizer
- siege engineers' [aoe2techtree.net]https://aoe2techtree.net/

1; touch
2; handheld
3; desktop

ai:
- easy: ai's units produce 5x slower
- normal: ai's techs take no time
- hard:
	- ai starts with free techs (heal,1 of each repeatable)
	- ai's techs take no time
 - ai's resource tiles start with +20%


	gather after kill:

--				typ.ant and t.typ.lady and
--					gogth(u,t.x8,t.y8)

custom load:
if stat"6"=="map" then
		memcpy(unspl"0x2000,0x8000,0x1000")
	else
		reload()
	end

32x32

unspl"256,256,105,107,19,19,32,32,13.47,13.47"
	--10.5=128/mmwratio+1
rect(unspl"-1,-1,10,10,10")

32x48

	unspl"384,256,105,107,19,12,48,32,21.333,20.21"
	rect(unspl"-1,-1,7,7,10")


32x64

unspl"512,256,105,107,19,9,64,32,28.444,26.947"
	--10.5=128/mmwratio+1
	rect(unspl"-1,-1,5,5,10")


selx,sely,selt=mx,my,t()

	if btnp(l) and hoverunit and
  selt and t()-selt<0.2 then
		selection,selx={}
		for u in all(units) do
			if u.onscr and
				u.typ==hoverunit.typ then
				add(selection,u).sel=true
			end
		end
		return
	end

--[[
the following will not be saved:
- unit states
- resource count in resource tiles
- units in production, along w/
  the used resources+pop count
- top-left tree will regrow :-)
]]

acct={}
times={}
function flush_time(str,f)
	if acct[str] and (not f or fps%f==0) then
		printh(str..": "..acct[str],"log")
	end
	acct[str]=0
end
function time(str,run_at_fps)
	local s=stat(1)
	if times[str] then
	 local prev,f=unpack(times[str])
	 if f==true or not f or fps%f==0 then
			if f==true then
				acct[str]=acct[str] or 0
				acct[str]+=s-prev
			else
				printh(str..": "..(s-prev),"log")
			end
		end
		times[str]=nil
	else
		times[str]={s,run_at_fps}
	end
end


function draw_dmap(res_typ)
 if (not dmaps) return
	local dmap=dmaps[res_typ]
 if (not dmap) return
 for x=0,16 do
		for y=0,16 do
			local n=g(dmap,x+flr(cx/8),y+flr(cy/8))
			print(n==0 and "+" or n or "",
				x*8+2,y*8+2,14)
	 end
	end
end
draw=_draw
_draw=function()
	draw()
	camera()
	draw_dmap("r")
end


	if u.sel and u.typ.range then
		circ(u.x,u.y,u.typ.los,13)
		circ(u.x,u.y,u.typ.range,8)
	end
	pset(u.x,u.y,13)
	if u.st.wayp then
		for wp in all(u.st.wayp) do
			pset(wp[1],wp[2],acc(wp[1]/8,wp[2]/8) and 12 or 8)
		end
	end




	 	foreach_spl(
[[-1,-1,0,-1,7
-256,0,-1,7,-1
256,0,8,7,8
1,8,0,8,7]],function(di,...)
 		if (arr[i+di]) line(...)
 	end
 	)

last=0
update()
local mem=stat"0"
	if fps==0 then
		printh(mem.." ("..mem-last..")","log")
		last=mem
	end


if fps==0 then
			printh("offsqd: \0","log")
			for u in all(offsqd) do
				printh(u.typ.atk_typ..", \0","log")
			end
			printh("\ndefsqd: \0","log")
			for u in all(defsqd) do
				printh(u.typ.atk_typ..", \0","log")
			end
			printh("","log")
		end


ai_init()

		for y=0,31 do
		memcpy(
			0x2060+y*128,
			0x2010+y*128,
			32)
	end
	mset(121,23,8)
	mset(122,23,9)
	foreach(bo,function(bi)
		local _,t,x,y=unpack(bi)
		local typ=ant.prod[t].typ
		local sx,sy=typ.rest_x,typ.rest_y
		local tile=sy\8*16+sx\8
		function set(x,y,tile)
			if fget(mget(x,y),0) then
				assert(false,x..","..y)
			end
			mset(x,y,tile)
		end
		set(x,y,tile)
		if typ.w>8 then
			set(x+1,y,tile+1)
			if typ.h>8 then
				set(x+1,y+1,tile+17)
			end
		end
		if typ.h>8 then
			set(x,y+1,tile+16)
		end
	end)
	cstore(0x2000,0x2000,4096)



		 		printh(
	 			"b="..tostr(b).." boi="..
	 			tostr(u.boi)
	 		,"log")


--gives 0.2 cpu
	 if (arr[i-1]) line(unspl"-1,0,-1,7")
	 if (arr[i-256]) line(unspl"0,-1,7,-1")
	 if (arr[i+256]) line(unspl"0,8,7,8")
		if (arr[i+1]) line(unspl"8,0,8,7")

local borderline={
	"8,0,8,7",
	[-1]="-1,0,-1,7",
	[-256]="0,-1,7,-1",
	[256]="0,8,7,8"
}

function borders(arr,i,col)
 	for k,v in next,borderline do
 		color(col)
 		if (arr[i+k]) line(unspl(v))
 	end
end


function nohold(p)
	function x(k)
		return p[k]==0 or
			res2[k]-p[k]>=uhold[k] and
	end
	return not uhold or
		x"r" and x"g" and x"b"

	for k in all(split"r,g,b") do
		if uhold and p[k]!=0 and
			res2[k]-p[k]<uhold[k] then
			return
		end
	end
	return true

	return not uhold or
	 (p.r==0 or res2.r-p.r>=uhold.r) and
	 (p.g==0 or res2.g-p.g>=uhold.g) and
	 (p.b==0 or res2.b-p.b>=uhold.b)
end

\*6 


	--autosave
	if time()%15<1 and fps==0 then
		save()
	end

ai_diff,
	mapw,maph,mmx,mmy,mmw,
	mmh, --maph\mmwratio
	mapw8,maph8,
	mmhratio, --maph/mmh
	mmwratio, --mapw/mmw
	menu,cx,cy,cvx,cvy

--stopwatches
	--right aligned
	?"\^:00702070c8a88870"

	--left aligned
	?"\^:000e040e1915110e"

-- more clockly clock (right)
?"\^:107c8292b282827c"

-- more clockly clock (left)
?"\^:083e41495941413e"

?"\^:00083e414959413e"

negg/pear
?"\^:380c12255149413e"

function been(k,dt)
	local x=bt[k] or 0
	local y=t()-x>=(dt or 0)
	if (y) bt[k]=t()
	return y
end




				88-i%5*12,
				106+i\5*11,

startpos:
	--x*8+7,y*8+4 -64
	
--7=128/mmwratio+1

dirty token savers
============
x remove `.."_vs_"..` (2 tok)
- organic endscreen (6 tok)
(2 tok) pal(14,0) => 	pspl"1,2,3,4,5,6,7,8,9,10,11,12,13,0"
- revert 0532b54 (... hack, 2 tokens)
- revert c02cd41 (hbld renew farm, pal on farm, 11 tok)
  (hbld is extreme luxury, only matters if new ant is assigned to farm, 6 tok)
- revert bf60644 (lady wandering, 25 tok)
x remove sfx from save (2 tok)
x 9c01935 hbanner toggle (8 tok)
x inline ai_dmg() in dmg() (7 tok)
- inline a bunch of other functions (~5-7 each)
x remove make_dmap argument (priotize resource) (5 tok)
- revert 0121c42bc52f8534e216baf94951f20601295fe0 parse trick in a* (6 tok)
- remove aoe hilite effect (15 tok)
x a8c9657 add `id=0` to cat (2 tok)
- (2 tok) put d<0.5 in norm
x (5 tok) inline new() in init()
x (4 tok) 7ded44f - make p3 color black
- (7 tok but +1.04%) arrs (see below)
- (2 tok but .07%) r.npl,r.diff=unspl(split"2:1,2:2,2:3,3:2,3:3"[ai_diff+1],":"))
x (10 tok) conv pop, very unncessary: res[e.p].p-=1 / res[u.p].p+=1
- (1 tok) los var (=typ.loc) in tick()
- (4 tok) parseify adding proj
- (6 tok) remove constants
x hunt

\)([^}|),\].<>\s/\-*%+=^\[\\!])
) $1

^\s+|\s+$

--[[
for source w/whitespace,
see /bbs/1230431

credits:
fast dist - musurca
a* - morgan3d
]]

clip(x+3,0,sec-6,128)
		sspr(unspl"10,64,2,2,0,104,128,2")
		clip()

memset(0x5f01,1,15)=memset(unspl"24321,1,15")


function arrs(v,...)
	_𝘦𝘯𝘷[v]={},... and ars(...)
end
arrs(split"avail,nxtres,miners")
arrs(split"dq,dmaps,exp,vcache,units,restiles,sel,ladys,proj,bldgs,new_viz,typs,ais")

builders keep building (bldrepair):
else
		g.rest(u)
	g.surr(function(_𝘦𝘯𝘷)
			local b=g.bldgs[k]
			if b and b.hu and b.const then
				g.bld(u,b)
			end
		end,x8,y8,4)



sfx/music toggle (47) (45 if combine assignment and smd is unspl'd)

--	_sfx,_music,sm,
--	sfx,music,--add 3 to unspl


sm,_sfx,_music=3,sfx,music
function snd()
	_music"-1"
	sm%=3
	sm+=1
	sfx,music=
		pack(_sfx,max,_sfx)[sm],
		pack(_music,_music,max)[sm]
	music"1"
	menuitem(5,
		split"♪ music+sfx,♪ music only,♪ sfx only"[sm],
		snd)
end
snd()

worse (61)

_music,_sfx=music,sfx
function stog(m,o)
	local fn=split"music,sfx"[m]
 menuitem(3+m,
 	"♪ "..fn..
 	split" on, off"[o],
 	function()
 		_𝘦𝘯𝘷[fn]=pack(_𝘦𝘯𝘷["_"..fn],max)[o]
 		stog(m,o%2+1)
 end)
end
stog(1,1)
stog(2,1)



====
res collection
easy: gr=/1.5
med: /1.5
hard: /1


- larger map
- new unit prices, better stat balancing
- praying mantis monk
- ants can attack
- wild ladybug, can be eaten for food
- random start pos
- new upgrades, some are repeatable
- idle worker/military building
- double click
- click on unit pic to deselect it, right click to select only it
- alert when being attacked offscreen

typ=wayp
x=target


agg (1)
res (2) [tx,ty]
farm (1)


for k,r in inext,res do
		r.pos,r.diff=
			del(posidx,rnd(posidx)),
			ai_diff+1
	end	

	alt menu pal
	pspl"0,5,3,13,13,13,6,2,6,5,13,13,1,0,5"


+               sspr(x,unspl"0,16,8,25,12,32,16")
+               sspr(x,unspl"0,16,8,74,12,32,16,1")
                pspl"1,0,3,4,4,6,7,8,9,10,11,12,13,14,15"
+               sspr(x,unspl"0,16,8,25,11,32,16")
                pspl"2"
+               sspr(x,unspl"0,16,8,74,11,32,16,1")
+               
+               ?"\^j58\-j\f0\^w\^tage of ants\^j58\|f\-i\f7age of ants\^-w\^-t\^jcg\-h\f0◀\-z\-p▶\^jad\|h\f0ai difficulty:\^jad\f6ai difficulty:\^jcn\-h\f0◀\-z\-p▶\^jck\-h\|h\f0ai count:\^jck\-h\f6ai count:\^j7q\f9\#0 press ❎ to start \^-#\^j2t\|h\f0EEOOTY\^j2t\f6EEOOTY\^jqt\f0V1.0\-0\|f\f6V1.0\0"
+               ?"\^jcg\-h\|f\fa◀\-z\-p▶"
+               ?"\^jcn\-h\|f\f6◀\-z\-p▶\^jeg\-j\0"