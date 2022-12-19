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
  selt and t()-selt<0.5 then
		selection,selbox={}
		for u in all(units) do
			if intersect(u_rect(u),
				{cx,cy,cx+128,cy+128},0) and
				u.p==1 and u.typ==hoverunit.typ then
				add(selection,u).sel=true
			end
		end
		return
	end


--[[
todo:
- ai
- balancing
	- dmg mult table
	- unit stats (spd,los,hp)
 - costs
- addtl map?
]]

--[[
the following will not be saved:
- unit states
- resource count in resource tiles
- units in production, along w/
  the used resources+pop count
- techs (research, upgrades)
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
