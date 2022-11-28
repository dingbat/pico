pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--main loop

--constants
mapw,maph=256,256
fogtile,mvtile=8,8
mmw=19
mmh=maph\(mapw/mmw)
mmx,mmy=105,107
menuh,menuy=21,104

bldg_drop,bldg_farm,
 bldg_const,bldg_other=
 "drop","farm","const","other"

--global state
cx,cy,mx,my,fps=0,0,0,0,0

--tech can change this
farm_cycles=5
carry_capacity=6

units,restiles,dmaps,selection,
	proj,bldgs={},{},{},{},{},{}
res={r=15,g=15,b=15,p=7}

function unit(typ,x,y,p,const)
 return {
		typ=typ,
		x=x,
		y=y,
		st={t="rest"},
		dir=1,
		p=p,
		hp=typ.hp,
		const=const,
	}
end

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
	foreach(af,draw_unit)
	
	--rally flag
	if sel1 and sel1.rx then
		spr(70+(fps/5)%3,
			sel1.rx-2,sel1.ry-5)
	end

	if selbox then
		fillp(▒)
		rect(unpack(selbox))
		fillp()
	end
	
	if (hilite) draw_hilite()
		
	camera()
	
	draw_menu()
	if (to_build) draw_to_build()
	
	--minimap hilite
	if hilite and hilite.px then
		circ(hilite.px,hilite.py,2,8)
	end
	
	draw_cursor()
	
	--[[local s=selection[1]
		if s and s.st.t=="gather" then
			local x=g(restiles,s.st.tx,s.st.ty)
			print(x,0,0,7)
		end
	end]]
end

function _update()
	fps+=1
	if fps==60 then
		fps=0
 end
 
 hilite=hilite and
 	t()-hilite.t<0.5 and hilite
	
 handle_input()
 
 vizmap,buttons,pos,hoverunit,
 	sel_typ={},{},{}
 
 update_projectiles()
 
 if selbox then
 	bldg_sel,my_sel,enemy_sel=nil
 end
 foreach(units,tick_unit)
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
	if hilite.x then
		circ(hilite.x,hilite.y,
		 min(1/dt/2,4),8)
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
	local typ=to_build.typ
	local w,h,x,y=typ.fw,typ.h,
		to_build.x-cx,to_build.y-cy
	
	if not buildable() then
		pal(split"8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8")
	end
	if amy>=menuy then
		x,y=amx-3,amy-3
	else
		fillp(▒)
		rect(
 		x-1,y-1,
 		x+ceil(w/8)*8-h%2,
 		y+ceil(h/8)*8,
 		3
 	)
 	fillp()
 end
	sspr(typ.rest_x,typ.rest_y,
	 w,h,x,y)
	pal()
end
-->8
--unit defs/states

function parse(unit,typ,tech)
	local obj={typ=typ,tech=tech}
	obj[1],obj[2]={},{}
	for l in all(split(unit,"\n")) do
		if #l>0 then
			local vals=split(l,"=")
			local v1,v2=vals[1],
				tonum(vals[2]) or vals[2]
			obj[v1],obj[1][v1],
				obj[2][v1]=v2,v2,v2
		end
	end
	return obj
end

ant=parse([[
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

move_x=8
move_y=8
move_fr=2
move_fps=30

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
def_typ=ant
]])
beetle=parse([[
w=7
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
atk=2
]])
spider=parse([[
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

spd=2
los=30
hp=15

def_typ=spider
atk_typ=spider
atk=2
]])
archer=parse([[
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
proj_col=11
proj_freq=30
proj_s=0
range=20

atk_typ=ant
def_typ=ant
atk=1
]])
warant=parse([[
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

atk_typ=ant
def_typ=ant
atk=1
]])
cat=parse([[
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
proj_col=5
proj_s=1
range=50

atk_typ=cat
def_typ=ant
atk=2
]])
queen=parse([[
w=15
h=7
fw=16

rest_x=64
rest_y=0
rest_fr=2
rest_fps=30

attack_x=80
attack_y=0
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

bldg=drop
los=20
range=20
hp=50
proj_col=11
proj_xo=-4
proj_yo=2
proj_freq=30
proj_s=0

atk_typ=ant
def_typ=ant
atk=1
]])

tower=parse([[
w=7
fw=8
h=13

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
bldg=other

los=30
hp=40
dir=-1
range=25
const=20
proj_col=5
proj_yo=-2
proj_xo=-1
proj_freq=30
proj_s=0

atk_typ=tower
def_typ=building
atk=1
]])
mound=parse([[
w=7
fw=8
h=7

rest_x=0
rest_y=97

portx=35
porty=80
portw=8

fire=1
dead_x=48
dead_y=104
dead_fr=7
dead_fps=9

bldg=drop
los=5
hp=30
dir=-1
const=12
has_q=1
drop=1
def_typ=building
]])
web=parse([[
w=8
fw=8
h=8

portx=8
porty=80
portw=9

bldg=other
los=5
hp=5
dir=-1
const=12
def_typ=building
]])

btden=parse([[
w=8
fw=8
h=8

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

bldg=other
los=10
hp=20
dir=-1
const=20
has_q=1
def_typ=building
]])
barracks=parse([[
w=7
fw=8
h=7

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

bldg=other
los=10
hp=20
dir=-1
const=20
has_q=1
def_typ=building
]])
farm=parse([[
w=8
fw=8
h=8

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

bldg=farm
los=0
hp=10
dir=-1
const=6
def_typ=building
]])
farm_renew_cost_b=3


castle=parse([[
w=15
fw=16
h=13

rest_x=80
rest_y=115

attack_x=80
attack_y=115

fire=1
dead_x=48
dead_y=99
dead_fr=4
dead_fps=15

portx=8
porty=88
portw=9
bldg=other
has_q=1

los=40
hp=70
dir=-1
range=30
const=20
proj_col=5
proj_yo=0
proj_xo=0
proj_s=0
proj_freq=20

atk_typ=tower
def_typ=building
atk=1
]])


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
]],farm),

	parse([[
r=0
g=3
b=8
]],btden),

	parse([[
r=0
g=5
b=5
]],barracks),

	parse([[
r=0
g=3
b=8
]],tower),

	parse([[
r=0
g=3
b=3
]],castle),
}
spider.prod={
	parse([[
t=4
r=0
g=2
b=0
]],web),
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
]],parse([[
portx=96
porty=88
portw=8
]]),function()
			carry_capacity=9
		end
	),
}

btden.prod={
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
]],parse([[
portx=114
porty=64
portw=9
]]),function()
			beetle[1].atk+=1
		end
	),
	parse([[
t=5
r=0
g=2
b=0
]],parse([[
portx=105
porty=64
portw=9
]]),function()
			spider[1].atk+=1
		end
	),
}

mound.prod={
	parse([[
t=12
r=5
g=5
b=1
]],parse([[
portx=104
porty=88
portw=9
]]),function()
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
]],archer),

	parse([[
t=10
r=1
g=2
b=1
]],warant),
	{},{},
	parse([[
t=5
r=0
g=2
b=0
]],parse([[
portx=96
porty=64
portw=9
]]),function()
			archer[1].range+=5
			archer[1].los+=5
		end
	),

	parse([[
t=5
r=0
g=2
b=0
]],parse([[
portx=105
porty=72
portw=9
]]),function()
			warant[1].atk+=1
		end
	),
		
	parse([[
t=5
r=0
g=2
b=0
]],parse([[
portx=96
porty=72
portw=9
]]),function()
			archer[1].atk+=1
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
}

dmg_mult=parse([[
ant_vs_ant=1
ant_vs_spider=1
ant_vs_beetle=1
ant_vs_building=1
ant_vs_cat=1

spider_vs_ant=1
spider_vs_spider=1
spider_vs_beetle=1
spider_vs_building=1
spider_vs_cat=1

beetle_vs_ant=1
beetle_vs_spider=1
beetle_vs_beetle=1
beetle_vs_building=2
beetle_vs_cat=1

tower_vs_ant=1
tower_vs_spider=1
tower_vs_beetle=1
tower_vs_building=1
tower_vs_cat=1

cat_vs_ant=1
cat_vs_spider=1
cat_vs_beetle=1
cat_vs_building=1
cat_vs_cat=1
]])

function rest(u)
	u.st={t="rest"}
end

function move(u,x,y)
	u.st={
		t="move",
		wayp=get_wayp(u,x,y),
	}
end

function build(u,b)
	u.st,u.res={
		t="build",
		target=b,
		wayp=get_wayp(u,b.x,b.y),
	}
end

function target_tile(tx,ty)
	return {
		x=tx*8+3,y=ty*8+3,
		typ={w=8,h=8},
	}
end

function gather(u,tx,ty,wp)
	u.st={
		t="gather",
		tx=tx,
		ty=ty,
		res=f2res["f"..fget(mget(tx,ty))],
		wayp=wp or
			get_wayp(u,tx*8+3,ty*8+3,true),
		target=target_tile(tx,ty),
	}
end

function drop(u,nxt_res,dropu)
	local wayp,x,y
	if dropu then
		wayp=get_wayp(u,dropu.x,
			dropu.y,true)
	else
		wayp,x,y=dmap_find(u,"d")
	end
	if wayp then
		u.st={
			t="drop",
			wayp=wayp,
			nxt=nxt_res,
			target=dropu or
				target_tile(x,y),
		}
	else
		rest(u)
	end
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
	local lclick=btnp(5)

	--check left click on button
	if lclick and hovbtn then
		hovbtn.handle()
		return
	end
	
	--click in menubar
	if amy>menuy and not selbox then
		local dx,dy=amx-mmx,amy-mmy
		--minimap
		if dx>=0 and dy>=0 and
			dx<mmw and dy<mmh+1	then
			local x,y=
				dx/mmw*mapw,
				dy/mmh*maph
			if btnp(4) and sel1 then
				--right click, move
				for u in all(selection) do
					move(u,x,y)
				end
				hilite={t=t(),px=amx,py=amy}
			elseif lclick then
				--move camera
				cx,cy=
					mid(0,x-64,mapw-128),
				 mid(0,y-64,maph-128+menuh)
			end
		end
		if (lclick) to_build=nil
	 return
	end
	
	--right click cancels place
 if btnp(4) and to_build then
 	to_build=nil
 	return
 end

 --left click places building
 if lclick and to_build then
  if (not buildable()) return
  pay(to_build,-1)
		local typ=to_build.typ
		local w,h,x,y=
			typ.w,typ.h,
		 to_build.x,to_build.y
		local new=unit(
			typ,x+w\2,
			y+h\2,
			1,0)
		add(units,new)
		register_bldg(new)

		--make selected units build it
		for u in all(selection) do
		 build(u,new)
		end
		to_build=nil
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
 if btnp(4) and sel1 and sel1.p==1 then
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

function pan(dx,dy)
	if dpad and not btn(4) and (
	 dx>0 and amx!=126 or
	 dx<0 and amx!=0 or
	 dy>0 and amy!=126 or
	 dy<0 and amy!=0
	)
	 then
		amx,amy=
	 	mid(0,amx+dx,126),
	  mid(-1,amy+dy,126)
	else
		cx,cy=
	 	mid(0,cx+dx,mapw-128),
	  mid(0,cy+dy,maph-128+menuh)
	end
end

function handle_input()
 if(btn(⬅️)or btn(⬅️,1))pan(-2,0)
 if(btn(⬆️)or btn(⬆️,1))pan(0,-2)
 if(btn(➡️)or btn(➡️,1))pan(2,0)
 if(btn(⬇️)or btn(⬇️,1))pan(0,2)
 
 --mouse
	if not dpad then
		amx,amy=
	 	mid(0,stat(32),126),
		 mid(-1,stat(33),126)
 end
 
 --mouse-based calculations
 mx,my,hovbtn=amx+cx,amy+cy
 for b in all(buttons) do
 	if intersect(b.r,
 		{amx,amy,amx,amy},1) then
			hovbtn=b
 	end
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
	u.sel=intersect(selbox,u_rect(u))
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
		if (u.dead==fps) del(units,u)
		return
	end
	if u.hp<=0 and not u.dead then
		u.dead,u.st,u.sel=
			fps,{t="dead"}
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
	
	--queen slowly regens
	if u.typ==queen and
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

	update_unit(u)
	
	--update viz
	if u.p==1 or u.st.t=="attack" and not u.st.wayp then
		local x,y=u.x\fogtile,
			u.y\fogtile
		for t in all(
			surrounding_tiles(
			x,y,ceil(typ.los/fogtile))
		) do
			if dist(
				u.x-(t[1]+0.5)*fogtile,
				u.y-(t[2]+0.5)*fogtile
			)<(u.p==1 and typ.los or 8) then
				s(vizmap,t[1],t[2],true)
			end
		end
	end
	
	if typ.unit and not u.st.wayp then
		while g(pos,u.x/4,u.y/4) do
			u.x+=rnd(2)-1
			u.y+=rnd(2)-1
		end
		s(pos,u.x/4,u.y/4,1)
	end
end

function update_projectiles()
 for p in all(proj) do
 	local dx,dy=norm(p.to,p,0.8)
  p.x+=dx
  p.y+=dy
		if adj(
			p.x,p.y,p.to[1],p.to[2],0.5
		) then
   if intersect(u_rect(p.to_unit),
  	{p.x,p.y,p.x,p.y}) then
 	 	deal_dmg(p.from_unit,p.to_unit)
			end
  	del(proj,p)
  end
 end
end
-->8
--map

function draw_map()
 camera(cx%8,cy%8)
 --pal(15,6)
	map(cx/8,cy/8,0,0,15,15)
	--pal()
	camera(cx,cy)
end

function darken(x,y)
	fillp(▒)
	rectfill(x-1,y-1,x+fogtile,y+fogtile,1)
	fillp()
	rectfill(x,y,x+fogtile-1,y+fogtile-1,1)
end

function draw_fow()
	camera()	
	pal(1,0)
	for x=-fogtile,128,fogtile do
	 for y=-fogtile,128,fogtile do
	 	if
	 		not vget(
	 			x+cx\fogtile*fogtile,
	 			y+cy\fogtile*fogtile
	 		) then
	 		darken(
	 			x-cx%fogtile,
	 			y-cy%fogtile
	 		)
	 	end
	 end
	end
	pal()
	camera(cx,cy)
end

function draw_minimap()
	camera(-mmx,-mmy)
	local tilew,tileh=
		mapw/mmw,
		maph/mmh
	
	--map tiles
	for tx=0,mmw do
	 for ty=0,mmh do
	 	pset(
	 		tx,ty,
	 		rescol["f"..fget(
	 			mget(tilew*tx/8,tileh*ty/8)
	 		)]
	 	)
		end
	end
	
	--units
	for u in all(units) do
		if not u.dead then
			pset(
				u.x/mapw*mmw,
				u.y/maph*mmh,
				u.sel and 9 or
				u.p==1 and 1 or 2
			)
		end
	end
	
	--fog
	pal(1,0)
	for tx=0,mmw do
	 for ty=0,mmh do
	 	if 
	 		not vget(tilew*tx,tileh*ty)
	 	then
				pset(tx,ty,1)
			end
	 end
	end
	pal()
	
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
--		if p.s==1 then
		local typ=p.from_unit.typ
		rectfill(
			p.x,p.y,
			p.x+typ.proj_s,
			p.y+typ.proj_s,
			typ.proj_col
		)
--		else
--			sspr(
--				48+flr((fps%15)/3.75)*2,64,2,2,p.x,p.y,2,2
--			)
--		end
	end
end
-->8
--units

function draw_unit(u)
	if
		not intersect(
			u_rect(u),
			{cx,cy,cx+128,cy+128},
		 1
		)
	then
		return
	end
	
	local ut,st,res_typ=u.typ,u.st,
		u.res and u.res.typ or ""
	local fw,w,h,stt,f=
	 ut.fw,ut.w,ut.h,st.t,fps
	if stt=="attack" and
		not st.active then
		stt="rest"
	end
	if (u.st.wayp) stt="move"
	local xoff,yoff=
		ut["xoff_"..res_typ] or 0,
		ut["yoff_"..res_typ] or 0
	local x,y,ufps,fr=
	 	ut[stt.."_x"]+xoff,
	 	ut[stt.."_y"]+yoff,
	 	ut[stt.."_fps"],
	 	ut[stt.."_fr"]
	
	if u.const then
		fillp(▒)
		rectaround(u,12)
		fillp()
		local bx,by,p=
			u.x-fw/2,
		 u.y-ceil(h/2),
			u.const/ut.const
		line(bx,by,bx+fw-1,by,5)
		line(bx,by,bx+fw*p,by,14)
		x+=p<0.5 and fw*2 or fw
		if (u.const<=1) return
	elseif ut==farm then
	 --in case of emrgncy (37 tok)
		--x=ut[u.res.qty..u.exp..u.ready]
		local q=u.res.qty
		x=u.exp and 72 or
			u.ready and (q>4 and 48 or 64) or
			q>6 and 48 or q>3 and 56 or x
	elseif ufps then
		if u.dead then
			f=fps-u.dead
			if (f<0) f+=60
		end
		x+=f\ufps%fr*fw
	end
	local col=u.p==1 and 1 or 2
	pal(2,col)
	if u.sel and (
	 (u.p==1 and (ut.unit or
	 	not my_sel)) or
	 not (my_sel or bldg_sel)
	) then
		col=9
	end
	pal(1,col)
	local xx,yy=u.x-w\2,
		u.y-h\2
	sspr(x,y,w,h,xx,yy,w,h,u.dir==ut.dir)
	pal()
	local hp=u.hp/u.typ.hp
	if not u.dead and hp<=0.5 then			
	 if ut.fire then
			spr(230+fps/20,u.x-3,u.y-8)
		end
		bar(xx,yy-1,w,hp)
	end

	--ctrl-b to uncomment
--	pset(u.x,u.y,14)
--	if u.st.wayp then
--		for wp in all(u.st.wayp) do
--			pset(wp[1],wp[2],acc(wp[1]/8,wp[2]/8) and 12 or 8)
--		end
--	end
end

function check_dead_target(u)
	local t=u.st.target
	if t and (t.dead or (
		u.st.t=="build" and
		not t.const and
		t.hp>=t.typ.hp
	)) then
		rest(u)
	end
end

function update_unit(u)
	check_dead_target(u)
	local t=u.st.t
	if (t=="attack") fight(u)
	if t=="rest" and u.typ.atk then
		aggress(u)
 end
 if (u.q) produce(u)
 if (u.typ==farm) update_farm(u)
 if u.st.active then
 	if (t=="harvest") farmer(u)
 	if (t=="build") buildrepair(u)
  if (t=="gather") mine(u)
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
		if e.p!=u.p and not e.dead then
			local typ=u.typ[u.p]
			local r=typ.bldg and
				typ.range or max(typ.los,typ.range)
			if dist(e.x-u.x,e.y-u.y)<=r then
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
		in_range=d<=typ.range
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
 	 u_rect(e))
		if in_range and fps%30==0 then
		 deal_dmg(u,e)
		end
 end
 u.st.active=in_range
 if in_range and not typ.fire then
		u.dir,u.st.wayp=sgn(e.x-u.x)
	elseif fps%30==0 then
		if typ.los>=d then
			--pursue enemy
	 	attack(u,e)
	 	deli(u.st.wayp,1)
	 else
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
		 drop(u)
		end
	elseif fps==u.st.fps then
		collect(u)
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
				add(units,new)
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
		u.dir,st.active=
			sgn(t.x-u.x),true
		if st.t=="harvest" then
			if (st.farm.exp)	rest(u)	
		else
			st.wayp=nil
		end
		if st.t=="gather" then
			st.fps=fps
			collect(u)
		elseif st.t=="drop" then
			local ures=u.res
			if ures then
				res[ures.typ]+=ures.qty/3
				u.res=nil
			end			
			if st.farm then
				harvest(u,st.farm)
			elseif (
				not st.nxt or
				not mine_nxt_res(u,st.nxt)
			) then
				rest(u)
			end
		end
	end
end

function step(u)
	local wayp=u.st.wayp
	if wayp then
 	local wp=wayp[1]
 	local dx,dy=norm(wp,u,u.typ.spd/3.5)
 	
	 u.dir=sgn(dx)
 	u.x+=dx
 	u.y+=dy	
		
 	if adj(u.x,u.y,wp[1],wp[2],2) then
 		if (#wayp==1) then
				if u.st.t=="harvest" then
					u.st.wayp=nil
				else
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
	e=e or 0
	return r1[1]-e<r2[3] and
		r1[3]+e>r2[1] and
		r1[2]-e<r2[4] and
		r1[4]+e>r2[2]
end

function u_rect(u)
	local w2,h2=u.typ.w/2,u.typ.h/2
 return {
 	u.x-w2,u.y-h2,
 	u.x+w2,u.y+h2
 }
end

function dist(dx,dy)
 local maskx,masky=dx>>31,dy>>31
 local a0,b0=(dx+maskx)^^maskx,(dy+masky)^^masky
 return a0>b0 and
 	a0*0.9609+b0*0.3984 or
  b0*0.9609+a0*0.3984
end

--[[function fmget(x,y,f)
	return fget(mget(x,y),f or 0)
end]]

function corner_cuttable(x,y,dx,dy)
	return not (
		(
		 x+dx<0 or x+dx>=mapw/8 or
		 fget(mget(x+dx,y),0)
		) and
		(
		 y+dy<0 or y+dy>=maph/8 or
		 fget(mget(x,y+dy),0)
		)
	)
end

function surrounding_tiles(x,y,n,cut)
	local st={}
	for dx=-n,n do
	 for dy=-n,n do
	 	local xx,yy=x+dx,y+dy
	 	if
	 		xx>=0 and yy>=0 and
	 		xx<mapw/8 and yy<maph/8 and
	 		(not cut or
	 			corner_cuttable(x,y,dx,dy)
	 		)
	 	then
			 add(st,{
			  xx,yy,
			 	diag=(dx!=0 and dy!=0)
			 })
			end
		end
	end
	return st
end

function mine_nxt_res(u,res)
	local wp,x,y=dmap_find(u,res)
	if wp then
		gather(u,x,y,wp)
		return true
	end
end

function is_res(x,y)
	return fget(mget(x/8,y/8),1)
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
		vget(mx,my) and
		sur_acc(mx/8,my/8)
end

function can_attack()
	if	vget(mx,my) and
		hoverunit and
	 hoverunit.p!=1
	then
		for u in all(selection) do
			if (u.typ.atk) return true
		end
	end
end

function can_build()
	return hoverunit and
		hoverunit.typ.bldg and
		hoverunit.p==1 and
		(hoverunit.const or
			hoverunit.hp<hoverunit.typ.hp
	 ) and
		sel_typ==ant
end

function rectaround(u,c)
	local w,h=u.typ.w,u.typ.h
	rect(
		u.x-ceil(w/2)-1,
		u.y-ceil(h/2)-1,
		u.x+ceil(w/2),
		u.y+ceil(h/2),
		c
	)
end

res_full_qty=parse([[
r=40
g=35
b=50
]])

function mine_res(x,y,r)
	local full=res_full_qty[r]
	--could add +10 to full if
	--mget(x,y) has flag x
	--(give alt res more capacity)
	local n=g(restiles,x,y) or full
	n-=1
	if n==full\3 or n==full*4\5 then
		mset(x,y,mget(x,y)+16)
	elseif n==0 then
		mset(x,y,73)
		s(dmap_st[r],x,y,nil)
		make_dmaps()
	end
	s(restiles,x,y,n)
end

function adj(x1,y1,x2,y2,n)
	return abs(x1-x2)<=n and
		abs(y1-y2)<=n
end

--x y are absolute coords, 0-128
--returns true if coord is viz
--in currently visible screen
function vget(x,y)
 return x<0 or
  y<0 or
  g(vizmap,x\fogtile,y\fogtile)
end

function norm(it,nt,f)
	local xv,yv=
		it[1]-nt.x,it[2]-nt.y
	local norm=f/(abs(xv)+abs(yv))
	return xv*norm,yv*norm
end

--strict=f to ignore farms+const
function acc(x,y,strict)
	local b=g(bldgs,x,y)
	return not fget(mget(x,y),0) and
		--somehow unnecessary
		--x>=0 and y>=0 and
		--x<mapw/8 and y<maph/8 and
		(not b or (not strict and (
		b==bldg_farm or b==bldg_const
	)))
end

function buildable()
	local x,y,w,h=
		to_build.x/8,
		to_build.y/8,
		to_build.typ.w,
		to_build.typ.h
	return (
		acc(x,y,true) and
		(w<9 or acc(x+1,y,true)) and
		(h<9 or acc(x,y+1,true)) and
		(h<9 or w<9 or acc(x+1,y+1,true))
	)
end

function register_bldg(b)
	local typ,upd,v=
		b.typ,
		not b.const,
		not b.dead and
			(b.const and bldg_const or
			b.typ.bldg)
	local w,h,x,y=typ.w,typ.h,
		(b.x-2)\8,(b.y-2)\8

	add_building(v,x,y,upd)
	if w>8 then
		add_building(v,x+1,y,upd)
		if h>8 then
			add_building(v,x+1,y+1,upd)
		end
	end
	if h>8 then
		add_building(v,x,y+1,upd)
	end
end

function add_building(v,x,y,up_dmap)
	s(bldgs,x,y,v)
	if v!=bldg_farm and up_dmap then
		add_dmap_obs("r",x,y)
		add_dmap_obs("g",x,y)
		add_dmap_obs("b",x,y)
		if v==bldg_drop then
			add_dmap_sink("d",x,y)
		else
			add_dmap_obs("d",x,y)
		end
	end
end

function deal_dmg(from,to)
	to.hp-=from.typ[from.p].atk*dmg_mult[from.typ.atk_typ.."_vs_"..to.typ.def_typ]
end

function collect(u,res)
	res=res or u.st.res
	if not u.res or u.res.typ!=res then
		u.res={typ=res,qty=1}
	else 
		u.res.qty+=1
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

-->8
--get_wayp

function nearest_acc(x,y,sx,sy)
	for n=1,999 do
		local best_t,best_d
		for t in all(
			surrounding_tiles(x,y,n)) do
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
			return unpack(best_t)
		end
	end
end

function get_wayp(u,x,y,enter)
	if (u.typ.bldg) return
 local destx,desty,wayp=
 	x\mvtile,
 	y\mvtile,
 	{}
	local dest_acc=acc(destx,desty)
 --this if can be removed if oot
 --as nearest_acc will return
 --destx,desty if its acc anyway
 if not dest_acc then
 	destx,desty=nearest_acc(
	 	destx,desty,u.x,u.y)
	end
	local path,exists=find_path({
 		u.x\mvtile,
 		u.y\mvtile},
 		{destx,desty})
 for n in all(path) do
 	add(wayp,
 		{n[1]*mvtile+4,
 		 n[2]*mvtile+4},1)
 end
 if exists and (enter or dest_acc) then
 	add(wayp,{x,y})
 end
 return wayp
end

function estimate(n1,n2)
 return dist(n1[1]-n2[1],n1[2]-n2[2])
end

function neighbor(ns,n,dx,dy)
	local x,y=n[1]+dx,n[2]+dy
 if (
 	x>=0 and x<mapw/mvtile and
		y>=0 and y<maph/mvtile and
		acc(x,y) and
		(
			dx==0 or dy==0 or
			corner_cuttable(n[1],n[2],dx,dy)
		)
	) then
		add(ns,{x,y})
	end
end

function neighbors(n)
	local ns={}
	neighbor(ns,n,-1,0)
	neighbor(ns,n,0,-1)
	neighbor(ns,n,0,1)
	neighbor(ns,n,1,0)
	
	neighbor(ns,n,-1,1)
	neighbor(ns,n,1,-1)
	neighbor(ns,n,1,1)
	neighbor(ns,n,-1,-1)
	return ns
end

function node_to_id(node)
	return node[1]..","..node[2]
end

--a*
--https://t.co/nasud3d1ix

function find_path(start,goal)
 
 -- the final step in the
 -- current shortest path
 local shortest, 
 -- maps each node to the step
 -- on the best known path to
 -- that node
 best_table = {
  last = start,
  cost_from_start = 0,
  cost_to_goal = estimate(start, goal)
 }, {}

 best_table[node_to_id(start)] = shortest
	--dh
	closest=shortest

 -- array of frontier paths each
 -- represented by their last
 -- step, used as a priority
 -- queue. elements past
 -- frontier_len are ignored
 local frontier, frontier_len, goal_id, max_number = {shortest}, 1, node_to_id(goal), 32767.99

 -- while there are frontier paths
 while frontier_len > 0 do

  -- find and extract the shortest path
  local cost, index_of_min = max_number
  for i = 1, frontier_len do
   local temp = frontier[i].cost_from_start + frontier[i].cost_to_goal
   if (temp <= cost) index_of_min,cost = i,temp
  end
 
  -- efficiently remove the path 
  -- with min_index from the
  -- frontier path set
  shortest = frontier[index_of_min]
  frontier[index_of_min], shortest.dead = frontier[frontier_len], true
  frontier_len -= 1

  -- last node on the currently
  -- shortest path
  local p = shortest.last
  
  if node_to_id(p) == goal_id then
   -- we're done.  generate the
   -- path to the goal by
   -- retracing steps. reuse
   -- 'p' as the path
   p = {goal}

   while shortest.prev do
    shortest = best_table[node_to_id(shortest.prev)]
    add(p, shortest.last)
   end

   -- we've found the shortest path
   return p,true
  end -- if

  -- consider each neighbor n of
  -- p which is still in the
  -- frontier queue
  for n in all(neighbors(p)) do
   -- find the current-best
   -- known way to n (or
   -- create it, if there isn't
   -- one)
   local id = node_to_id(n)
   local old_best, new_cost_from_start =
    best_table[id],
    shortest.cost_from_start + 1
   
   if not old_best then
    -- create an expensive
    -- dummy path step whose
    -- cost_from_start will
    -- immediately be
    -- overwritten
    old_best = {
     last = n,
     cost_from_start = max_number,
     cost_to_goal = estimate(n, goal)
    }

    -- insert into queue
    frontier_len += 1
    frontier[frontier_len], best_table[id] = old_best, old_best
   end -- if old_best was nil

   -- have we discovered a new
   -- best way to n?
   if not old_best.dead and old_best.cost_from_start > new_cost_from_start then
    -- update the step at this
    -- node
    old_best.cost_from_start, old_best.prev = new_cost_from_start, p
   end -- if
			--dhstart
			if old_best.cost_to_goal < closest.cost_to_goal then
				closest = old_best
			end
			--dhend
  end -- for each neighbor
  
 end -- while frontier not empty

	--dhstart
 local p = {closest.last}
 while closest.prev do
  closest = best_table[node_to_id(closest.prev)]
  add(p, closest.last)
 end
 return p
	--dhend
end
-->8
--menu/cursor

resorder=split"r,g,b,p"
rescol=parse([[
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
]])
f2res=parse([[
f7=r
f11=g
f19=b
]])

function print_res(rsc,x,y,s,hide_0,pop)
	for i=1,#resorder do
		local r=resorder[i]
		local v=pop and i==4 and "" or flr(rsc[r])
		local no_pop=v==0 and i==4
		local xoff=no_pop and 6 or 3
		if v!=0 or not hide_0 then
			if v!="" or pop then
				if v=="" or res[r]<v or no_pop then
					rectfill(x-xoff/3,y-1,
						x+xoff+#tostr(v)*4,y+5,
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

function can_pay(costs)
 return res.r>=costs.r and
 	res.g>=costs.g and
 	res.b>=costs.b and
 	(not costs.typ.unit or res.p>=1)
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
		costs and
		3 or 1
	)
	rectfill(x+1,y+1,x+9,y+8,
		cant_pay and 7 or costs and
 	(costs.tech and 10 or 6) or 6
	)
	pal(14,0)
	if cant_pay then
		pal(split"5,5,5,5,5,6,6,13,6,6,6,6,13,6,6,5")
	end
	sspr(typ.portx,typ.porty,typ.portw,8,x+1,y+1)
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
			prog or u.hp/u.typ.hp,
			prog and 12,
			prog and 5
		)
	end
end

function cursor_spr()
 --pointer (buttons)
 if (hovbtn) return 66
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

function draw_cursor()
	local mspr=cursor_spr()
 spr(mspr,amx,amy)
	if mspr==66 then --pointer
		pset(amx-1,amy+4,5)
	end
end

function draw_sel_ports()
	for i=1,#selection do
		local x,u=i*13-10,selection[i]
		if i>6 then
			print("+"..#selection-6,x,menuy+6,1)
			break
		end
		draw_port(
			u.typ,x,menuy+3,nil,
			function()
				u.sel=false
				del(selection,u)
			end,
			nil,u)
	end
end

function single_unit_section()
	local y,typ,r,q=menuy+2,
		sel1.typ,sel1.res,sel1.q
	
	if #selection<3 then
		draw_sel_ports()
	else
		draw_port(typ,3,y+2,nil,
			function()
				sel1.sel=false
				deli(selection,1)
			end)
		print("\88"..#selection,16,y+5,7)
	end
	
	if (sel1.p!=1) return
	
	if #selection==1 and r then
		for i=0,sel1.typ==ant and 
			carry_capacity-1 or 8 do
			local xx,yy=
				20+i%3*3,
				y+2+i\3*3
			rect(xx,yy,xx+3,yy+3,7)
			rect(xx+1,yy+1,xx+2,yy+2,
				r.qty>i and rescol[r.typ] or 5)
		end
	end

	if sel1.cycles then
		print(sel1.cycles.."/"..farm_cycles,36,y+4,4)
		spr(170,49,y+2,2,2)
	end
	
	if typ.prod and not sel1.const then
		for i=0,#typ.prod-1 do
			local b=typ.prod[i+1]
			draw_port(
				b.typ,
				88-i%4*13,
				y+i\4*11,
				b,
				function()
					if not can_pay(b) or q and
						(q.b!=b or b.tech) then
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
							fps15=max(fps%15-1,0)
						}
					end
				end
			)
		end
		if q then 
			local b,qty,x=q.b,q.qty,20
			draw_port(b.typ,x,y+1,nil,
				function()
					pay(b,1)
					if qty==1 then
						sel1.q=nil
					else
						q.qty-=1
					end
				end,q.t/b.t
			)
			print("\88"..qty,x+12,y+4,7)
		end
	end
end

function draw_menu()
 draw_menu_bg()
 if sel_typ then
		single_unit_section()
	else
		draw_sel_ports()
	end
	
	--minimap
	draw_minimap()
	
	--resources
	local len=print_res(res,0,150,2)
	rectfill(0,121,len-1,128,7)
	print_res(res,1,122,2)
	line(0,120,len-2,120,5)
	pset(len-1,121)
	line(len,122,len,128)
	
	if hovbtn and hovbtn.costs then
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

function draw_menu_bg()
 local x,secs,modstart=
 	0,{102,26},1
 if sel_typ then
		if sel_typ.has_q then
  	secs={17,24,61,26}
 	elseif sel_typ.prod then
  	secs,modstart={35,67,26},0
  end
	end
 for i=1,#secs do
 	if i%2==modstart then
 		pal(4,15)
 	end
 	local xx=secs[i]+x-4
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
 --assert(x==128)
end
-->8
--notes
--[[

todo
- map
- ai
- spiderweb?
- dmg multiplier balancing
- costs balancing
- tech tree
- min range for cat+tower?
- menu/wincond

pathfinding:
- if destination tile is impass,
 draw line from unit to tile to
 find the furthest passable tile
 along that line, then a* there

spider: can build "web", spans
limited length but is just a
white line. spider must station
on the web. takes time to do and
undo web. if any enemy crosses
the web, they are stuck and
spider takes time to eat them.

]]
-->8
--dmaps

rows,dmap_limit,dmap_st=
	mapw/4,7,{}

function dmap_find(u,key)
	local x,y,dmap,wayp,lowest=
		u.x\8,
		u.y\8,
		dmaps[key],
		{},9
	while lowest>=1 do
		for t in all(
		 surrounding_tiles(x,y,1)) do
			local w=g(dmap,t[1],t[2],9)
			if (t.diag) w+=0.4
			if w<lowest then
				lowest,x,y=w,unpack(t)
			end
		end
		if (lowest>=dmap_limit) return
		add(wayp,{x*8+3,y*8+3})
	end
	return wayp,x,y
end
 
function g(a,x,y,def)
	return a[flr(x)+
		flr(y)*rows+1] or def
end

function s(a,x,y,v)
 a[flr(x)+flr(y)*rows+1]=v
end

function add_neigh(to,closed,x,y)
	for t in all(
		surrounding_tiles(x,y,1,true)
	) do
		local xx,yy=unpack(t)
		if
			not g(closed,xx,yy) and
			acc(xx,yy)
		then
			s(closed,xx,yy,true)
			add(to,{xx,yy})
		end
	end
end
	
function make_dmaps()
	dmaps={
		r=make_dmap("r"),
		g=make_dmap("g"),
		b=make_dmap("b"),
		d=make_dmap("d"),
	}
end

function add_dmap_obs(key,x,y)
	local dmap=dmaps[key]
	for t in all(
		surrounding_tiles(x,y,1)) do
		if (t[1]!=x or t[2]!=y) and
			g(dmap,unpack(t))==
    g(dmap,x,y)
  then
			s(dmap,x,y,nil)
			return
		end
	end
	--regen
	dmaps[key]=make_dmap(key)
end

function add_dmap_sink(key,x,y)
	local dmap,fr,c=dmaps[key],
		{},
		1
	s(dmap,x,y,0)
	add_neigh(fr,{},x,y)
	while #fr>0 do
		local new_fr={}
		for t in all(fr) do
		 if c<g(dmap,t[1],t[2],-1) then
		 	s(dmap,t[1],t[2],c)
		 	add_neigh(new_fr,{},unpack(t))
		 end
		end
		fr=new_fr
		c+=1
	end
end

--based off
--https://github.com/henryxz/dijkstra-map/blob/main/dijkstra_map.py

key2res=parse([[
r=2
g=3
b=4
d=d
]])

function make_dmap(key)
	local dmap,closed,start,
		open,c,starts=
	 {},{},{},{},1,
	 dmap_st[key]
	 
	--ensure starts exists
	if not starts then
		starts={}
		for x=0,mapw/8 do
			for y=0,maph/8 do
				if 
			 	key=="d" and 
			 		g(bldgs,x,y)==bldg_drop or
			 	key!="d" and 
			 		fget(mget(x,y),key2res[key])
			 then
			 	s(starts,x,y,{x,y})
			 end
			end
		end
		dmap_st[key]=starts	
	end

	--initialize start
	for i,t in pairs(starts) do
		--closed[i],dmap[i]=false,9
		if
			sur_acc(unpack(t))
		 --optimization (not so great)
		 --	and g(vizmap,x,y)
		then
			closed[i],dmap[i]=true,0
			add(start,t)
		elseif not acc(unpack(t)) then
		 closed[i]=true
		end
	end
	
	--create initial open list
	for st in all(start) do
		add_neigh(open,closed,unpack(st))
	end
	
 --flood
 while c<dmap_limit do
 	local nxt_open={}
 	for op in all(open) do
 		s(dmap,op[1],op[2],c)
 		if c<dmap_limit-1 then
	 		add_neigh(nxt_open,closed,unpack(op))
 		end
 	end
 	open=nxt_open
 	c+=1
 end
	
	return dmap
end

--function draw_dmap(res_typ)
--	local dmap=dmaps[res_typ]
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
--init() func wastes tokens

--enable mouse & mouse btns
poke(0x5f2d,0x1|0x2)

local qx,qy=6,5
units={
	unit(queen,qx*8+9,qy*8+4,1),
	unit(ant,qx*8-8,qy*8,1),
	unit(ant,qx*8+20,qy*8+3,1),
	unit(ant,qx*8+2,qy*8-8,1),
--	unit(ant,qx*8-8,qy*8,1),
--	unit(ant,qx*8+20,qy*8+3,1),
--	unit(ant,qx*8+2,qy*8-8,1),
--	unit(ant,qx*8-8,qy*8,1),
--	unit(ant,qx*8+20,qy*8+3,1),
--	unit(ant,qx*8+2,qy*8-8,1),
--	unit(ant,qx*8-8,qy*8,1),
--	unit(ant,qx*8+20,qy*8+3,1),
--	unit(ant,qx*8+2,qy*8-8,1),
	
	--unit(warant,48,56,1),
	--unit(beetle,58,56,1),
	--unit(archer,58,30,1),
	--unit(beetle,40,36,1),
	--unit(cat,40,36,1),

	unit(beetle,60,76,2),
	unit(spider,65,81,2),
	unit(archer,70,84,2),
	--unit(beetle,65,81,2),
	--unit(tower,65,81,2),

	--unit(tower,65,65,1)
}
s(bldgs,qx,qy,bldg_drop)
s(bldgs,qx+1,qy,bldg_drop)
make_dmaps()

menuitem(1,"turn mouse off",function()
	menuitem(1,"turn mouse "..(dpad and "off" or "on"))
	dpad=not dpad
end)

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
001111110011001100111111001100118011081100110011001100110000000000d000000011500000d00000000000100d000000000000003310000000000000
0b0000000b0000b00400000004000040000000000000000000000000000000000d100000001300000d1000000001131133100000000000003311310000000000
bb000b00bb000bb04400040044000440000000000000000000000000000000003311311331350000331131131131135033113113113113100011311311311310
1100bb00110001101100440011000110000000000000000000000000000000003311311331105000331131131130500000113113113113110505001311311311
00111111001100110011111100110011000000000155000000000000000000000505005050500000050500505050000000505050505050500000005050505050
00000000000000000000000000000000000000000000000000000000000000000050500000000000000505000000000000000000000000000000000000000000
05050500000000000000000000000000000000000000000000000000000000000501515000505050055015100000000000000000000000000000000000000000
50151050050505000050505000505050005050500505050005050500000000000501515005015105500615150000000000000000000000000000000000000000
50151050501510500501510505051105050511505015150050115050005050005060600505015105000065050000000000000000000000000000000000000000
50050050501510505001510550051105050511505015150050115050551515500000000505660005000000050000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003d11311311311310
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033d1515351515351
0000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d000000000000000000000000000000dd0000000d00000000d0000000000000000000000000000000d000000000000000000000000000000000000000000000
d00001100d0000000dd000000000000000b1001100b100110d0000000000000000d00000000000000d0000000000000000d000000000000000d0000000000000
b1000110d0000110d00001100000000005d1001105d1001133000000000000000d0000000000000033100000000000000d000000000000000000000000000000
00111100b1111110b11111100d000110505d1110000d111033100000000000013310000000000000331131000000000033100013113000000d10000000011310
001d1d000d1d1d0001d1d1d0d1d1d1100000d1d00050d1d001113113113113113311311311311310001131131131131033113113113113103311311311311311
00000000000000000000000000000000000000000000000000513113113113500011311311311311050500131131131100113105050113113311311311350505
00000000000000000000000000000000000000000000000005005050505050000050505050505050000000505050505000505000000050500050505050500000
050000005550000000500000005555000000500000555500000000000000000000000000ffffffff0000000000000000ffffffffffffffffffffffffffffffff
575000005775000005750000057777500005750005777750048800000480080004008800ffff6fff0000000000000000ffffffffffffffffffffffffffffffff
577500005677550005755550574755000057775057555575048888000488880004888800ffffffff0000000000000000ffffffffffffffffffffffffffffffff
577750000565400055757575577440000577775055000055048888000488880004888800f6ffffff0000000000000000ffffffffffffffffffffafffffffffff
577775000054440075777775575444005777740054555545040088000408800004880000ffffff6f0000000000000000ffafffffff7fffffffffffffffffffff
577550000050445057777775575044400577444054944945040000000400000004000000ffffffff0000000000000000ffffffffffffffffffffffffffffffff
055750000000050005577750050004450055044554944945141000001410000014100000fff6ffff0000000000000000ffffffffffffffffffffffff7fffffff
000500000000000000055500000000500000005005555550111000001110000011100000ffffffff0000000000000000ffffffffffffffffffffffffffffffff
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
ffff8ffffffff8ffffffffffffffbfffffffffffffffffffff66ccccc11cccc7cccc66ff6f555fff6f5555fffffff7ffffffffffffffffffffffffffffffffff
ff88f8fff8ffff8fffffffffffff3bbffff44ffffff4f4fffff6ccccccc6ccc6cccc6ffff55555f5f533555fffff797fffffffffffffffffffffffffffffffff
f8788ffff88fffdffffffbffffb3fbffff494ffffff4444ffff76ccccc6cc6ccccc67ffff555565ff535535ffffff73ffffffffffffffaffffffffff7fffffff
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
0000000000000000050000050000000000000000d0000000000000000000000000000000dd000000000000000000000000022000000d00d00000000000000000
0002000202909092505000505000005000500d00d00d002200022000d0000d00dd600000060000000000000000000000202000b00d777d000000000000000000
00002020002999205055555050000005050000d777d00000202000000d00d000005100610510001600000000000000004440b00dd7555700dd00000000000000
0000404040444400055e5e55000222250500007555700000444000000333300005d100665d1000660000000000000000e4e400d7d544450d7d00000000000000
44047474444e4e0050555550502622dddd0d005444500004e4e400000b33b000505d661000d16610000000000000000044404d7d04e4e4d7d000000000000000
444044404504400050500050502266d5d507d04e4e40444044400133133330000000d1d005001d100000000000000000043304d00044404d0000000000000000
050504055050050050050500502222dddd04440444004403040301331110000000000000000000000000000000000000b0b04040050404040000000000000000
000000000000000005000005005050505000505040505050b0b00050500000000000000000000000000000000000000000000000000000000000000000000000
0000b000eee7eeeee000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000
000b3500eee7ee6ee000870000700007070000000000000000000000000000000000000000000000004400440000000000000000000000000000000000000000
00b33350ee6e77e6e087887800074444700000000000000000000000000000000000000000000000044440444000000000000000000000000000000000000000
0b444445e6e76e7ee078888800744114400000040000000000000000000000000000000000000000404400004000000000000000000000000000000000000000
00411d40eee7e676e343775334441111440000411000000000000000000000000000000000000000404000404000000000000000000000000000000000000000
00411d40e77e77eee453773345471551147004511400000000000000000000000000000000000000400004404000000000000000000000000000000000000000
00444440eee6ee7ee532772453741551470045544540000000000000000000000000000000000000444044440000000000000000000000000000000000000000
00044400eeeeeee7e342222534074114407054545450000000000000000000000000000000000000044004400000000000000000000000000000000000000000
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
004110000004000000000000b4444450040004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0451140000411000000400000411d400040004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4554454004511400004110000411d400040004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
54545450455445400451140004444400044444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000411d400041114000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60000606000000000000000004444400044444000044400000000060000600600005060000056050000006050000060000000000000000000000000000000000
07444470000000000000000000414000004140000041400000060600000565060056050000000565000060600000000600000000000000000000000000000000
74411440007440700000000000444000004440000041400000056560005050500000565000606000000000000000000000000000000000000000000000000000
4411114407411400000000000041400000414000004140000050555000a005000060600000000000000000000000000000000000000000000000000000000000
47155114041511400004700000414550004040000040400000a0aa000aaa0aa000a00a0000a00500000005000000000000000000000000000000000000000000
7415514604111140004144000000000000000000000000000a9aa9a50a99a9950a95a9a5059a59a505a65a650075050000750500007505000000000000000000
0741144007411400004444000000000000000000000000005989989559899895598998955a89a895569a69a50576576005765760057657600000000000000000
00000000000000000000000000000000000000000000000028222822288288222282828225228522552852525657657556576575565765750000000000000000
00000000000000000000000000000000000000000000000000000000000600600005060000000000000000000000000000000000000000000000000000000000
00000000000000000000000000030000000000000000000000060500000500060006000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000333000000000000000000000056060000060500000060000000000000000000000000000000000000000000000000000000000
0000000000000000000000000113110000000000000000000050500000a000000000600000000000505050000050505000000000000000000000000000000000
00000000000000000000000004111400000000000000000000a0a000000a0a0000a00a0000000000404040000040404000000000000000000000000000000000
0000000000000000000000004011104000000000000000000a9aa9000099a9000099a000000000000444000b0004440000400000000000000000000000000000
000000000000000000000000404040400000000000000000098890000a8990000a88900000000000041400b35004140004140000000000000000000000000000
0000000000000000000000000000000000000000000000000029000000280000009200000000000004140b333504140004140003000000000000000000000000
000000000000000000000000345334533353345500000bb0345334533453345334533453030334500444b3313354440004440331330000000000000000000000
0500050000000000000000004533453343434343434040b045387533453345334533453343434345041405111504140004140511150400000000000000000000
575057500000000000000000533453345543553343b3000058788784533453345338873455435533041455555554140004145555555404000000000000000000
7470747000000000000000003345334534435343044043b037888885334788453387884534435340044454545454440004445454545444000000040404000000
04000400040004000000000034533453333343550300b0b434377453345887533453745303344355044444454444450004444444444444000000044444400400
4111114001111100001110004533453345533453b0b0044045377533453375334537353345533453045444515444440004444441444444000000444144404400
4011104040111040401110405334533445444533b04b400053577534533473345334733445444533044445111544540004444411144444000400441114404400
4040404040404040404040403345334535335543030033b033555545334533453345334505035540044545111544440004444411144444000440441114404400
__gff__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000007070b0b13130121012121000000000007070b0b13132121212121000000000007070b0b131301210101010000000000
0000000000000000000000000000000000000000000000000000000000000000000000000707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007070000000000000000000000000000000000000007070707070707070707070707
__map__
545454545454545552535253525254545554545454544e4f4c4d4e4f4c525252000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
545454545554545f7b5253535352535454545454545d5e5f5c5352535c535352000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5454515454546e6f6c5352535352535555545554556d56575758535050525352000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
545455547c7d7e507c5350505352537f555451547c566a676769585350535252000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5454554f4c4d4e4f4c4d52535252534f6c5454544c765a676767695853525152000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
54546e5f5c5d7e5f5c5d5e5352535e5f5c51515f5c5d6667676767685c515152000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
54546e51516d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d765a676759786c6d5252000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
54557e7f7c7d7e7f7c517e7f565757587c6b7e7f7c7d7e767777787f7c7d5454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
544d4e4f52524e4f4c4d4e6b66676769584d4e4f4c4d4e4f4c4d4e4f4c555455000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5d53525052535f5c5d56576a676767685d5e7a5c7b5e5f5c5d5e5f5c545454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c5352525352526f6c6d6667676767676879796f6c6d6e6f6c5657586c545554000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c52505252527e7f7c7d666767676759787d7e7f7c7d7e56576a67687c7d5454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4c535352524d4e4f4c7b6667676767684c4d4e4f4c4d566a676767684c4d4e54000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5d53535c5d5e5f5c796667597777785c5d5e5f5c5d6667676759785c5d5050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6d6e6f6c6d6e6f7a6d7677787a6e6f6c6d6e6f6c6d66676759786f6c535350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c7d536b527d7e7f7c7d7e7f7c7d797f7c7d7e7f7a7a76777778507f53535353000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4c52565758544e4f4c4d4e4f4c4d4e4f4c4d4e794c54545454554e4f53525253000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051666768535e5f5c5d5e5f5c5d5e5f5c5d5e5f5c54545554555e5353535353000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5150666768536e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d5454556d6e5252505353000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c52767778517e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e5352535053000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4c545452524d4e4f4c6d6e6f565757575757586f6c4d4e4f4c4d4e4f53535252000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5d53535c5d5e5f5c7d7a566a67676767676957585d5e5f5c5d5e5f5c5d5e52000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6d6e6f6c6d6e6f6c7a566a6767676767676767686d6e6f6c6d6e6f6c6d6e6f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
527d7e7f7c7d7e7f7c566a676767676767676759787d7e7f7c7d7e7f7c7d7e7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
52524e4f4c4d4e4f4c66676767676767676767686c4d4e4f4c4d4e4f4c4d4e54000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5353525f5c5d5e5f52765a676767676767597778515d5e5f5c5d5e5f5c5d5e54000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
525251546c6d6e6f50537677775a675977785053536d6e6f6c6d6e6f6c555454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
52525154547d7e7f7c52535353767778535052535c7d7e7f7c7d7e7f54555454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
52535554554d4e4f4c4d535253535253535253534c4d4e4f4c4d4e5455545554000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5354545454555e5f5c5d5e5f53525353525d5e5f5c5d5e545454545551545454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
54555455555454556c6d6e6f6c6d6e6f6c6d6e6f6c6d54555454555454545554000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5454545454545454547d7e7f7c7d7e7f7c7d7e7f7c5555545554545455545454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100001a050000001d050000001f050200502205024050270502905029050290502805027050250502205020050200501f0501e0501e0501f05020050220502405024050210501d0501b050190501705017050
