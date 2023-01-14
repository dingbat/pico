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
-	(const or "")..",".. to tostr(const) (1tok, ugly [nil]s in save)
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
- new unit prices, better balancing
- praying mantis monk
- wild ladybug, can be eaten for food
- random start pos
- new upgrades, some are repeatable
- idle worker/military building
- double click
- click on unit pic to deselect it, right click to select only it
- alert when being attacked offscreen