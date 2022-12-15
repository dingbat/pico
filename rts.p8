pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--main loop

function _draw()
 --cls() not needed!
 draw_map(0) --mainmap
	if menu then
		camera()
		sspr(unspl"40,88,31,8,49,75")
	 --mascots
	 --42 tok (replace with pal())
	 local x=64+t()\0.5%2*16
	 pal(split"0,5,0,0,0,0,0,0,0,0,0,0,0,0,0")
	 sspr(x,unspl"0,16,8,25,31,32,16")
	 sspr(x,unspl"0,16,8,72,31,32,16,1")
	 pal(split"1,0,3,4,4,6,7,8,9,10,11,12,13,14,15")
	 sspr(x,unspl"0,16,8,25,30,32,16")
	 pal(1,2)
	 sspr(x,unspl"0,16,8,72,30,32,16,1")
	 --
--  pal()
		?"\f0\^w\^tage of ants\-0\-0\-0\-0\-0\-7\|f\f7age of ants\n \^-w\^-t\|l\f0  ai difficulty:\-0\-0\-0\-8\|f\fcai difficulty:\n\n\n\f0  press ❎ to start\-0\-0\-0\-0\-c\|f\f9press ❎ to start\|z\|s\-q\f0V0.1\-0\|f\f6V0.1",22,50
		?split"\f0easy\-0\|f\fbeasy,\f0\-jmed\-4\|f\famed,\f0hard\-0\|f\fehard"[ai_diff+1],57,77
		return
	end

 local bf,af={},{}
 for u in all(units) do
		if
			not loser and
		 not g(viz,u.x\8,u.y\8)
		 and u.discovered
		then
 		add(af,u)
 	elseif u.typ.bldg then
	 	draw_unit(u)
	 else
	 	add(bf,u)
	 end
 end

	if sel_typ==farm and
		not sel1.const then
	 rectaround(sel1,9)
	end

	foreach(bf,draw_unit)
	foreach(proj,draw_projectile)

	if loser then
		camera()
		rectfill(unspl"0,96,128,115,9")
		pal(2,0)
	 sspr(64+
	 	({48,t()\0.2%3*16})[loser],
	 	unspl"0,16,8,14,98,32,16")
	 pal()		
		?split"\#9\|d\-0\*8 \-0\-4\-e\|h\f2easy ai,\#9\|d\-0\*a \-0\-0\-a\|h\f2medium ai,\#9\|d\-0\*8 \-0\-4\-e\|h\f2hard ai"[ai_diff+1],22,93
	 ?split"\^w\^t\fa\|gyou lose\-0\-0\-0\-0\|f\f1you lose,\^w\^t\fa\|gyou win!\-0\-0\-0\-0\|f\f1you win!"[loser],53,102
	 ?"\f4\#9\|k\-0\-4\*j \-0\-0\-0\-e\|d\-0\-a\|ipress ❎ for menu"
	 return
	end
	
 pal(split"0,5,13,13,13,13,6,2,6,6,13,13,13,0,5")
	draw_map(mapw8) --map
	
	_pal,pal=pal,max
	foreach(af,draw_unit)
	pal=_pal
	pal()
	
	fillp"23130.5"--▒
	
	for x=cx\8,cx\8+16 do
	for y=cy\8,cy\8+16 do
 	local i=x|y<<8
		camera(x*-8+cx,y*-8+cy)
	 color(not fget(mget(x,y),7)
	 	and exp[i] and 5)
		
		borders(exp,i)
	 borders(viz,i)
	end
	end
	
	camera(cx,cy)

	if selx then
		rect(unpack(selbox))
	end
	
	fillp()
	
	--rally
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
		local typ,x,y=to_build.typ,
			to_build.x-cx,to_build.y-cy
		
		pal(buildable() or
		 split"8,8,8,8,8,8,8,8,8,8,8,8,8,8,8"
		)
		--menuy
		if amy>=104 then
			x,y=amx,amy
		else
			fillp"23130.5"--▒
			rect(x-1,y-1,x+typ.fw,
			 y+typ.fh,3)
	 	fillp()
	 end
		sspr(typ.rest_x,typ.rest_y,
		 typ.fw,typ.h,x,y)
		pal()
	end
	
	if hilite and hilite.circ then
		circ(unpack(hilite.circ))
	end
	
	spr(cursor_spr(),amx,amy)
end

function _update()
	if menu then
		cx+=cvx
		cy+=cvy
		if (cx%256==0) cvx*=-1
		if (cy%120==0) cvy*=-1
 	if btnp"5" then
 		new_game()
 	else
			ai_diff-=btnp()
			ai_diff%=3
		end
		pal(split"1,5,3,13,13,13,6,2,6,5,13,13,13,0,5")
 	return
	end
	
	async_dmap()
	fps+=1
	fps%=60
	upc=fps%upcycle
	ai=upc==0
	
 handle_input()
	
 buttons,pos,hoverunit,
 	idle,idle_mil=
  {},{}
 if loser then
 	poke"24365" --no mouse
 	if rdy and btnp"5" then
 		init_menu()
 	end
		rdy=not btnp"5"
 	return
	end
	
 --turn over viz
 if upc==0 then
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
	  	u_rect(del(proj,p).to_unit),
	 		{p.x,p.y},0
	 	) then
		 	deal_dmg(
		 	 p.from_unit,
		 		p.to_unit)
			end
		end
 end

 if selx then
 	bldg_sel,my_sel,enemy_sel=nil
 end
 
 foreach(units,tick_unit)
 for u in all(units) do
		if (ai) ai_unit2(u)	
 	if selx and
 		(g(viz,u.x\8,u.y\8) or
 			u.discovered) then
 	 update_sel(u)
		end
 	if not (u.const or u.dead) then
		 if upc==u.uid%upcycle and
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
		--check for nil, can be false
		sel_typ=(sel_typ==nil or
			s.typ==sel_typ) and s.typ
	end)
	
	if ai then
	 ai_frame()
	end
end

-->8
--unit defs/states

function parse(unit,typ,tech)
	local p2={}
	local obj={{},p2,p2,
		typ=typ,tech=tech}
	for l in all(split(unit,"\n")) do
		local k,v=unpack(split(l,"="))
		if v then
			obj[k],obj[1][k],p2[k]=v,v,v
		end
	end
	if (obj.idx) add(typs,obj)
	return obj
end

function init_typs()
typs={}
ant=parse[[
idx=1
spd=1
los=20
hp=10

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
def=ant]]

beetle=parse[[
idx=2
spd=0.9
los=20
hp=10
atk=1

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
dir=1
def=seige
atk_typ=seige]]

spider=parse[[
idx=3
spd=2
los=30
hp=15
atk=1.6

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
dir=1
def=spider
atk_typ=spider]]

archer=parse[[
idx=4
spd=1.5
los=30
hp=25
range=25
atk=1
proj_freq=30

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
proj_s=28
atk_typ=acid
def=ant]]

warant=parse[[
idx=5
spd=1.5
los=25
hp=25
atk=1

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
dir=1
atk_typ=ant
def=ant]]

cat=parse[[
idx=6
spd=0.75
los=30
hp=15
range=50
atk=2
proj_freq=60

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
atk_typ=seige
def=seige]]

queen=parse[[
idx=7
los=20
hp=60
atk=1.5
range=20
proj_freq=30

w=15
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
atk_typ=acid
def=queen
bitmap=0
units=1]]

tower=parse[[
idx=8
los=30
hp=50
range=30
const=25
atk=1
proj_freq=30

w=8
fw=8
h=14
fh=16
rest_x=40
rest_y=96
attack_x=40
attack_y=96
fire=1
dead_x=48
dead_y=99
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
atk_typ=tower
def=building
bitmap=1]]

mound=parse[[
idx=9
los=5
hp=25
const=12

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
def=building
bitmap=2]]

den=parse[[
idx=10
los=10
hp=35
const=30

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
def=building
bitmap=4
units=2
mil=1]]

barracks=parse[[
idx=11
los=10
hp=30
const=20

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
def=building
bitmap=8
units=2
mil=1]]

farm=parse[[
idx=12
los=0
hp=10
const=6

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
def=building
bitmap=16]]

castle=parse[[
idx=13
los=45
hp=80
range=40
const=40
atk=1.2
proj_freq=20

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
atk_typ=tower
def=building
bitmap=32
units=1]]

ant.prod={
	parse([[
r=0
g=0
b=10
breq=0]],mound),
	parse([[
r=0
g=8
b=0
breq=2]],farm),
	parse([[
r=0
g=7
b=12
breq=0]],barracks),
	parse([[
r=0
g=10
b=15
breq=8]],den),
	parse([[
r=0
g=3
b=12
breq=0]],tower),
--breq=1|4|8=13 (twr,den,bar)
	parse([[
r=3
g=8
b=20
breq=13]],castle),
}

queen.prod={
	parse([[
t=6
r=2
g=0
b=0
p=
breq=0]],ant),
nil,nil,nil,
parse([[
t=10
r=0
g=12
b=0
idx=5
breq=0]],parse[[
portx=96
porty=88
portw=8]],function()
		ant[1].carry=9
	end),
parse([[
t=10
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
breq=0]],ant),1)
	end),
}

den.prod={
	parse([[
t=13
r=4
g=2
b=0
p=
breq=0]],beetle),
	parse([[
t=13
r=2
g=4
b=0
p=
breq=0]],spider),
nil,
nil,
parse([[
t=5
r=10
g=5
b=5
idx=5
breq=0]],parse[[
portx=114
porty=64
portw=9]],function()
		beetle[1].atk+=1
	end),
parse([[
t=5
r=6
g=12
b=0
idx=6
breq=0]],parse[[
portx=105
porty=64
portw=9]],function()
		spider[1].atk+=1
	end),
}

mound.prod={
	parse([[
t=12
r=7
g=7
b=7
idx=1
breq=0]],parse[[
portx=104
porty=88
portw=9]],function()
		farm_cycles=10
	end),
}

barracks.prod={
	parse([[
t=10
r=4
g=0
b=2
p=
breq=0]],warant),
	parse([[
t=10
r=3
g=3
b=0
p=
breq=0]],archer),
	parse([[
t=5
r=12
g=8
b=0
idx=3
breq=0]],parse[[
portx=96
porty=64
portw=9
]],function()
		archer[1].range+=5
		archer[1].los+=5
	end),
nil,
parse([[
t=5
r=0
g=8
b=12
idx=5
breq=0]],parse[[
portx=105
porty=72
portw=9]],function()
		warant[1].atk+=1
	end),
	parse([[
t=5
r=8
g=12
b=0
idx=6
breq=0
]],parse[[
portx=96
porty=72
portw=9
]],function()
		archer[1].atk+=1
end),
}

castle.prod={
	parse([[
t=18
r=5
g=8
b=4
p=
breq=0]],cat),
nil,nil,nil,
 parse([[
t=5
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
t=5
r=0
g=10
b=20
idx=6
breq=0]],parse[[
portx=113
porty=88
portw=9]],function()
		for x in all{tower,castle,
			den,barracks} do
			x[1].los+=5
		end
	end),
}
end

dmg_mult=parse[[
ant_vs_ant=1
ant_vs_queen=0.9
ant_vs_spider=1
ant_vs_seige=1.5
ant_vs_building=1

spider_vs_ant=1.5
spider_vs_queen=0.9
spider_vs_spider=1
spider_vs_seige=1.1
spider_vs_building=0.8

seige_vs_ant=1
seige_vs_queen=0.8
seige_vs_spider=1
seige_vs_seige=0.9
seige_vs_building=1.6

tower_vs_ant=1
tower_vs_queen=0.75
tower_vs_spider=1.1
tower_vs_seige=0.8
tower_vs_building=0.5

acid_vs_ant=1
acid_vs_queen=1
acid_vs_spider=1.5
acid_vs_seige=0.9
acid_vs_building=0.6]]

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
		u.st={
			t="attack",
			target=e,
			wayp=get_wayp(u,e.x,e.y),
		}
		u.discovered=u.typ.bldg and 1
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
	local l,r=5,4
	
	if btnp(l) and hovbtn then
		hovbtn.handle()
		return
	end

	if (btnp"5" or btnp"4") and action then
		r,action=5
	end
	
	if btnp(l) and hoverunit and
  selt and t()-selt<0.2 then
		selection,selx={}
		for u in all(units) do
			if intersect(u_rect(u),
				{cx,cy,cx+128,cy+128},0) and
				u.p==1 and u.typ==hoverunit.typ then
				add(selection,u).sel=true
			end
		end
		return
	end

	--menuy
	if amy>104 and not selx then
		local dx,dy=amx-mmx,amy-mmy
		if min(dx,dy)>=0 and
			dx<mmw and dy<mmh+1	then
			local x,y=
				mmwratio*dx,mmhratio*dy
			if btnp(r) and sel1 then
				foreachsel(move,x,y)
				hilite={t=t(),
					circ={amx,amy,2,8}}
			elseif btnp(l) then
				cx,cy=
					mid(0,x-64,mapw-128),
					--menuh=21
				 mid(0,y-64,maph-107)
			end
		end
		if (btnp(l)) to_build=nil
	 return
	end
	
 if btnp(r) and to_build then
 	to_build=nil
 	return
 end

 if btn(l) and to_build then
  if buildable() then
  	local b=unit(
				to_build.typ,
				to_build.x+to_build.typ.w\2,
				to_build.y+to_build.typ.h\2,
				1,nil,1,0)
			b.cost=to_build
			foreachsel(build,b)
			to_build,selx=pay(to_build,-1)
		end
		return
 end

 if btnp(l) and not selx then
 	selx,sely,selt=mx,my,t()
 end
 if btn(l) and selx then
		selbox={
			min(selx,mx),
			min(sely,my),
			max(selx,mx),
			max(sely,my),
			7 --color
 	}
 else
 	selx=nil
 end
	
 if btnp(r) and sel1 and
 	sel1.p==1 then
	 local tx,ty=mx\8,my\8
	 local htile={
	 	t=t(),
	 	unit=tile_as_unit(tx,ty)
	 }
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
	  	foreachsel(gather,tx,ty)
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
  	movegrp(selection,mx,my,l==4)
  	hilite={t=t(),cx=mx,cy=my}
  	
  elseif sel1.typ.prod then
  	--set rally
  	if fget(mget(tx,ty),1) then
 	  hilite=htile
			end
  	sel1.rx,sel1.ry,
  		sel1.rtx,sel1.rty=
  		mx,my,tx,ty
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
	if (b>32) b>>=8 --allow esdf
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
 	mid(0,stat(32),126),
	 mid(-1,stat(33),126)

 mx,my,hovbtn=
 	amx+cx,amy+cy
end

function handle_input()
	mouse_cam()
	
 --buttons added in _draw()
 for b in all(buttons) do
 	if intersect(b.r,{amx,amy},1) then
			hovbtn=b
 	end
	end

 handle_click()
 
 if to_build then
	 to_build.x,to_build.y=
	 	mx\8*8,my\8*8
	end
end

function update_sel(u)
	u.sel=intersect(u_rect(u),selbox,0)
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

function tick_unit(u)
	local typ=u.typ[u.p]
	if u.hp<=0 and not u.dead then
		del(selection,u)
		u.dead,
			u.st,u.sel=0,parse"t=dead"
		if typ.bldg then
			register_bldg(u)
		end
		local r=res[u.p]
		if typ.drop then
			r.ppl-=5
			r.pl=min(r.ppl,99)
		elseif typ.unit then
			r.p-=1
			modify_totalu(u.p-2)
		end
	end
	if u.dead then
		if u.typ==queen then
			loser=u.p
		end
		u.dead+=1
		if (typ.unit) update_viz(u)
		if u.dead==60 then
			del(units,u)
		end
		return
	end
	
	if units_heal[u.p] and
		not u.fire and
	 u.hp<typ.hp and
		fps==0 then
		u.hp+=0.5
	end
	
	if intersect(u_rect(u),
	 {mx,my},1) and (
	 not hoverunit or hoverunit.p==1
	) then
		hoverunit=u
	end
	
	if (u.const) return
	if u.st.target and u.st.target.dead then
		rest(u)
	end
	
	if u.p==1 then
		if u.typ==ant and 
			u.st.rest then
			if (u.st.idle) idle=u
			u.st.idle=1
		elseif u.typ.mil and not u.q then
			idle_mil=u
		end
	end
	
	update_unit(u)
	if (ai) ai_unit1(u)

	update_viz(u)

	if typ.unit and not u.st.wayp then
		while g(pos,u.x\4,u.y\4) do
			u.x+=rnd(2)-1
			u.y+=rnd(2)-1
		end
		s(pos,u.x\4,u.y\4,1)
	end
end

function update_viz(u)
	if u.p==1 and
		u.uid%upcycle==upc then
		local k0=u.x\8|u.y\8<<8
		for t in all(viztiles(
		 u.x,u.y,u.typ[u.p].los)
		) do
			local k=k0+t
			if bldgs[k] then
				bldgs[k].discovered=1
			end
			--"v" to index into rescol
			exp[k],new_viz[k]=1,"v"
		end
	end
end

function viztiles(x,y,los)
	local xo,yo,l=x%8\2,y%8\2,
		ceil(los/8)
	if not vcache[los] then
		vcache[los]={}
	end
	local v=g(vcache[los],xo,yo)
	if not v then
		v={}
		s(vcache[los],xo,yo,v)
		for dx=-l,l do
		for dy=-l,l do
		 if dist(xo*2-dx*8-4,
		  yo*2-dy*8-4)<los then
				add(v,dx+dy*256)
			end
		end
		end
	end
	return v
end
-->8
--map

function draw_map(offset)
 camera(cx%8,cy%8)
 map(cx/8+offset,cy/8,unspl"0,0,17,17")
 camera(cx,cy)
end

function borders(arr,i)
 if not arr[i] then
	 if (arr[i-1]) line(unspl"-1,0,-1,7")
	 if (arr[i-256]) line(unspl"0,-1,7,-1")
	 if (arr[i+256]) line(unspl"0,8,7,8")
		if (arr[i+1]) line(unspl"8,0,8,7")
	end
end

function draw_minimap()
	camera(-mmx,-mmy)
	
	if fps%20==0 then
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
	pal(14,0)
	spr(unspl"153,0,0,3,3")
	pal()
	
	for u in all(units) do
		if u.discovered or
			g(viz,u.x\8,u.y\8) then
			pset(
				u.x/mmwratio,
				u.y/mmhratio,
				u.sel and 9 or u.p
			)
		end
	end
	
	--current view
	camera(
		-mmx-ceil(cx/mmwratio),
	 -mmy-ceil(cy/mmhratio)
	)
	--10.5=128/mmwratio+1
	rect(unspl"-1,-1,7,7,10")
	camera()
end

function draw_projectile(p)
	sspr(
		p.from_unit.typ.proj_s+
			fps\5%2*2,
		112,2,2,p.x,p.y
	)
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
	 hpp=
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
	pal(2,u.p) --queen eyes
	pal(1,not loser and u.sel and (
	 u.p==1 and typ.unit
	 or u==sel1) and 9 or u.p)
	sspr(sx,sy,w,h,xx,yy,w,h,
  --bldgs shldnt rotate
		not typ.fire and u.dir==typ.dir)
	pal()
	if not u.dead and hpp<=0.5 then			
	 if typ.fire then
			spr(229+f/20,u.x-3,u.y-8)
		end
		bar(xx,yy-1,w,hpp)
	end
end

function update_unit(u)
	local st=u.st
	local t=st.t
 if (u.q) produce(u)
 if (u.typ.farm) update_farm(u)
 if st.active then
 	if (t=="harvest") farmer(u)
 	if (t=="build") buildrepair(u)
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
		u.res.qty+=0.5
		u.sproff+=1
		u.ready=u.res.qty==9
	end
end

function farmer(u)
	local f=u.st.farm
	if f.ready and fps==0 then
		f.res.qty-=1
		f.sproff+=1
		collect(u,"r")
		if f.res.qty==0 then
			drop(u)
			f.cycles+=1
			f.exp,f.ready=f.p==1 and
			 f.cycles==farm_cycles
			f.sproff=f.exp and 32 or 0
		end
		u.st.farm=f
	end
end

function aggress(u)
	local typ=u.typ[u.p]
	local los,targ_d,targ,pref=max(
		typ.unit and typ.los,
		typ.range),9999
	for e in all(units) do
		local d=dist(e.x-u.x,e.y-u.y)
		if e.p!=u.p and not e.dead and
			viz[e.x\8|e.y\8<<8] and
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
		u.typ[u.p],u.st.target,
		u.st.active,u.uid
	local dx,dy=
		e.x-u.x,e.y-u.y
	if typ.range then
		if upc==id%upcycle then
			d=dist(dx,dy)
			in_range=d<=typ.range and
				g(viz,e.x\8,e.y\8)	
		end
		if in_range and
			fps%typ.proj_freq==
			(u.typ==cat and 0 or
			 id%typ.proj_freq)
		then
 		add(proj,{
 			from_unit=u,
 			x=u.x-u.dir*typ.proj_xo,
 			y=u.y+typ.proj_yo,
 			to={e.x,e.y},
 			to_unit=e,
 		})
 	end
 else
 	in_range=intersect(u_rect(u),
 	 u_rect(e),0)
		if in_range and fps%30==id%30 then
		 deal_dmg(u,e)
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
	if fps%30==0 then
		if b.const then
 		b.const+=1
 		if b.const>=b.typ.const then
 			b.const=nil
 			register_bldg(b)
 			if b.typ.drop then
 				r.ppl+=5
 				r.pl=min(r.ppl,99)
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
	if fps%15==u.q.fps15 then
		local b=u.q.b
		u.q.t-=0.5
		if u.q.t==0 then
			if b.tech then
				u.typ.prod[b.idx]=b.tech()
			else
				local new=unit(
					b.typ,u.x,u.y,u.p)
				if new.typ==ant and
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
end

function check_target(u)
	local st=u.st
	local t,nxt=st.target,st.nxt
	if
		t and
		intersect(u_rect(t),u_rect(u),
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
				res[u.p][u.res.typ]+=u.res.qty/gather_f[u.p]
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
	local st=u.st
	local wayp,spd=st.wayp,
	 st.spd or u.typ.spd
	if wayp then
 	if (st.first_pt) spd/=2
 	u.x,u.y,u.dir=norm(wayp[1],u,
 		spd/3.5)
 	local x,y=unpack(wayp[1])
 	if dist(x-u.x,y-u.y)<2 then
 		if #wayp==1 then
 			st.wayp=nil
			else
			 deli(wayp,1)
			end
 	end
 end
end
-->8
--utils

function unspl(...)
	return unpack(split(...))
end

function foreach_spl(str,func)
	for s in all(split(str,"\n")) do
		func(unspl(s))
	end
end

function sel_only(unit)
	foreachsel(function(u)
		u.sel=nil
	end)
	selection,unit.sel={unit},1
end
	
--x=k<<8>>8 (k&0x00ff)
--y=k>>24<<16 (k\256)
function g(a,x,y,def)
	return a[x|y<<8] or def
end

function s(a,x,y,v)
 a[x|y<<8]=v
end

function modify_totalu(diff)
	totalu+=diff
	upcycle=totalu>=80 and 60 or
		totalu>=60 and 30 or
		totalu>=45 and 15 or
		totalu>=35 and 10 or 5
end

--r2 can be {x,y}
function intersect(r1,r2,e)
	local a,b,c,d=unpack(r2)
	return r1[1]-e<(c or a) and
		r1[3]+e>a and
		r1[2]-e<(d or b) and
		r1[4]+e>b
end

function tile_as_unit(tx,ty)
	return {
		x=tx*8+4,y=ty*8+4,
		typ=parse[[w=8
h=8]],
	}
end

function u_rect(_ENV,e)
	local w2,h2,e=typ.w/2,
		typ.h/2,e or 0
 return {
 	x-w2-e,y-h2-e,
 	x+w2,y+h2
 }
end

-- musurca/freds - /bbs/?tid=36059
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
	 		xx<mapw8 and yy<maph8
	 		and (not chk_acc or
	 			acc(xx,yy)
	 			--and (acc(xx,y) or acc(x,yy))
	 		)
	 	then
			 add(st,{
			  xx,yy,
			 	diag=dx!=0 and dy!=0,
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
	local x,y=mx\8,my\8
	return (fget(mget(x,y),1) or
		avail_farm()) and
		sel_typ==ant and
		g(exp,x,y) and
		sur_acc(x,y)
end

function can_attack()
	local v=g(viz,mx\8,my\8)
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
		sel_typ==ant
end

function rectaround(u,c)
	color(c)
	rect(unpack(u_rect(u,1)))
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
	--get ⬇️⬅️ tile
	local w,h,x,y=typ.w,typ.h,
		(b.x-2)\8,(b.y+2)\8

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
	
	if (typ==queen) queens[b.p]=b
	if not b.const and typ!=farm then
		make_dmaps"d"
		res[b.p].reqs|=typ.bitmap
	end
end

function deal_dmg(from,to)
	to.hp-=from.typ[from.p].atk*dmg_mult[from.typ.atk_typ.."_vs_"..to.typ.def]
end

function collect(u,res)
	if u.res and u.res.typ==res then
		u.res.qty+=1
	else
		u.res={typ=res,qty=1}
	end
	if u.res.qty>=u.typ[u.p].carry then
		drop(u,res)
	end
end

function can_drop()
 for u in all(selection) do
		if u.res and u.typ.unit then
			return hoverunit and
			 hoverunit.typ.drop
		end
	end
end

function can_renew_farm()
	return hoverunit and
		res1.b>=farm_renew_cost_b and
		sel_typ==ant and
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

function unit(typ,x,y,p,hp,
	discovered,const)
 local typ,u=typs[typ] or typ,
 	add(units,
 		parse[[dir=1
sproff=0
lastp=1]])
 		
 u.typ,u.x,u.y,u.p,u.hp,u.const,
  u.discovered,u.uid=
 	typ,
		x,y,p,hp or typ.hp,const,
		discovered==1,uid

	rest(u)
	uid+=1
	if typ.farm then
		u.res,u.cycles=parse[[typ=r
qty=0]],0
	end		
	if typ.bldg then
		register_bldg(u)
	else
		modify_totalu(2-p)
	end
	return u
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
		if best_t then
			return best_t,n
		end
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
    shortest.cost_from_start+1
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
--menu/cursor

function print_res(r,x,y,zero)
--	local res1=res[2]
	local oop=res1.p>=res1.pl
	for i,k in inext,split"r,g,b,p" do
		local newx,v=0,i!=4 and
			flr(r[k]) or zero and
			"\-b \-i"..res1.p..
				"/\^x9 \^-#\^x1.\|h\#5\^x0 \^x4\^-#\|f\-6"..res1.pl or
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
			spr(128+i,x,y)
			x=newx+(zero or 1)
		end
	end
	return x-1
end

function can_pay(costs,p)
	local r=res[p or 1]
 return r.r>=costs.r and
 	r.g>=costs.g and
 	r.b>=costs.b and
 	(not costs.p or r.p<r.pl) and
 	r.reqs|costs.breq==r.reqs
end

function pay(costs,dir,p)
	for r in all(split"r,g,b") do
  res[p or 1][r]+=costs[r]*dir
	end
	if costs.p then
		res[p or 1].p-=dir
	end
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

function cursor_spr()
 if hovbtn then
		pset(amx-1,amy+4,5)
  return 66
	end
	if sel1 and sel1.p==1 then
		if to_build or
			can_build() or
			can_renew_farm() then
			return 68
		end
		if (can_gather())	return 67
		if (can_attack()) return 65
		if (can_drop()) return 69
	end
	return 64
end

function draw_sel_ports(x)
	for i,u in inext,selection do
		x+=13
		if i>5 then
			--menuy+6
			if (numsel>15) x-=4
			x=?"\f1+"..numsel-5,x-15,121
			spr(132,x+1,121)
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
	 		pay(sel1.cost,1)
	 		sel1.hp=0
	 	end,sel1.const/sel_typ.const
	 )
	 return
	end
	
	if sel1.cycles then
		--menuy+6
		? sel1.cycles.."/"..farm_cycles,unspl"38,111,4"
		--menuy+4
		sspr(unspl"112,96,9,9,51,109")
	end
	if sel_typ.prod then
		for i,b in next,sel_typ.prod do
			i-=1
			draw_port(
				b.typ,
				88-i%4*13,
				--menuy+2
				106+i\4*11,
				b,
				function()
					if not can_pay(b) or q and
						(q.b!=b or b.tech or
						q.qty==9) then
						return
					end
					if b.typ.bldg then
						to_build=b
						return
					end
					pay(b,-1)
					if q then
						q.qty+=1
					else
						sel1.q={
							b=b,qty=1,t=b.t,
							fps15=(fps-1)%15
						}
					end
				end
			)
		end
		if q then
			draw_port(
			 q.b.typ,
			 q.b.tech and 24 or
			  --menuy+6
			  ?"X"..q.qty,unspl"32,110,7"
			  and 20,
			 --menuy+3
			 107,nil,
				function()
					pay(q.b,1)
					if q.qty==1 then
						sel1.q=nil
					else
						q.qty-=1
					end
				end,q.t/q.b.t
			)
		end
	end
end

function draw_menu()
	local x,secs=0,split"102,26"
	if sel1 and sel1.p==1 then
		--4 tok (and...)
		if sel1.typ.has_q and not sel1.const then
			secs=split"17,24,61,26"
		else
	 	secs=split"17,17,68,26"
		end
	end
 for i,sec in inext,secs do
 	pal(i%2!=0 and 4,15)
 	camera(x)
 	--104=menuy
 	spr(unspl"128,0,104")
 	spr(128,sec-8,104)
 	line(sec-4,unspl"105,3,105,7")
 	rectfill(sec-4,unspl"106,3,108,4")
 	rectfill(sec,unspl"108,0,128")
 	x-=sec
 	pal()
 end
 camera()

 if numsel==1 or sel_typ==ant then
		single_unit_section()
	else
		draw_sel_ports(24)
	end
	if numsel>1 then
		if (numsel<10) camera(-2)
		?"X"..numsel,unspl"5,111,1"
		spr(unspl"132,1,111")
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
	 	sel_typ==ant and parse[[
portx=24
porty=32
portw=8
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
			cx,cy=idle.x-64,idle.y-64
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
	
--	local res1=res[2]
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
		u.x\8,
		u.y\8,
		dmaps[key],
		{},9
	while lowest>=1 do
		local orig=max(1,g(dmap,x,y,9))
		for t in all_surr(x,y,1) do
			local w=dmap[t.k] or 9
			if (t.diag) w+=0.4
			if w<lowest then
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
		if i>20 then
			--continue next tick
			return
		end
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

mapw,maph,mmx,mmy,mmw,
	mmh, --maph\(mapw/mmw)
	mapw8, --mapw/8
	maph8, --maph/8
	mmhratio, --maph/mmh
	mmwratio= --mapw/mmw
	unspl"384,256,105,107,19,12,48,32,21.333,20.21"
	
ai_diff,reskeys,f2res,resqty,
 key2resf,rescol
 =0,
split"r,g,b,p,pl,ppl,reqs",parse[[
7=r
11=g
19=b
]],parse[[
r=40
g=35
b=50
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
	reload() --reset maps
		
	queue,exp,vcache,dmaps,
	units,restiles,selection,
		proj,bldgs,spiders,viz,
		new_viz,queens,
		dmap_st,res,loser,menu,selx=
		{},{},{},{},{},{},{},
		{},{},{},{},{},{},{d={}},
	 parse[[
r=5
g=5
b=5
p=4
pl=10
ppl=10
reqs=0]]

	res1,
	--tech can change
	units_heal,gather_f,
	farm_cycles,farm_renew_cost_b,
	--global state
	cx,cy,mx,my,fps,
	uid,totalu,numsel,
	dmaps_ready=
		res[1],{false,true},
		{3,2-ai_diff/2},
		unspl"5,3,0,0,0,0,59,0,0,0"

	init_typs()
	
	--ai init
	ai_frame()
	bo_idx,nxt_res,res_alloc,uprod,
		defsqd,offsqd,atksqd,
		ant[2].carry,
		tower[2].range,
		defst=
		0,1,split"r,b,g",true,
		{},{},{},
		40,9
end

function init_menu()
	menu,cx,cy,cvx,cvy=
		unspl"1,0,30,1,1"
end

function new_game()
	menu=init()
	--q=6,5
	foreach_spl(
[[7,57,44,1
1,40,40,1
1,68,43,1
1,50,32,1
5,48,56,1
7,337,188,2
1,320,184,2
1,348,187,2
1,330,196,2
5,328,170,2
8,268,178,2
2,65,150,3]],unit)
	
	make_dmaps"d"
end

init_menu()
-->8
--ai

--1m 2f 3b 4d 5t 6c
bo=
[[6,1,123,27
8,3,119,21
9,1,123,21
12,5,118,16
13,1,125,25
14,4,117,22
15,2,121,24
16,2,122,24
17,2,123,24
18,3,120,18
19,1,117,25
20,2,123,23
21,2,123,22
22,4,120,20
23,2,122,22
24,2,121,22
25,1,123,16
26,6,115,18
27,2,120,22
28,1,119,28
29,2,120,23
30,2,120,24
31,2,124,24
33,1,118,19
34,3,120,16
35,5,118,23
37,1,122,28
43,1,127,22
47,1,125,13
53,1,117,27
54,2,125,24
55,5,112,30
56,2,126,24
57,1,116,29
59,2,124,25
62,2,124,26]]

function ai_unit1(u)
 if u.p==2 then
 	if u.typ==ant then
 		antcount+=1
 		if u.st.res=="r" and
 			not g(dmaps.r,24,24) then
			 drop(u)
			 res_alloc=split"b,g"
			end
 		if u.st.t=="gather" then			
		 	add(miners,u)
		 elseif u.st.rest and
		 	dmaps_ready then
				nxt_res%=#res_alloc
				nxt_res+=1
		 	mine_nxt_res(u,
		 		res_alloc[nxt_res])
		 end
	 elseif u.typ.atk and
	 	u.typ.unit then
	 	if u.dead==0 then
	 		del(u.sqd,u)
	 	elseif not u.sqd then
	 		u.sqd=(#defsqd>#offsqd or
	 		 u.typ.atk_typ=="seige") and
	 			offsqd or defsqd
	 		add(u.sqd,u)
	 	end
	 end
 end
end

function ai_prod(u)
	local p=u.typ.prod[u.lastp]
	if uprod and
		not u.q and can_pay(p,2) then
		pay(p,-1,2)
		u.q={
			b=p,qty=1,t=p.t,
			fps15=0,
		}
		u.lastp%=u.typ.units
		u.lastp+=1
	end
end

function ai_unit2(u)
	if u.p==2 then
		if u.typ.bldg and
			(u.hp<u.typ.hp*0.75 or 
			 u.const) and
			not u.w then
			u.w=deli(miners)
			if (u.w) build(u.w,u)
		end
		if u.w and
			u.w.st.t!="build" then
			u.w=nil
		end
		if u.typ.farm and
		 not u.const and
		 not u.farmer then
			local w=deli(miners)
			if (w) harvest(w,u)
		end
		if u.typ==queen then
			if antcount<30 then
				ai_prod(u)
			end
		elseif u.typ.units then
			ai_prod(u)
		end
	elseif u.st.t=="attack" and
		u.st.active and
		u.x>192 and u.y>120 and
		not defst
	then
		inv,defst=true,"attack"
		movegrp(defsqd,u.x,u.y,true)
	end
end

function ai_build(t,pid,x,y)
	local b=ant.prod[pid]
	if res[2].p>=t and bo_idx<t then
		uprod=can_pay(b,2)
		if uprod then
			bo_idx=t
			pay(b,-1,2)
			unit(b.typ,
				(x-80)*8+b.typ.w/2,
				y*8+b.typ.h/2,
				2,nil,nil,0)
		end
	end
end

function ai_frame()
	if dmaps_ready then
		foreach_spl(bo,ai_build)
		if #offsqd>=10 and not defst
		then
			atksqd,offsqd=offsqd,{}
		end
		movegrp(atksqd,
			queens[1].x,queens[1].y,
			true,true)
		if (not inv) defst=nil
	end
	miners,antcount,inv={},0
end
-->8
--saving

menuitem(1,"⌂ save to clip",function()
	if (menu) return
	local str=ai_diff..","..bo_idx.."/"
	for _ENV in all(units) do
		str=str..
		 typ.idx..","..
			x..","..
			y..","..
			p..","..
			hp..","..
			max(discovered)..
			(const and ","..const or "")..
			"/"
	end
	for k in next,exp do
		str=str..k..","
	end
	str=str.."/"
	for r in all(reskeys) do
		str=str..res1[r]..","..res[2][r]..","
	end
	str=str.."/"
	for i=1,mapw8*maph8-1 do
		str=str..
		 mget(i%mapw8,i/mapw8)..","
	end
	printh(str,"@clip")
end)

menuitem(2,"◆ load from clip",function()
	init()
	local lines=split(stat(4),"/")	
	ai_diff,bo_idx=unspl(deli(lines,1))
	for i,t in inext,split(deli(lines)) do
		if t!="" then
			mset(i%mapw8,i/mapw8,t)
		end
	end
	local r,e=
		split(deli(lines)),
		split(deli(lines))
	for i,k in inext,reskeys do
		i*=2
		i-=1
		res1[k],res[2][k]=r[i],r[i+1]
	end
	for l in all(lines) do
		unit(unspl(l))
	end
	for k in all(e) do
		if k!="" then
			exp[k]=1
		end
	end
	
	make_dmaps"d"
end)

menuitem(3,"   (paste first)")
__gfx__
00000000d000000000000000000000000000000000d0000000000000000000000000000001000100000000000000000000000000110001100000000000000000
000000000d000000d00000000000000000000000000d000000000000000000000110000000101000000000001100011000000000001010000000000000000000
00700700005111000d000000dd00000000000000000051100d011100dd0000001111000000101000011100000010100001110000044440000000000000010100
000770000051111000511100005111000000000000005111d0511110005111001111011104444000111101110444400011110111042420000110001110144410
000770000001111000511110005111100d51110000000d11005d1110005111101101441144242000110144114424200011014411404400001111144114124210
00700700000d1d10000d1d100001d1d0d051d1d00000000d000000d0000d1d100005440050440000110544005044000011054405050050001150544505044000
00000000000000000000000000000000000000000000000000000000000000000050500505005000005050050500500000505000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000800000008000080000000000000000000000000000000000000000010050000000000000000000000000000000000000000000000000000
000000000000000088000800880008800000000050000000000080000000000000000000115000000000000000000000000000000000000000d0000000000000
11000000110001101100880011000110110001100110511081101100000000000000000003300000000000000000000000d00000000000000d00000000000000
0011111100110011001111110011001180110811001100110011001100000000000000000011500000d00000000000100d000000000000003310000000000000
0b0000000b0000b004000000040000400000000000000000000000000000000000d00000001300000d0000000001131133100000000000003311310000000000
bb000b00bb000bb04400040044000440000000000000000000000000000000000d11311331350000331131131131135033113113113113100011311311311310
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
d00001100d0000000dd000000000000000310011003100110d0000000000000000d00000000000000d0000000000000000d000000000000000d0000000000000
31000110d0000110d00001100000000005d1001105d1001133000000000000000d0000000000000033100000000000000d000000000000000000000000000000
0d11110031111110311111100d000110505d1110000d111033100000000000013310000000000000331131000000000033100013113000000d10000000011310
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
00000000080000000bb000000400000010100000113333110000000000000000000000000000000000000000dd00000000000080000005000000050000000000
0077770088800000bbb0000044000000101000001b333b310d000000000000000000000000000000dd6000000600000000000088050050500050500000000000
0744447088800000bb00000004000000c1c0000033bbbf33600006600d0000000dd000000000000000510061051000168080888885555050dd50522226600000
74444447060000000b00000004400000c1c0000033bbbb835100016060000660600006600000000005d100665d100066000000880e5e550d7ddddd2267600000
44444444060000000b000000040000001110000033bbbf330d16610051166160511661600d000660505d661000d1661000300080055554d7d05d5d4676000000
44444444000000000000000000000000000000003b333b11001d1d000d1d1d0001d1d1d061d6d1600000d1d005001d104300b000b000504d00dddd2462000000
444444440000000000000000000000000000000013333111000000000000000000000000000000000000000000000000430000b0050504040005054045000000
44444444000000000000000000000000000000001133311100000000000000000000000000000000000000000000000000300000000000000000000000000000
0000000000000000050000050000000000000000d000000000000000000000000000000044444444444444444444000000000000000d00d00000005000000000
0002000202909092505000505000005000500d00d00d220002200000d0000d0000000000444444444444444444440000000220b00d777d000050057506000000
00002020002999205055555050000005050000d777d00020200000000d00d000000000004444444444444444444400002020b00dd7555700dd55560770600000
0000444040444400055e5e550002222505000075557000444000b0000333300000000000440000040000400000440000444000d7d544450d7de5e57607000000
44047474444e4e0050555550502622dddd0d0054445044e4e0b000000b33b00000000000440404040440404440440000e4eb4d7d04e4e4d7d055567067600000
404044404504400050500050502266d5d507d04e4e4040444b0001331333300000000000440404040000400000440000444004d00044404d0006650770000000
050504055050050050050500502222dddd0444044400050b050b013311100000000000004404440404404044444400005b054040050004040050506006000000
000000000000000005000005005050505000505000500000b0000050500000000000000044044404044040444444000000b00000000000000000000000000000
0000b000444744444000000000000000000000000000000002200000000000000000000044444444444444444444000000000000880055088000000555000000
000b350044474464400087000070000707000000000000002dd20000000000000000000044444444444444444444000000990990088577880000005775000000
00b333504464774640878878000744447000000000000002d4dd2000000000000000000044444444444444444444000009889889008878850000557765000000
0b4444454647647440788888007441144000000400000002ddd42000000000000000000044444444444444444444000009888889057888500088845650000000
00411d404447467643437753344411114400004110000002d4dd2000000000000000000044444444444444444444000009888889577888400800484500000000
00411d4047747744445377334547155114700451140000402dd20000000000000000000044444444444444444444000000988890058848840808480500000000
00444440444644744532772453741551470045544540041402200000000000000000000044444444444444444444000000098900088504885800580000000000
00044400444444474342222534074114407054545450454540000000000000000000000044444444444444444444000000009000880000588088800000000000
00000000000000001dd11111dd1111dd113331110000000000000000000000000000000044444444444444444444000000000000004000440000000800000000
05000500005050505111115111121211133831110070000000000000000000000000700044444444444444444444000000055500004400444000008880000000
575057500040404015545511151141153bfbfb110770000000000000000000000000770044444444444444444444000000500050444440004001188888000000
74707470b0044400111411111155455133bbb3337770000000000000000000000000777044444444444444444444000005000005404400404015551800000000
0400040b35041400155455111111411133bbb333e77000000000000000000000000077e000000000000000000000000005686bb540b0044041d5e5d800000000
4111114333541400511411511155455133bbb3330e700000000000000000000000007e00000000000000000000000000054949454bbb44444015551800000000
4d111d451504440011212111151111151b333b3100e0000000000000000000000000e0000000000000000000000000000549494544b004400001110000000000
4d404d4454544444dd1111dd11111dd1113333110000000000000000000000000000000000000000000000000000000000555550044000400000000000000000
0000000000000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000040000000000000
000000000000000000000000000000000000000000b3500000000000000000000000000000000000000000000000000000000000000000000044004400000000
00000000000000000004000000000000000000000b33350000000000000000000000000000000000000000000000000000000000000000000444404440000000
0004000000000000004110000000000000000000b444445000000000000000000000000000000000000000000000000000000000000000004044000040000000
00411000000400000451140000000000000000000411d40000000000000000000000000000000000000000000000000000000000000000004040004040000000
04511400004110004554454005000500000000000411d40000000000000000000000000000000000000000000000000000000000000000004000044040000000
45544540045114005454545004444400000000000444440000000000000000000000000000000000000000000000000000000000000000004440444400000000
00000000000000000000000004111400000000000411d40000000000000000000000000000000000000000000000000000000000000000000440044000000000
00000000000000006000060604444400005050000444440000000060000600600005060000056050000006050000060000000000000000000000004000000000
00000000000000000744447000414000004140000041400000060600000565060056050000000565000060600000000600000000000000000999999005555550
00744070000000007441144000444000004140000044400000056560005050500000565000606000000000000000000000000000000000009929929955255255
0741140000000000441111440041400000414000004140000050555000a005000060600000000000000000000000000000000000000000009929929955255255
04151140000470004715511400414500004045000041455000a0aa000aaa0aa000a00a0000a005000000050000000000000000000000000099d44d9955d44d55
0411114000414400741551460000000000000000000000000a9aa9a50a99a9950a95a9a5059a59a505a65a650075050000750500007505009944449955444455
0741140000444400074114400000000000000000000000005989989559899895598998955a89a895569a69a50576576005765760057657600999999005555550
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
0000000000000000000000000000000000000000000000000000000000000000000000000707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
545454545454545552535253525253525251515454545454545554544d4e4f4c4d4e55555454554f4c4d4e4f7b5252524b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b545454545454545552535253525254545554545454544e4f4c4d4e4f7b525252
545454545554545f7b525353535253524c4d4e4f55545554545454545d5e5f5c5d5e5f5554555e5f5c5352535c5353524b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b545454545554545f7b5253535352535454545454545d5e5f5c5352535c535352
5454515454546e6f6c535253535252525c5d5e5f6f545455545554546d6e6f6c6d6e6f6c556d4c5657585350505253524b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5454515454546e6f6c5352535352535555545554556d56575758535050525352
545455547c7d7e507c5350505352537f6c6d6e6f4f7e51545454557c7d7e7f7c7d7e7f7c7c7d566a67695853505352524b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b545455547c7d7e507c5350505352537f555451547c7d66676769585350535252
5454554f4c4d4e4f4c4d52535252534f7c7d7e7f5f4e555454544f4c4d4e4f4c4d4e4f4c4c4d666767676852525353534b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5454554f4c4d4e4f4c4d52535252534f6c5454544c4d66676767685252535353
54546e5f5c5d7e5f5c5d5e5352535e5f5c6c6d6e6f5e5554555e5f5c5d5e5f5c5d5e5f5f5c5d66676759785f535d5e5f4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b54546e5f5c5d7e5f5c5d5e5352535e5f5c51515f5c5d66676759785f535d5e5f
54546e51516d6e6f6c6d6e6f6c6d6e6f6c7c7d7e7f6e54556d6e6f6c6d6e5657586e6f6f6c6d767777786e6f6c6d6e6f4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b54546e51516d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d767777786e6f6c6d6e6f
54557e7f7c7d7e7f517e7f7d7e7f565757587c6b7e7e7f7c7d7e7f7c7d566a6769587f7f7c7d7e7f7c7d7e7f7c7d7e554b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b54557e7f7c7d7e7f7c517e7f565757587c6b7e7f7c7d7e7f7c7d7e7f7c7d7e55
5452534f4c4d4e4f4c4e4f4d4e6b66676769584d4e4e4f4c4d4e4f56576a676767684f4f4c4d4e4f4c4d4e4f4c4d55554b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5452534f4c4d4e4f4c4d4e6b66676769584d4e4f4c4d4e4f4c4d4e4f4c4d5555
525253525c5d5e5f5c5e5f5d56576a67b367685d7a5e5f5c5d5e5f666767676767685f5f5c7b5e5f5c5d5e5f5c5e54544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b525253525c5d5e5f5c5d56576a676767685d7a5f5c7b5e5f5c5d5e5f5c545454
5253525253526e6f6c6e6f6d66676767676768796e6e6f6c6d6e6f666767676759786c6d6e6f6c5657584e7f6c4d55544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5253525253526e6f6c6d66676767676768796e6f6c6d6e6f6c5657586c545554
5252505252527e7f7c7e7f7d666785676759787d7e7e7f7c7d7e7f765a676759786f7c7d7e56576a67685e4f7c4e54544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5252505252527e7f7c7d666767676759787d7e7f7c7d7e56576a67687c545454
52535352524d4e4f4c4e4f7b6667676767687b4d4e4e4f4c4d4e4f4c665977784d7f4c4d566a676767686e5f4c4d55554b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b52535352524d4e4f4c7b6667676767687b4d4e4f4c4d566a676767684c4d5555
525253535c5d5e5f5c5e5f796667597777785c5d5e5e5f5c5d5e5f5c76785f5c5d4f5c5d6667676759787e6f5c5d50504b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b525253535c5d5e5f5c796667597777785c5d5e5f5c5d6667676759785cc25050
526d6e6f6c6d6e6f6c6e6f6d7677787a6e6f6c6d6e6e6f6c6d6e6f6c6d6e6f6c6d5f6c6d66676759786f4e7f6c5353504b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b526d6e6f6c6d6e6f6c6d7677787a6e6f6c6d6e6f6c6d66676759786f6c535350
7c7d536b527d7e7f7c7e7f7d7e7f7c7d797f7c7d7e7e7f7c7d7e7f7c7d7e7f7c7d6f7c7a767777787e7f5e4f535353534b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b7c7d536b527d7e7f7c7d7e7f7c7d797f7c7d7e7f7c7a767777784c7f53535353
4c52565757584e4f4c4d4e4f4c4d4e4f4c4d4e4c4d4e4f4c4d4e4f4c4d4e4f4c4d7f7f7f7c7d7e7f7c7d7e5f535252534b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4c52565758544e4f4c4d4e4f4c4d4e4f4c4d4e4f794dc54fe24d4ec253525253
5051666767685e5f5c5d5e5f5c5d5e5f5c5d5e5c5d5e5f5c5d5e5f5c5d5e5f5c5d4f4c4d4e4f4c4d4e4f5e53535353534b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5051666768535e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5dd55f5c5d5e5353535353
5150666759784c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f6f7c7d7e7f7c7d7e7f7c6b7e7f7f7c7d6e6f6c6d6e52525053534b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5150666768536e6f6c6d6e6f6c6d6e6f6c6d6eeeef6d6e6fe26d6e5252505353
7c52767778515c5d5e5f56575757585d5e5f5c5d5e5f7f4f4c6d6e6f56575757575757586c4d7e7f7c7d5253525350534b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b7c52767778517e7f7c7d7e7f7c7d7e7f7c6b7efeff7dc27f7c7d525352535053
4c545452524d6c6d6e566a67676769586e6f6c6d6e6f4e5f5c6b7a566a67676759775a69587a4e4f4c4d4e53535352524b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4c545452524d4e4f4c6d6e6f56575757575757586c4d4e4fd24d4e5353535252
5c5d53535c5d7c7d7e666767676767687e7f7c7d7e7f5e6f6c7a566a67676767684c6667686d5e5f5c5d515f525253524b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5c5d53535c5d5e5f5c6b7a566a67676759775a69587a5ee25c5d51c252525352
7b6d6e6f6c6d4c4d4e765a67676767684e4f4c4d4e4f6e7f7c566a676767b36769576a59787d6e6f6c6d6e6f6c6d6e6f4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b7b6d6e6f6c6d6e6f6c7a566a67676767684c666768d06e6ff2f2f2f26c6d6ec2
527d7e7f7c7d5c5d5e5f666767676769585f5c5d5e5f7e4f4c66676767b46767b26767686c4d7e7f7c7d7e7f7c507e7f4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b527d7e7f7c7d7e7f7c566a676767676769576a59787dc57ff20a0bf27c507e7f
5252534f4c4d6c6d6e6f66676767676769586c6d6e6f4e5f52765a676767676767676768535d4e4f4c4d4e4f4c4d4e544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5252534f4c4d4e4f4c66676767676767676767686c4dd54ff2f2f2f2f2f2f254
5353525f5c5d7c7d7e7f765a6767676767685c7d7e7f5e5250537677775a67597777777853535e5f5c5d5e5f5c5d55544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5353525f5c5d5e5f52765a676767676767676768535d5e5f5c5d5e5ff2c25554
5252516f6c6d4c4d4e4f4c666767676767686c4d4e4f6e7f505253535376777853505253527d6e6f51516e6f6c5554544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5252516f6c6d6e5250537677775a67597777777853536e6f51516e6ff2555454
5252517f7c7d5c5d5e5f5c765a67676759785c5d5e5f7e4e4f4d53525353525353525353534d7e7f7c7d7e7f545554544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5252517f7c7d7e7f50525353537677785350525352c27e7f7c7d7ec254555454
525355554c4d6c6d6e6f6c6d76777777786f6c4c4d4e4f5e5f5d5e5f53525353525d5e5f5c5d4e4f4c4d4e54555455544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b525355554c4d4e4f4c4d53525353525353525353534d4ec24c4d4e5455545554
5354545455547c7d7e7f7c7d7e7f7c7d7e7f7c5c5d5e5f5c5d5e5f5c5d5e5f5c5d4f4c4d4e4f5e5455545455545454544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5354545455545e5f5c5d5e5f53525353525d4c5fc25d5e545554545554545454
54555455555454556c6d6e6f6c6d6e6f6c6d6e6c6d6e6f6e6f6e6f4c4d4c6e6f4d4c4d4c4d6d545454545554545455544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b54555455555454556c6d6e6f6c6d6e6fc56d6e6f6c6d54545454555454545554
5454545454545454547d7e7f7c7d7e7f7c7d7e7c7d7e7f7e7f7e7f5c5d5c7e7f5d5c5d5c5d55555455545454555454544b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b5454545454545454547d7e7f7c7d7e7fd57d7e7f7c5555545554545455545454
__sfx__
0101000027000000001f000200002200024000270002900029000290002800027000250002200020000200001f0001e0001e0001f00020000220002400024000210001d0001b0001900017000170000000000000
