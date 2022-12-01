pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--main loop

function _draw()
 cls()
 draw_map()
 
 local bf1,bf2,af={},{},{}
 for u in all(units) do
 	if u.const and u.p==1 then
 		add(af,u)
 	elseif u.typ.bldg then
	 	add(bf1,u)
	 else
	 	add(bf2,u)
	 end
 end
 
	foreach(bf1,draw_unit)

	--highlight selected farm
	if sel1 and sel1.typ==farm and
		not sel1.const then
	 rectaround(sel1,9)
	end

	draw_projectiles()
	foreach(bf2,draw_unit)
	draw_fow()
	draw_hiviz()
	foreach(af,draw_unit)
	
	--rally flag
	if sel1 and sel1.rx then
		spr(71+fps/5%3,
			sel1.rx-2,sel1.ry-5)
	end

	if selbox then
		fillp(▒)
		rect(unpack(selbox))
		fillp()
	end
	
	if (hilite) draw_hilite()
	if webx then
		line(webx,weby,wmx,wmy,
		 acc(wmx\8,wmy\8) and 7 or 8)
	end
	
	camera()
	
	draw_menu()
	if (to_build) draw_to_build()
	
	--minimap hilite
	if hilite and hilite.px then
		circ(hilite.px,hilite.py,2,8)
	end
	
	--cursor
	spr(cursor_spr(),amx,amy)
	--cursor can change pal, so
	--reset
	pal()
	
--	if sel1 then
--		print(sel1.st.t.." "..(sel1.st.active and "active" or ""),0,0,7)
--	end
end

function _update()
	async_task()
	fps=(fps+1)%60
 
 handle_input()

 vizmap,buttons,pos,hoverunit,
 	sel_typ={},{},{}
 
 update_projectiles()
 
 if selbox then
 	bldg_sel,my_sel,enemy_sel=nil
 end
 foreach(units,tick_unit)
 --fighting has to happen after
 --tick because viz is involved
 for u in all(units) do
 	if not (u.const or u.dead) then
		 if u.st.t=="rest" and
		  u.typ.atk then
				aggress(u)
		 end
	 	if u.st.t=="attack" then
	 		fight(u)
	 	end
	 end
 end
 if selbox then
		selection=my_sel or
			bldg_sel or
			enemy_sel or {}
	end
	sel1=selection[1]
	for s in all(selection) do
		--must explicitly check for
		--nil bc it can be false
		sel_typ=(sel_typ==nil or
			s.typ==sel_typ) and s.typ
	end
end

function draw_hilite()
	local dt=t()-hilite.t
	if dt>0.5 then
		hilite=nil
	elseif hilite.x then
		circ(hilite.x,hilite.y,
		 min(0.5/dt,4),8)
	elseif dt<=0.1 or dt>=0.25 then
		if hilite.tx then
			local x,y=hilite.tx*8,
				hilite.ty*8
			rect(x-1,y-1,x+8,y+8,8)
		elseif hilite.unit then
			rectaround(hilite.unit,8)
		end
	end
end

function draw_to_build()
	local typ,x,y=to_build.typ,
		to_build.x-cx,to_build.y-cy
	
	pal(buildable() or
	 split"8,8,8,8,8,8,8,8,8,8,8,8,8,8,8"
	)
	--menuy
	if amy>=104 then
		x,y=amx-3,amy-3
	else
		fillp(▒)
		rect(
 		x-1,y-1,
 		x+typ.fw,
 		y+typ.fh,3
 	)
 	fillp()
 end
	sspr(typ.rest_x,typ.rest_y,
	 typ.fw,typ.h,x,y)
	pal()
end

-->8
--unit defs/states

typs={}
function parse(unit,typ,tech)
	local obj={
		typ=typ,tech=tech,
		[1]={},[2]={}
	}
	for l in all(split(unit,"\n")) do
		if #l>0 then
			local v1,v2=unpack(
				split(l,"="))
			obj[v1],obj[1][v1],
				obj[2][v1]=v2,v2,v2
		end
	end
	return add(typs,obj)
end

ant=parse[[
idx=1
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

spd=1
los=20
hp=10
def_typ=worker
]]
beetle=parse[[
idx=2
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

spd=1.5
los=20
hp=20

def_typ=beetle
atk_typ=beetle
atk=1
]]
spider=parse[[
idx=3
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

web_x=88
web_y=16

dead_x=56
dead_y=16

portx=16
porty=72
portw=9
unit=1
dir=1

spd=2
los=30
hp=15

def_typ=spider
atk_typ=spider
atk=2
]]
archer=parse[[
idx=4
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

spd=1.5
los=30
hp=15
proj_xo=-2
proj_yo=0
proj_freq=30
proj_s=4
range=25

atk_typ=archer
def_typ=archer
atk=1
]]
warant=parse[[
idx=5
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

attack_x=64
attack_y=72
attack_fr=2
attack_fps=10

dead_x=72
dead_y=64

portx=35
porty=72
portw=9
unit=1
dir=1

spd=1.5
los=30
hp=15

atk_typ=warant
def_typ=warant
atk=1
]]
cat=parse[[
idx=6
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

spd=0.75
los=30
hp=15
proj_freq=60
proj_xo=1
proj_yo=-4
proj_s=8
range=50

atk_typ=cat
def_typ=cat
atk=2
]]
queen=parse[[
idx=7
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
los=20
range=20
hp=50
proj_xo=-4
proj_yo=2
proj_freq=30
proj_s=4

atk_typ=archer
def_typ=queen
atk=1
bitmap=0
]]

--#########----

tower=parse[[
idx=8
w=8
fw=8
h=14
fh=16

rest_x=24
rest_y=96

attack_x=24
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

los=30
hp=40
dir=-1
range=25
const=20
proj_yo=-2
proj_xo=-1
proj_freq=30
proj_s=0

atk_typ=tower
def_typ=building
atk=1
bitmap=1
]]
mound=parse[[
idx=9
w=8
fw=8
h=8
fh=8

rest_x=0
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
los=5
hp=30
dir=-1
const=12
has_q=1
drop=1
def_typ=building
bitmap=2
]]

den=parse[[
idx=10
w=8
fw=8
h=8
fh=8

rest_x=0
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
los=10
hp=20
dir=-1
const=20
has_q=1
def_typ=building
bitmap=4
]]
barracks=parse[[
idx=11
w=8
fw=8
h=8
fh=8

rest_x=0
rest_y=121

fire=1
dead_x=48
dead_y=104
dead_fr=7
dead_fps=9

portx=0
porty=88
portw=8

bldg=1
los=10
hp=20
dir=-1
const=20
has_q=1
def_typ=building
bitmap=8
]]
farm=parse[[
idx=12
w=8
fw=8
h=8
fh=8

rest_x=24
rest_y=120

fire=1
dead_x=48
dead_y=104
dead_fr=7
dead_fps=9

portx=17
porty=80
portw=9

bldg=1
los=0
hp=10
dir=-1
const=6
def_typ=building
bitmap=16
]]
farm_renew_cost_b=3


castle=parse[[
idx=13
w=15
fw=16
h=16
fh=16

rest_x=80
rest_y=113

attack_x=80
attack_y=113

fire=1
dead_x=48
dead_y=97
dead_fr=4
dead_fps=15

portx=8
porty=88
portw=9
bldg=1
has_q=1

los=40
hp=70
dir=-1
range=30
const=20
proj_yo=0
proj_xo=0
proj_s=0
proj_freq=20

atk_typ=tower
def_typ=building
atk=1
bitmap=32
]]

ant.prod={
	parse([[
r=0
g=0
b=2
]],mound),

	parse([[
r=1
g=3
b=0
breq=2
]],farm),

	parse([[
r=0
g=5
b=5
]],barracks),

	parse([[
r=0
g=3
b=8
breq=8
]],den),

	parse([[
r=0
g=3
b=8
]],tower),

--breq=1|4|8=13 (twr,den,bar)
	parse([[
r=0
g=3
b=3
breq=13
]],castle),
}

queen.prod={
	parse([[
t=6
r=2
g=3
b=0
]],ant),
{},{},{},
	parse([[
t=10
r=0
g=12
b=0
]],parse[[
portx=96
porty=88
portw=8
]],function()
			carry_capacity=9
		end
	),
}

web=parse([[
t=4
r=0
g=2
b=0
breq=1000
]],parse[[
portx=8
porty=80
portw=9
]])

spider.prod={web}

den.prod={
	parse([[
t=8
r=0
g=4
b=3
]],beetle),

	parse([[
t=8
r=3
g=4
b=0
]],spider),
{},{},
 parse([[
t=5
r=0
g=2
b=0
]],parse[[
portx=114
porty=64
portw=9
]],function()
			beetle[1].atk+=1
		end
	),
	parse([[
t=5
r=0
g=2
b=0
]],parse[[
portx=105
porty=64
portw=9
]],function()
			spider[1].atk+=1
		end
	),
	parse([[
t=5
r=0
g=2
b=0
]],parse[[
portx=114
porty=72
portw=9
]],function()
			web.breq=nil
		end
	),
}

mound.prod={
	parse([[
t=12
r=5
g=5
b=1
]],parse[[
portx=104
porty=88
portw=9
]],function()
			farm_cycles=10
		end
	),
}

barracks.prod={
	parse([[
t=10
r=1
g=2
b=1
]],warant),
	parse([[
t=10
r=1
g=2
b=1
]],archer),

	{},{},
	
		parse([[
t=5
r=0
g=2
b=0
]],parse[[
portx=105
porty=72
portw=9
]],function()
			warant[1].atk+=1
		end
	),
	
	parse([[
t=5
r=0
g=2
b=0
]],parse[[
portx=96
porty=72
portw=9
]],function()
			archer[1].atk+=1
		end
	),
	parse([[
t=5
r=0
g=2
b=0
]],parse[[
portx=96
porty=64
portw=9
]],function()
			archer[1].range+=5
			archer[1].los+=5
		end
	),
}

castle.prod={
	parse([[
t=10
r=1
g=2
b=1
]],cat),
{},{},{},
 parse([[
t=5
r=0
g=2
b=0
]],parse[[
portx=96
porty=80
portw=8
]],function()
			units_heal[1]=true
		end
	),
	parse([[
t=5
r=0
g=2
b=0
]],parse[[
portx=104
porty=80
portw=9
]],function()
			for x in all{tower,castle,
				den,barracks} do
				x[1].los+=5
			end
		end
	),
}

dmg_mult=parse[[
warant_vs_worker=1
warant_vs_archer=1
warant_vs_warant=1
warant_vs_queen=1
warant_vs_spider=1
warant_vs_beetle=1.5
warant_vs_building=1
warant_vs_cat=1.5

spider_vs_worker=1
spider_vs_archer=1
spider_vs_warant=1
spider_vs_queen=1
spider_vs_spider=1
spider_vs_beetle=1.5
spider_vs_building=1
spider_vs_cat=1

beetle_vs_worker=1
beetle_vs_archer=1
beetle_vs_warant=1
beetle_vs_queen=1
beetle_vs_spider=1
beetle_vs_beetle=1
beetle_vs_building=2
beetle_vs_cat=1

tower_vs_worker=1
tower_vs_archer=1
tower_vs_warant=1
tower_vs_queen=1
tower_vs_spider=1
tower_vs_beetle=1
tower_vs_building=1
tower_vs_cat=1

cat_vs_worker=1
cat_vs_archer=1
cat_vs_warant=1
cat_vs_queen=1
cat_vs_spider=1
cat_vs_beetle=1
cat_vs_building=2.5
cat_vs_cat=1

archer_vs_worker=1
archer_vs_archer=1
archer_vs_warant=1
archer_vs_queen=1
archer_vs_spider=1
archer_vs_beetle=1
archer_vs_building=1
archer_vs_cat=1
]]

function rest(u)
	u.st={t="rest"}
end

function move(u,...) --u,x,y
	u.st={
		t="move",
		wayp=get_wayp(u,...),
	}
end

function build(u,b)
	u.st,u.res={
		t="build",
		target=b,
		wayp=get_wayp(u,b.x,b.y,true),
	}
end

function target_tile(tx,ty)
	return {
		x=tx*8+3,y=ty*8+3,
		typ={w=8,h=8},
	}
end

function gather(u,tx,ty,wp)
	local t=target_tile(tx,ty)
	u.st={
		t="gather",
		tx=tx,
		ty=ty,
		res=f2res["f"..fget(mget(tx,ty))],
		wayp=wp or
			get_wayp(u,t.x,t.y,true),
		target=t,
	}
end

function drop(u,nxt_res,dropu)
	if not dropu then
		wayp,x,y=dmap_find(u,"d")
		dropu=not wayp and p1q
	end
	if dropu then
		wayp=get_wayp(u,dropu.x,
			dropu.y,true)
	end
	u.st={
		t="drop",
		wayp=wayp,
		nxt=nxt_res,
		target=dropu or
			target_tile(x,y),
	}
end

function attack(u,e)
	if u.typ.atk then
		u.st={
			t="attack",
			target=e,
			wayp=get_wayp(u,e.x,e.y,true),
		}
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
	local lclick,rclick=btnp(5),
		btnp(4)

	--check left click on button
	if lclick and hovbtn then
		hovbtn.handle()
		return
	end
	
	--click in menubar
	--menuy
	if amy>104 and not selbox then
		local dx,dy=amx-mmx,amy-mmy
		--minimap
		if dx>=0 and dy>=0 and
			dx<mmw and dy<mmh+1	then
			local x,y=
				dx/mmw*mapw,
				dy/mmh*maph
			if rclick and sel1 then
				--right click, move
				for u in all(selection) do
					move(u,x,y)
				end
				hilite={t=t(),px=amx,py=amy}
			elseif lclick then
				--move camera
				cx,cy=
					mid(0,x-64,mapw-128),
					--menuh=21
				 mid(0,y-64,maph-107)
			end
		end
		if (lclick) to_build=nil
	 return
	end
	
	--right click cancels place
 if rclick and (to_build or
 	webbing) then
 	to_build,webbing,webx=nil
 	return
 end
 
 --left click places web
 if webbing then
 	if lclick and acc(wmx\8,wmy\8) then
	 	if webx then
				pay(web,-1)
	 		sel1.st,webbing,webx={
	 		 t="web",
	 		 wayp=get_wayp(
	 		 	sel1,webx,weby),
	 		 x1=webx,
	 		 y1=weby,
	 		 x2=wmx,
	 		 y2=wmy,
	 		}
	 	else
	 		webx,weby=wmx,wmy
	 	end
 	end
 	return
 end

 if lclick and to_build then
  if buildable() then
	  pay(to_build,-1)
			local new=unit(
				to_build.typ,
				to_build.x+to_build.typ.w\2,
				to_build.y+to_build.typ.h\2,
				1,nil,nil,0)
			for u in all(selection) do
			 build(u,new)
			end
			to_build=nil
		end
		return
 end
 
	--left drag makes selbox
 if btn(5) and not to_build then
 	if not selbox then
 		selx,sely=mx,my
 	end
		selbox={
			min(selx,mx),
			min(sely,my),
			max(selx,mx),
			max(sely,my),
			7 --color when unpacking
 	}
 else
 	selbox=nil
 end
	
 --right click
 if rclick and sel1 and sel1.p==1 then
	 local tx,ty=mx\8,my\8
	 
	 if can_renew_farm() then
	 
	 	hilite_hoverunit()
	 	hoverunit.exp,
	 		hoverunit.cycles=false,0
	 	res.b-=farm_renew_cost_b
	 	harvest(sel1,hoverunit)
	 	
	 elseif can_gather() then
	 
	 	hilite={t=t(),tx=tx,ty=ty}
	  for u in all(selection) do
			 if avail_farm() then
			 	harvest(u,hoverunit)
			 	break
			 else
			 	gather(u,tx,ty)
  		end
  	end
  	
  elseif can_build() then
  
  	for u in all(selection) do
  		build(u,hoverunit)
  	end
  	hilite_hoverunit()
  	
	 elseif can_attack() then
	 
	 	for u in all(selection) do
  		attack(u,hoverunit)
  	end
  	hilite_hoverunit()
  	
  elseif can_drop() then
  
	 	for u in all(selection) do
				drop(u,nil,hoverunit)
  	end
  	hilite_hoverunit()
  	
  elseif sel1.typ.unit then
  
	 	for u in all(selection) do
				move(u,mx,my)
  	end
  	hilite={t=t(),x=mx,y=my}
  	
  elseif sel1.typ.prod then
  	--set rally
  	if is_res(mx,my) then
 	  hilite={t=t(),tx=tx,ty=ty}
			end
  	sel1.rx,sel1.ry=mx,my
  end
 end
end

function hilite_hoverunit()
	hilite={t=t(),unit=hoverunit}
end

function handle_input()
	local b=btn()
	--make p1=p2, allowing esdf
	if (b>32) b>>=8
	cx,cy,amx,amy=
 	mid(0,
 		cx+band(b,0x2)-band(b,0x1)*2,
 		mapw-128
 	),
 	mid(0,
 		cy+band(b,0x8)/4-band(b,0x4)/2,
	 	--menuh=21
 		maph-107
 	),
 	mid(0,stat(32),126),
	 mid(-1,stat(33),126)
 
 --mouse-based calculations
 --buttons are actually added
 --in _draw(), frame behind
 mx,my,wmx,wmy,hovbtn=
 	amx+cx,amy+cy,mx+3,my+3
 for b in all(buttons) do
 	if intersect(b.r,
 		{amx,amy,amx,amy},1) then
			hovbtn=b
 	end
	end
	if webx and dist(webx-wmx,weby-wmy)>18 then
		wmx,wmy=norm({wmx,wmy},
			{x=webx,y=weby},20)
	end
 
 handle_click()
 --should happen after click
 --because click could be on a
 --to_build
 if to_build then
	 to_build.x,to_build.y=
	 	mx\8*8,my\8*8
	end
end

function update_sel(u)
	u.sel=intersect(selbox,u_rect(u),0)
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
	if u.dead then
		u.dead+=1
		if (u.dead==60) del(units,u)
		if (typ.bldg) mset(u.x/8,u.y/8,74)
		return
	end
	if u.hp<=0 then
		u.dead,u.st,u.sel=
			0,{t="dead"}
		del(selection,u)
		if typ.bldg then
			register_bldg(u)
		end
		if u.p==1 then
			if u.typ==mound then
				res.p-=5
			elseif typ.unit then
				res.p+=1
			end
		end
		return		
	end
	
	if units_heal[u.p] and
		not u.fire and
	 u.hp<typ.hp and
		fps==0 then
		u.hp+=0.5
	end
	
	if intersect(
		u_rect(u),
		{mx,my,mx,my},1
	) then
		hoverunit=u
	end
	
	if (selbox) update_sel(u)
	if (u.const) return
	if u.st.target and u.st.target.dead then
		rest(u)
	end
	
	update_unit(u)
	
	--update viz
	if u.p==1 or u.st.t=="attack" then
		for t in all(
		 viztiles(
		 	u.x,u.y,
		 	u.p==1 and typ.los or 8
		 )
		) do
			local x,y=u.x\8+t[1],
				u.y\8+t[2]
			s(hiviz,x,y,g(bldgs,x,y,1))
			--"f" bc it's used for concat
			--when drawing minimap
			--in theory can be any truthy
			s(vizmap,x,y,"f")
		end
	end

	if typ.unit and not u.st.wayp then
		while g(pos,u.x\4,u.y\4) do
			u.x+=rnd(2)-1
			u.y+=rnd(2)-1
		end
		s(pos,u.x\4,u.y\4,1)
	end
end

function viztiles(x,y,los)
	local xo,yo,vlos,l=x%8\2,y%8\2,
		vcache[los],ceil(los/8)
	if not vlos then
		vlos={}
		vcache[los]=vlos
	end
	local viz=vlos[pt2key{xo,yo}]
	if not viz then
		viz={}
		vlos[pt2key{xo,yo}]=viz
		for dx=-l,l do
		 for dy=-l,l do
				if dist(
					xo-dx*4-2,
					yo-dy*4-2
				)<los/2 then
					add(viz,{dx,dy})
				end
			end
		end
	end
	return viz
end

function update_projectiles()
 for p in all(proj) do
 	p.x,p.y=norm(p.to,p,0.8)
  if adj(p.to,p,0.5) then
   if intersect(
   	u_rect(p.to_unit),
  		{p.x,p.y,p.x,p.y},0
  	) then
 	 	deal_dmg(p.from_unit,
 	 		p.to_unit)
			end
  	del(proj,p)
  end
 end
end
-->8
--map

function draw_map()
 camera(cx%8,cy%8)
 map(cx/8,cy/8,0,0,17,17)
 camera(cx,cy)
end

function draw_hiviz()
	pal(split"0,5,13,13,13,13,6,2,6,6,13,13,13,5,5")
	for i,v in pairs(hiviz) do
		i-=1
 	local xx,yy=i%(mapw/4),i\(mapw/4)
		if not vizmap[i+1]
		--tokens, no perf impact
--			and xx>=cx\8 and xx<=cx\8+16
--			and yy>=cy\8 and yy<=cy\8+16
		then
			map(xx,yy,xx*8,yy*8,1,1)
			if v!=1 then
				clip(xx*8-cx,yy*8-cy,8,8)
				_pal,pal=pal,max
				draw_unit(v)
				pal=_pal
				clip()
			end
		end
	end	
	pal()
end

function draw_fow()
	for x=cx\8,cx\8+16 do
	 for y=cy\8,cy\8+16 do
	 	if not g(vizmap,x,y) then
	 		local xx,yy=x*8,y*8
				fillp(▒)
				--make it so … doesn't
				--draw on black
				poke(0x5f5e,158)
				rectfill(xx-1,yy-1,
					xx+8,yy+8,0)
				poke(0x5f5e,255)
				
				-- nicer … but more tok
--				color(
--					g(hiviz,x,y) and 5 or 0)
--				if g(vizmap,x-1,y) then
--		 		line(xx-1,yy,xx-1,yy+7)
--				end
--				if g(vizmap,x,y-1) then
--		 		line(xx,yy-1,xx+7,yy-1)
--				end
--				if g(vizmap,x,y+1) then
--		 		line(xx,yy+8,xx+7,yy+8)
--				end
--				if g(vizmap,x+1,y) then
--		 		line(xx+8,yy,xx+8,yy+7)
--				end

				fillp()
				rectfill(xx,yy,xx+7,yy+7,nil)
	 	end
	 end
	end
end

-- 0.11 cpu
function draw_minimap()
	camera(-mmx,-mmy)
	
	--map tiles
	for tx=0,mmw do
	 for ty=0,mmh do
	 	local x,y=mapw/mmw*tx\8,
	 		maph/mmh*ty\8
	 	pset(
	 		tx,ty,
				rescol[
					(g(hiviz,x,y) and "" or "_")..
					g(vizmap,x,y,"h")..
					fget(mget(x,y))
				]
	 	)
		end
	end
	
	--units
	for u in all(units) do
		if g(hiviz,u.x\8,u.y\8) then
			pset(
				u.x/mapw*mmw,
				u.y/maph*mmh,
				u.sel and 9 or
				 u.p==1 and 1 or 14
			)
		end
	end
	
	--current view area outline
	local vx,vy=
		ceil(cx/mapw*mmw),
	 ceil(cy/maph*mmh)
	rect(
		vx-1,vy-1,
		vx+128/mapw*mmw+1,
		vy+128/maph*mmh+1,
		10
	)
	camera()
end

function draw_projectiles()
 for p in all(proj) do
		sspr(
			p.from_unit.typ.proj_s+
				fps\5%2*2,
			112,2,2,p.x,p.y
		)
	end
end
-->8
--units

function draw_unit(_ENV)
-- possibly unnecessary opt
--	if
--		not intersect(
--			u_rect(u),
--			{cx,cy,cx+128,cy+128},
--		 1
--		)
--	then
--		return
--	end
	local
		res_typ,
		col=
			res and res.typ or "",
			p==1 and 1 or 2

	local fw,w,h,
	 stt,
	 hpp=
		 typ.fw,typ.w,typ.h,
		 st.wayp and "move" or st.t,
		 hp/typ.hp
	
	local xx,yy,sx,sy,ufps,fr,f=
		x-w/2,y-h\2,
	 typ[stt.."_x"]+max(typ["xoff_"..res_typ]),
	 typ[stt.."_y"]+max(typ["yoff_"..res_typ]),
	 typ[stt.."_fps"],
	 typ[stt.."_fr"],
  --can't use fps bc of _ENV
		dead or time()*30%60

	if stt=="web" and st.first_pt then
		line(st.x1,st.y1,
			st.second_pt and st.x2 or x,
			st.second_pt and st.y2 or y,
			7)
	end
	
	if const then
		fillp(▒)
		rectaround(_ENV,_ENV==sel1 and 9 or 12)
		fillp()
		local p=const/typ.const
		bar(
			xx,
			yy,
			fw-1,
			p,
			14,5
		)
		--construction sprite
		--(switches after 0.5)
		sx+=fw*ceil(p*2)
		if (p<=0.1) return
	elseif typ==farm then
	 --maybe can turn this to be
	 --stateful?
		local q=res.qty
		sx=exp and 72 or
			ready and (q>4 and 48 or 64) or
			q>6 and 48 or q>3 and 56 or sx
	elseif ufps then
		sx+=f\ufps%fr*fw
	end
	pal(2,col)
	if sel and (
	 (p==1 and (typ.unit or
	 	not my_sel)) or
	 not (my_sel or bldg_sel)
	) then
		col=9
	end
	pal(1,col)
	if st.webbed then
		pal(split"7,7,6,6,6,7,7,7,7,7,7,7,6,7,7,6")
	end
	sspr(sx,sy,w,h,xx,yy,w,h,
		not typ.fire and dir==typ.dir)
	pal()
	if not dead and hpp<=0.5 then			
	 if typ.fire then
			spr(230+f/20,x-3,y-8)
		end
		bar(xx,yy-1,w,hpp)
	end

--	if u.sel and u.typ.range then
--		circ(u.x,u.y,u.typ.los,13)
--		circ(u.x,u.y,u.typ.range,8)
--	end
--	pset(u.x,u.y,13)
--	if u.st.wayp then
--		for wp in all(u.st.wayp) do
--			pset(wp[1],wp[2],acc(wp[1]/8,wp[2]/8) and 12 or 8)
--		end
--	end
end

function update_unit(u)
	local st=u.st
	if st.webbed then
		if (fps==0) st.webbed-=1
		if (st.webbed==0) rest(u)
	end
	local t=st.t
	if t=="web" and st.ready then
		line(st.x1,st.y1,
			st.x2,st.y2,12)
		for e in all(units) do
			if e.p!=u.p and
				(pget(e.x,e.y)==12 or
					pget(e.x+1,e.y)==12) then
				e.st={t="dead",webbed=5}
				attack(u,e)
				break
			end
		end
	end
 if (u.q) produce(u)
 if (u.typ==farm) update_farm(u)
 if st.active then
 	if (t=="harvest") farmer(u)
 	if (t=="build") buildrepair(u)
  if (t=="gather") mine(u)
  if t=="drop" and st.nxt then
  	mine_nxt_res(u,st.nxt)
		end
 else
 	check_target_col(u)
 end
 step(u)
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
		u.ready=u.res.qty==9
	end
end

function farmer(u)
	local f=u.st.farm
	if f.ready and fps==0 then
		collect(u,"r")
		f.res.qty-=1
		if f.res.qty==0 then
			f.cycles+=1
			f.exp,f.ready=
				f.cycles==farm_cycles
		end
		if u.res.qty==carry_capacity or
			f.exp then
			drop(u)
			u.st.farm=f
		end
	end
end

function aggress(u)
	for e in all(units) do
		if g(vizmap,e.x\8,e.y\8) and
			e.p!=u.p and not e.dead then
			local typ=u.typ[u.p]
			if dist(e.x-u.x,e.y-u.y)<=
				max(
					typ.bldg and 0 or typ.los,
					typ.range) then
				attack(u,e)
				break
			end
		end
	end
end

function fight(u)
	local typ,e,in_range=
		u.typ[u.p],u.st.target
	local d=dist(e.x-u.x,e.y-u.y)
	if typ.range then
		in_range=d<=typ.range and
			g(vizmap,e.x\8,e.y\8)
		if in_range and fps%typ.proj_freq==0 then
 		add(proj,{
 			from_unit=u,
 			x=u.x-u.dir*typ.proj_xo,
 			y=u.y+typ.proj_yo,
 			to={e.x,e.y},to_unit=e,
 		})
 	end
 else
 	in_range=intersect(u_rect(u),
 	 u_rect(e),0)
		if in_range and fps%30==0 then
		 deal_dmg(u,e)
		end
 end
 u.st.active=in_range
 if in_range then
		u.dir,u.st.wayp=sgn(e.x-u.x)
	elseif fps%30==0 then
		if typ.los>=d and not typ.bldg then
			--pursue enemy
	 	attack(u,e)
	 elseif not u.st.wayp then
	 	rest(u)
	 end
 end
end

function buildrepair(u)
	local b=u.st.target
	if fps%30==0 then
		if b.const then
 		b.const+=1
 		if b.const==b.typ.const then
 			b.const=nil
 			register_bldg(b)
 			if b.typ==mound and b.p==1 then
 				res.p+=5
 			elseif b.typ==farm then
 				harvest(u,b)
 				b.res,b.cycles=
 					{typ="r",qty=0},0
 			end
 		end
 	elseif (
 		b.hp<b.typ.hp and
 		res.b>=1
 	) then
 		b.hp+=1
 		res.b-=0.5
 	else
 		rest(u)
 	end
 end
end

function mine(u)
	local x,y,r=u.st.tx,u.st.ty,u.st.res
	if g(restiles,x,y)==0 then
		if not mine_nxt_res(u,r) then
		 drop(u,r)
		end
	elseif fps==u.st.fps then
		collect(u,r)
		mine_res(x,y,r)
		if u.res.qty>=carry_capacity then
			drop(u,r)
		end
	end
end

function produce(u)
	if fps%15==u.q.fps15 then
		local b=u.q.b
		u.q.t-=0.5
		if u.q.t==0 then
			if b.tech then
				del(u.typ.prod,b)
				b.tech()
			else
				local new=unit(
					b.typ,u.x,u.y,1
				)
				if new.typ==ant and
					u.rx and
					is_res(u.rx,u.ry)
				then
					gather(new,u.rx\8,u.ry\8)
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

function check_target_col(u)
	local st=u.st
	local t=st.target
	if (
		t and
		intersect(u_rect(t),u_rect(u),
			st.t=="gather" and -3 or 0)
	) then
		u.dir,st.active,st.fps=
			sgn(t.x-u.x),true,fps
		if st.t=="harvest" then
			if (st.farm.exp)	rest(u)	
		else
			st.wayp=nil
		end
		if st.t=="drop" then
			local ures=u.res
			if ures then
				res[ures.typ]+=ures.qty/3
				u.res=nil
			end
			if st.farm then
				harvest(u,st.farm)
			elseif not st.nxt then
				rest(u)
			end
		end
	end
end

function step(u)
	local st=u.st
	local wayp,spd=st.wayp,u.typ.spd
	if wayp then
	 --spider making web is slow
 	if (st.first_pt) spd/=2
 	u.x,u.y,u.dir=norm(wayp[1],u,
 		spd/3.5)
 	
 	if adj(wayp[1],u,2) then
 		if #wayp==1 then
 			st.wayp=nil
				if st.t=="web" then
					if st.second_pt then
						st.ready=true
					elseif st.first_pt then
						st.wayp,st.second_pt={
							{u.x-(st.x2-st.x1)/2,
							 u.y-(st.y2-st.y1)/2}
						},true
					else
						st.wayp,st.first_pt={
							{st.x2,st.y2}
						},true
					end
				elseif st.t!="harvest" and
					st.t!="attack" then
					rest(u)
				end
			else
			 deli(wayp,1)
			end
 	end
 end
end
-->8
--utils

function intersect(r1,r2,e)
	return r1[1]-e<r2[3] and
		r1[3]+e>r2[1] and
		r1[2]-e<r2[4] and
		r1[4]+e>r2[2]
end

function u_rect(u,e)
	local w2,h2,e=u.typ.w/2,
		u.typ.h/2,e or 0
 return {
 	u.x-w2-e,u.y-h2-e,
 	u.x+w2,u.y+h2
 }
end

-- musurca - https://www.lexaloffle.com/bbs/?tid=36059
function dist(a,b)
 local a0,b0=abs(a),abs(b)
 return max(a0,b0)*0.9609+
 	min(a0,b0)*0.3984
end

function all_surr(x,y,n,chk_acc)
	local st={}
	for dx=-n,n do
	 for dy=-n,n do
	 	local xx,yy=x+dx,y+dy
	 	if
	 		xx>=0 and yy>=0 and
	 		xx<mapw8 and yy<maph8
	 		and (not chk_acc or
	 			acc(xx,yy) and
	 			(acc(xx,y) or acc(x,yy))
	 		)
	 	then
			 add(st,{
			  xx,yy,
			 	diag=dx!=0 and dy!=0
			 })
			end
		end
	end
	return all(st)
end

function mine_nxt_res(u,res)
	local wp,x,y=dmap_find(u,res)
	if wp then
		gather(u,x,y,wp)
		return true
	end
end

function is_res(x,y)
	return fget(mget(x\8,y\8),1)
end

function avail_farm()
	return hoverunit and
		hoverunit.typ==farm and
		not hoverunit.farmer and
		not hoverunit.const
end

function can_gather()
	return (is_res(mx,my) or
		avail_farm()) and
		sel_typ==ant and
		g(hiviz,mx\8,my\8) and
		sur_acc(mx\8,my\8)
end

function can_attack()
	for u in all(selection) do
		if u.typ.atk and
			g(hiviz,mx\8,my\8) and
			hoverunit and
		 hoverunit.p!=1
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

function mine_res(x,y,r)
	local full=resqty[r]
	--could add +10 to full if
	--mget(x,y) has flag x
	--(give alt res more capacity)
	local n=g(restiles,x,y,full)-1
	if n==full\3 or n==full*4\5 then
		mset(x,y,mget(x,y)+16)
	elseif n==0 then
		mset(x,y,74) --exhaust tile
		s(dmap_st[r],x,y)
		s(dmaps[r],x,y)
		make_dmaps(r)
	end
	s(restiles,x,y,n)
end

function adj(it,nt,n)
	return abs(it[1]-nt.x)<=n and
		abs(it[2]-nt.y)<=n
end

function norm(it,nt,f)
	local xv,yv=
		it[1]-nt.x,it[2]-nt.y
	local norm=f/(abs(xv)+abs(yv))
	return nt.x+xv*norm,
		nt.y+yv*norm,
		sgn(xv) --xdir
end

--strict=f to ignore farms+const
function acc(x,y,strict)
	local b=g(bldgs,x,y)
	return not fget(mget(x,y),0) and
		x>=0 and y>=0 and
		x<mapw8 and y<maph8 and
		(not b or (not strict and (
			b.const or b.typ==farm
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
	--subt 2 to make sure we ref
	--the top-left tile
	local w,h,x,y=typ.w,typ.h,
		(b.x-2)\8,(b.y-2)\8

	local reg=function(xx,yy)
		s(bldgs,xx,yy,
			not b.dead and b or nil)
		if b.dead then
			s(hiviz,xx,yy,1)
			s(dmap_st.d,xx,yy)
		elseif	typ.drop then
			s(dmap_st.d,xx,yy,{xx,yy})
		end
	end
	reg(x,y)
	if w>8 then
		reg(x+1,y)
		if (h>8) reg(x+1,y+1)
	end
	if (h>8) reg(x,y+1)
	
	if not b.const and typ!=farm then 
		make_dmaps"d"
		if b.p==1 then
			bldg_bmap|=typ.bitmap
			if (typ==queen) p1q=b
		end
	end
end

function deal_dmg(from,to)
	to.hp-=from.typ[from.p].atk*dmg_mult[from.typ.atk_typ.."_vs_"..to.typ.def_typ]
end

function collect(u,res)
	if u.res and u.res.typ==res then
		u.res.qty+=1
	else 
		u.res={typ=res,qty=1}
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
		res.b>=farm_renew_cost_b and
		sel_typ==ant and
		hoverunit.typ==farm and
		hoverunit.exp
end

function bar(x,y,w,prog,fg,bg)
	line(x,y,x+w,y,bg or 8)
	line(x,y,x+flr(w*prog),y,
		fg or 11)
end

function sur_acc(x,y)
	return acc(x-1,y) or
		acc(x+1,y) or
		acc(x,y-1) or
		acc(x,y+1)
end

function unit(typ,x,y,p,hp,
	id,const)
 uid+=1
 local u=add(units,{
		typ=typs[typ] or typ,
		x=x,
		y=y,
		st={t="rest"},
		dir=1,
		p=p,
		hp=hp or typ.hp,
		const=const,
		uid=id or uid,
		--allow calling from ENV
		bar=bar,
		rectaround=rectaround
	})
	if u.typ.bldg then
		register_bldg(u)
	end
	return u
end

-->8
--get_wayp

function nearest_acc(x,y,sx,sy)
	for n=0,99 do
		local best_t,best_d
		for t in all_surr(x,y,n) do
			if acc(unpack(t)) then
				local d=dist(
					t[1]*8+4-sx,
					t[2]*8+4-sy
				)
				if not best_t or
					d<best_d then
					best_t,best_d=t,d
				end
			end
		end
		if best_t then
			return n==0,unpack(best_t)
		end
	end
end

function get_wayp(u,x,y,enter)
	if (u.typ.bldg) return
 local wayp,d_acc,destx,desty=
 	{},
 	nearest_acc(
 		x\8,y\8,
 		u.x,u.y)
	local path,exists=find_path(
	 {u.x\8,u.y\8},
 	{destx,desty})
 for n in all(path) do
 	add(wayp,
 		{n[1]*8+4,
 		 n[2]*8+4},1)
 end
 if exists and (enter or d_acc) then
 	add(wayp,{x,y})
 end
 return wayp
end

--a*
--https://t.co/nasud3d1ix

function find_path(start,goal)
 
 local shortest, 
 best_table = {
  last = start,
  cost_from_start = 0,
  cost_to_goal = 32767
 }, {}

 best_table[pt2key(start)] = shortest
 local frontier, frontier_len,
 	closest = {shortest}, 1,
 	shortest
 while frontier_len > 0 do
  local cost, index_of_min = 32767
  for i = 1, frontier_len do
   local temp = frontier[i].cost_from_start + frontier[i].cost_to_goal
   if (temp <= cost) index_of_min,cost = i,temp
  end
  shortest = frontier[index_of_min]
  frontier[index_of_min], shortest.dead = frontier[frontier_len], true
  frontier_len -= 1
  local p = shortest.last
  
  if pt2key(p) == pt2key(goal) then
   p = {goal}

   while shortest.prev do
    shortest = best_table[pt2key(shortest.prev)]
    add(p, shortest.last)
   end

   return p,true
  end -- if
  for n in all_surr(
  	p[1],p[2],1,true
  ) do
   local old_best, new_cost_from_start =
    best_table[pt2key(n)],
    shortest.cost_from_start + 1
   
   if not old_best then
    old_best = {
     last = n,
     cost_from_start = 32767,
     cost_to_goal = 
     	dist(n[1]-goal[1],n[2]-goal[2])
    }

    frontier_len += 1
    frontier[frontier_len], best_table[pt2key(n)] = old_best, old_best
   end
   if not old_best.dead and old_best.cost_from_start > new_cost_from_start then
    old_best.cost_from_start, old_best.prev = new_cost_from_start, p
   end -- if
			if old_best.cost_to_goal < closest.cost_to_goal then
				closest = old_best
			end
			
  end
 end
 local p = {closest.last}
 while closest.prev do
  closest = best_table[pt2key(closest.prev)]
  add(p, closest.last)
 end
 return p
end
-->8
--menu/cursor

resorder,f2res,resqty,key2resf,
	dmap_queue,rescol=
	split"r,g,b,p",parse[[
f7=r
f11=g
f19=b
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
r=r,g,b,d
g=g,r,b,d
b=b,g,r,d
d=d,r,g,b
]],parse[[
r=8
g=11
b=4
p=1

f0=15
f1=15
f7=8
f11=11
f19=4
f33=12

h0=5
h1=5
h7=2
h11=3
h19=4
h33=13
]]

function print_res(rsc,x,y,s,hide_0,pop)
	for i,r in pairs(resorder) do
		local v=pop and i==4 and "" or flr(rsc[r])
		local no_pop=v==0 and i==4
		local xoff=no_pop and 6 or 3
		if v!=0 or not hide_0 then
			if v!="" or pop then
				if v=="" or res[r]<v or no_pop then
					rectfill(x-xoff/3,y-1,
						x+xoff+#tostr(v)*4-s\2,y+5,
						10)
				end
				spr(129+i,x,y)
				x+=4+i\4
			end
			if v!="" then
				x=print(v,x,y,rescol[r])+s
				if not hide_0 and i==3 then
					line(x-1,y-1,x-1,y+5,5)
					x+=2
				end
			end
		end
	end
	return x
end

function breq_satisfied(costs)
	return not costs.breq or
 	bldg_bmap&costs.breq==
 	costs.breq
end

function can_pay(costs)
 return res.r>=costs.r and
 	res.g>=costs.g and
 	res.b>=costs.b and
 	(not costs.typ.unit or res.p>=1) and
 	breq_satisfied(costs)
end

function pay(costs,dir)
 res.r+=costs.r*dir
	res.g+=costs.g*dir
	res.b+=costs.b*dir
	if costs.typ.unit then
		res.p+=dir
	end
end

function draw_port(
	typ,x,y,costs,onclick,prog,u
)
	if (not typ) return
	local cant_pay=costs and not can_pay(costs)
	rect(x,y,x+10,y+9,
		u and u.p!=1 and 2 or
		cant_pay and 6 or
		costs and 3 or 1
	)
	rectfill(x+1,y+1,x+9,y+8,
		cant_pay and 7 or costs and
 	costs.tech and 10 or 6
	)
	pal(14,0)
	if cant_pay then
		pal(split"5,5,5,5,5,6,6,13,6,6,6,6,13,6,6,5")
	end
	if not costs then
		--gray bg, turn gray to white
		pal(6,7)
	end
	sspr(typ.portx,typ.porty,
	 typ.portw,8,x+1,y+1)
	pal()
	
	if onclick then
		add(buttons,{
			r={x,y,x+10,y+8},
			handle=onclick,
			costs=costs,
		})
	end

	if u or prog then
		bar(x,y+11,10,
			prog or u.hp/typ.hp,
			prog and 12,
			prog and 5
		)
	end
end

function cursor_spr()
 --pointer (buttons)
 if webbing then
 	--menuy
 	if amy<104 and not acc(wmx\8,wmy\8) then
			pal(split"8,8,8,8,8,8,8")
 	end
 	return 70
 end
 if hovbtn then
 	--pointer spr missing 1px
		pset(amx-1,amy+4,5)
  return 66
	end
	if sel1 and sel1.p==1 then
	 --build cursor
		if to_build or 
			can_build() or
			can_renew_farm() then
			return 68
		end
		--pick
		if (can_gather())	return 67
		--sword
		if (can_attack()) return 65
		--basket
		if (can_drop()) return 69
	end
	--default
	return 64
end

function draw_sel_ports()
	for i,u in pairs(selection) do
		local x=i*13-10
		if i>6 then
			--menuy+6
			print("+"..#selection-6,x,110,1)
			break
		end
		draw_port(
			--menuy+3
			u.typ,x,107,nil,
			function()
				u.sel=false
				del(selection,u)
			end,
			nil,u)
	end
end

function single_unit_section()
	local typ,r,q=
		sel1.typ,sel1.res,sel1.q
	
	if #selection<3 then
		draw_sel_ports()
	else
		--menuy+4
		draw_port(typ,3,108,nil,
			function()
				sel1.sel=false
				deli(selection,1)
			end)
		--menuy+7
		print("X"..#selection,unspl"16,111,7")
	end
		
	if #selection==1 and r then
		for i=0,sel1.typ==ant and 
			carry_capacity-1 or 8 do
			local xx,yy=
				20+i%3*3,
				--menuy+4
				108+i\3*3
			rect(xx,yy,xx+3,yy+3,7)
			rect(xx+1,yy+1,xx+2,yy+2,
				r.qty>i and rescol[r.typ] or 5)
		end
	end

	if sel1.cycles then
		--menuy+6
		print(sel1.cycles.."/"..farm_cycles,unspl"36,110,4")
		--menuy+4
		spr(unspl"170,49,108,2,2")
	end
	if typ.prod and not sel1.const then
		for i,b in pairs(typ.prod) do
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
					if b==web then
						webbing,webx=true
						return
					end
					pay(b,-1)
					if q then
						q.qty+=1
					else
						sel1.q={
							b=b,qty=1,t=b.t,
							fps15=max(fps%15-1)
						}
					end
				end
			)
		end
		if q then 
			draw_port(
			 q.b.typ,
			 q.b.tech and 24 or
			  print("X"..q.qty,
			   --menuy+6
			   unspl"32,110,7") and 20,
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
	local x,secs,modstart=
 	0,split"102,26",1
 if sel_typ then
		if sel_typ.has_q then
  	secs=split"17,24,61,26"
 	elseif sel_typ.prod then
  	secs,modstart=split"35,67,26",0
  end
	end
 for i,sec in pairs(secs) do
 	if i%2==modstart then
 		pal(4,15)
 	end
 	local xx=sec+x-4
 	--104="y"=menuy
 	spr(128,x,104)
 	spr(128,xx-4,104)
 	line(x+3,105,xx,105,7)
 	rectfill(x+3,106,xx,108,4)
 	xx+=4
 	rectfill(x,108,xx,128)
 	x=xx
 	pal()
 end
 
 if sel_typ and
 	(#selection==1 or
 		sel_typ!=spider) and
 	sel1.p==1
 then
		single_unit_section()
	else
		draw_sel_ports()
	end
	
	--minimap
	draw_minimap()
	
	--resources
	local len=print_res(res,
		unspl"0,150,2")
	rectfill(len-1,unspl"121,0,128,7")
	print_res(res,unspl"1,122,2")
	line(len-2,unspl"120,0,120,5")
	pset(len-1,121)
	line(len,122,len,128)
	
	if hovbtn and hovbtn.costs and
		breq_satisfied(hovbtn.costs) then
		local pop=res.p<1 and
			hovbtn.costs.typ.unit
		local len=print_res(
		 hovbtn.costs,0,150,1,true,pop)
		local x,y=
			hovbtn.r[1]-(len-10)/2,
			hovbtn.r[2]-8
		rectfill(x,y,x+len,y+8,7)
		rect(x,y,x+len+1,y+8,1)
		print_res(hovbtn.costs
		 ,x+2,y+2,1,true,pop)
	end
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
			local w=g(dmap,t[1],t[2],9)
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

function pt2key(pt)
	return pt[1]+pt[2]*mapw/4+1
end
 
function g(a,x,y,def)
	return a[pt2key{x,y}] or def
end

function s(a,x,y,v)
 a[pt2key{x,y}]=v
end
	
function make_dmaps(r)
	queue=split(dmap_queue[r])
end

function async_task()
	--local x=stat(1)
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
		--printh(stat(1)-x,"log")
	end
end

function dmapcc(q)
	local nxt,off=q.nxt or {},
		q.offset or 1
	for i=off,#q.open do
		local x,y=unpack(q.open[i])
		if i-off>20 then
			q.offset,q.nxt=i,nxt
			--stop for now, continue
			--next frame
			return
		end
		s(q.dmap,x,y,q.c)
		if q.c<8 then
			for t in all_surr(x,y,1,true) do
				local xx,yy=unpack(t)
				if not g(q.closed,xx,yy) then
					s(q.closed,xx,yy,add(nxt,t))
				end
			end
		end
	end

	q.open,
	q.c,
	q.nxt,q.offset=
		nxt,
		q.c+1
end

function make_dmap(key)
	local open,starts={},
		dmap_st[key]
	 
	--ensure starts exists (we
	--won't enter the if for "d")
	if not starts then
		starts={}
		dmap_st[key]=starts
		for x=0,mapw8 do
			for y=0,maph8 do
				if
					fget(mget(x,y),key2resf[key])
			 then
			 	s(starts,x,y,{x,y})
			 end
			end
		end
	end

	for i,t in pairs(starts) do
		if	sur_acc(unpack(t)) then
			--don't need to set closed[i]
			--here bc these tiles are
			--inaccessible anyway
			add(open,t)
		end
	end
	
	return {
		key=key,
		dmap={},
		open=open,
		c=0,
		closed={},
	}
end

--function draw_dmap(res_typ)
--	local dmap=dmaps[res_typ]
-- if (not dmap) return
-- for x=0,16 do
--		for y=0,16 do
--			local n=g(dmap,x+flr(cx/8),y+flr(cy/8))
--			print(n==0 and "+" or n or "",
--				x*8+2,y*8+2,14)
--	 end
--	end
--end
--draw=_draw
--_draw=function()
--	draw()
--	draw_dmap("r")
--end
-->8
--init

poke(0x5f2d,3)

function unspl(...)
	return unpack(split(...))
end

function init()
	mapw,maph,mmx,mmy,mmw=
		unspl"256,256,105,107,19"
	mmh,mapw8,maph8=
		maph\(mapw/mmw),
		mapw/8,maph/8
	
	--tech can change this
	units_heal,farm_cycles,
	carry_capacity,
	--global state
	cx,cy,mx,my,fps,bldg_bmap,uid=
		{},unspl"5,6,0,0,0,0,0,0,1"
	
	queue,hiviz,vcache,dmaps,
	units,restiles,selection,
		proj,bldgs,dmap_st,res=
		{},{},{},{},
		{},{},{},{},{},{d={}},
	 parse[[
r=5
g=5
b=5
p=7
]]
end

init()

local qx,qy=6*8,5*8
--qx=6*8, qy=5*8, +9, +4
unit(queen,unspl"57,44,1")
unit(mound,unspl"55,102,2")

make_dmaps"d"

unit(ant,unspl"40,40,1")-- -8,0
unit(ant,unspl"68,43,1")-- 20,3
unit(ant,unspl"50,32,1")-- 2,-8
unit(beetle,unspl"48,56,1")--0,16

--unit(beetle,unspl"65,81,2")

-->8
--clipboard saving

--[[
the following will not be saved:
- unit states
- resource count in partially
  mined resource tiles
- units in production, along w/
  the used resources+pop count
- techs (research, upgrades)
- if a prereq building was built
  but there are none left when
  saving, the prereq won't save
- top-left tree will regrow :-)
]]
menuitem(2,"save to clpbrd",function()
	local str=""
	--units
	for _ENV in all(units) do
		str=str..
		 typ.idx..","..
			x..","..
			y..","..
			p..","..
			hp..","..
			uid..
			(const and ","..const or "")..
			"\n"
	end
	--hiviz
	for k,v in pairs(hiviz) do
		if (v!=1) v=v.uid
		str=str..k.."="..v..","
	end
	str=str.."\n"
	--res
	for r in all(resorder) do
		str=str..res[r]..","
	end
	str=str.."\n"
	--map
	for i=1,mapw8*maph8-1 do
		str=str..
		 mget(i%mapw8,i/mapw8)..","
	end
	printh(str,"@clip")
end)

menuitem(3,"load from clpbrd",function()
	init()

	local lines,uids=
		split(stat(4),"\n"),
		{}
		
	for i,t in pairs(split(deli(lines))) do
		mset(i%mapw8,i/mapw8,t)
	end
	local r,hvz=
		split(deli(lines)),
		split(deli(lines))
	for i,k in pairs(resorder) do
		res[k]=r[i]
	end
	for l in all(lines) do
		local u=unit(unspl(l))
		uids[u.uid],uid=u,
			max(uid,u.uid)
	end
	for kv in all(hvz) do
		local k,v=unspl(kv,"=")
		hiviz[k]=v==1 and 1 or uids[v]
	end
	make_dmaps"d"
end)

menuitem(4," (do ctrl-v 1st)")
__gfx__
00000000d000000000000000000000000000000000d0000000000000000000000000000001000100000000000000000000000000110001100000000000000000
000000000d000000d00000000000000000000000000d000000000000000000000110000000101000000000001100011000000000001010000000000000000000
00700700005111000d000000dd00000000000000000051100d011100dd0000001111000000101000011100000010100001110000044440000000000000000000
000770000051111000511100005111000000000000005111d0511110005111001111011104444000111101110444400011110111042420000000000000010100
000770000001111000511110005111100d51110000000d11005d1110005111101101441144242000110144114424200011014411404400000110001110144410
00700700000d1d10000d1d100001d1d0d051d1d00000000d000000d0000d1d100005440050440000110544005044000011054405050050001111144114154510
00000000000000000000000000000000000000000000000000000000000000000050500505005000005050050500500000505000000000001150544505044000
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
50050050501510505001510550051105050511505015150050115050551515500000000505dd0005000000050000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003d11311311311310
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033d1515351515351
0000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d000000000000000000000000000000dd0000000d00000000d0000000000000000000000000000000d000000000000000000000000000000000000000000000
d00001100d0000000dd000000000000000310011003100110d0000000000000000d00000000000000d0000000000000000d000000000000000d0000000000000
31000110d0000110d00001100000000005d1001105d1001133000000000000000d0000000000000033100000000000000d000000000000000000000000000000
0011110031111110311111100d000110505d1110000d111033100000000000013310000000000000331131000000000033100013113000000d10000000011310
001d1d000d1d1d0001d1d1d0d3d1d1100000d1d00050d1d001113113113113113311311311311310001131131131131033113113113113103311311311311311
00000000000000000000000000000000000000000000000000513113113113500011311311311311050500131131131100113105050113113311311311350505
00000000000000000000000000000000000000000000000005005050505050000050505050505050000000505050505000505000000050500050505050500000
05000000555000000050000000555500000050000055550000700000000000000000000000000000ffffffff00000000ffffffffffffffffffffffffffffffff
57500000577500000575000005777750000575000577775000700600048800000480080004008800ffff6fff00000000ffffffffffffffffffffffffffffffff
57750000567755000575555057475500005777505755557506077060048888000488880004888800ffffffff00000000ffffffffffffffffffffffffffffffff
57775000056540005575757557744000057777505500005560760700048888000488880004888800f6ffffff00000000ffffffffffffffffffffafffffffffff
57777500005444007577777557544400577774005455554500706760040088000408800004880000ffffff6f00000000ffafffffff7fffffffffffffffffffff
57755000005044505777777557504440057744405494494577077000040000000400000004000000ffffffff00000000ffffffffffffffffffffffffffffffff
05575000000005000557775005000445005504455494494500600700141000001410000014100000fff6ffff00000000ffffffffffffffffffffffff7fffffff
00050000000000000005550000000050000000500555555006000070111000001110000011100000ffffffff00000000ffffffffffffffffffffffffffffffff
fff88fffffffff8fffffffffffffbbbfffffffffffffffffffffffffffffffffffffffff1111d111111d111100000000ffffffffffffffffffffffffffffffff
f887888ff8fff888f33fff33fffbb3bfff444fffffff44fffffffff6776fff766fffffff1dd1111111111dd100000000ffffffffffffffffffffffffffffffff
87887878888ff888f3bff3bbffbb3bbfff444ffff4f4444ffffff7666cc666cc667fffff1111111cc111111100000000fffffffffffffff7ffffffffffffffaf
88788788888f8fdfffbbfbffffb3bbbff4494fffff44454fffff67cccccccccccc76ffff1111cccccccc111100000000fffff7ffffffffffffffffffffffffff
fff77ffffdf888dffffbbbffffbbbbffff544ffff444544ffff76ccccc6cc6ccccc67fff111cccccccccc11100000000fffffffffffffffffffffaffffffffff
ff7777fffdd888dfffffbffffffbbfffff9444ff499544fffff6cccc6ccc6ccccccc6fff1d1cccccccccc1d100000000ffffffffffffffffffffffffffffffff
fff77fffffdfdfdfffffbffffffbffffff5444ff49944fffff66cccc7cccc11ccccc66ff111ccc6666ccc11100000000ffffffffffffffffffffffffffffffff
fff77fffffffdfffffffbffffffbffffff445ffff444fffff6c7ccc1111111111ccc7c6f11ccc667766ccc1100000000fffffffffffffaffffffffffffffffff
fff88ffffffffffffffffffffffffbfffffffffffffffffff66ccc111111111111ccc66f11ccc667766ccc11ffffffffffffffffffffffffffffffffffffffff
f887888ff8fff88fffffffffffffb3fffff4fffffffff4fff6ccc6111dd11111116ccc6f111ccc6666ccc111fffffffffffffffffffffffffffffffff7ffffff
ff8878f8f88ff888f3bfff3fffff3bbffff44ffffff4f44ff7cccc111166111111cccc7f1d1cccccccccc1d1ffefffffffffffffffffffffffffffffffffffff
f8788fff888f8fdffffbfbffffb3fbffff494fffff44454ff6c6cc111111111111cc6c6f111cccccccccc111fedeffffffffffffffffffffff7fffffffffffff
fff77ffffdff88dffffbbbffffbbbbffff544fffff4454fff66ccc1111111dd111ccc66f1111cccccccc1111f3effffffffaffffffffffffffffffffffffffff
ff77ffffffd88fdfffffbffffffbbfffff9444fff495ffffff6c6cc1111111111cc6c6ff1111111cc1111111f3ffffffffffffffffffffffffffffffffffffff
fff7ffffffdfdfffffffbffffffbfffffff44fff49944fffff6cccc111dd11111cccc6ff1dd1111111111dd1ffffaffffffffffff7ffffffffffffffffffafff
fff77fffffffdfffffffbffffffbfffffffffffff444fffff76c6c111111111111c6c67f1111d111111d1111ffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffff6c7ccc1111111111ccc7c6fffffff5ffffffff5ffffffffffffffffffffffffffffffffffffffff
ffff8ffffffff8ffffffffffffffbfffffffffffffffffffff66ccccc11cccc7cccc66ff6f555fff6f5555fffffffdffffffffffffffffffffffffffffffffff
ff88f8fff8ffff8fffffffffffff3bbffff44ffffff4f4fffff6ccccccc6ccc6cccc6ffff55555f5f533555fffffd9dfffffffffffffffffffffffffffffffff
f8788ffff88fffdffffffbffffb3fbffff494ffffff4444ffff76ccccc6cc6ccccc67ffff555565ff535535ffffffd3ffffffffffffffaffffffffff7fffffff
ffff7ffffdff8ffffffbbfffffffbbfffff44fffff4454ffffff67cccccccccccc76fffff565555ff555555fffffff3ff7ffffffffffffffffffffffffffffff
fff7ffffffd88fdfffffbffffffbfffffff45ffff4944ffffffff766cc666cc6667ffffff566555ff53555f6ffafffffffffffffffffffffffffffffffffffff
fff7ffffffdfdfffffffbffffffbfffffff4ffffff4ffffffffffff667fff6776fffffffff5555f6ff555fffffffffffffffffffffffffffffffffffffffffff
fff77fffffffffffffffbffffffffffffffffffffffffffffffffffffffffffffffffffff6ffffff6fffff5fffffffffffffffffffffffffffffffffffffffff
0000000000000000080000000bb00000040000001010000000000000000000000000000000000000000000000000000000000800000005000000050000000000
007777000000000088800000bbb0000044000000101000000d000000000000000000000000000000000000000000000000000880050050500050500000000000
074444700000000088800000bb00000004000000c1c00000600006600d0000000dd000000000000000000000000000008080888805555050dd50522226600000
7444444700000000060000000b00000004400000c1c00000510001606000066060000660000000000000000000000000000008800e5e550d7ddddd2267600000
4444444400000000060000000b00000004000000111000000016610051166160511661600d000660000000000000000000300800055554d7d05d5d4676000000
444444440000000000000000000000000000000000000000001d1d000d1d1d0001d1d1d061d6d1600000000000000000430000b00000504d00dddd2462000000
4444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000004300b000b50504040005054045000000
44444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000
0000000000000000050000050000000000000000d0000000000000000000000000000000dd000000000000000000000000022000000d00d00000005000000000
0002000202909092505000505000005000500d00d00d002200022000d0000d00dd600000060000000000000000000000202000b00d777d000050057506000000
00002020002999205055555050000005050000d777d00000202000000d00d000005100610510001600000000000000004440b00dd7555700dd55560770600000
0000404040444400055e5e55000222250500007555700000444000000333300005d100665d1000660000000000000000e4e400d7d544450d7de5e57607000000
44047474444e4e0050555550502622dddd0d005444500004e4e400000b33b000505d661000d16610000000000000000044404d7d04e4e4d7d055567067600000
444044404504400050500050502266d5d507d04e4e40444044400133133330000000d1d005001d100000000000000000043304d00044404d0006650770000000
050504055050050050050500502222dddd04440444004403040301331110000000000000000000000000000000000000b0b04040050404040050506006000000
000000000000000005000005005050505000505040505050b0b00050500000000000000000000000000000000000000000000000000000000000000000000000
0000b000444744444000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000800000000000000000
000b3500444744644000870000700007070000000000000000000000000000000000000000000000004400440000000000990990000008880000000000000000
00b33350446477464087887800074444700000000000000000000000000000000000000000000000044440444000000009889889001188888000000000000000
0b444445464764744078888800744114400000040000000000000000000000000000000000000000404400004000000009888889015551800000000000000000
00411d404447467643437753344411114400004110000000000000000000000000000000000000004040004040000000098888891d5e5d800000000000000000
00411d40477477444453773345471551147004511400000000000000000000000000000000000000400004404000000000988890015551800000000000000000
00444440444644744532772453741551470045544540000000000000000000000000000000000000444044440000000000098900001110000000000000000000
00044400444444474342222534074114407054545450000000000000000000000000000000000000044004400000000000009000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000400000000000000000004000440000000000000000
00500050000505050000000000000000000000000000000000000000000000000000000000000000000000000000000000055500004400444000000000000000
05750575000404040000000000000000000000000000000000000000000000000000000000000000000000000000000000500050444440004000000000000000
074707470b0044400000000000000000000000000000000000000000000000000000000000000000000000000000000005000005404400404000000000000000
00400040b35041400000000000000000000000000000000000000000000000000000000000000000000000000000000005686bb540e004404000000000000000
041111143335414000000000000000000000000000000000000000000000000000000000000000000000000000000000054949454eee44444000000000000000
0401110451504440000000000000000000000000000000000000000000000000000000000000000000000000000000000549494544e004400000000000000000
04040404454544444000000000000000000000000000000000000000000000000000000000000000000000000000000000555550044000400000000000000000
000000000000000000000000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000b35000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000000000000000000000b333500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004110000000000000040000b4444450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0451140000040000004110000411d400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4554454000411000045114000411d400000000000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000
54545450045114004554454004444400000000000444440000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000411d400000000000411140000000000000000000000000000000000000000000000000000000000000000000000000000000000
60000606000000000000000004444400004040000444440000000060000600600005060000056050000006050000060000000000000000000000000000000000
07444470000000000000000000414000004140000041400000060600000565060056050000000565000060600000000600000000000000000000000000000000
74411440000000000074407000444000004140000044400000056560005050500000565000606000000000000000000000000000000000000000000000000000
4411114400000000074114000041400000414000004140000050555000a005000060600000000000000000000000000000000000000000000000000000000000
47155114000470000415114000414550004045000041450000a0aa000aaa0aa000a00a0000a00500000005000000000000000000000000000000000000000000
7415514600414400041111400000000000000000000000000a9aa9a50a99a9950a95a9a5059a59a505a65a650075050000750500007505000000000000000000
0741144000444400074114000000000000000000000000005989989559899895598998955a89a895569a69a50576576005765760057657600000000000000000
00000000000000000000000000000000000000000000000028222822288288222282828225228522552852525657657556576575565765750000000000000000
509030b0505500000000000000000000000000000000000000000000000600600005060000000000000000000000000000000000000000000000000000000000
0000000055050000000000000000000022aaa2200003000000060500000500060006000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000002a999a200033300000056060000060500000060000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000a99899a0011311000050500000a000000000600000000000505050000050505000000000000000000000000000000000
00000000000000000000000000000000a98689a00411140000a0a000000a0a0000a00a0000000000404040000040404000000000000000000000000000000000
00000000000000000000000000000000a99899a0401110400a9aa9000099a9000099a000000000000444000b0004440000000000000000000040000000000000
000000000000000000000000000000002a999a2040404040098890000a8990000a88900000000000041400b35004140000000000000000000414000000000000
0000000000000000000000000000000022aaa220000000000029000000280000009200000000000004140b333504140000000000000000000414000300000000
0000000000000000000000003453345300000bb003533450345334533453345334533453030334500444b3313354440000000000000000000444033133000000
05000500000000000000000045334533434040b0434b404345387533453345334533453343434345041405111504140000000000000000000414051115040000
5750575000000000000000005334533443b30000554355b358788784533453345338873455435533041455555554140000000000000000000414555555540400
74707470000000000400040033453345044043b03443534337888885334788453387884534435340044454545454440000000404040000000444545454544400
040004000000000004000400345334530300b0b43b0b405534377453345887533453745303344355044444454444450000000444444004000444444444444500
41111140001110000111110045334533b0b00440455b345345377533453375334537353345533453045444515444440000004441444044000454444144444400
40111040401110404011104053345334b04b4000454445b353577534533473345334733445444533044445111544540004004411144044000444441114445400
40404040404040404040404033453345030033b00533554033555545334533453345334505035540044545111544440004404411144044000445441114444400
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000ff444fffff444ffffffffffff7fffff00000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000f444fffff444fffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000f4494ffff4494fffff7ffffffffffff00000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000f544fffff544fffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000ff9444ffff9444fffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000f5444ffff5444ffffffffffffffafff0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000ff445fffff445ffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000f0f0f0ffffffffffffffffffffffffffff88fff0f0f0f0f0f0f0b0f000000000000000000000000000000000000000000000000
000000000000000000000000ff444ffffffffffffffffffffffffffff887888ffffffffffffbb3b0000000000000000000000000000000000000000000000000
0000000000000000000000000f444fffffffffffffffffffffffffff87887878ffffffffffbb3bbf000000000000000000000000000000000000000000000000
000000000000000000000000f4494ffffffffffffffffaffffffffff88788788ffffffffffb3bbb0000000000000000000000000000000000000000000000000
0000000000000000000000000f544ffff7fffffffffffffffffffffffff77ffff7ffffffffbbbbff000000000000000000000000000000000000000000000000
000000000000000000000000ff9444ffffffffffffffffffffffffffff7777fffffffffffffbbff0000000000000000000000000000000000000000000000000
0000000000000000000000000f5444fffffffffffffffffffffffffffff77ffffffffffffffbffff000000000000000000000000000000000000000000000000
000000000000000000000000ff445ffffffffffffffffffffffffffffff77ffffffffffffffbfff0000000000000000000000000000000000000000000000000
0000000000000000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffff0f0f0f0f0000000000000000000000000000000000000000
000000000000000000000000ffffffffffffffffffffffff1111fffffffffffffffffffffffffffff33fff300000000000000000000000000000000000000000
0000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff3bff3bb0000000000000000000000000000000000000000
000000000000000000000000ffffffffffffffffffffffffffffafffffffffffffffffffffffffffffbbfbf00000000000000000000000000000000000000000
0000000000000000000000000fffffffffafffffff7fffffffffffffffffffffffafffffff7ffffffffbbbff0000000000000000000000000000000000000000
000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbff00000000000000000000000000000000000000000
0000000000000000000000000fffffffffffffffffffffffffffffff7fffffffffffffffffffffffffffbfff0000000000000000000000000000000000000000
000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbff00000000000000000000000000000000000000000
0000000000000000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000
000000000000000000000000ffffffffffffff1111fffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000
0000000000000000000000000fffffaffffffffffffffff7ffffffffff11ffa11ffffffffffffff7ffffffff0000000000000000000000000000000000000000
000000000000000000000000fffffffffffff7fffffffffffff111ffffff1f1ffffff7fffffffffffffffff00000000000000000000000000000000000000000
0000000000000000000000000fffffffffffffffffffffffff1111f111f4444fff1111fffffffffffffffaff0000000000000000000000000000000000000000
000000000000000000000000ffffffffffffffffffffffffff11f1441144141ffffffffffffffffffffffff00000000000000000000000000000000000000000
0000000000000000000000000fffffffffffffffffffffffff11f544ff5f44ffffffffffffffffffffffffff0000000000000000000000000000000000000000
000000000000000000000000fffffffffffffffffffffaffffff5f5ff5f5ff5ffffffffffffffafffffffff00000000000000000000000000000000000000000
00000000000000000f0f0f0fffffff8fffffff8fffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000
0000000000000000fffffffff8fff888f8fff888fffffffffffffffff7fffffffffffffffffffffffffffff00000000000000000000000000000000000000000
00000000000000000fffffff888ff888888ff888ffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000
0000000000000000ff7fffff888f8fdf888f8fdfffffffffff7fffffffffffffffffffffffffffffff7ffff00000000000000000000000000000000000000000
00000000000000000ffffffffdf888dffdf888dffffffffffffffffffffffffffffaffffffffffffffffffff0000000000000000000000000000000000000000
0000000000000000fffffffffdd888dffdd888dffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000
00000000000000000fffffffffdfdfdfffdfdfdff7ffffffffffffffffffaffffffffffff7ffffffffffffff0000000000000000000000000000000000000000
0000000000000000ffffffffffffdfffffffdfffffffffffffdffffffffffffffffffffffffffffff0f0f0f00000000000000000000000000000000000000000
00000000000000000ffffffffffffffffffffffffffff66ffff6ffffffffffffffffffffffffff8f000000000000000000000000000000000000000000000000
0000000000000000fffffffffffffffffffffffffffff6166115fffffffffffffffffffff8fff880000000000000000000000000000000000000000000000000
00000000000000000fffffffffffffffffffffffffffffd1d1dfffffffffffffffffffff888ff888000000000000000000000000000000000000000000000000
0000000000000000ffffffff7ffffffffffffffffffffaffffffffff7fffffffffffffff888f8fd0000000000000000000000000000000000000000000000000
00000000000000000ffffffffffffffff7fffffffffffffffffffffffffffffff7fffffffdf888df000000000000000000000000000000000000000000000000
0000000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffdd888d0000000000000000000000000000000000000000000000000
00000000000000000fffffffffffffffffffffffffffff5fffffffffffffffffffffffffffdfdfdf000000000000000000000000000000000000000000000000
0000000000000000f0f0f0f0fffffffffffffffffffff575fffffffffffffffffffffffff0f0d0f0000000000000000000000000000000000000000000000000
0000000000000000000000000ffffffffffffffffffff5775fffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000
000000000000000000000000fffffffffffffffffffff57775fffffffffffffffffffff000000000000000000000000000000000000000000000000000000000
0000000000000000000000000ffffffffffffffffffff577775fffffffffffffffffffff00000000000000000000000000000000000000000000000000000000
000000000000000000000000fffffffffffffffffffff57755ffaffffffffffffffffff000000000000000000000000000000000000000000000000000000000
0000000000000000000000000fffffffffafffffff7fff5575ffffffffffffffffafffff00000000000000000000000000000000000000000000000000000000
000000000000000000000000ffffffffffffffffffffffff5ffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000
0000000000000000000000000fffffffffffffffffffffffffffffff7fffffffffffffff00000000000000000000000000000000000000000000000000000000
000000000000000000000000fffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000
0000000000000000000000000fffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000
000000000000000000000000f33fff33fffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000
00000000000000000000000003bff3bbfffffffffffffff7ffffffffffffffafffffffff00000000000000000000000000000000000000000000000000000000
000000000000000000000000ffbbfbfffffff7fffffffffffffffffffffffffffffff7f000000000000000000000000000000000000000000000000000000000
0000000000000000000000000ffbbbfffffffffffffffffffffffaffffffffffffffffff00000000000000000000000000000000000000000000000000000000
000000000000000000000000ffffbffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000
0000000000000000000000000fffbfffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000
000000000000000000000000f0f0b0f0f0f0f0f0fffffafffffffffff0f0f0f0f0f0f0f000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000fffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000f33fff33fffffff0000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000003bff3bbffffffff000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000ffbbfbffff7ffff0000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000ffbbbffffffffff000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000ffffbffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000fffbfffffffffff000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000f0f0b0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777770000777777777777777777777700
07ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7007aaaaaaaaaaaa444444444470
7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff774a0000000000a000000000447
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff44a0000000000a000000000444
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff44a0011ff0000a000000000444
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff44a00ff11f000a000000000444
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff44a0081fff000a000000000444
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff44a00ffff0000a000000000444
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff44a000bf00000a000000000444
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff44a0000000000a000000000444
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff44a0000000000a000000000444
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff44a0000000000a000000000444
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff44aaaaaaaaaaaa000000000444
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff44400000000000000000000444
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff44400000000000000000000444
555555555555555555555555555555555555555555555555555555ffffffffffffffffffffffffffffffffffffffffffffffff44400000000000000000000444
7777777777777777777777777777777777777777775777777777775fffffffffffffffffffffffffffffffffffffffffffffff44400000000000000000000444
7787788878887777bb7bbb7bbb777747744474447757717177111775ffffffffffffffffffffffffffffffffffffffffffffff44400000000000000000000444
788878777877777bbb7b777b77777447747774777757717177771775ffffffffffffffffffffffffffffffffffffffffffffff44400000000000000000000444
788878887888777bb77bbb7bbb7777477444744477577c1c77771775ffffffffffffffffffffffffffffffffffffffffffffff44400000000000000000000444
7767777877787777b7777b777b7777447774777477577c1c77771775ffffffffffffffffffffffffffffffffffffffffffffff44400000000000000000000444
7767788878887777b77bbb7bbb777747744474447757711177771775ffffffffffffffffffffffffffffffffffffffffffffff44400000000000000000000444
77777777777777777777777777777777777777777757777777777775ffffffffffffffffffffffffffffffffffffffffffffff44444444444444444444444444

__gff__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007070b0b13130121012121000000000007070b0b13132121212121000000000007070b0b131301210101010000000000
0000000000000000000000000000000000000000000000000000000000000000000000000707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
545454545454545552535253525254545554545454544e4f4c4d4e4f4c525252000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
545454545554545f7b5253535352535454545454545d5e5f5c5352535c535352000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5454515454546e6f6c5352535352535555545554556d56575758535050525352000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
545455547c7d7e507c5350505352537f555451547c7d66676769585350535252000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5454554f4c4d4e4f4c4d52535252534f6c5454544c4d66676767695853525152000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
54546e5f5c5d7e5f5c5d5e5352535e5f5c51515f5c5d6667676767685c515152000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
54546e51516d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d765a676759786c6d5252000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
54557e7f7c7d7e7f7c517e7f565757587c6b7e7f7c7d7e767777787f7c7d5454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5452534f4c4d4e4f4c4d4e6b66676769584d4e4f4c4d4e4f4c4d4e4f4c555455000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
525253525c5d5e5f5c5d56576a676767685d5e7a5c7b5e5f5c5d5e5f5c545454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5253525253526e6f6c6d6667676767676879796f6c6d6e6f6c5657586c545554000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5252505252527e7f7c7d666767676759787d7e7f7c7d7e56576a67687c7d5454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
52535352524d4e4f4c7b6667676767684c4d4e4f4c4d566a676767684c4d4e54000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
525253535c5d5e5f5c796667597777785c5d5e5f5c5d6667676759785c5d5050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
526d6e6f6c6d6e6f7a6d7677787a6e6f6c6d6e6f6c6d66676759786f6c535350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c7d536b527d7e7f7c7d7e7f7c7d797f7c7d7e7f7a7a76777778507f53535353000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4c52565758544e4f4c4d4e4f4c4d4e4f4c4d4e794c54545454554e4f53525253000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051666768535e5f5c5d5e5f5c5d5e5f5c5d5e5f5c54545554555e5353535353000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5150666768536e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d5454556d6e5252505353000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c52767778517e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e5352535053000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4c545452524d4e4f4c6d6e6f565757575757586f6c4d4e4f4c4d4e4f53535252000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5d53535c5d5e5f5c7d7a566a67676767676957587a5e5f5c5d515f5c5d5e52000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6d6e6f6c6d6e6f6c7a566a6767676767676767686d6e6f6c6d6e6f6c6d6e6f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
527d7e7f7c7d7e7f7c566a676767676767676759787d7e7f7c7d7e7f7c507e7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
52524e4f4c4d4e4f4c66676767676767676767686c4d4e4f4c4d4e4f4c4d4e54000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5353525f5c5d5e5f52765a676767676767597778515d5e5f5c5d5e5f5c5d5e54000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
525251546c6d6e6f50537677775a675977785053536d6e6f51516e6f6c555454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
52525154547d7e7f7c52535353767778535052535c7d7e7f7c7d7e7f54555454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
52535554554d4e4f4c4d535253535253535253534c4d4e4f4c4d4e5455545554000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5354545454555e5f5c5d5e5f53525353525d5e5f5c5d5e545454545551545454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
54555455555454556c6d6e6f6c6d6e6f6c6d6e6f6c6d54555454555454545554000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5454545454545454547d7e7f7c7d7e7f7c7d7e7f7c5555545554545455545454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100001a050000001d050000001f050200502205024050270502905029050290502805027050250502205020050200501f0501e0501e0501f05020050220502405024050210501d0501b050190501705017050
