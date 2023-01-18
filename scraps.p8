credits:
- a*
- dist
- sfx pack: "explosion 18", "17 slipways"

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
- remove `.."_vs_"..` (2 tok)
- organic endscreen (6 tok)
x pal(14,0) => 	pspl"1,2,3,4,5,6,7,8,9,10,11,12,13,0"
- revert 0532b54 (... hack, 2 tokens)
- revert c02cd41 (hbld renew farm, pal on farm, 11 tok)
  (hbld is extreme luxury, only matters if new ant is assigned to farm, 6 tok)
- revert bf60644 (lady wandering, 25 tok)
- remove sfx from save (2 tok)
- 9c01935 hbanner toggle (8 tok)
- inline ai_dmg() in dmg() (7 tok)
- inline a bunch of other functions (~5-7 each)
- remove make_dmap argument (priotize resource) (5 tok)
- revert 0121c42bc52f8534e216baf94951f20601295fe0 parse trick in a* (6 tok)
- remove aoe hilite effect (15 tok)
- a8c9657 add `id=0` to cat (2 tok)

memset(0x5f01,1,15)=memset(unspl"24321,1,15")


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

		ms,mms=mms,{}
		foreach(ms,function(s)
			surr(s[1],s[2],function(t)
				del(mms,t)
				add(mms,t)
				mset(t[1]+mapw8,t[2],0)
			end,1,1)
		end)

putting research in bo:

	if pid>6 then
		b.tech(b.techt[2])
	end


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



esdf mouse mode (58 tok):

function cam()
	local b,m=btn()
	if b>32 then
		b>>=8
		m=mm==2
	end
	local dx,dy=(b&0x2)-(b&0x1)*2,
		(b&0x8)/4-(b&0x4)/2
	if m then
		amx+=dx
		amy+=dy
	else
		cx,cy=
			mid(cx+dx,256),
			mid(cy+dy,
				loser and 128 or 149)
		if mm==1 then
			amx,amy=stat"32",stat"33"
		end
	end
	amx,amy=mid(amx,126),
		mid(amy,126)

	mx,my,hovbtn=amx+cx,amy+cy
	mx8,my8=mx\8,my\8
end

mm=2
function mouse_mode()
	mm%=2
	mm+=1
	menuitem(
		4,
		split"● mouse on,● mouse off"[mm],
		mouse_mode
	)
end
mouse_mode()


crazy idea to copy in savefile:
	join(chr(peek(0x2000,0x1000)))

monk upgrade (15 tok)


parse([[
t=30
r=10
g=20
b=0
breq=0
i=6
tmap=1024
up=-1
idx=27]],parse[[
portx=62
porty=88]],function(_𝘦𝘯𝘷)
	spd*=1.25
	hp*=1.2
end,monk),





tostr[[[[]]
ai_debug=true
srand"1"
if ai_debug then
	_update60=_update
	_draw_map,_dr,_pr,_resbar=
		draw_map,_draw,print_res,
		resbar
	function draw_map(o,y)
		if not ai_debug or o==0 then
			_draw_map(o,y)
		end
	end
	function _draw()
		_dr()
		if ai_debug and res1 then
		camera()
		local secs=res1.t\1%60
		?res2.diff,60,107,9
		?(res1.t\60)..(secs>9 and ":" or ":0")..secs,80,121,1
		?bgrat,80,114,3
		?":\-e#\-e:"..(res2.boi/2),80,107,2
		camera()
		end
	end
	function print_res(...)
		if (ai_debug) res1=res2
		local x=_pr(...)
		res1=res[1]
		return x
	end
	function resbar(...)
		if (ai_debug) res1=res2
		_resbar(...)
		res1=res[1]
	end
end
--]]


--	for i,k in inext,resk do
--		i*=2
--		res1[k],res2[k]=r[i-1],r[i]
--	end
--	foreach(typs,function(_𝘦𝘯𝘷)
--		if res1.techs|tmap==res1.techs then
--			tech(techt.p1)
--			up,done=up and 0,not up
--			typ.up=up
--		end
--	end)
--	foreach(data,comp(unit,unspl))

