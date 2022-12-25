pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
--main loop

function _draw()
 draw_map(0,17)
	if menu then
		camera()
		spr(unspl"184,45,75,1,1,1")
		spr(unspl"184,76,75,1,1")

	 local x=64+t()\0.5%2*16
	 pal(split"0,5,0,0,0,0,0,0,0,0,0,0,0,0,0")
	 sspr(x,unspl"0,16,8,25,31,32,16")
	 sspr(x,unspl"0,16,8,72,31,32,16,1")
	 pal(split"1,0,3,4,4,6,7,8,9,10,11,12,13,14,15")
	 sspr(x,unspl"0,16,8,25,30,32,16")
	 pal(1,2)
	 sspr(x,unspl"0,16,8,72,30,32,16,1")

		?"\f0\^w\^tage of ants\-0\-0\-0\-0\-0\-7\|f\f7age of ants\n \^-w\^-t\|l\f0  ai difficulty:\-0\-0\-0\-8\|f\fcai difficulty:\n\n\n\f0  press ❎ to start\-0\-0\-0\-0\-c\|f\f9press ❎ to start\|z\|s\-0\-0\-0\-0\-0\-2\f0\*6 \-0\-8\|f\f6\*6 \|h\*k \-h\f0V0.1\-0\|f\f6V0.1",22,50
		?split"\f0easy\-0\|f\fbeasy,\f0\-cnormal\-0\-8\|f\fanormal,\f0hard\-0\|f\fehard"[ai_diff+1],57,77
		return
	end

 local bf,af,proj_so={},{},
 	fps\5%2*2
 for u in all(units) do
 	if u.onscr or loser then
			if
				not loser and
			 not g(viz,u.x8,u.y8)
			 and u.discovered
			then
	 		add(af,u)
	 	elseif u.typ.bldg then
		 	draw_unit(u)
		 else
		 	add(bf,u)
		 end
		end
 end

	if sel_typ and sel_typ.farm and
		not sel1.const then
	 rectaround(sel1,9)
	end
	
	foreach(bf,draw_unit)
	for _ENV in all(proj) do
		sspr(
			from_typ.proj_s+proj_so,
			112,2,2,x,y
		)
	end
	if loser then
		camera()
		rectfill(unspl"0,96,128,115,9")
		pal(2,0)
	 sspr(64+
	 	pack(48,fps\5%3*16)[loser],
	 	unspl"0,16,8,14,98,32,16")
		?split"\#9\|d\-0\*8 \-0\-4\-e\|h\f7easy ai,\#9\|d\-0\*a \-0\-0\-a\|h\f5normal ai,\#9\|d\-0\*8 \-0\-4\-e\|h\f0hard ai"[res2.diff+1],22,93
	 ?split"\^w\^t\fa\|gdefeat\-d\^x2...\^x4\-0\-0\-0\-7\|f\f1defeat\-d\^x2...,\^w\^t\fa\|gvictory!\-0\-0\-0\-0\|f\f1victory!"[loser],53,102
	 ?"\f4\#9\|k\-0\-4\*j \-0\-0\-0\-e\|d\-0\-a\|ipress ❎ for menu"
	 return
	end
	
 pal(split"0,5,13,13,13,13,6,2,6,6,13,13,13,0,5")
--	draw_map(mapw8,15) --fogmap

	_pal,pal,buttons=pal,max,{}
	foreach(af,draw_unit)
	pal=_pal
	pal()
	
	fillp"23130.5"--▒
	
	for x=cx\8,cx\8+16 do
	for y=cy\8,cy\8+13 do
 	local i=x|y<<8
 	local brd=function(arr,col)
			color(col)
			camera(x*-8+cx,y*-8+cy)		
			if (arr[i-1]) line(unspl"-1,0,-1,7")
		 if (arr[i-256]) line(unspl"0,-1,7,-1")
		 if (arr[i+256]) line(unspl"0,8,7,8")
			if (arr[i+1]) line(unspl"8,0,8,7")
		end
  if not exp[i] then
	 	brd(exp)
		elseif not viz[i] then
	 	brd(viz,
		 	not fget(mget(x,y),7) and 5)
		end
	end
	end
	
	camera(cx,cy)

	if selx then
		rect(unpack(selbox))
	end
	
	fillp()
	
	if sel1 and sel1.rx then
		spr(71+fps\5%3,
			sel1.rx-2,sel1.ry-5)
	end

	if hilite then
		local dt=t()-hilite.t
		if dt>0.5 then
			hilite=nil
		elseif hilite.cx then
			circ(hilite.cx,hilite.cy,
			 min(0.5/dt,4),8)
		elseif dt<=0.1 or dt>=0.25 then
			if hilite.unit then
				rectaround(hilite.unit,8)
			end
		end
	end
	
	draw_menu()
	if to_build then
		camera(cx-to_build.x,
			cy-to_build.y)
		pal(buildable() or
		 split"8,8,8,8,8,8,8,8,8,8,8,8,8,8,8"
		)
		--menuy
		if amy>=104 then
			camera(4-amx,4-amy)
		else
			fillp"23130.5"--▒
			rect(to_build.typ.fw,
				to_build.typ.fh,
				unspl"-1,-1,3")
	 	fillp()
	 end
	 local _ENV=to_build.typ
		sspr(rest_x,rest_y,fw,h)
		pal()
	end
	camera()
	
	if hilite and hilite.circ then
		circ(unpack(hilite.circ))
	end
	
	--cursor
	spr(
	 hovbtn and pset(amx-1,
	  amy+4,5) and 66 or
		sel1 and sel1.p==1 and
		((to_build or
			can_build() or
			can_renew_farm()) and 68 or
		can_gather() and 67 or
		can_attack() and 65 or
		can_drop() and 69) or 64,
	amx,amy)
end

function _update()
	if menu then
		cx+=cvx
		cy+=cvy
		if (cx%256==0) cvx*=-1
		if (cy%127==0) cvy*=-1
 	if btnp"5" then
 		new_game()
 	else
			ai_diff-=btnp()
			ai_diff%=3
		end
		pal(split"1,5,3,13,13,13,6,2,6,5,13,13,13,0,5")
 	return
	end
	
	--autosave
--	if time()%15<1 and fps==0 then
--		save()
--	end
	
	local total=res1.p+res2.p
	upcycle=total>=100 and 30 or
		total>=75 and 15 or
		total>=40 and 10 or 5

	fps+=1
	fps%=60
	upc=fps%upcycle
	
	async_dmap()
	lclk,rclk=llclk and not btn"5",
		lrclk and not btn"4"
 handle_input()
 llclk,lrclk=btn"5",btn"4"
 
 if fps%30==19 then
		for tx=0,mmw do
		for ty=0,mmh do
	 	local x,y=tx*mmwratio\8,
	 		ty*mmhratio\8
	 	sset(72+tx,72+ty,
				g(exp,x,y) and rescol[
					g(viz,x,y,"e")..
					fget(mget(x,y))
				] or 14)
		end
		end
	end
	
 upc_0,pos,hoverunit,
 	idle,idle_mil=
  upc==0,{}
 if loser then
 	poke"24365" --no mouse
 	if lclk then
 		menu,cx,cy=unspl"1,5,35"
 	end
 	return
	end
	
 if upc_0 then
 	viz,new_viz=new_viz,{}
		for k in next,exp do
 		local x,y=k&0x00ff,k\256
 		mset(x+mapw8,y,viz[k] and
	   0 or mget(x,y))
		end
 end
 for p in all(proj) do
 	p.x,p.y,_,d=norm(p.to,p,.8)
  if d<0.5 then
	  if intersect(
	  	del(proj,p).to_unit.r,
	 		{p.x,p.y,p.x,p.y},0
	 	) then
		 	deal_dmg(p.from_typ,p.to_unit)
			end
		end
 end

 if selx then
 	bldg_sel,my_sel,enemy_sel=nil
 end
 
 foreach(units,tick_unit)
 for u in all(units) do
		if (upc_0) ai_unit2(u)	
 	if selx
 		and (g(viz,u.x8,u.y8)
 		 or u.discovered)
 	then
 	 u.sel=intersect(u.r,selbox,0)
		 if u.sel then
				if u.p!=1 then
					enemy_sel={u}
				elseif u.typ.unit then
					my_sel=my_sel or {}
					add(my_sel,u)
				else
					bldg_sel={u}
				end
			end
		end
 	if not (u.const or u.dead) then
		 if upc==u.id%upcycle and
		  u.st.aggress and
		  u.typ.atk
		 then
				aggress(u)
	 	end
	 	if u.st.t=="attack" then
	 		fight(u)
	 	end
	 end
 end

 if selx then
		selection=my_sel or
			bldg_sel or
			enemy_sel or {}
	end
	sel1,numsel,sel_typ=
		selection[1],#selection
	foreachsel(function(s)
		--check nil, can be false
		sel_typ=(sel_typ==nil or
			s.typ==sel_typ) and s.typ
	end)
	
	if upc_0 then
	 ai_frame()
	end
end

-->8
--units/states

function unspl(...)
	return unpack(split(...))
end

function parse(str,typ,tech,t)
	local p2={}
	local obj={{},p2,p2,
		typ=typ,
		tech=tech,
		techt=t or {},
		prod={}}
	for l in all(split(str,"\n")) do
		local k,v=unspl(l,"=")
		if v then
			obj[k],obj[1][k],p2[k]=v,v,v
		end
	end
	add(obj.idx and typs,obj)
	return obj
end

function init_typs()
typs={}
ant=parse[[
idx=1
spd=0.286
los=20
hp=5
def=ant

w=4
fw=4
h=4
xoff_r=16
yoff_g=4
xoff_b=16
yoff_b=4
rest_x=0
rest_y=8
rest_fr=2
rest_fps=30
drop_x=0
drop_y=8
drop_fr=2
drop_fps=30
move_x=8
move_y=8
move_fr=2
move_fps=15
gather_x=8
gather_y=8
gather_fr=2
gather_fps=15
build_x=40
build_y=8
build_fr=2
build_fps=15
harvest_x=32
harvest_y=8
harvest_fr=2
harvest_fps=15
dead_x=40
dead_y=12
portx=0
porty=72
portw=8
dir=1
unit=1
carry=6
ant=1]]
ant1=ant[1]

beetle=parse[[
idx=2
spd=0.19
los=20
hp=30
atk=1
def=seige
atk_typ=seige

w=8
fw=8
h=6
rest_x=8
rest_y=0
rest_fr=2
rest_fps=30
move_x=16
move_y=0
move_fr=2
move_fps=10
attack_x=40
attack_y=0
attack_fr=3
attack_fps=10
dead_x=32
dead_y=0
portx=26
porty=72
portw=9
unit=1
dir=1]]

spider=parse[[
idx=3
spd=0.482
los=30
hp=15
atk=1.667
def=spider
atk_typ=spider

w=8
fw=8
h=5
rest_x=0
rest_y=16
rest_fr=2
rest_fps=30
attack_x=64
attack_y=16
attack_fr=3
attack_fps=10
move_x=8
move_y=16
move_fr=6
move_fps=2
dead_x=56
dead_y=16
portx=16
porty=72
portw=9
unit=1
dir=1]]

archer=parse[[
idx=4
spd=0.343
los=30
hp=5
range=25
atk=0.667
proj_freq=30
atk_typ=acid
def=ant

w=7
fw=8
h=6
rest_x=0
rest_y=25
rest_fr=2
rest_fps=30
move_x=8
move_y=24
move_fr=2
move_fps=10
attack_x=32
attack_y=24
attack_fr=2
attack_fps=10
dead_x=24
dead_y=25
portx=44
porty=72
portw=9
unit=1
dir=1
proj_xo=-2
proj_yo=0
proj_s=28]]

warant=parse[[
idx=5
spd=0.321
los=25
hp=10
atk=1
atk_typ=ant
def=ant

w=8
fw=8
h=6
rest_x=48
rest_y=64
rest_fr=2
rest_fps=30
move_x=56
move_y=64
move_fr=2
move_fps=10
attack_x=80
attack_y=64
attack_fr=2
attack_fps=10
dead_x=72
dead_y=64
portx=35
porty=72
portw=9
unit=1
dir=1]]

cat=parse[[
idx=6
spd=0.2
los=50
hp=15
range=50
atk=1.667
proj_freq=60
atk_typ=seige
def=seige

w=16
fw=16
h=8
rest_x=48
rest_y=24
rest_fr=2
rest_fps=30
move_x=64
move_y=24
move_fr=4
move_fps=8
attack_x=64
attack_y=8
attack_fr=4
attack_fps=15
dead_x=112
dead_y=16
portx=53
porty=72
portw=9
unit=1
dir=1
proj_xo=1
proj_yo=-4
proj_s=32
cat=1]]

queen=parse[[
idx=7
los=20
hp=400
atk=1.5
range=20
proj_freq=30
atk_typ=acid
def=queen

w=16
h=8
fw=16
rest_x=64
rest_y=-1
rest_fr=2
rest_fps=30
attack_x=80
attack_y=-1
attack_fr=2
attack_fps=15
dead_x=112
dead_y=0
dir=-1
portx=8
porty=72
portw=8
has_q=1
drop=1
bldg=1
proj_xo=-4
proj_yo=2
proj_s=28
bitmap=0
units=1
queen=1]]

tower=parse[[
idx=8
los=30
hp=250
range=30
const=32
atk=1.2
proj_freq=30
atk_typ=tower
def=building

w=8
fw=8
h=16
fh=16
rest_x=40
rest_y=96
attack_x=40
attack_y=96
fire=1
dead_x=48
dead_y=96
dead_fr=7
dead_fps=9
portx=0
porty=80
portw=8
bldg=1
dir=-1
proj_yo=-2
proj_xo=-1
proj_s=24
bitmap=1]]

mound=parse[[
idx=9
los=5
hp=100
const=10
def=building

w=8
fw=8
h=8
fh=8
rest_x=16
rest_y=96
portx=35
porty=80
portw=8
fire=1
dead_x=48
dead_y=104
dead_fr=7
dead_fps=9
bldg=1
dir=-1
has_q=1
drop=1
bitmap=2]]

den=parse[[
idx=10
los=10
hp=250
const=25
def=building

w=8
fw=8
h=8
fh=8
rest_x=16
rest_y=104
fire=1
dead_x=48
dead_y=104
dead_fr=7
dead_fps=9
portx=26
porty=80
portw=9
bldg=1
dir=-1
has_q=1
bitmap=4
units=2
mil=1]]

barracks=parse[[
idx=11
los=10
hp=200
const=20
def=building

w=8
fw=8
h=8
fh=8
rest_x=16
rest_y=112
fire=1
dead_x=48
dead_y=104
dead_fr=7
dead_fps=9
portx=-1
porty=88
portw=8
bldg=1
dir=-1
has_q=1
bitmap=8
units=2
mil=1]]

farm=parse[[
idx=12
los=0
hp=50
const=6
def=building

w=8
fw=8
h=8
fh=8
rest_x=16
rest_y=120
fire=1
dead_x=48
dead_y=104
dead_fr=7
dead_fps=9
portx=17
porty=80
portw=9
farm=1
carry=9
bldg=1
dir=-1
bitmap=16]]

castle=parse[[
idx=13
los=45
hp=600
range=40
const=80
atk=1.8
proj_freq=15
atk_typ=tower
def=building

w=15
fw=16
h=16
fh=16
rest_x=112
rest_y=113
attack_x=112
attack_y=113
fire=1
dead_x=48
dead_y=97
dead_fr=4
dead_fps=15
portx=7
porty=88
portw=9
bldg=1
has_q=1
dir=-1
proj_yo=0
proj_xo=0
proj_s=24
bitmap=32
units=1]]

ant.prod={
	parse([[
r=0
g=0
b=6
idx=1
breq=0]],mound),
	parse([[
r=0
g=3
b=3
idx=2
breq=2]],farm),
	parse([[
r=0
g=4
b=15
idx=3
breq=0]],barracks),
	parse([[
r=0
g=4
b=20
idx=4
breq=8]],den),
	parse([[
r=0
g=5
b=15
idx=5
breq=0]],tower),
--t,d,b
	parse([[
r=0
g=25
b=60
idx=6
breq=13]],castle),
}

queen.prod={
	parse([[
t=10
r=5
g=0
b=0
p=
idx=1
breq=0]],ant),
nil,nil,nil,
parse([[
t=30
r=18
g=0
b=5
idx=5
breq=0]],parse[[
portx=96
porty=88
portw=8]],function(_ENV)
		carry=9
		spd*=1.15
	end,ant),
parse([[
t=20
r=15
g=15
b=0
idx=6
breq=32]],parse[[
portx=44
porty=80
portw=9]],function()
		add(mound.prod,parse([[
t=8
r=4
g=0
b=0
p=
idx=2
breq=0]],ant))
	end),
}

den.prod={
	parse([[
t=13
r=0
g=10
b=10
p=
idx=1
breq=0]],beetle),
	parse([[
t=13
r=8
g=8
b=0
p=
idx=2
breq=0]],spider),
nil,
nil,
parse([[
t=20
r=0
g=20
b=0
idx=5
breq=0]],parse[[
portx=114
porty=64
portw=9]],function(_ENV)
		atk*=1.5
		hp*=1.15
	end,beetle),
parse([[
t=30
r=10
g=10
b=0
idx=6
breq=0]],parse[[
portx=105
porty=64
portw=9]],function(_ENV)
		atk*=1.2
		hp*=1.2
	end,spider),
}

mound.prod={
	parse([[
t=8
r=12
g=8
b=8
idx=1
breq=0]],parse[[
portx=104
porty=88
portw=9]],function()
		--also makes farms grow +25% 
		farm_cycles[1]=10
	end),
}

barracks.prod={
	parse([[
t=8
r=6
g=2
b=0
p=
idx=1
breq=0]],warant),
	parse([[
t=14
r=3
g=0
b=5
p=
idx=2
breq=0]],archer),
	parse([[
t=10
r=9
g=6
b=0
idx=3
breq=0]],parse[[
portx=96
porty=64
portw=9
]],function(_ENV)
		range+=5
		los+=5
	end,archer),
nil,
parse([[
t=18
r=15
g=7
b=0
idx=5
breq=0]],parse[[
portx=105
porty=72
portw=9]],function(_ENV)
		atk*=1.5
		los+=5
		hp*=1.333
	end,warant),
	parse([[
t=10
r=9
g=6
b=0
idx=6
breq=0
]],parse[[
portx=96
porty=72
portw=9
]],function(_ENV)
		atk*=1.25
end,archer),
}

castle.prod={
	parse([[
t=18
r=2
g=14
b=14
p=
idx=1
breq=0]],cat),
nil,nil,nil,
 parse([[
t=40
r=20
g=0
b=0
idx=5
breq=0]],parse[[
portx=96
porty=80
portw=8]],function()
	units_heal[1]=true
end),
parse([[
t=10
r=0
g=10
b=20
idx=6
breq=0]],parse[[
portx=113
porty=88
portw=9]],function()
		for x in all(typs) do
			if (x.bldg) x[1].los+=10
		end
	end),
}
end

dmg_mult=parse[[
ant_vs_ant=1
ant_vs_queen=0.7
ant_vs_spider=0.8
ant_vs_seige=1.5
ant_vs_building=0.5

acid_vs_ant=1
acid_vs_queen=0.6
acid_vs_spider=1.5
acid_vs_seige=0.7
acid_vs_building=0.25

spider_vs_ant=1.5
spider_vs_queen=0.9
spider_vs_spider=1
spider_vs_seige=1
spider_vs_building=0.1

seige_vs_ant=0.9
seige_vs_queen=3
seige_vs_spider=0.7
seige_vs_seige=1
seige_vs_building=15

tower_vs_ant=1
tower_vs_queen=0.75
tower_vs_spider=1.25
tower_vs_seige=0.9
tower_vs_building=0.1]]

function rest(u)
	u.st=parse[[t=rest
rest=1
aggress=1]]
end

function movegrp(us,x,y,aggress,rest)
	local lowest=999
	for u in all(us) do
		if not rest or
		 u.st.rest then
			move(u,x,y,aggress)
		end
		lowest=min(u.typ.spd,lowest)
	end
	for u in all(us) do
		u.st.spd=lowest
	end
end

function move(u,x,y,aggress)
	u.st={
		t="move",
		wayp=get_wayp(u,x,y,0),
		aggress=aggress,
	}
end

function build(u,b)
	u.st,u.res={
		t="build",
		target=b,
		wayp=get_wayp(u,b.x,b.y),
	}
end

function gather(u,tx,ty,wp)
	local t=tile_as_unit(tx,ty)
	u.st={
		t="gather",
		tx=tx,
		ty=ty,
		res=f2res[fget(mget(tx,ty))],
		wayp=wp or
			get_wayp(u,t.x,t.y),
		target=t,
	}
end

function drop(u,nxt_res,dropu)
	if not dropu then
		wayp,x,y=dmap_find(u,"d")
		dropu=not wayp and queens[u.p]
	end
	if dropu then
		wayp=get_wayp(u,dropu.x,
			dropu.y)
	end
	u.st={
		t="drop",
		wayp=wayp,
		nxt=nxt_res,
		target=dropu or
			tile_as_unit(x,y),
	}
end

function attack(u,e)
	if u.typ.atk and e then
		u.st,u.discovered={
			t="attack",
			target=e,
			wayp=get_wayp(u,e.x,e.y),
		},u.typ.bldg and 1
	end
end

function harvest(u,f)
	f.farmer,u.st,u.res=u,{
		t="harvest",
		target=f,
  wayp=get_wayp(u,
  	f.x-3+rnd(6),
  	f.y-3+rnd(6)),
  farm=f
	}
end
-->8
--update

function handle_click()
	local l,r,cont,htile,axn=
		5,4,not action,{
	 	t=t(),
	 	unit=tile_as_unit(mx8,my8)
	 }
	
	if lclk and hovbtn then
		hovbtn.handle()
		return
	end

	if lclk and action then
		rclk,axn,action=lclk,true
	end

	--menuy
	if amy>104 and not selx then
		local dx,dy=amx-mmx,amy-mmy
		if min(dx,dy)>=0 and
			dx<mmw and dy<mmh+1	then
			local x,y=
				mmwratio*dx,mmhratio*dy
			if rclk and sel1 then
				foreachsel(move,x,y,axn)
				hilite={t=t(),
					circ={amx,amy,2,8}}
			elseif lclk then
				cx,cy=
					mid(0,x-64,mapw-128),
					--menuh=21
				 mid(0,y-64,maph-107)
			end
		end
		if (lclk) to_build=nil
	 return
	end
	
 if to_build then
 	if rclk then
	 	to_build=nil
	 elseif lclk and buildable() then
  	local b=unit(
				to_build.typ,
				to_build.x+to_build.typ.w\2,
				to_build.y+to_build.typ.h\2,
				1,nil,0)
			foreachsel(build,b)
			b.cost,to_build,selx=
			 to_build,pay(to_build,-1,1)
		end
		return
 end
	
 if rclk and sel1 and sel1.p==1
 then
	 if can_renew_farm() then
	 	hilite_hoverunit()
	 	hoverunit.sproff,
	 		hoverunit.cycles,
	 		hoverunit.exp=0,0
	 	res1.b-=farm_renew_cost_b
	 	harvest(sel1,hoverunit)
	 	
	 elseif can_gather() then
	 	hilite=htile
	 	if avail_farm() then
	 		harvest(sel1,hoverunit)
	 	else
	  	foreachsel(gather,mx8,my8)
	 	end
	 	
  elseif can_build() then
  	foreachsel(build,hoverunit)
			hilite_hoverunit()
			
	 elseif can_attack() then
  	foreachsel(attack,hoverunit)
  	hilite_hoverunit()
  	
  elseif can_drop() then
  	foreachsel(drop,nil,hoverunit)
  	hilite_hoverunit()
  	
  elseif sel1.typ.unit then
  	movegrp(selection,mx,my,axn)
  	hilite={t=t(),cx=mx,cy=my}
  	
  elseif sel1.typ.units then
  	if fget(mget(mx8,my8),1) then
 	  hilite=htile
			end
  	sel1.rx,sel1.ry,
  		sel1.rtx,sel1.rty=
  		mx,my,mx8,my8
  else
   cont=true
  end
 end
 
 if cont then
	 if btnp"5" and not selx then
	 	selx,sely=mx,my
	 end
	 if btn"5" and selx then
			selbox={
				min(selx,mx),
				min(sely,my),
				max(selx,mx),
				max(sely,my),7 --col
	 	}
	 else
	 	selx=nil
	 end
 end
end

function foreachsel(func,...)
	for u in all(selection) do
		func(u,...)
	end
end

function hilite_hoverunit()
	hilite={t=t(),unit=hoverunit}
end

function mouse_cam()
	local b=btn()
	if (b>32) b>>=8 --esdf
	cx,cy,amx,amy=
 	mid(0,
 		cx+band(b,0x2)-band(b,0x1)*2,
 		mapw-128
 	),
 	mid(0,
 		cy+band(b,0x8)/4-band(b,0x4)/2,
	 	--menuh=21
 		maph-(loser and 128 or 107)
 	),
 	mid(0,stat"32",126),
	 mid(-1,stat"33",126)

 mx,my,hovbtn=amx+cx,amy+cy
 mx8,my8=mx\8,my\8
end

function handle_input()
	mouse_cam()
	
 for b in all(buttons) do
 	if intersect(b.r,{amx,amy,amx,amy},1) then
			hovbtn=b
 	end
	end

 handle_click()
 
 if to_build then
	 to_build.x,to_build.y=
	  mx8*8,my8*8
	end
end

function tick_unit(u)
	u.onscr=intersect(u.r,
		{cx,cy,cx+128,cy+128},0)

	local typ=u.typ
	if u.hp<=0 and not u.dead then
		del(selection,u)
		u.dead,
			u.st,u.sel=0,parse"t=dead"
		if typ.bldg then
			register_bldg(u)
		end
		local r=res[u.p]
		if typ.drop then
			r.pl-=5
		elseif typ.unit then
			r.p-=1
		end
	end
	if u.dead then
		if (typ.queen)	loser=u.p
		u.dead+=1
		if (typ.unit) update_viz(u)
		del(u.dead==60 and units,u)
		return
	end
	
	if units_heal[u.p] and
		not u.fire and
	 u.hp<typ.hp and
		fps==0 then
		u.hp+=0.5
	end
	
	if intersect(u.r,
	 {mx,my,mx,my},1) and (
	 not hoverunit or
	  hoverunit.p==1
	) then
		hoverunit=u
	end
	
	if (u.const) return
	local targ=u.st.target
	if targ and targ.dead then
		if u.st.t=="attack" then
			move(u,targ.x,targ.y,true)
		else
			rest(u)
		end
	end
	
	if u.p==1 then
		if typ.ant and 
			u.st.rest then
			if (u.st.idle) idle=u
			u.st.idle=1
		elseif typ.mil and not u.q then
			idle_mil=u
		end
	end
	
	update_unit(u)
	if (upc_0) ai_unit1(u)

	update_viz(u)

	if typ.unit and not u.st.wayp then
		local x,y,change=u.x,u.y
		while g(pos,x\4,y\4) and
			not u.st.adj do
			x+=rnd"4"-2
			y+=rnd"4"-2
			change=1
		end
		if change then
			u.st.wayp,u.st.adj={{x,y}},1
		end
		s(pos,x\4,y\4,1)
	end
end

function update_viz(u)
	if u.p==1 and
		u.id%upcycle==upc then
		local k0,los=u.x8|u.y8<<8,
			u.typ.los

		local xo,yo,l=
			u.x%8\2,u.y%8\2,
			ceil(los/8)
		local i=xo|yo*16|los*256
		local v=vcache[i]
		if not v then
			v={}
			for dx=-l,l do
			for dy=-l,l do
			 if dist(xo*2-dx*8-4,
			  yo*2-dy*8-4)<los then
					add(v,dx+dy*256)
				end
			end
			end
			vcache[i]=v
		end
		
		for t in all(v) do
			local k=k0+t
			if k<maph8<<8 and k>=0 and
				k%256<mapw8 then
				if bldgs[k] then
					bldgs[k].discovered=1
				end
				--"v" to index into rescol
				exp[k],new_viz[k]=1,"v"
			end
		end
	end
end
-->8
--map

function draw_map(offset,y)
 camera(cx%8,cy%8)
 map(cx/8+offset,cy/8,0,0,17,y)
 camera(cx,cy)
end

function draw_minimap()
	camera(-mmx,-mmy)
	
	pal(14,0)
	spr(unspl"153,0,0,3,3")
	
	for u in all(units) do
		if u.discovered or
			g(viz,u.x8,u.y8) then
			pset(
				u.x/mmwratio,
				u.y/mmhratio,
				u.sel and 9 or u.p
			)
		end
	end
	
	camera(
		-mmx-ceil(cx/mmwratio),
	 -mmy-ceil(cy/mmhratio)
	)
	--7=128/mmwratio+1
	rect(unspl"-1,-1,7,7,10")
	camera()
end
-->8
--units

function draw_unit(u)
	local typ,st,
		res_typ=
			u.typ,u.st,
			u.res and u.res.typ or ""

	local fw,w,h,
	 stt,
	 hp=
		 typ.fw,typ.w,typ.h,
		 st.wayp and "move" or st.t,
		 u.hp/typ.hp
	
	local xx,yy,sx,sy,ufps,fr,f=
		u.x-w/2,u.y-h\2,
	 typ[stt.."_x"]+
	 	max(typ["xoff_"..res_typ])+
	 	u.sproff\8*8,
	 typ[stt.."_y"]+max(typ["yoff_"..res_typ]),
	 typ[stt.."_fps"],
	 typ[stt.."_fr"],
		u.dead or fps
	
	if u.const and not u.dead then
		fillp"23130.5"--▒
		rectaround(u,
			u==sel1 and 9 or 12)
		fillp()
		local p=u.const/typ.const
		bar(xx,yy,fw-1,p,14,5)
		sx-=fw*ceil(p*2)
		if (p<=0.1) return
	elseif ufps then
		sx+=f\ufps%fr*fw
	end
	pal(2,u.p) --qn ☉
	pal(1,not loser and u.sel and (
	 u.p==1 and typ.unit
	 or u==sel1) and 9 or u.p)
	sspr(sx,sy,w,h,xx,yy,w,h,
		not typ.fire and u.dir==typ.dir)
	pal()
	if not u.dead and hp<=0.5 then			
	 if typ.fire then
			spr(229+f/20,u.x-3,u.y-8)
		end
		bar(xx,yy-1,w,hp)
	end
end

function update_unit(u)
	local st=u.st
	local t=st.t
 if u.q and fps%15==u.q.fps%15 then
 	produce(u)
 end
 if (u.typ.farm) update_farm(u)
 if st.active then
 	if (t=="harvest") farmer(u)
 	if t=="build" and fps%30==0 then
 	 buildrepair(u)
 	end
  if (t=="gather") mine(u)
 else
 	check_target(u)
 end
 step(u)
 if not st.wayp and t=="move" then
		rest(u)
 end
end

function update_farm(u)
	local f=u.farmer
	if not f or f.dead or f.st.farm!=u then
		u.farmer=nil
		return
	end
	if f.st.active and not u.exp and
		not u.ready and fps==59 then
		u.fres+=0.375+farm_cycles[u.p]/40
		u.sproff+=1
		u.ready=u.fres>=9
	end
end

function farmer(u)
	local f=u.st.farm
	if f.ready and fps==0 then
		f.fres-=1
		f.sproff+=1
		collect(u,"r")
		if f.fres<=0 then
			drop(u)
			f.cycles+=1
			f.exp,f.ready=f.p==1 and
			 f.cycles==farm_cycles[1]
			f.sproff=f.exp and 32 or 0
		end
		u.st.farm=f
	end
end

function aggress(u)
	local typ=u.typ
	local los,targ_d,targ,pref=max(
		typ.unit and typ.los,
		typ.range),9999
	for e in all(units) do
		local d=dist(e.x-u.x,e.y-u.y)
		if e.p!=u.p and not e.dead and
			viz[e.x8|e.y8<<8] and
			d<los
		then
			if (d<targ_d)targ,targ_d=e,d
			if typ.atk_typ=="seige"
				and e.typ.fire then
				pref=e
			end
		end
	end
	attack(u,pref or targ)
end

function fight(u)
	local typ,e,in_range,id,d=
		u.typ,u.st.target,
		u.st.active,u.id
	local dx,dy=e.x-u.x,e.y-u.y
	if typ.range then
		if upc==id%upcycle then
			d=dist(dx,dy)
			in_range=d<=typ.range and
				g(viz,e.x8,e.y8)	
		end
		if in_range and
			fps%typ.proj_freq==
			(typ.cat and 0 or
			 id%typ.proj_freq)
		then
 		add(proj,{
 			from_typ=typ,
 			x=u.x-u.dir*typ.proj_xo,
 			y=u.y+typ.proj_yo,
 			to={e.x,e.y},
 			to_unit=e,
 		})
 	end
 else
 	in_range=intersect(u.r,e.r,0)
		if in_range and fps%30==id%30 then
		 deal_dmg(typ,e)
		end
 end
 u.st.active=in_range
 if in_range then
 	u.dir,u.st.wayp=sgn(dx)
	elseif upc==id%upcycle then
		if (not d)	d=dist(dx,dy)
		if typ.los>=d and typ.unit then
	 	attack(u,e) --pursue
	 end
	 if not u.st.wayp then
	 	rest(u)
	 end
 end
end

function buildrepair(u)
	local b,r=u.st.target,res[u.p]
	if b.const then
		b.const+=1
		if b.const>=b.typ.const then
			b.const=nil
			register_bldg(b)
			if b.typ.drop then
				r.pl+=5
			elseif b.typ.farm then
				harvest(u,b)
			end
		end
	elseif b.hp<b.typ.hp and
		r.b>=1 then
		b.hp+=1
		r.b-=0.5
	else
		rest(u)
	end
end

function mine(u)
	local x,y,r=u.st.tx,u.st.ty,u.st.res
	local full,t=resqty[r],mget(x,y)
	local n=g(restiles,x,y,full)
	if n==0 then
		mine_nxt_res(u,r)
	elseif fps==u.st.fps then
		collect(u,r)
		if t<112 and
			(n==full\3 or n==full\1.25)
		then
			mset(x,y,t+16)
		elseif n==1 then
			mset(x,y,74) --exhaust
			s(dmap_st[r],x,y)
			s(dmaps[r],x,y)
			make_dmaps(r)
		end
		s(restiles,x,y,n-1)
	end
end

function produce(u)
	local b=u.q.b
	u.q.t-=0.5
	if u.q.t<=0 then
		if b.tech then
			b.tech(b.techt[1])
		else
			local new=unit(
				b.typ,u.x,u.y,u.p,u.boi)
			if new.typ.ant and
				u.rtx and
				fget(mget(u.rtx,u.rty),1)
			then
				gather(new,u.rtx,u.rty)
			else
				move(new,u.rx or u.x+5,
					u.ry or u.y+5)
			end
		end
		if u.q.qty>1 then
			u.q.qty-=1
			u.q.t=b.t
		else
			u.q=nil
		end
	end
end

function check_target(u)
	local st=u.st
	local t,nxt=st.target,st.nxt
	if
		t and
		intersect(t.r,u.r,
			st.res and -3 or 0)
	then
		u.dir,st.active,st.fps=
			sgn(t.x-u.x),true,fps
		if st.t=="harvest" then
			if (st.farm.exp)	rest(u)	
		else
			st.wayp=nil
		end
		if st.t=="drop" then
			if u.res then
				res[u.p][u.res.typ]+=u.res.qty/(2-res[u.p].diff/2)
			end
			u.res=nil
			if st.farm then
				harvest(u,st.farm)
			else
				rest(u)
				u.st.res=nxt
			end
		end
	elseif st.res and not st.wayp then
 	mine_nxt_res(u,st.res)
	end
end

function mine_nxt_res(u,res)
	local wp,x,y=dmap_find(u,res)
	if wp then
		gather(u,x,y,wp)
	elseif not u.st.rest then
		drop(u,res)
	end
end

function step(u)
	local wayp=u.st.wayp
	if wayp then
 	u.x,u.y,u.dir=norm(wayp[1],u,
 		u.st.spd or u.typ.spd)
 	local x,y=unpack(wayp[1])
 	if dist(x-u_rect(u).x,y-u.y)<0.5 then
 		if #wayp==1 then
 			u.st.wayp=nil
			else
			 deli(wayp,1)
			end
 	end
 end
end
-->8
--utils

function splspl(str,spl)
	local x={}
	foreach(split(str,spl or "\n"),
		function(s)
			add(x,split(s))
		end)
	return x
end

function sel_only(unit)
	foreachsel(function(u)
		u.sel=nil
	end)
	selection,unit.sel={unit},1
end

function g(a,x,y,def)
	return a[x|y<<8] or def
end

function s(a,x,y,v)
 a[x|y<<8]=v
end

function intersect(r1,r2,e)
	return r1[1]-e<r2[3] and
		r1[3]+e>r2[1] and
		r1[2]-e<r2[4] and
		r1[4]+e>r2[2]
end

function tile_as_unit(tx,ty)
	return u_rect{
		x=tx*8+4,
		y=ty*8+4,
		typ=parse[[w=8
h=8]],
	}
end

function u_rect(_ENV)
	local w2,h2=typ.w/2,typ.h/2
 r,x8,y8={x-w2,y-h2,x+w2,y+h2},
  x\8,y\8
 return _ENV
end

function can_pay(costs,p)
	local r=res[p or 1]
 return r.r>=costs.r and
 	r.g>=costs.g and
 	r.b>=costs.b and
 	(not costs.p or
 		r.p<min(r.pl,99)) and
 	r.reqs|costs.breq==r.reqs
end

function pay(costs,dir,p)
	for r in all(split"r,g,b") do
  res[p][r]+=costs[r]*dir
	end
	if costs.p then
		res[p].p-=dir
	end
end

-- musurca/freds /bbs/?tid=36059
function dist(dx,dy)
 local maskx,masky=dx>>31,dy>>31
 local a0,b0=(dx+maskx)^^maskx,
 	(dy+masky)^^masky
 return a0>b0 and
 	a0*0.9609+b0*0.3984 or
  b0*0.9609+a0*0.3984
end

function all_surr(x,y,n,chk_acc)
	local st={}
	for dx=-n,n do
	 for dy=-n,n do
	 	local xx,yy=x+dx,y+dy
	 	if
	 		min(xx,yy)>=0 and
	 		xx<mapw8 and yy<maph8 and
	 		(not chk_acc or acc(xx,yy))
	 	then
			 add(st,{
			  xx,yy,
			 	d=dx!=0 and dy!=0 and 1.4 or 1,
			 	k=xx|yy<<8
			 })
			end
		end
	end
	return all(st)
end

function avail_farm()
	return hoverunit and
		hoverunit.typ.farm and
		not hoverunit.farmer and
		not hoverunit.const
end

function can_gather()
	return (fget(mget(mx8,my8),1)
	 or avail_farm()) and
		sel_typ==ant1 and
		g(exp,mx8,my8) and
		sur_acc(mx8,my8)
end

function can_attack()
	local v=g(viz,mx8,my8)
	for u in all(selection) do
		if hoverunit and
		 hoverunit.p!=1 and
			u.typ.atk and
			(v or hoverunit.discovered)
		then
			return true
		end
	end
end

function can_build()
	return hoverunit and
		hoverunit.typ.bldg and
		(hoverunit.const or
			hoverunit.hp<hoverunit.typ.hp
	 ) and
		sel_typ==ant1
end

function rectaround(u,c)
	local w,x,y,z=unpack(u.r)
	rect(w-1,x-1,y,z,c)
end

function norm(it,nt,f)
	local xv,yv=
		it[1]-nt.x,it[2]-nt.y
	local d=dist(xv,yv)+0.0001
	return nt.x+xv*f/d,
		nt.y+yv*f/d,
		sgn(xv),--xdir
		d
end

--strict incl farms+const
function acc(x,y,strict)
	local b=g(bldgs,x,y)
	return not fget(mget(x,y),0) and
		min(x,y)>=0 and
		x<mapw8 and y<maph8 and
		(not b or (not strict and (
			b.const or b.typ.farm
	)))
end

function buildable()
	local x,y,w,h=
		to_build.x/8,
		to_build.y/8,
		to_build.typ.w,
		to_build.typ.h
	return	acc(x,y,true) and
		(w<9 or acc(x+1,y,true)) and
		(h<9 or acc(x,y+1,true)) and
		(h<9 or w<9 or acc(x+1,y+1,true))
end

function register_bldg(b)
	local typ=b.typ
	local w,h,x,y=typ.w,typ.h,
		b.x8,b.y8

	function reg(xx,yy)
		s(bldgs,xx,yy,
			not b.dead and b or nil)
		if b.dead then
			s(exp,xx,yy,1)
			s(dmap_st.d,xx,yy)
			if typ.fire and y==yy then
				mset(xx,yy,91)
			end
		elseif	typ.drop then
			s(dmap_st.d,xx,yy,{xx,yy})
		end
	end
	reg(x,y)
	if w>8 then
		reg(x+1,y)
		if (h>8) reg(x+1,y-1)
	end
	if (h>8) reg(x,y-1)
	
	if (typ.queen) queens[b.p]=b
	if not b.const and not typ.farm then
		make_dmaps"d"
		res[b.p].reqs|=typ.bitmap
	end
end

function deal_dmg(from_typ,to)
	to.hp-=from_typ.atk*dmg_mult[
		from_typ.atk_typ.."_vs_"..
		to.typ.def]
	if to.st.rest then
		move(to,
			to.x+rnd"6"*2-6,
			to.y+rnd"6"*2-6,true)
	end
end

function collect(u,res)
	if u.res and u.res.typ==res then
		u.res.qty+=1
	else
		u.res={typ=res,qty=1}
	end
	if u.res.qty>=u.typ.carry then
		drop(u,res)
	end
end

function can_drop()
 for u in all(selection) do
		if u.res then
			return hoverunit and
			 hoverunit.typ.drop
		end
	end
end

function can_renew_farm()
	return hoverunit and
		res1.b>=farm_renew_cost_b and
		sel_typ==ant1 and
		hoverunit.exp
end

function bar(x,y,w,prog,fg,bg)
	line(x+w,y,x,y,bg or 8)
	line(x+flr(w*prog),y,fg or 11)
end

function sur_acc(x,y)
	return acc(x-1,y) or
		acc(x+1,y) or
		acc(x,y-1) or
		acc(x,y+1)
end

function unit(typ,x,y,p,boi,
	const,discovered,hp)
 local typ,u=
 	typs[typ] or typ,
 	add(units,
 		parse[[dir=1
sproff=0
lastp=1
cycles=0
fres=0]])
 		
 u.typ,u.x,u.y,u.p,u.hp,u.const,
  u.discovered,u.id,u.boi,
  u.prod=
 	typ[p],x,y,p,hp or typ[p].hp,
		tonum(const),
		discovered==1,
		flr(rnd"60"),tonum(boi),
		typ.prod
	rest(u_rect(u))		
	if typ.bldg then
		register_bldg(u)
	end
	return u
end

function queue_prod(u,b)
	pay(b,-1,u.p)
	if u.q then
		u.q.qty+=1
	else
		u.q={
			b=b,qty=1,t=b.t,fps=fps-1,
		}
	end
end
-->8
--a*

function nearest_acc(x,y,u)
	for n=0,16 do
		local best_d,best_t=32767
		for t in all_surr(x\8,y\8,n) do
			if acc(unpack(t)) then
				local d=dist(
					t[1]*8+4-u.x,
					t[2]*8+4-u.y
				)
				if d<best_d then
					best_t,best_d=t,d
				end
			end
		end
		if (best_t) return best_t,n
	end
end

function get_wayp(u,x,y,tol)
	if u.typ.unit then
		local wayp,dest,dest_d=
			{},
			nearest_acc(x,y,u)
		--unstick
		local path,exists=find_path(
		 nearest_acc(u.x,u.y,u),
		 dest)
		deli(path) --start
		for n in all(path) do
			add(wayp,
				{n[1]*8+4,
				 n[2]*8+4},1)
		end
		if exists and
			dest_d<=(tol or 1) then
			add(wayp,{x,y})
		end
		return #wayp>0 and wayp
	end
end

--a* based on t.co/NaSUd3d1ix
function find_path(start,goal)
 local shortest,best_table={
  last=start,
  cost_from_start=0,
  cost_to_goal=32767
 },{}
 best_table[start.k]=shortest
 function path(p,s)
	 while s.prev do
   s=best_table[s.prev.k]
   add(p,s.last)
  end
  return p
 end
 local frontier,frontier_len,
 	closest={shortest},1,
 	shortest
 while frontier_len>0 do
  local cost,index_of_min=32767
  for i=1,frontier_len do
   local temp=frontier[i].cost_from_start+frontier[i].cost_to_goal
   if (temp<=cost) index_of_min,cost=i,temp
  end
  shortest=frontier[index_of_min]
  frontier[index_of_min],shortest.dead=frontier[frontier_len],true
  frontier_len-=1
  
  local p=shortest.last
  if p.k==goal.k then
   return path({goal},shortest),1
  end
  for n in all_surr(p[1],p[2],1,true) do
   local old_best,new_cost_from_start=
    best_table[n.k],
    shortest.cost_from_start+n.d
   if not old_best then
    old_best={
     last=n,
     cost_from_start=32767,
     cost_to_goal=
     	dist(n[1]-goal[1],n[2]-goal[2])
    }
    frontier_len+=1
    frontier[frontier_len],best_table[n.k]=old_best,old_best
   end
   if not old_best.dead and old_best.cost_from_start>new_cost_from_start then
    old_best.cost_from_start,old_best.prev=new_cost_from_start,p
   end
			if old_best.cost_to_goal<closest.cost_to_goal then
				closest=old_best
			end
  end
 end
 return path({closest.last},closest)
end
-->8
--menu

function print_res(r,x,y,zero)
	local res1=res2
	local oop=res1.p>=res1.pl
	for i,k in inext,split"r,g,b,p" do
		local newx,v=0,i!=4 and
			min(flr(r[k]),99) or zero and
			"\-b \-i"..res1.p..
				"/\^x9 \^-#\^x1.\|h\#5\^x0 \^x4\^-#\|f\-6"..min(res1.pl,99) or
			oop and r[k] or 0
		if zero and i==3 then
			newx,v=-2,v.."\-g \-c\^t\|f\f5\^-#|"
		end
		if v!=0 or zero then
			v=(
				(i==4 and oop or
				res1[k]<flr(v)) and "\#a "
				or "\#7\-f\^x5 \^x4")..v
			newx+=? v,x,y,rescol[k]
			spr(129+i,x,y)
			x=newx+(zero or 1)
		end
	end
	return x-1
end

function draw_port(
	typ,x,y,costs,onclick,prog,u
)
	camera(-x,-y)
	local cant_pay,axnsel=
		costs and not can_pay(costs),
	 typ.portf and action
	rect(0,0,10,9,
		u and u.p or
		cant_pay and 6 or
		costs and 3 or
		axnsel and 10 or
		typ.porto or 1
	)
	rectfill(1,1,9,8,
		cant_pay and 7 or costs and
 	costs.tech and 10 or
 	axnsel and 9 or
 	typ.portf or 6
	)
	pal(cant_pay and split"5,5,5,5,5,6,6,13,6,6,6,6,13,6,6,5")
	pal(14,0)
	pal(not costs and 6,7)
	sspr(typ.portx,typ.porty,
	 typ.portw,unspl"8,1,1")
	pal()
	
	add(buttons,{
		r={x,y,x+10,y+8},
		handle=onclick,
		costs=costs,
	})

	if u or prog then
		bar(0,11,10,
			prog or u.hp/typ.hp,
			prog and 12,
			prog and 5
		)
	end
	camera()
end

function draw_sel_ports(x)
	for i,u in inext,selection do
		x+=13
		if i>5 then
			--menuy+6
			if (numsel>14) x-=4
			camera(-?"\f1+"..numsel-5,x-15,121)
			spr(unspl"133,1,121")
			break
		end
		draw_port(
			--menuy+3
			u.typ,x,107,nil,
			function()
				del(selection,u).sel=false
			end,
			nil,u)
	end
end

function single_unit_section()
	local q=sel1.q
	
	if numsel==1 then
		draw_sel_ports(-10)
 end
 
 if (sel1.p!=1) return
	
	if sel1.const then
	 draw_port(
	 	parse[[
portx=104
porty=80
portw=9
porto=8
portf=9
	 	]],20,
	 	--menuy+3
	 	107,nil,function()
	 		pay(sel1.cost,1,1)
	 		sel1.hp=0
	 	end,sel1.const/sel_typ.const
	 )
	 return
	end
	
	if sel1.typ.farm then
		--menuy+6
		camera(-? sel1.cycles.."/"..farm_cycles[1],unspl"38,111,4")
		--menuy+4
		sspr(unspl"112,96,9,9,2,109")
	end
	for i,b in next,sel1.prod do
		i-=1
		draw_port(
			b.typ,
			88-i%4*13,
			--menuy+2
			106+i\4*11,
			b,
			function()
				if can_pay(b) and (
					not q or
					q.b==b and q.qty<9) then
					if b.typ.bldg then
						to_build=b
						return
					end
					queue_prod(sel1,b)
					if b.tech then
						sel1.prod[b.idx]=nil
					end
				end
			end
		)
	end
	if q then
		local b=q.b
		draw_port(
		 b.typ,
		 b.tech and 24 or
		  --menuy+6
		  ?"X"..q.qty,unspl"32,110,7"
		  and 20,
		 --menuy+3
		 107,nil,
			function()
				pay(b,1,1)
				if q.qty==1 then
					sel1.q=nil
				else
					q.qty-=1
				end
				sel1.prod[b.idx]=b
			end,q.t/b.t
		)
	end
end

function draw_menu()
	local x,secs=0,split"102,26"
	if sel1 and sel1.p==1 then
		if sel1.typ.has_q then
			secs=split"17,24,61,26"
		else
	 	secs=split"17,17,68,26"
		end
	end
 for i,sec in inext,secs do
 	pal(i%2!=0 and 4,15)
 	camera(x)
 	--104=menuy
 	spr(unspl"129,0,104")
 	spr(129,sec-8,104)
 	line(sec-4,unspl"105,3,105,7")
 	rectfill(sec-4,unspl"106,3,108,4")
 	rectfill(sec,unspl"108,0,128")
 	x-=sec
 	pal()
 end
 camera()

 if numsel==1 or sel_typ==ant1 then
		single_unit_section()
	else
		draw_sel_ports(24)
	end
	if numsel>1 then
		camera(numsel<10 and -2)
		?"X"..numsel,unspl"5,111,1"
		spr(unspl"133,1,111")
		add(buttons,{
			r=split"0,110,14,119",
			handle=function()
			 deli(selection).sel=false
			end
		})
	end
	
	if sel1 and sel1.p==1 and
		sel1.typ.unit then
		draw_port(
	 	sel_typ==ant1 and parse[[
portx=63
porty=72
portw=9
porto=2
portf=13
]] or parse[[
portx=113
porty=80
portw=9
porto=2
portf=13
]],20,
	 	--menuy+3
	 	108,nil,function()
	 		action=not action
	 	end
	 )
	end
	
	draw_minimap()
	
	sspr(idle and 112 or 120,
	 unspl"105,8,6,116,121")
	add(buttons,idle and {
		r=split"116,121,125,128",
		handle=function()
			sel_only(idle)
			cx,cy,hilite=
				idle.x-64,idle.y-64,
				{t=t(),unit=idle}
			mouse_cam()
		end
	})
	
	sspr(idle_mil and 64 or 72,
 unspl"113,8,6,106,121")
 add(buttons,idle_mil and {
		r=split"106,121,113,128",
		handle=function()
			sel_only(idle_mil)
		end
	})
	
	local res1=res2
	camera(-print_res(res1,
	 unspl"1,122,2"))
	line(unspl"-4,120,-128,120,5")
	pset(-3,121)
	
	if hovbtn and hovbtn.costs and
		res1.reqs|hovbtn.costs.breq==
			res1.reqs then
		local len=print_res(
		 hovbtn.costs,0,150)
		camera(
			len/2-4-hovbtn.r[1],
			8-hovbtn.r[2]
		)
		print_res(hovbtn.costs,2,2)
		rect(len+2,unspl"0,0,8,1")
	end
	camera()
end
-->8
--dmaps

function dmap_find(u,key)
	local x,y,dmap,wayp,lowest=
		u.x8,
		u.y8,
		dmaps[key],
		{},9
	while lowest>=1 do
		local orig=max(1,g(dmap,x,y,9))
		for t in all_surr(x,y,1) do
			local w=dmap[t.k] or 9
			if w+t.d-1<lowest then
				lowest,x,y=w,unpack(t)
			end
		end
		if (lowest>=orig) return
		add(wayp,{x*8+3,y*8+3})
	end
	return wayp,x,y
end
	
function make_dmaps(r)
	queue=split(parse[[r=r,g,b,d
g=g,r,b,d
b=b,g,r,d
d=d,r,g,b]][r])
end

function async_dmap()
	local q=queue[1]
	if q then
		if #q==1 then
	 	queue[1]=make_dmap(q)
		else
			dmapcc(q)
			if q.c==9 then
				dmaps[q.key]=
					deli(queue,1).dmap
			end
		end
	else
		dmaps_ready=true
	end
end

function dmapcc(q)
	for i=1,#q.open do
		if (i>20)	return
		local p=deli(q.open)
		q.dmap[p.k]=q.c
		if q.c<8 then
			for t in all_surr(p[1],p[2],1,true) do
				if not q.closed[t.k] then
					q.closed[t.k]=add(q.nxt,t)
				end
			end
		end
	end

	q.c+=1
	q.open,q.nxt=q.nxt,{}
end

function make_dmap(key)
	if not dmap_st[key] then
		dmap_st[key]={}
		for x=0,mapw8 do
		for y=0,maph8 do
			if
				fget(mget(x,y),key2resf[key])
		 then
		 	s(dmap_st[key],x,y,{x,y})
		 end
		end
		end
	end
	
	local open={}
	for i,t in next,dmap_st[key] do
		if	sur_acc(unpack(t)) then
			add(open,t).k=i
		end
	end
	
	return {
		key=key,
		dmap={},
		open=open,
		c=0,
		closed={},
		nxt={},
	}
end

-->8
--init

ai_diff,
	mapw,maph,mmx,mmy,mmw,
	mmh, --maph\mmwratio
	mapw8,maph8,
	mmhratio, --maph/mmh
	mmwratio, --mapw/mmw
	menu,cx,cy,cvx,cvy
	=
unspl"0,384,256,105,107,19,12,48,32,21.333,20.21,1,0,30,1,1"
	
reskeys,f2res,resqty,
 key2resf,rescol
 =
split"r,g,b,p,pl,reqs,tot,bo_idx,diff",parse[[
7=r
11=g
19=b
]],parse[[
r=45
g=50
b=40
]],parse[[
r=2
g=3
b=4
d=d
]],parse[[
r=8
g=11
b=4
p=1

v0=15
v1=15
v7=8
v11=11
v19=4
v33=12

e0=5
e1=5
e7=8
e11=3
e19=4
e33=13]]

function init()
	poke(0x5f2d,3) --mouse
	reload()
		
	queue,exp,vcache,dmaps,
	units,restiles,selection,
		proj,bldgs,spiders,viz,
		new_viz,queens,
		dmap_st,res,loser,menu,selx=
		{},{},{},{},{},{},{},
		{},{},{},{},{},{},{d={}},
	 parse[[
r=20
g=10
b=20
p=4
pl=10
tot=4
bo_idx=1
reqs=0
diff=-2]]

	res1,res2,
	--upgradable
	units_heal,
	farm_cycles,farm_renew_cost_b,

	cx,cy,mx,my,fps,numsel,
	dmaps_ready=
		res[1],res[2],{false,true},
		split"5,12",
		unspl"6,0,0,0,0,59,0"

	init_typs()
	
	ai_init()
end

function new_game()
	menu=init()
	--q=6,5
	foreach(
splspl[[7,55,44,1
1,40,40,1
1,68,43,1
1,50,32,1
5,48,56,1
7,337,188,2
1,320,184,2
1,348,187,2
1,330,196,2
5,320,170,2,3
8,268,169,2
2,65,150,3]],
	function(u) unit(unpack(u)) end
)
	
	make_dmaps"d"
end
-->8
--ai

function ai_init()
	res_alloc,
		defsqd,offsqd,atksqd,
		miners,rebuild,
		res2.diff,
		nxt_res,
		antcount,inv,
		ant[2].carry,
		uhold=
		split"r,b,g,r,b",
		parse"",parse"",{},
		{},{},ai_diff,
		unspl"1,0,0,9"
	defsqd[4],offsqd[4]={},{}
	
	--1m 2f 3b 4d 5t 6c
	bo=splspl[[5,1,123,27
8,1,117,26
8,3,120,18,2
11,1,123,21
12,5,118,16
15,2,121,24
16,1,125,25
16,2,122,24
17,2,123,24
20,2,123,23
21,2,123,22
21,1,122,20
22,4,118,21,2
23,1,123,16
23,2,122,22
24,2,121,22
25,1,119,28
26,6,114,17,2
27,2,120,22
29,2,120,23
30,2,120,24
31,2,124,24
31,1,118,19
32,4,120,20,2
34,3,120,16,2
36,1,125,9
39,5,120,7
40,1,127,22
41,2,125,24
41,2,126,24
42,2,124,25
42,2,124,26
43,1,124,12
43,6,114,11
45,5,117,20
48,1,113,28
49,3,121,8,1
50,5,112,30
52,4,122,8,1
53,1,122,28
53,2,123,26
53,3,115,28,4
53,5,118,23
54,2,122,26
54,2,122,27
57,1,123,5
60,5,114,29
65,2,121,27
65,2,121,28
65,1,114,8
65,6,115,4]]
end

function ai_unit1(u)
 if u.p==2 then
 	if u.typ.ant then
 		antcount+=1
 		if u.st.res=="r" and
 			--41,24
 			not dmaps.r[6185] then
			 drop(u)
			 res_alloc=split"b,g,b,g,b,g"
			end
			if u.st.rest and
				u.st.res=="b" then
			 if u.y>168 and
			 	--42,7
			 	not dmaps.b[6954] then
				 move(u,352,64)
				end
				if u.x>288 and
					--46,8
					not dmaps.b[2094] then
					move(u,280,64)
				end
			end
 		if u.st.res then			
		 	add(miners,u)
		 elseif u.st.rest and
		 	dmaps_ready then
				mine_nxt_res(u,
		 		res_alloc[nxt_res])
		 	nxt_res%=#res_alloc
				nxt_res+=1
		 end
	 elseif u.typ.atk and
	 	u.typ.unit then
	 	if u.dead then
	 		del(u.sqd,u)
	 	elseif not u.sqd then
	 		local b=bo[u.boi][5]
	 		u.sqd=(#defsqd[b]>
	 									#offsqd[b] or
	 		 u.typ.atk_typ=="seige") and
	 			offsqd[b] or
	 			defsqd[b]
	 		add(u.sqd,u)
	 	end
	 end
 end
end

function nohold(p)
 for k in all(split"r,g,b") do
		if uhold and p[k]!=0 and
			res2[k]-p[k]<uhold[k] then
			return
		end
	end
	return true
end

function ai_prod(u)
	local p=u.prod[u.lastp]
	if not u.q and nohold(p) and
		can_pay(p,2) then
		queue_prod(u,p)
		u.lastp%=u.typ.units
		u.lastp+=1
		res2.tot+=1
	end
end

function ai_unit2(u)
	if u.p==2 then
		if u.typ.bldg and
			(u.hp<u.typ.hp*0.75 or 
			 u.const)
		then
			if u.dead then
			 del(rebuild,u.boi)
			 add(rebuild,u.boi)
			elseif not u.w then
				u.w=deli(miners)
				if (u.w) build(u.w,u)
			end
		elseif u.typ.farm and
		 not u.const and
		 not u.farmer then
			local w=deli(miners)
			if (w) harvest(w,u)
		elseif u.typ.queen then
			if antcount<30 then
				ai_prod(u)
			end
		elseif u.typ.units and
			bo[u.boi][5] then
			ai_prod(u)
		end
		if u.w and
			u.w.st.t!="build" then
			u.w=nil
		end
	elseif u.st.t=="attack" and
		u.st.active and u.x>232 then
		local b=u.y<112 and 1 or
			u.y>208 and 4 or 2
		inv|=b
		movegrp(defsqd[b],u.x,u.y,1)
	end
end

_update60=_update

function ai_bld(boi)
	local bld=bo[boi]
	if bld then
		local p,pid,x,y=unpack(bld)
		local b=ant.prod[pid]
		if res2.tot>=p then
			if can_pay(b,2) then
				pay(b,-1,2)
				unit(b.typ,
					x*8+b.typ.w/2-640,
					y*8+b.typ.h/2,
					2,boi,0)
				if not del(rebuild,boi) then
					res2.bo_idx+=1
				end
			else
				uhold=b
			end
		end
	end
end

function ai_frame()
	if inv==0 then
	 foreach(rebuild,ai_bld)
	end	
	ai_bld(res2.bo_idx)
	for i,sqd in next,offsqd do
		if #sqd>=10 and inv&i==0 then
			while #sqd>0 do
				add(atksqd,deli(sqd))
			end
		end
	end
	movegrp(atksqd,
	 unspl"48,40,1,1")
	inv,miners,antcount,uhold=
		0,{},0
end
-->8
--saving

function save()
	if (menu) return
	local str=""
	for _ENV in all(units) do
		str=str..
		 typ.idx..","..
			x..","..
			y..","..
			p..","..
			tostr(boi)..","..
			tostr(const)..","..
			max(discovered)..","..
			hp..",/"
	end
	for i=1,mapw8*maph8-1 do
		str=str..
		 mget(i%mapw8,i/mapw8)..","
	end
	str=str.."/"
	for k in next,exp do
		str=str..k..","
	end
	str=str.."/"
	for r in all(reskeys) do
		str=str..res1[r]..","..res2[r]..","
	end
	printh(str,"@clip")
end
menuitem(1,"⌂ save to clip",save)

menuitem(2,"◆ load from clip",function()
	init()
	local data=splspl(stat"4","/")
	local r=deli(data)
	for i,k in inext,reskeys do
		i*=2
		res1[k],res2[k]=r[i-1],r[i]
	end
	for k in all(deli(data)) do
		--k can be ""
		exp[k]=tonum(k)
	end
	for i,t in inext,deli(data) do
		mset(i%mapw8,i/mapw8,t)
	end
	for l in all(data) do
		unit(unpack(l))
	end
	for i,b in inext,bo do
		add(i<res2.bo_idx and
		 g(bldgs,b[3]-80,b[4],rebuild)
		 ,i)
	end
	make_dmaps"d"
end)

menuitem(3,"   (paste first)")
menuitem(4,"∧ resign",function() loser=1 end)
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
11000000110001101100880011000110110001100110511081101100000000000000000003300000000000000000000000d00000000000000d00000000000000
0011111100110011001111110011001180110811001100110011001100000000000000000011500000d00000000000100d000000000000003310000000000000
0b0000000b0000b004000000040000400000000000000000000000000000000000000000001300000d0000000001131133100000000000003311310000000000
bb000b00bb000bb04400040044000440000000000000000000000000000000000dd1311331350000331131131131135033113113113113100011311311311310
1100bb00110001101100440011000110000000000000000000000000000000003311311331105000331131131130500000113113113113110505001311311311
00111111001100110011111100110011000000000155000000000000000000003305005050500000050500505050000000505050505050500000005050505050
00000000000000000000000000000000000000000000000000000000000000000050500000000000000505000005050000000000000000000000000000000000
05050500000000000000000000000000000000000000000000000000000000000501515000505050055015100051515000000000000000000000000000000000
50151050050505000050505000505050005050500505050005050500000000000501515005015105500d15150051515000000000000000000000000000000000
501510505015105005015105050511050505115050151500501150500050500050d0d005050151050000d5050005150000000000000000000000000000000000
50050050501510505001510550051105050511505015150050115050051515000000000505dd0005000000050000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
05000000555000000050000000555500000050000055550000700000000000000000000000000000ffffffffeeeeeeeeffffffffffffffffffffffffffffffff
57500000577500000575000005777750000575000577775000700600048800000480080004008800ffff6fffeeeeeeeeffffffffffffffffffffffffffffffff
57750000567755000575555057475500005777505755557506077060048888000488880004888800ffffffffeeeeeeeeffffffffffffffffffffffffffffffff
57775000056540005575757557744000057777505500005560760700048888000488880004888800f6ffffffeeeeeeeeffffffffffffffffffffafffffffffff
57777500005444007577777557544400577774005455554500706760040088000408800004880000ffffff6feeeeeeeeffafffffff7fffffffffffffffffffff
57755000005044505777777557504440057744405494494577077000040000000400000004000000ffffffffeeeeeeeeffffffffffffffffffffffffffffffff
05575000000005000557775005000445005504455494494500600700141000001410000014100000fff6ffffeeeeeeeeffffffffffffffffffffffff7fffffff
00050000000000000005550000000050000000500555555006000070111000001110000011100000ffffffffeeeeeeeeffffffffffffffffffffffffffffffff
fff88fffffffff8fffffffffffffbbbfffffffffffffffffffffffffffffffffffffffff1111d111111d1111ffffffffffffffffffffffffffffffffffffffff
f887888ff8fff888f33fff33fffbb3bfff444fffffff44fffffffff6776fff766fffffff1dd1111111111dd1ffff6fffffffffffffffffffffffffffffffffff
87887878888ff888f3bff3bbffbb3bbfff444ffff4f4444ffffff7666cc666cc667fffff1111111cc1111111fffff5fffffffffffffffff7ffffffffffffffaf
88788788888f8fdfffbbfbffffb3bbbff4494fffff44454fffff67cccccccccccc76ffff1111cccccccc1111f6f5fffffffff7ffffffffffffffffffffffffff
fff77ffffdf888dffffbbbffffbbbbffff544ffff444544ffff76ccccc6cc6ccccc67fff111cccccccccc111fffff5fffffffffffffffffffffffaffffffffff
ff7777fffdd888dfffffbffffffbbfffff9444ff499544fffff6cccc6ccc6ccccccc6fff1d1cccccccccc1d1ff5fff6fffffffffffffffffffffffffffffffff
fff77fffffdfdfdfffffbffffffbffffff5444ff49944fffff66cccc7cccc11ccccc66ff111ccc6666ccc111fff6ffffffffffffffffffffffffffffffffffff
fff77fffffffdfffffffbffffffbffffff445ffff444fffff6c7ccc1111111111ccc7c6f11ccc667766ccc11fffffffffffffffffffffaffffffffffffffffff
fff88ffffffffffffffffffffffffbfffffffffffffffffff66ccc111111111111ccc66f11ccc667766ccc11ffffffffffffffffffffffffffffffffffffffff
f887888ff8fff88fffffffffffffb3fffff4fffffffff4fff6ccc6111dd11111116ccc6f111ccc6666ccc111fffffffffffffffffffffffffffffffff7ffffff
ff8878f8f88ff888f3bfff3fffff3bbffff44ffffff4f44ff7cccc111166111111cccc7f1d1cccccccccc1d1ff2fffffffffffffffffffffffffffffffffffff
f8788fff888f8fdffffbfbffffb3fbffff494fffff44454ff6c6cc111111111111cc6c6f111cccccccccc111f292ffffffffffffffffffffff7fffffffffffff
fff77ffffdff88dffffbbbffffbbbbffff544fffff4454fff66ccc1111111dd111ccc66f1111cccccccc1111f32ffffffffaffffffffffffffffffffffffffff
ff77ffffffd88fdfffffbffffffbbfffff9444fff495ffffff6c6cc1111111111cc6c6ff1111111cc1111111f3ffffffffffffffffffffffffffffffffffffff
fff7ffffffdfdfffffffbffffffbfffffff44fff49944fffff6cccc111dd11111cccc6ff1dd1111111111dd1ffffaffffffffffff7ffffffffffffffffffafff
fff77fffffffdfffffffbffffffbfffffffffffff444fffff76c6c111111111111c6c67f1111d111111d1111ffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffff6c7ccc1111111111ccc7c6fffffff5ffffffff5ffffffffffffffffffffffffffffffffffffffff
ffff8ffffffff8ffffffffffffffbfffffffffffffffffffff66ccccc11cccc7cccc66ff6f555fff6f5555fffffffdffffffffffffffffffffffffffffffffff
ff88f8fff8ffff8fffffffffffff3bbffff44ffffff4f4fffff6ccccccc6ccc6cccc6ffff55555f5f533555fffffd6dfffffffffffffffffffffffffffffffff
f8788ffff88fffdffffffbffffb3fbffff494ffffff4444ffff76ccccc6cc6ccccc67ffff555565ff535535ffffffd3ffffffffffffffaffffffffff7fffffff
ffff7ffffdff8ffffffbbfffffffbbfffff44fffff4454ffffff67cccccccccccc76fffff565555ff555555fffffff3ff7ffffffffffffffffffffffffffffff
fff7ffffffd88fdfffffbffffffbfffffff45ffff4944ffffffff766cc666cc6667ffffff566555ff53555f6ffafffffffffffffffffffffffffffffffffffff
fff7ffffffdfdfffffffbffffffbfffffff4ffffff4ffffffffffff667fff6776fffffffff5555f6ff555fffffffffffffffffffffffffffffffffffffffffff
fff77fffffffffffffffbffffffffffffffffffffffffffffffffffffffffffffffffffff6ffffff6fffff5fffffffffffffffffffffffffffffffffffffffff
0000000000000000080000000bb0000004000000101000000000000000000000000000000000000000000000dd00000000000080000005000000050000000000
000770000077770088800000bbb0000044000000101000000d000000000000000000000000000000dd6000000600000000000088050050500050500000000000
000770000744447088800000bb00000004000000c1c00000600006600d0000000dd000000000000000510061051000168080888885555050dd50522226600000
0007700074444447060000000b00000004400000c1c000005100016060000660600006600000000005d100665d100066000000880e5e550d7ddddd2267600000
0007700044444444060000000b00000004000000111000000d16610051166160511661600d000660505d661000d1661000300080055554d7d05d5d4676000000
000000004444444400000000000000000000000000000000001d1d000d1d1d0001d1d1d061d6d1600000d1d005001d104300b000b000504d00dddd2462000000
000770004444444400000000000000000000000000000000000000000000000000000000000000000000000000000000430000b0050504040005054045000000
00000000444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000
0000000000000000050000050000000000000000d0000000000000000000000000555500eeeeeeeeeeeeeeeeeeee000000000000000d00d00000005000000000
0002000202909092505000505000005000500d00d00d220002200000d0000d0005777750eeeeeeeeeeeeeeeeeeee0000000220b00d777d000050057506000000
00002020002999205055555050000005050000d777d00020200000000d00d00000557475eeeeeeeeeeeeeeeeeeee00002020b00dd7555700dd55560770600000
0000444040444400055e5e550002222505000075557000444000b0000333300088844775eeeeeeeeeeeeeeeeeeee0000444000d7d544450d7de5e57607000000
44047474444e4e0050555550502622dddd0d0054445044e4e0b000000b33b00800484575eeeeeeeeeeeeeeeeeeee0000e4eb4d7d04e4e4d7d055567067600000
404044404504400050500050502266d5d507d04e4e4040444b0001331333300808480575eeeeeeeeeeeeeeeeeeee0000444004d00044404d0006650770000000
050504055050050050050500502222dddd0444044400050b050b01331110000854480050eeeeeeeeeeeeeeeeeeee00005b054040050004040050506006000000
000000000000000005000005005050505000505000500000b00000505000000088800000eeeeeeeeeeeeeeeeeeee000000b00000000000000000000000000000
0000b000444744444000000000000000000000000000000002200000f66c6c6fcfc6c66feeeeeeeeeeeeeeeeeeee000000000000880055088000000555000000
000b350044474464400087000070000707000000000000002dd20000f6c6f6ccfb6f6c6feeeeeeeeeeeeeeeeeeee000000990990088577880000005775000000
00b333504464774640878878000744447000000000000002d4dd2000f76b6b6f6fc6b67feeeeeeeeeeeeeeeeeeee000009889889008878850000557765000000
0b4444454647647440788888007441144000000400000002ddd42000f6c6cfb6c6fb6c6feeeeeeeeeeeeeeeeeeee000009888889057888500088845650000000
00411d404447467643437753344411114400004110000002d4dd2000f66bfc6f6fcfc66feeeeeeeeeeeeeeeeeeee000009888889577888400800484500000000
00411d4047747744445377334547155114700451140000402dd20000ff6c6fbc6bf6b6ff44444444444444444444000000988890058848840808480500000000
00444440444644744532772453741551470045544540041402200000ff6fcc6f66ccf6ff44000004000040000044000000098900088504885800580000000000
00044400444444474342222534074114407054545450454540000000f76c6cf6cfc6c67f44040404044040444044000000009000880000588088800000000000
00000000000000001dd11111dd1111dd113331111133331100000000000000000000000044040404000040000044000000000000004000440000000800000000
05000500005050501511151111121211133831111b333b3100000000000000000000700044044404044040444444000000055500004400444000008880000000
575057500040404011545111115141513bfbfb1133bbbf3300000000000000000000770044044404044040444444000000500050444440004001188888000000
74707470b0044400111411111115451133bbb33333bbbb8300000000000000000000777044444444444444444444000005000005404400404015551800000000
0400040b35041400115451111111411133bbb33333bbbf330000000000000000000077e000000000000000000000000005686bb540b0044041d5e5d800000000
4111114333541400151415111115451133bbb3333b333b11000000000000000000007e00000000000000000000000000054949454bbb44444015551800000000
4d111d451504440011212111115111511b333b311333311100000000000000000000e0000000000000000000000000000549494544b004400001110000000000
4d404d4454544444dd1111dd11111dd1113333111133311100000000000000000000000000000000000000000000000000555550044000400000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044004400000000
0000000000000000000400000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000444404440000000
000400000000000000411000000000000000000000b3500000000000000000000000000000000000000000000000000000000000000000004044000040000000
00411000000400000451140000000000000000000b33350000000000000000000000000000000000000000000000000000000000000000004040004040000000
0451140000411000455445400000000000000000b444445000000000000000000000000000000000000000000000000000000000000000004000044040000000
45544540045114005454545005000500000000000411d40000000000000000000000000000000000000000000000000000000000000000004440444400000000
00000000000000000000000004444400000000000411d40000000000000000000000000000000000000000000000000000000000000000000440044000000000
00000000000000006000060604111400000000000444440000000060000600600005060000056050000006050000060000000000000000000000004000000000
00000000000000000744447004444400005050000411d40000060600000565060056050000000565000060600000000600000000000000000999999005555550
00744070000000007441144000414000004140000444440000056560005050500000565000606000000000000000000000000000000000009929929955255255
0741140000000000441111440044400000414000004140000050555000a005000060600000000000000000000000000000000000000000009929929955255255
04151140000470004715511400414000004140000044400000a0aa000aaa0aa000a00a0000a005000000050000000000000000000000000099d44d9955d44d55
0411114000414400741551460041450000404500004140000a9aa9a50a99a9950a95a9a5059a59a505a65a650075050000750500007505009944449955444455
0741140000444400074114400000000000000000004145505989989559899895598998955a89a895569a69a50576576005765760057657600999999005555550
00000000000000000000000000000000000000000000000028222822288288222282828225228522552852525657657556576575565765750000000000000000
000000000000000000000000509030b0505500000005060000000000000600600000000000000000000000000000000000000000000000000000000000000000
00000000000000000500050000000000550500000006000000060500000500060999999005555550000000000000000000000000000000000000000000000000
00000000000000005750575000000000000000000000060000056060000060509979979955655655000000000000000000000000000000000000000000000000
0500050000000000747074700000000000000000000060000050500000a0000097d77d7956566565000000000000000000000000000000005050500000505050
040004000000000004000400000000000000000000a00a0000a0a000000a0a009941149955411455000000000000000000000000000000004040400000404040
01111100001110004111114000000000000000000099a0000a9aa9000099a9009944449955444455005000000000000000000000000000000444000b00044400
44111440501110504d111d4000000000000000000a889000098890000a899000099999900555555005150000000000000000000000000000041400b350041400
40404040404040404d404d40000000000000000000920000002900000028000000000000000000000414000300000000000000000000000004140b3335041400
000000000000000034533453345334533453345334533453030334500000000022aaa22000000000044403313300000000000000000000000444b33133544400
434b4043434040b04533453345334533453875334533453343434345000000002a999a2000030000041405111505000000000000000000000414051115041400
554355b343b30000533453345334533458788784533873345543553300000000a99899a000333000041455555554050000000000000000000414555555541400
34435343044043b0334533453347884538888885338888453443534000000000a98689a001131100044454545454440000000505050000000444545454544400
3b0b40550300b0b4345334533458885334377453345374530334435500000000a99899a004111400044444444444450000000444444005000444444544444500
455b3453b0b004404533453345337533453775334537753345533453000000002a999a2040111040045444414444440000005441444055000454445154444400
454445b3b04b400053345334533473345357753453377334454445330000000022aaa22040404040044444111444540005004411144044000444451115445400
05335540030033b03345334533453345335555453345334505035540000000000000000000000000044544111444440004404411144044000445451115444400
__label__
555555555555555555555555555ddddd111111111111111111111111111111111111111111ddddd555dddddd5555555555555555555555555555555555555555
555555555555555555655555555ddddd111dd111111dd111111dd111111dd111111dd11111ddddd5555dddd5d555555555555555555555555565555555555555
555555555555555555555555556dddd11111111111111111111111111111111111111111111dddd655d555555555555555555555555555555555555555555555
55555555555555555555555555ddddd11111111111111111111111111111111111111d1111ddd6dd555555555555555555555555555555555555555555555555
55555555555555555555555555ddddd111dd111111dd111111dd111111dd111111dd11111dddddd5555555555555555555555555555555555555555555555555
555555555555555555555555556dddd1111dd111111dd111111dd111111dd11111111111dddddd55555555555555555555555555555555555555555555555555
56555555555555555555555555ddddd11111111111111111111111111111111111111dddddddd655555555555555555556555555555555555555555555555555
55555555556555555555555555ddddd1111111dd111111dd111111dd111111dd1111ddddddd6d555555555555555555555555555556555555555555555555555
555555555555555555555555555ddddd1111111111111111111111111111111111d1ddddddd65555555555555555555555555555555555555555555555555555
555555555555555555555555555ddddd111dd111111dd111111dd111111dd1111111dddddd555555555555555555555555555555555555555555555555555555
555555555555555555555555556dddd111111111111111111111111111111111111ddddd65555555555555555555555555555555555555555555555555555555
55555555555555555555555555ddddd111111111111111111111111111111111111ddddd55555555555555555555555555555555555555555555555555555555
5555555555555555555555d555ddddd111dd111111dd111111dd111111dd1111111ddddd555555d5555555555555555555555555555555555555555555555555
555555555555555555555ddd556dddd1111dd111111dd111111dd111111dd111111dddd655555ddd55555555555555555555555555555555555555555555556d
5555555555555555555555d355ddddd111111111111111111111111111111111111ddddd555555d3555555555555555555555555555555555555555555555d6d
55555555555555555555555355ddddd1111111dd111111dd111111dd111111dd111ddddd55555553555655555555555555555555555555555556555555556ddd
555555555555555555555555555ddddd1111111111111111111111111111111111ddddd55555555555555555555555555555555555555555555555555555dddd
565555555555555555555555555ddddd111dd111111dd111111dd111111dd11111ddddd5555555555555555555555555565555555555555555555555555ddddd
555555555555555555555555556dddd111111111111111111111111111111111111dddd655555555555555555555555555555555555555555555555555dd6ddd
55555555555555555555555d55ddddd11111111111111d11111111111111111111ddd6dd55555555555555555555555555555555555555555555555555ddddd1
55555555555555555d5ddd5555ddddd111dd111111dd11111d11dddd6d11dddd6dddddd555555555555555555555555555555555555555555555555555ddddd1
555555555555555555ddddd5d56dddd1111dd11111111111dddddddddddddddddddddd55555555555555555565555555555555555555555555555555656dddd1
555555555555556555dddddd55ddddd11111111111111dddddddddddddddddddddddd65555555565555555555555555555555555555555655555555555ddddd1
555555555555555555dddddd55ddddd1111111dd1111ddddddddddddddddddddddd6d55555555555555555555555555555555555555555555555555555ddddd1
555555555555555555dddddd555ddddd1111111111d1ddddddddddddddddddddddd65555555555555555555555555555555555555555555555555555555ddddd
5555555555555555555dddd5d55ddddd111dd1111111dddddd6555d66d6555d66d555555555555555555555555555555555555555555555555555555555ddddd
555555555555555555d55555556dddd111111111111ddddd655555555555555555555555555555555555555555555555555555555555555555555555556dddd1
55555555555555555555555555dd6ddd1111111111ddd6dd55555555d55555555555555555555555555555555555555555555555555555555555555555ddddd1
556555555555555555555555555ddddddd11dddd6dddddd55d5dddd5555555555565555555555555555555555555555555655555555555555555555555ddddd1
5555555555555555555555555555dddddddddddddddddd5555d33ddd5555555555555555555555555555555555555555555555555555555555555555556dddd1
55555555555555555555555555556dddddddddddddddd65555d3dd3d555655555555555555555555555555555556555555555555555555555555555555ddddd1
55555555555555555555555555555d6dddddddddddd6d55555dddddd555555555555555555555555555555555555555555555555555555555555555555ddddd1
5555555555555555555555555555556dddddddddd111155555d11115d555555555555555552222555555222255555555555555555555555555555555555ddddd
55555555555555555565555555555555dd6555d661111555555111155555555555555555552222555565222255555555555555555555555555655555555ddddd
5555555555555555555555555551111115555555500001155110000d5555555555555555550000225522000055555555222222555555555555555555556dddd1
555555555555555555555555555111111555555555555115511555555555555d55555555555555225522555555555555222222555555555555555555d5dd6ddd
555555555555555555555555511111111551111115544444444555555d5ddd555555555555555544444444552222225522222222555555555d5dddd5555ddddd
5555555555555555555555555111111115511111155444444445555555ddddd5d5555555555555444444445522222255222222225555555555d33ddd5555dddd
5655555555555555555555555111100114444111144440044005555555dddddd56555555555555004400444422224444220022225555555555d3dd3d55556ddd
5555555555655555555555555111155114444111144440044005555555dddddd55555555556555004400444422224444225522225565555555dddddd55555d6d
5555555555555555555555555111155444444000044004444555555555dddddd55555555555555554444004400004444445522225555555555d3ddd5d555556d
55555555555555555555555551111554444445555445544445555555555dddd5d55555555555555544445544555544444455222255555555555ddd5555555555
5555555555555555555555555000044004400554400440000445555555d555555555555555555544000044004455004400440000555555555d55555d55555555
555555555555555555555555555554455445555445544555544555555555555555555555555555445555445544555544554455555555555d5555555555555555
555555555555555555555555555550055005555005500555500555555555555555555555555555005555005500555500550055555d5ddd555555555555555555
5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555ddddd5d555555555555555
5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555dddddd5555555555555555
5555555555555555555655555555555555555555555555555556555555555555555555555555555555565555555555555555555555dddddd5556555555555555
5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555dddddd5555555555555555
56555555555555555555577777755557777557777775555555555557777557777775555555555777777557777555577777755557777dddd5d555555555555555
55555555555555555555577777705557777057777770555555555557777057777770555555555777777057777055577777705557777055555555555555555555
55555555555555555555577007705775000057700000555555555775077057700000555555555770077057700775550770005775000055555555555555555555
55555555555555555555577057705770555557705555555555555770577057705555555555555770577057705770555770555770555555555555555555555555
55555555555555555555577777705770555557777555555555555770677057777555555555555777777057706770555770555777777555555555555565555555
55555555555555655555577777705770555557777055556555555770577057777055555555555777777057705770555770555777777055655555555555555555
55555555555555555555577007705770577557700055555555555770577057700055555555555770077057705770555770555500077055555555555555555555
55555555555555555555577057705770577057705555555555555770577057705555555555555770577057705770555770555555577055555555555555555555
55555555555555555555577057705777777057777775555555555777750057705555555555555770577057705770555770555777750055555555555555555555
55555555555555555555577057705777777057777770555555555777705557705555555555555770577057705770555770555777705555555555555555555555
55555555555555555555550055005500000055000000555555555500005555005555555555555500550055005500555500555500005555555555555555555555
55655555555555555555555555555555556555555555555555555555555555555565555555555555555555555555555555655555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555565555555555555555555555555555555655555555555555555555555555555556555555555555555555555555555555565555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555565555555555555555555ccc5ccc55555cc55ccc5ccc5ccc5ccc55cc5c5c5c555ccc5c5c555555555555555555555555565555555555555
55555555555555555555555555555555555555c0c50c055555c0c50c05c005c0050c05c005c5c5c5550c05c5c55c555555555555555555555555555555555555
55555555555555555555555555555555555555ccc55c555555c5c55c55cc55cc555c55c555c5c5c5555c55ccc550555555555555555555555555555555555555
55555555555555555555555555555555555555c0c55c555555c5c55c55c055c0555c55c555c5c5c5555c5500c55c555555555555555555555555555555555555
55555555555555555555555555555555555555c5c5ccc55555ccc5ccc5c555c555ccc50cc50cc5ccc55c55ccc550555555555555555555555555555555555555
56555555555555555555555555555555565555050500055555000500050555055600055005500500055055000555555556555555555555555555555555555555
55555555556555555555555555555555555555555565555555555555555555555555555555655555553555555555555555555555556555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555553555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555555555555555555555555555565555555555555d6665556dbbb5bbbd6bb5b5bd66d5656d66d5556d66d5556dd555555555555555555555555555555
55555555555555555555555555555555555555555555556ddd66dddddb00db0bdb00dbdbddddd66dddddddddddddddddddd65555555555555555555555555555
555555555555555555555555555655555555555555555d6dd666dddddbbddbbbdbbbdbbbddddd666ddddddddddddddddddd6d555555555555555555555555555
555555555555555555555555555555555555555555556dddd066dddddb0ddb0bd00bd00bddddd660ddddddddddddddddddddd655555555555556555555555555
55555555555555555555555555555555555555555555dddddd06dddddbbbdbdbdbb0dbbbddddd60ddddddddddddddddddddddd55555555555555555555555555
5655555555555555556555555555555555555555555dddddd6d0dd11d000d010d00dd000d6ddd011d6dddd11d6dddd11ddddddd5555555555555555555555555
555555555555555555555555555555555555555555dd6ddd11111111111111111111111111111111111111111111111111ddd6dd555555555555555555555555
55555555555555555555555555555555d555555556ddddd111111111111111111111111111111d11111111111111d111111ddddd6555555555555555d5555555
5555555555555555555555555d5dddd555555555dddddd1111dd111111dd111111dd111111dd11111d11dddd611111dd1111dddddd5555555d5dddd555555555
55555555555555555555555555d33ddd5555556ddddddd1d111dd111111dd111111dd11111111111dddddddddd11111111d1ddddddd6555555d33ddd55555555
55555555555555655556555555d3dd3d55555d6ddddddd1111111111111111111111111111111dddddddddddddddd1111111ddddddd6d55555d3dd3d55555555
55555555555555555535555555dddddd55556dddddddd111111111dd111111dd111111dd1111dddddddddddddddddd1111111dddddddd65555dddddd55555555
55555555555555555535555555d3dd9995999d999d19911991111119999911111199911991d1ddd99d999d999d999d9991111111dddddd5555d3ddd5d5555555
555555555555555555555555555ddd9095909d9001900190011dd19909099111110901909111dd900d0905909d909d0901dd11111dddddd5555ddd5555555555
5555555555555555555555555d55559995990d9911999199911111999099911111191191911ddd999559559996990dd911111d1111ddd6dd5d55555d55555555
555555555555555555555555d555559006909d9011009100911111990909911111191191911ddd009559559095909dd911111111111ddddd5555555555555555
55655555555555555d5dddd555555595dd9d9d999199019901dd11099999011111d91199011ddd9905595595959d9dd911dd1111111ddddd5555555555555555
555555555555555555d33ddd5555550ddd0d0d000100d100111dd1100000d1111110d100111ddd0055505505050d0dd0111dd111111dddd65555555555555555
555555555555555555d3dd3d55555d6ddddddd1111111111111111111111111111111111111ddddd5555555555ddddd111111111111ddddd5555555555565555
555555555555555555dddddd55556dddddddd111111111dd111111dd111111dd111111dd111ddddd5555555555ddddd1111111dd111ddddd5555555555555555
555555555555555555d3ddd5d555dddddd1111111111111111111111111111111111111111ddddd555555555555ddddd1111111111ddddd55555555555555555
5555555555555555555ddd55555dddddd11111dd111dd111111dd111111dd111111dd11111ddddd555555555555ddddd111dd11111ddddd55565555555555555
55555555555555555d55555d55dd6ddd1111d11111111111111111111111111111111111111dddd655555555556dddd111111111111dddd65555555555555555
55555555555555555555555556ddddd11111111111111111111111111111111111111111111ddddd6555555556ddddd111111d1111ddd6dd5555555555555555
555555555555555555555555dddddd1111dd111111dd111111dd111111dd111111dd11111111ddddd66d5556dddddd1111dd11111dddddd55555555555555555
55555555555555555555556ddddddd1d111dd111111dd111111dd111111dd111111dd11111d1dddddddddddddddddd1d11111111dddddd555555555555555555
565555555555555555555d6ddddddd1111111111111111111111111111111111111111111111dddddddddddddddddd1111111dddddddd6555555555555555555
555555555565555555556dddddddd111111111dd111111dd111111dd111111dd111111dd11111dddddddddddddddd1111111ddddddd6d5555555555555555555
55555555555555555555dddddd111111111111111111111111111111111111111111111111111111dddddddddd11111111d1ddddddd655555555555555555555
5555555555555555555dddddd11111dd111dd111111dd111111dd111111dd111111dd11111dd111116dddd11d11111dd1111dddddd5555555555555555555555
555555555555555555dd6ddd1111d111111111111111111111111111111111111111111111111d11111111111111d111111ddddd655555555555555555555555
555555555555555555ddddd1111111111111111111111111111111111111111111111111111111111111111111111111111ddddd555555555555555555555555
555555555555555555ddddd111dd111111dd111111dd111111dd111111dd111111dd111111dd111111dd111111dd1111111ddddd555555555555555555555555
5555555555555555556dddd1111dd111111dd111111dd111111dd111111dd111111dd111111dd111111dd111111dd111111dddd6555555555555555555555555
555555555555555555ddddd1111111111111111111111111111111111111111111111111111111111111111111111111111ddddd555555555555555555555555
555555555555555555ddddd1111111dd111111dd111111dd111111dd111111dd111111dd111111dd111111dd111111dd111ddddd555555555556555555555555
5555555555555555555ddddd11111111111111111111111111111111111111111111111111111111111111111111111111ddddd5555555555555555555555555
5655555555555555555ddddd111dd111111dd111111dd111111dd111111dd111111dd111111dd111111dd111111dd11111ddddd5555555555555555555555555
5555555555555555556dddd1111111111111111111111111111111111111111111111111111111111111111111111111111dddd6555555555555555555555555
555555555555555555dd6ddd1111d1111111111111111111111111111111111111111111111111111111111111111111111ddddd55555ddd5555555555555555
5555555555335553355dddddd11111dd11dd111111dd111111dd111111dd111111dd111111dd111111dd111111dd1111111ddddd5555dd3d5555555555555555
55555555553d553dd555dddddd111111111dd111111dd111111dd111111dd111111dd111111dd111111dd111111dd111111dddd6555dd3dd5555555565555555
55555555555dd5d555556dddddddd1111111111111111111111111111111111111111111111111111111111111111111111ddddd555d3ddd6665555566555555
555555555555ddd555555d6ddddddd11111111dd111111dd111111dd111111dd111111dd111111dd111111dd111111dd111ddddd555d6d656065555506555555
5555555555555d555555556ddddddd1d111111111111111111111111111111111111111111111111111111111111111111ddddd555556d656565555556555555
5555555555555d5555555555dddddd11111dd111111dd111111dd111111dd111111dd111111dd111111dd111111dd11111ddddd5555566656565555556555555
5555555555555d555555555556ddddd11111111111111111111111111111111111111111111111111111111111111111111dddd6555506056665565566655555
555555555555225555555ddd55dd6ddd11111111111111111111d1111111111111111d1111111111111111111111111111ddd6dd555550dd000550dd00055555
55335553352262225555dd3d555ddddddd11dddd6d11dddd611111dd11dd111111dd11111d11dddd6d11dddd6d11dddd6dddddd55555dd3d5555dd3d55555555
553d553dd2622626255dd3dd5555dddddddddddddddddddddd111111111dd11111111111dddddddddddddddddddddddddddddd55555dd3dd555dd3dd55555555
555dd5d552262262255d3ddd55556dddddddddddddddddddddddd1111111111111111dddddddddddddddddddddddddddddddd655555d3ddd555d3ddd55565555
5555ddd555556655555dddd555555d6ddddddddddddddddddddddd11111111dd1111ddddddddddddddddddddddddddddddd6d555555dddd5555dddd555555555

__gff__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007070b0b13130121012121000000000007070b0b131321a1212121000000000007070b0b131301210101010000000000
0000000000000000000000000000000000000000000000000000000000000000000000000707002121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
54545454545454555253525352525352525151545454545454555454535353525353555554546c4f4c4d4e4f7b5252524b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b525151545454545454555454535353525353555554546c4f4c4d4e4f7b525252
545454545554545f7b525353535253524c4d545455545554545454555352525353545455546c5e5f5c5352535c5353524b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4c4d545455545554545454555352525353545455546c5e5f5c5352535c535352
5454515454546e6f6c535253535252525c5d5e55545454555455545455535352545455546c6d4c5657585350505253524b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5c5d5e55545454555455545455535352545455546c6d4c565758535050525352
545455547c7d7e507c5350505352537f6c6d6e6f555454545454557c7d7e7f7c7d7e7f7c7c7d566a67695853535352544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b6c6d6e6f555454545454557c7d7e7f7c7d7e7f7c7c7d566a6769585353535254
5454554f4c4d4e4f4c4d5253524d4c4f7c7d7e7f5f51525253524f4c4d4e4f4c4d4e4f4c4c4d6667b3676852525554544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b7c7d7e7f5f51525253524f4c4d4e4f4c4d4e4feeef4d66676767685252555454
54546e5f5c5d7e5f5c5d5e5f5c5d5e5f5c6c6d6e6f5e5253525e5f5c5d5e5f5c5d5e5f5f5c5d66676759785f535455554b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5c6c6d6e6f5e5253525e5f5c5d5e5f5c5d5e5ffeff5d6667675978c253545555
54546e51516d6e6f6c6d6e6f6c6d6e6f6c7c7d7e7f6e6e52526e6f6c6d54545454556f6f6c6d767777786e6f6c5554544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b6c7c7d7e7f6e6e52526e6f6c6d54545454556f6f6c6d767777786e6f6c555454
54557e7f7c7d7e7f517e7f7d7e7f565757587c6b7e7e7f7c7d7e7f7b555454555554547f7c7d7e7f7c7d7e7f7c7d55554b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b57587c6b7e7e7f7c7d7e7f7b555454555554547f7c7d7e7fc57d7e7f7c7d5555
5452534f4c4d4e4f4c4e4f4d4e6b66676769584d4e4e4f4c4d4e4f525254555154544f4f4c4d4e4f4c4d4e4f4c4d54554b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b6769584d4e4e4f4c4d4e4f52525455515454c24f4c4d4e4fd5e2d24f4c4d5455
525253525c5d5e5f5c5e5f5d56576a67b367685d7a5e5f5c5d5e52535352545555555f5f5c7b5e5f5c5d5e5f5c5e55544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4bb367685d7a5e5f5c5d5e52535352545555555f5f5c7b5e5f5c5d5e5f5cc25554
5253525253526e6f6c6e6f6d66676767676768796e6e6f6c6d6e535253525254544c6c6d6e6f6c5657584e7f6c5554544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b676768796e6e6f6c6d6e535253525254544c6c6d6e6f6c5657584e7f6c555454
5252505252527e7f7c7e7f7d6667b5676759787d7e7e7f7c7d7e5353505253534c6f7c7d7e56576a67685e4f7c5253534b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b6759787d7e7e7f7c7d7e5353505253534c6feeef7e56576a67685e4f7c525353
52535352524d4e4f4c4e4f7b6667676767687b4d4e4e4f4c4d4e7b52535352524d7f4c4d566a6767b2686e5f4c5352524b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b67687b4d4e4e4f4c4d4e7b52535352524d7ffeff566a676767686e5fc2535252
525253535c5d5e5f5c5e5f796667597777785c5d5e5e5f5c5d5e5f5c5252535c5d4f5c6b6667b56759787e6f525253534b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b77785c5d5e5e5f5c5d5e5f5c5252535c5d4f5c6b6667676759787e6f52525353
526d6e6f6c6d6e6f6c6e6f6d7677787a526f6c6d6e796f6c6d6e6f6c6d6e6f6c6d5f6c6d66676759786f4e7f525352534b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b526f6c6d6e796f6c6d6e6f6c6d6e6f6c6d5f6c6d66676759786f4e7f52535253
7c7d536b527d7e7f7c7e7f7d7e7f7c7d797f7c7d7e7e7f7c6b7e7f7c7d7e7f7c7d6f7c7a76777778537f5e4f535253534b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b797f7c7d7e7e7f7c6b7e7f7c7d7e7f7c7d6f7c7a76777778537f5e4f53525353
4c52565757584e4f4c4d4e4f4c4d4e4f4c4d4e4c6b4e4f4c4d4e4f794d4e4f4c4d7f7f7f7c7d7e4c7c7d7e5f535252534b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4c4d4e4c6b4e4f4c4d4e4f794d4e4f4c4d7f7f7f7c7dc54ce27d7ec253525253
505166b367687b5f5c5d5e5f5c5d5e5f5c5d5e5c5d5e5f5c5d5e5f5c5d5e5f5c5d4f4c4d4e4f4c4d4e4f5e53535353534b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5c5d5e5c5d5e5f5c5d5e5f5c5d5e5f5c5d4feeef4e4fd54d4e4f5e5353535353
5150666759784c4d4e4f4c4d4e4f4c4d4e4f7b4d4e4f7b7c7d7e7f7c7d7e527c6b7e7f7f7c7d6e6f6c6d6e52525053534b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4e4f7b4d4e4f7b7c7d7e7f7c7d7e527c6b7efeff7c7d6e6fe26d6e5252505353
7c52767778515c5d5e5f53525352535d5e5f5c5d5e5f7f4f4c6d6e5256575757575757587a4d7e7f7c7d5253525350534b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5e5f5c5d5e5f7f4f4c6d6e5256575757575757587a4dc27f7c7d525352535053
4c545452524d6c6d6e52525253525252796f6c6d796f4e5f5c6b7a566a67676759775a69586d4e4f4c4d4e53535352524b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b796f6c6d796f4e5f5c6b7a566a67676759775a6958c54e4fd24dc25353535252
5c5d55535c5d7c7d53525352525253527a7f7c7d7e7f5e6f6c7a566a67676767684c6667686d5e5f5c5d515f525253524b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b7a7f7c7d7e7f5e6f6c7a566a67676767684c666768d5d25f5c5d51c252525352
7b6d6e6f6c6d4c4d525252535253525252534c4d4e4f6e7f7c566a676767b36769576a59787d6e6f6c6d6e6f6c6d6e6f4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b52534c4d4e4f6e7f7c566a676767b36769576a59787d6e6ff2f2f2f26c6d6ec2
527d7e7f7c7d5c5d50535253525252545454535d5e5f7e4f4c66676767b46767b26767686c4d7e7f7c7d7e7f7c507e7f4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5454535d5e5f7e4f4c66676767b46767b26767686c4dc57ff20809f27c507e7f
5252534f4c4d6c6d6e525252525353535454546d6e6f4e5f52765a676767676767676768535d4e4f4c4d4e4f4c4d4e544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5454546d6e6f4e5f52765a676767676767676768535dd54ff2f2f2f2f2f2f254
5353525f5c5d7c7d7e535252535454545454557d7e7f5e5250537677775a67597777777853535e5f5c5d5e5f5c5d55544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5454557d7e7f5e5250537677775a67597777777853535e5f5c5d5e5ff2c25554
5252516f6c6d4c4d4e505455545455545454554d4e4f6e7f505253535376777853505253527d6e6f51516e6f6c5554544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5454554d4e4f6e7f50525353537677785350525352c26e6f5151f2f2f2555454
525251547c7d5c5d5e5f5454545454545554545d5e5f7e4e4f4d53525353525353525353534d7e7f7c7d7e7f545554544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5554545d5e5f7e4e4f4d53525353525353525353534d7e7f7cf2f2c254555454
5253555554546c6d6e6f6c545554545554546c4c4d4e4f5e5f5d5e5f53525353525d5e5f5c5d4e4f4c4d4e54555455544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b54546c4c4d4e4f5e5f5d5e5f5352535352c25ee25c5d4ec24cf2c25455545554
535454545554557d7e7f7c7d7e6b7c7d7e7f7c5c565757585d5e5f5c5d5e5f5c5d4f4c4d4e4f5e5455545455545454544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b7e7f7c5c565757585d5e5f5c5d5e5f5c5d4fc54d4e4f5e545554545554545454
54555455555454556c6d6e6f6c6d6e6f6c6d6e566a676769586e6f4c4d4c6e6f4d4c4d4c4d6d545454545554545455544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b6c6d6e566a676769586e6f4c4d4c6e6fc54cd54c4d6d54545454555454545554
5454545454545454547d7e7f7c7d7e7f7c7d5d666767b46769587f5c5d5c7e7f5d5c5d5c5d55555455545454555454544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b7c7d5d666767676769587f5c5d5c7e7fd55c5d5c5d5555545554545455545454
__sfx__
0001000027000000001f000200002200024000270002900029000290002800027000250002200020000200001f0001e0001e0001f00020000220002400024000210001d0001b0001900017000170000000000000
