pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--constants

mapw=256
maph=256
fogtile=8
mvtile=8
mmw=19
mmh=flr(maph/(mapw/mmw))
mmx=105
mmy=107
menuh=21
menuy=104

melee=4

bldg_drop=1
bldg_farm=2
bldg_const=3
bldg_other=4

--global state
cx=0
cy=0
mx=0
my=0
fps=0

farm_cycles=1

--selbox=nil
--unit_sel=false
--p1q=nil
units={}
res={r=10.1,g=10.1,b=10.1,p=7.1}
restiles={}
dmaps={}
proj={}
bldgs={}

--reset every frame
buttons={}
--vizmap=nil
--hoverunit=nil
--hovbtn=nil
--hilite=nil
--to_build=nil
selection={}

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

function _init()
	--enable mouse & mouse btns
	poke(0x5f2d,0x1|0x2)
	
	local qx,qy=6,5
	p1q=unit(queen,qx*8+7,qy*8+3,1)
	units={
		unit(ant,qx*8-8,qy*8,1),
		unit(ant,qx*8+20,qy*8+3,1),
		unit(ant,qx*8+2,qy*8-8,1),
		unit(spider,48,16,1),
		unit(warant,58,30,1),
		unit(beetle,40,36,1),
		--unit(beetle,60,76,2),
		--unit(beetle,65,81,2),
		p1q,
		--unit(tower,65,65,1)
	}
	s(bldgs,qx,qy,bldg_drop)
	s(bldgs,qx+1,qy,bldg_drop)
 make_dmaps()
end

function _draw()
 cls()
 
 draw_map()
 
 local bf1,bf2,af={},{},{}
 for u in all(units) do
 	if u.const and u.p==1 then
 		add(af,u)
 	elseif u.typ.inert and u.typ!=queen then
	 	add(bf1,u)
	 else
	 	add(bf2,u)
	 end
 end
 
	foreach(bf1,draw_unit)

	for s in all(selection) do
		if s.typ==farm and not s.const then
		 rectaround(s,9)
		end
	end

	draw_projectiles()
	foreach(bf2,draw_unit)
	draw_fow()
	foreach(af,draw_unit)

	--selection box
	if selbox then
		fillp(▒)
		rect(selbox[1],selbox[2],selbox[3],selbox[4],7)
		fillp(0)
	end
	
	if (hilite) draw_hilite()
		
	camera(0,0)

	--if (show_dmap) draw_dmap("d")
	
	--menu
	draw_menu()

	draw_to_build()
	
	if hilite and hilite.px then
		circ(hilite.px,hilite.py,2,8)
	end
	
	--mouse
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
 
 if hilite and t()-hilite.t>=0.5 then
  hilite=nil
 end
	
 hovbtn=nil
 handle_input()
 
 vizmap={}
 hoverunit=nil
 buttons={}
 unit_sel=false
 pos={}
 update_projectiles()
 
 if selbox then
 	bldg_sel=nil
	 my_sel=nil
	 enemy_sel=nil
 end
 foreach(units,tick_unit)
 if selbox then
		selection=my_sel or
			bldg_sel or
			enemy_sel or {}
	end
end

function draw_hilite()
	local dt=t()-hilite.t
	if hilite.x then
		circ(hilite.x,hilite.y,min(1/dt/2,4),8)
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
	if to_build then
		local typ=to_build.typ
 	local w,h,x,y=typ.w,typ.h,
			to_build.x-cx,to_build.y-cy
			
		if amy>=menuy then
			x,y=amx-3,amy-3
		else
			rectfill(
	 		x-1,y-1,
	 		x+w,y+h,
	 		buildable() and 3 or 8
	 	)
	 end
 	sspr(typ.rest_x,typ.rest_y,w,h,x,y)
	end
end
-->8
--unit defs

atk_arrow=1
atk_acid=2
atk_seige=3
atk_pince=4

function parse(unit)
	local obj={}
	for l in all(split(unit,"\n")) do
		if #l>0 then
			local vals=split(l,"=")
			obj[vals[1]]=tonum(vals[2])
		end
	end
	return obj
end

ant=parse([[
w=4
h=4

xoff_r=12
yoff_g=4
xoff_b=12
yoff_b=4

rest_x=0
rest_y=8
rest_fr=2
rest_fps=30

move_x=4
move_y=8
move_fr=2
move_fps=30

gather_x=4
gather_y=8
gather_fr=2
gather_fps=30

build_x=24
build_y=8
build_fr=2
build_fps=15

harvest_x=32
harvest_y=8
harvest_fr=2
harvest_fps=15

dead_x=24
dead_y=12

portx=0
porty=72
unit=1

spd=1
los=20
hp=10
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

dead_x=32
dead_y=0

portx=26
porty=72
portw=9
unit=1

spd=1.5
los=25
hp=20

atk_typ=3
atk=2
]])
spider=parse([[
w=7
fw=8
h=4

rest_x=0
rest_y=16
rest_fr=2
rest_fps=30

move_x=8
move_y=16
move_fr=7
move_fps=3

dead_x=66
dead_y=16

portx=16
porty=72
portw=9
has_q=1
unit=1

spd=2
los=30
hp=15

atk_typ=4
atk=2
]])
warant=parse([[
w=7
fw=8
h=5

rest_x=0
rest_y=25
rest_fr=2
rest_fps=30

move_x=8
move_y=25
move_fr=2
move_fps=10

dead_x=24
dead_y=25

portx=35
porty=72
portw=9
unit=1

spd=1.5
los=30
hp=15

atk_typ=2
atk=1
]])
queen=parse([[
w=14
h=7
fw=16

rest_x=56
rest_y=0
rest_fr=2
rest_fps=30

dead_x=104
dead_y=0

dir=-1
portx=8
porty=72
has_q=1
drop=1

inert=1
los=20
range=15
hp=50
proj_col=11
proj_xo=-4
proj_yo=2

atk_typ=2
atk=1
]])

tower=parse([[
w=7
fw=8
h=13

rest_x=24
rest_y=96

portx=0
porty=80
inert=1

los=30
hp=40
dir=-1
range=25
const=20
proj_yo=-2
proj_xo=-1

atk_typ=1
atk=1
]])
mound=parse([[
w=7
fw=8
h=7

rest_x=0
rest_y=97

portx=0
porty=96

inert=1
los=5
hp=20
dir=-1
const=12
has_q=1
drop=1
]])
web=parse([[
w=8
h=8

portx=8
porty=80
portw=9

inert=1
los=5
hp=5
dir=-1
const=12
]])
spden=parse([[
w=8
fw=8
h=8

rest_x=0
rest_y=112

portx=0
porty=112
portw=9

inert=1
los=10
hp=20
dir=-1
const=20
has_q=1
]])
btden=parse([[
w=8
fw=8
h=8

rest_x=0
rest_y=104

portx=0
porty=104
portw=9

inert=1
los=10
hp=20
dir=-1
const=20
has_q=1
]])
barracks=parse([[
w=7
fw=8
h=7

rest_x=0
rest_y=121

portx=0
porty=88

inert=1
los=10
hp=20
dir=-1
const=20
has_q=1
]])
farm=parse([[
w=8
fw=8
h=8

rest_x=24
rest_y=120

portx=17
porty=80
portw=9

inert=1
los=0
hp=10
dir=-1
const=6
]])
farm_renew_cost_b=3

ant.prod={
	{typ=mound,b=2},
	{typ=farm,g=3,r=1},
	{typ=spden,b=2},
	{typ=btden,g=3,b=8},
	{typ=barracks,g=5,b=10},
	{typ=tower,g=3,b=8},
}
spider.prod={
	{typ=web,t=4,g=2},
}
queen.prod={
	{typ=ant,t=6,r=2,g=3}
}
barracks.prod={
	{typ=warant,t=10,r=1,g=2,b=1},
}
spden.prod={
	{typ=spider,t=8,r=3,g=4},
}
btden.prod={
	{typ=beetle,t=8,g=4,b=3},
}

mound.prod={
	{
		typ=parse([[
portx=80
porty=64
portw=9
]]),
		t=12,g=5,b=1,r=5,
		tech=function()
			farm_cycles=10
		end
	},
}

--put farm in u.st, that way gets
--auto-cleared when st changes
function rest(u)
	u.farm=nil
	u.st={t="rest"}
end

function move(u,x,y)
	u.farm=nil
	u.st={
		t="move",
		wayp=get_wayp(u,x,y),
	}
end

function build(u,b)
	u.farm=nil
	u.res=nil
	u.st={
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
	wp=wp or get_wayp(u,tx*8+3,ty*8+3)
	u.farm=nil
	u.st={
		t="gather",
		tx=tx,
		ty=ty,
		res=tile2res(tx,ty),
		wayp=wp,
		target=target_tile(tx,ty),
	}
end

function drop(u,nxt_res,dropu)
	local wayp,x,y
	if dropu then
		wayp=get_wayp(u,dropu.x,dropu.y)
	else
		wayp,x,y=dmap_find(u,"d")
	end
	u.st={
		t="drop",
		wayp=wayp,
		nxt=nxt_res,
		target=dropu or target_tile(x,y),
	}
end

function attack(u,e)
	if u.typ.atk then
		u.st={
			t="attack",
			target=e,
			wayp=get_wayp(u,e.x,e.y),
		}
	end
end

function harvest(u,f)
	u.st={
		t="harvest",
		target=f,
  wayp=get_wayp(u,
  	f.x-3+rnd(6),
  	f.y-3+rnd(6)),
	}
	u.farm=f
	f.farmer=u
end
-->8
--update

function handle_click()
	--check left click on button
	if btnp(5) and hovbtn then
		hovbtn.handle()
		return
	end
	
	--click in menubar
	if amy>menuy and not selbox then
		local dx=amx-mmx
		local dy=amy-mmy
		--minimap
		if (
			dx>=0 and dy>=0 and
			dx<mmw and dy<mmh+1)
		then
			local xoff=128/(mapw/128)
			local yoff=128/(maph/128)
			local x=dx/mmw*mapw
			local y=dy/mmh*maph
			if btnp(4) then
				--right click, move
				for u in all(selection) do
					move(u,x,y)
				end
				hilite={t=t(),px=amx,py=amy}
			elseif btnp(5) then
				--move camera
				cx=mid(0,x-xoff,mapw-128)
				cy=mid(0,y-yoff,maph-128+menuh)
			end
		end
		if (btnp(5)) to_build=nil
	 return
	end

 --left click places building
 if btnp(5) and to_build then
  if (not buildable()) return
 	res.r-=to_build.r or 0
		res.g-=to_build.g or 0
		res.b-=to_build.b or 0
		local typ=to_build.typ
		local w,h=typ.w,typ.h
		local x,y=to_build.x,to_build.y
		local new=unit(
			typ,x+flr(typ.w/2),
			y+flr(typ.h/2),
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
 	if selbox==nil then
 		selbox={mx,my,mx,my}
 	else
	 	selbox[3]=mx
	 	selbox[4]=my
 	end
 else
 	selbox=nil
 end
	
 --right click
	local sel1=selection[1]
 if btnp(4) and sel1 and sel1.p==1 then
	 local tx=flr(mx/8)
	 local ty=flr(my/8)
	 if can_renew_farm() then
	 	hilite={t=t(),unit=hoverunit}
	 	hoverunit.exp=false
	 	hoverunit.cycles=0
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
  	hilite={t=t(),unit=hoverunit}
	 elseif can_attack() then
	 	for u in all(selection) do
  		attack(u,hoverunit)
  	end
  	hilite={t=t(),unit=hoverunit}
  elseif can_drop() then
	 	for u in all(selection) do
				drop(u,nil,hoverunit)
  	end
  	hilite={t=t(),unit=hoverunit}
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

function handle_input()
 --arrow keys (map scroll)
 local oldcx,oldcy=cx,cy
 if (btn(⬅️) or btn(⬅️,1))cx-=2
 if (btn(⬆️) or btn(⬆️,1))cy-=2
 if (btn(➡️) or btn(➡️,1))cx+=2
 if (btn(⬇️) or btn(⬇️,1))cy+=2
 cx=mid(0,cx,mapw-128)
 cy=mid(0,cy,maph-128+menuh)
 
 --mouse
 amx=mid(0,stat(32),128-2)
	amy=mid(-1,stat(33),128-2)
 mx=amx+cx
 my=amy+cy
 
 for b in all(buttons) do
		if (
			amx>=b.x and amx<=b.x+b.w and
			amy>=b.y and amy<=b.y+b.h
		) then
			hovbtn=b
		end
	end
 
 handle_click()
 
 if to_build then
	 to_build.x=flr(mx/8)*8
	 to_build.y=flr(my/8)*8
	end
end

function update_sel(u)
	u.sel=intersect(selbox,u_rect(u))
 if u.sel then
		if u.p!=1 then
			enemy_sel={u}
		elseif u.typ.unit then
			if (not my_sel) my_sel={}
			add(my_sel,u)
		else
			bldg_sel={u}
		end
	end
end

function tick_unit(u)
	if u.dead then
		if (u.dead==fps) del(units,u)
		return
	end
	if u.hp<=0 and not u.dead then
		u.dead=fps
		u.st={t="dead"}
		u.sel=false
		del(selection,u)
		if u.typ.inert then
			register_bldg(u)
			if u.typ==mound and u.p==1 then
				res.p-=5
			end
		end
		return		
	end
	
	local mbox={mx,my,mx,my}
	if intersect(u_rect(u),mbox,1) then
		hoverunit=u
	end
	
	if (selbox) update_sel(u)
	if (u.const) return

	update_unit(u)
	
	if u.p==1 then
		update_viz(u)
	end
	
	if u.typ.unit and u.st.t=="rest" then
		while g(pos,u.x/4,u.y/4,mapw/4) do
			u.x+=rnd(2)-1
			u.y+=rnd(2)-1
		end
		s(pos,u.x/4,u.y/4,1,mapw/4)
	end
end

function update_viz(u)	
	local x,y=flr(u.x/fogtile),
		flr(u.y/fogtile)
	local st=surrounding_tiles(
		x,y,ceil(u.typ.los/fogtile),
		mapw/fogtile,maph/fogtile
	)
	for t in all(st) do
		local xx,yy,v=t[1],t[2],t[3]
		if not v then
			local mx=(xx+0.5)*fogtile
			local my=(yy+0.5)*fogtile
			local d=dist(u.x-mx,u.y-my)
			v=d<u.typ.los
		end
		if v then
			s(vizmap,xx,yy,true)
		end
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
	map(cx/8,cy/8,0,0,17,17)
	camera(cx,cy)
end

function darken(x,y)
	fillp(▒)
	local sw=1
	rectfill(x-sw,y-sw,x+fogtile+sw-1,y+fogtile+sw-1,1)
	fillp(0)
	rectfill(x,y,x+fogtile-1,y+fogtile-1,1)
end

function draw_fow()
	camera(0,0)	
	pal(1,0)
	local xoff=flr(cx/fogtile)*fogtile
	local yoff=flr(cy/fogtile)*fogtile
	for x=-fogtile,128,fogtile do
	 for y=-fogtile,128,fogtile do
	 	if not vget(x+xoff,y+yoff) then
	 		darken(x-cx%fogtile,y-cy%fogtile)
	 	end
	 end
	end
	pal()
	camera(cx,cy)
end

function draw_minimap()
	local w,h,x,y=mmw,mmh,mmx,mmy
	local tilew=mapw/w
	local tileh=maph/h
	
	--map tiles
	for tx=0,w do
	 for ty=0,h do
	 	local mapx=tilew*tx/8
	 	local mapy=tileh*ty/8
	 	local t=mget(mapx,mapy)
	 	local col=15
	 	if (fget(t,2)) col=8 --r
	 	if (fget(t,3)) col=11 --g
	 	if (fget(t,4)) col=4 --b
	 	if (fget(t,5)) col=12 --water
	 	pset(x+tx,y+ty,col)
		end
	end
	
	--units
	for u in all(units) do
		if not u.dead then
			local ux=(u.x/mapw)*w
			local uy=(u.y/maph)*h
			local col=u.p==1 and 1 or 2
			if (u.sel) col=9
			pset(x+ux,y+uy,col)
		end
	end
	
	--fog
	pal(1,0)
	for tx=0,w do
	 for ty=0,h do
	 	local mapx=tilew*tx
	 	local mapy=tileh*ty
	 	local v=vget(mapx,mapy)
	 	if not v then
				pset(tx+x,ty+y,1)
			end
	 end
	end
	pal()
	
	--current view area outline
	local vx=ceil((cx/mapw)*w)
	local vy=ceil((cy/maph)*h)
	local vw=(128/mapw)*w
	local vh=(128/maph)*h
	local vx1=x+vx-1
	local vy1=y+vy-1
	local vx2=x+vx+vw+1
	local vy2=y+vy+vh+1
	rect(vx1,vy1,vx2,vy2,10)

	--corners
	if (vx1>x or vy1>y) pset(x,y,4)
	if (vx2<x+w or vy1>y) pset(x+w,y,4)
	if (vx1>x or vy2<y+h) pset(x,y+h,4)
	if (vx2<x+w or vy2<y+h) pset(x+w,y+h,4)
end

function draw_projectiles()
 for p in all(proj) do
 	local c=p.from_unit.typ.proj_col or 5
		pset(p.x,p.y,c)
	end
end
-->8
--units

function draw_unit(u)
	local cr={cx,cy,cx+128,cy+128}
	if not intersect(u_rect(u),cr,1) then
		return
	end
	
	local ut,st,res_typ=u.typ,u.st,
		u.res and u.res.typ or ""
	local w,h,stt=
	 ut.fw or ut.w,ut.h,st.t
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
		fillp(0)
		local bx,by,p,bw=
			u.x-flr(w/2),
		 u.y-flr(h/2)-1,
			u.const/ut.const,
		 ut.w-1
		line(bx,by,bx+bw,by,5)
		line(bx,by,bx+bw*p,by,14)
		x+=p<0.5 and bw*2 or bw
		if (u.const<=1) return
	elseif ut==farm then
		local q=u.res.qty
		x=u.exp and 72 or
			u.ready and (q>4 and 48 or 64) or
			q>6 and 48 or q>3 and 56 or x
	elseif ufps then
		x+=(flr(fps/ufps)%fr)*w
	end
	local sel=u.sel and (
	 (u.p==1 and (ut.unit or
	 	not my_sel)) or
	 not (my_sel or bldg_sel)
	)
	local col=u.p==1 and 1 or 2
	pal(2,col)
	if (sel) col=9
	pal(1,col)
	local sdir=ut.dir or 1
	sspr(x,y,w,h,u.x-w/2,u.y-h/2,w,h,u.dir==sdir)
	pal()
	
	if (sel and u.rx) draw_rally(u)
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
	if (t=="harvest") farmer(u)
	if (t=="attack") fight(u)
	if (t=="rest") aggress(u)
 if (u.q) produce(u)
 if (u.typ==farm) update_farm(u)
 if (u.typ.inert) return
 if (t=="build") buildrepair(u)
 if (t=="gather") mine(u)
 check_target_col(u)
 step(u)
end

function update_farm(u)
	local f=u.farmer
	if not f or f.dead or f.farm!=u then
		u.farmer=nil
		return
	end
	if f.st.active and not u.exp and
		not u.ready and fps%10==0 then
		u.res.qty+=0.5
		if u.res.qty==9 then
			u.ready=true
		end
	end
end

function farmer(u)
	local f=u.farm
	if not f or f.dead then
		u.farm=nil
		return
	end
	if u.st.active and f.ready and fps==0 then
		collect(u,"r")
		f.res.qty-=1
		if f.res.qty==0 then
			f.ready=false
			f.cycles+=1
			f.exp=f.cycles==farm_cycles
		end
		if u.res.qty==9 then
			drop(u)
		end
	end
end

function aggress(u)
	if (not u.typ.atk) return
	for e in all(units) do
		if e.p!=u.p and not e.dead then
			if dist(e.x-u.x,e.y-u.y)<=u.typ.los then
				attack(u,e)
				break
			end
		end
	end
end

function fight(u)
	local e,in_range=u.st.target,false
	if (not e or fps%10!=0) return
	if u.typ.range then
		local d=dist(e.x-u.x,e.y-u.y)
		if (d<=u.typ.range) then
			if fps%30==0 then
	 		add(proj,{
	 			from_unit=u,
	 			x=u.x+u.dir*-(u.typ.proj_xo or 0),
	 			y=u.y+(u.typ.proj_yo or 0),
	 			to={e.x,e.y},to_unit=e,
	 		})
 		end
 		in_range=true
 	end
 else
 	if intersect(u_rect(u),u_rect(e),1) then
			if fps%30==0 then
			 deal_dmg(u,e)
			end
		 in_range=true
		end
 end
 if in_range then
		u.st.wayp=nil
	else
 	attack(u,e)
 	deli(u.st.wayp,1)
 end
end

function buildrepair(u)
 if u.st.active then
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
	 				b.res={typ="r",qty=0}
						b.cycles=0
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
end

function mine(u)
	if (not u.st.active) return
	local x,y,r=u.st.tx,u.st.ty,u.st.res
	--if res is exhausted, goto nxt
	--move on to the next one
	if g(restiles,x,y)==0 then
		if not mine_nxt_res(u,r) then
		 drop(u)
		end
	elseif fps==u.st.fps then
		collect(u)
		mine_res(x,y,r)
		if (u.res.qty==9) drop(u,r)
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
				local new=unit(b.typ,u.x,u.y,1)
				add(units,new)
				if (
					new.typ==ant and
					u.rx and
					is_res(u.rx,u.ry)
				) then
					gather(new,flr(u.rx/8),flr(u.ry/8))
				else
					move(new,u.rx or u.x+5,u.ry or u.y+5)
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
		not st.active and
		t and
		intersect(u_rect(u),u_rect(t))
	) then
		st.active=true
		if st.t=="harvest" then
			if (u.farm.exp)	rest(u)	
		else
			st.wayp=nil
		end
		if st.t=="gather" then
			st.fps=fps
			collect(u)
		elseif st.t=="drop" then
			local ures=u.res
			if ures then
				res[ures.typ]=min(
					res[ures.typ]+
					ures.qty/3,99)
				u.res=nil
			end			
			if u.farm then
				harvest(u,u.farm)
			elseif (
				not u.st.nxt or
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

function draw_rally(u)
	spr(70+(fps/5)%3,u.rx-2,u.ry-5)
end
-->8
--utils

function intersect(r1,r2,e)
	e=e or 0
	--if (r1.x) r1=u_rect(r1)
	--if (r2.x) r2=u_rect(r2)
	local r1_x1=min(r1[1],r1[3])-e
	local r1_x2=max(r1[1],r1[3])+e
	local r1_y1=min(r1[2],r1[4])-e
	local r1_y2=max(r1[2],r1[4])+e
	return (
		r1_x1<r2[3] and
		r1_x2>r2[1] and
		r1_y1<r2[4] and
		r1_y2>r2[2]
	)
end

--[[function p2r(x,y,o1,o2)
	o1,o2=o1 or 0,o2 or 0
	return {x+o1,y+o1,x+o2,y+o2}
end]]

function u_rect(u)
 return {
 	u.x-u.typ.w/2,u.y-u.typ.h/2,
 	u.x+u.typ.w/2,u.y+u.typ.h/2
 }
end

function dist(dx,dy)
 local maskx,masky=dx>>31,dy>>31
 local a0,b0=(dx+maskx)^^maskx,(dy+masky)^^masky
 if a0>b0 then
  return a0*0.9609+b0*0.3984
 end
 return b0*0.9609+a0*0.3984
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

function surrounding_tiles(x,y,n,maxx,maxy,cut)
	local st={}
	for dx=-n,n do
	 for dy=-n,n do
	 	local xx,yy=x+dx,y+dy
	 	if
	 		xx>=0 and yy>=0 and
	 		xx<maxx and yy<maxy and
	 		(not cut or
	 			corner_cuttable(x,y,dx,dy)
	 		)
	 	then
		 	local v=(
		 		dx<2 and dx>-2 and
		 		dy<2 and dy>-2)
			 add(st,{
			  xx,yy,v,
			 	diag=(dx!=0 and dy!=0)
			 })
			end
		end
	end
	return st
end

function res2flag(res_typ)
 if (res_typ=="r") return 2
 if (res_typ=="g") return 3
 return 4
end

function tile2res(x,y)
 local tile=mget(x,y)
 if (fget(tile,2)) return "r"
 if (fget(tile,3)) return "g"
 if (fget(tile,4)) return "b"
end

function mine_nxt_res(u,res)
	local wp,x,y=dmap_find(u,res)
	if wp then
		gather(u,x,y,wp)
		return true
	end
end

function all_ants()
	for u in all(selection) do
		if u.typ!=ant then
			return false
		end
	end
	return #selection>0
end

function is_res(x,y)
	return fget(mget(mx/8,my/8),1)
end

function avail_farm()
	return hoverunit and
		hoverunit.typ==farm and
		not hoverunit.farmer and
		not hoverunit.const
end

function can_gather()
	if (not vget(mx,my)) return
	return (is_res(mx,my) or
		avail_farm()) and
		all_ants()
end

function can_attack()
	if not (
		vget(mx,my) and
		hoverunit and
	 hoverunit.p!=1
	) then
		return
	end
	for u in all(selection) do
		if (u.typ.atk) return true
	end
end

function can_build()
	return hoverunit and
		hoverunit.typ.inert and
		hoverunit.p==1 and
		(hoverunit.const or
			hoverunit.hp<hoverunit.typ.hp
	 ) and
		all_ants()
end

function rectaround(u,c)
	local w=u.typ.fw or u.typ.w
	local h=u.typ.h
	rect(
		u.x-ceil(w/2)-1,
		u.y-ceil(h/2)-1,
		u.x+ceil(w/2)-1,
		u.y+ceil(h/2)-1,
		c
	)
end

function res_full_qty(r)
	if (r=="r") return 40
	if (r=="g") return 35
	return 50 --b
end

function mine_res(x,y,r)
	local full=res_full_qty(r)
	local n=g(restiles,x,y) or full
	n-=1
	if n==flr(full/3) or n==flr(full*4/5) then
		mset(x,y,mget(x,y)+16)
	elseif n==0 then
		mset(x,y,73)
		make_dmaps()
	end
	s(restiles,x,y,n)
end

function adj(x1,y1,x2,y2,n)
	return (
	 abs(x1-x2)<n and abs(y1-y2)<n
	)
end

--x y are absolute coords, 0-128
--returns true if coord is viz
--in currently visible screen
function vget(x,y)
	x=flr(x/fogtile)
 y=flr(y/fogtile)
 return x<0 or y<0 or g(vizmap,x,y)
end

function norm(it,nt,f)
	local xv=it[1]-nt.x
	local yv=it[2]-nt.y
	local norm=f/(abs(xv)+abs(yv))
	return xv*norm,yv*norm
end

--strict=f to ignore farms+const
function acc(x,y,strict)
	local b=g(bldgs,x,y)
	return not fget(mget(x,y),0) and
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

function bldg_type(b)
	if (b.dead) return
	if (b.const) return bldg_const
	if (b.typ==mound) return bldg_drop
	if (b.typ==farm) return bldg_farm
	return bldg_other
end

function register_bldg(b)
	local typ=b.typ
	local w,h,x,y=typ.w,typ.h,
		flr((b.x-2)/8),flr((b.y-2)/8)

	local v=bldg_type(b)
	s(bldgs,x,y,v)
	if (w>8) s(bldgs,x+1,y,v)
	if (h>8) s(bldgs,x,y+1,v)
	if (w>8 and h>8) s(bldgs,x+1,y+1,v)
	if v!=bldg_farm and not b.const then
		make_dmaps()
	end
end

function deal_dmg(from,to)
	--todo: rps
	to.hp-=1
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
			return hoverunit and hoverunit.typ.drop
		end
	end
end

function can_renew_farm()
	return hoverunit and
		res.b>=farm_renew_cost_b and
		all_ants() and
		hoverunit.typ==farm and
		hoverunit.exp
end
-->8
--get_wayp

function get_wayp(u,x,y)
	if (u.typ.inert) return
 local nodes=find_path(
		{flr(u.x/mvtile),flr(u.y/mvtile)},
		{flr(x/mvtile),flr(y/mvtile)}
 )
 local wayp={}
 for i=1,#nodes do
 	local n=nodes[#nodes-(i-1)]
 	add(wayp,
 		{n[1]*mvtile+mvtile/2,
 		 n[2]*mvtile+mvtile/2}
 	)
 end
 add(wayp,{x,y})
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
   return p
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

function cost_len(c)
	return	draw_resource("r",c.r)+
		draw_resource("g",c.g)+
		draw_resource("b",c.b)+
		((c.typ.unit and res.p<1) and
			draw_resource("p",1) or 0)
end

--typ="b/g/r/p"
function draw_resource(typ,val,x,y,sp)
 if ((val or 0)==0) return 0
 local sy,c=64,11 --g
	if (typ=="r") sy,c=72,8
 if (typ=="b") sy,c=80,4
 if (typ=="p") sy,c=88,1

	local total=0
	local w=0
	local s=""..flr(val)
	
	local bg=7
 if not sp and res[typ]<val then
 	bg=10
 	if (typ=="p") s=""
 end
 if typ=="p" and res.p<1 then
 	bg=10
 end
 
	for i=0,#s do
		if i==0 then
			w=typ=="p" and 6 or 4
			if x then
				rectfill(x-1,y-1,x+w,y+5,bg)
	 		sspr(72,sy,5,5,x,y)
	 	end
		elseif s[i]=="1" then
			w=2
  	if x then
	  	rectfill(x-1,y-1,x+w,y+5,bg)
				line(x,y,x,y+4,c)
			end
		else
			w=4
			if x then
				rectfill(x-1,y-1,x+w,y+5,bg)
				print(s[i],x,y,c)
			end
		end
		total+=w
		if (x) x+=w
	end
	return total+1+(sp or 0)
end

function can_pay(costs)
 return res.r>=(costs.r or 0) and
 	res.g>=(costs.g or 0) and
 	res.b>=(costs.b or 0) and
 	(costs.typ.inert or res.p>=1)
end

function draw_port(
	typ,x,y,costs,onclick,prog,u
)
	local outline=costs and 3 or 1
	if (u and u.p!=1) outline=2
	pal(14,0)
	if costs and not can_pay(costs) then
		pal(split("5,5,5,5,5,6,7,13,6,7,7,6,13,6,7,5"))
	end
	rect(x,y,x+10,y+9,outline)
	rectfill(x+1,y+1,x+9,y+8,costs and 11 or 6)
	--pal(11,3)
	sspr(typ.portx,typ.porty,typ.portw or 8,8,x+1,y+1)
	pal()
	
	if onclick then
		button(x,y,10,10,onclick,costs)
	end
	y+=11
	if u or prog then
		local lw=10
		local hp=prog or (u.hp/u.typ.hp)
		local hp_bg=prog and 5 or 8
		local hp_fg=prog and 12 or 11
		line(x,y,x+lw,y,hp_bg)
		line(x,y,x+lw*hp,y,hp_fg)
	end
end

function cursor_spr()
 --pointer (buttons)
 if (hovbtn) return 66
	if #selection>0 and
		selection[1].p==1 then
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

function button(x,y,w,h,handle,hover)
	add(buttons,{
		x=x,y=y,w=w,h=h,handle=handle,
		hover=hover
	})
end

function draw_sel_ports(y)
	for i=0,#selection-1 do
		local x=3+i*13
		local mu=6
		if i+1>mu then
			print("+"..(#selection-mu),x,y+4,1)
			break
		end
		local u=selection[i+1]
		draw_port(
			u.typ,x,y+1,nil,
			#selection>1 and function()
				u.sel=false
				del(selection,u)
			end,
			nil,u)
	end
end

function draw_unit_section(sel)
	local y=menuy+2
	if sel==1 then
		local u=selection[1]
		local typ=u.typ
		
		if #selection<3 then
			draw_sel_ports(y)
		else
			draw_port(typ,3,y+2,nil,
				function()
					selection[1]=false
					deli(selection,1)
				end)
			print("\88"..#selection,16,y+5,7)
		end
		
		if (u.p!=1) return
		
		if #selection==1 then
			local r=u.res
			if r then
				for i=0,8 do
					local xx=20+(i%3)*3
					local yy=y+2+flr(i/3)*3
					rect(xx,yy,xx+3,yy+3,7)
					local col=5
					if r.qty>i then
						if (r.typ=="g") col=11
						if (r.typ=="r") col=8
						if (r.typ=="b") col=9
					end
					rect(xx+1,yy+1,xx+2,yy+2,col)
				end
			end
			if u.cycles then
				print(u.cycles.."/"..farm_cycles,37,y+5,4)
				spr(170,50,y+3,2,2)
			end
		end
		
		if typ.prod and not u.const then
			for i=1,#typ.prod do
				local b=typ.prod[i]
				local x=102-i*14
				local yy=y+1
				if (#typ.prod>4) yy-=1
				if i>4 then
					x+=4*14
					yy+=11
				end
				draw_port(b.typ,x,yy,b,
					function()
						if (not can_pay(b)) return
						if b.typ.inert then
							to_build=b
							return
						end
						local q=u.q
						if q and (q.b!=b or q.qty==9) then
							return
						end
						res.r-=b.r or 0
						res.g-=b.g or 0
						res.b-=b.b or 0
						res.p-=1
						if q then
							q.qty+=1
						else
							u.q={
								b=b, qty=1, t=b.t,
								fps15=max(fps%15-1,0)
							}
						end
					end
				)
			end
			if u.q then 
				local b=u.q.b
				local qty=u.q.qty
				local x=20
				draw_port(b.typ,x,y+1,nil,
					function()
						res.r+=b.r or 0
						res.g+=b.g or 0
						res.b+=b.b or 0
						res.p+=1
						if qty==1 then
							u.q=nil
						else
							u.q.qty-=1
						end
					end,u.q.t/b.t
				)
				print("\88"..qty,x+12,y+4,7)
			end
		end
	elseif sel==2 then
		draw_sel_ports(y)
	end
end

function draw_menu()
 local sel=0
 for s in all(selection) do
 	sel=1
 	if s.typ!=selection[1].typ then
 		sel=2
 		break
 	end
 end
 
 local sections={102,26}
 if sel==1 then
 	local t=selection[1].typ
 	if t.has_q then
  	sections={17,24,61,26}
 	elseif t.prod then
  	sections={35,67,26}
  end
 end
 draw_menu_bg(sections)
 
	draw_unit_section(sel)
	
	--minimap
	draw_minimap()
	
	--resources
	local x=1
	local y=122
	x+=draw_resource("r",res.r,x,y,1)
	x+=draw_resource("g",res.g,x,y,1)
	x+=draw_resource("b",res.b,x,y,1)-1
	
	line(x,y-1,x,y+5,5)
	x+=1
	line(x,y-1,x,y+5,res.p<1 and 10 or 7)
	x+=2
	x+=draw_resource("p",res.p,x,y,1)-1

	pset(x-1,y-1,5)
	line(0,y-2,x-2,y-2,5)
	line(x,y,x,y+5,5)
	
	if hovbtn and hovbtn.hover then
		local b=hovbtn.hover
		local w=cost_len(b)
		local h=8
		local x,y=hovbtn.x-(w-hovbtn.w)/2,
			hovbtn.y-h
		rectfill(x,y,x+w,y+h,7)
		local rx=x+2
		rx+=draw_resource("r",b.r,rx,y+2)
		rx+=draw_resource("g",b.g,rx,y+2)
		rx+=draw_resource("b",b.b,rx,y+2)
		if res.p<1 and b.typ.unit then
			rx+=draw_resource("p",1,rx,y+2)
		end
		rect(x,y,x+w+1,y+h,1)
	end
end

function draw_menu_bg(secs)
	local mod=#secs==3 and 0 or 1
 local x,y=0,menuy
 for i=1,#secs do
 	local c=i%2==mod and 15 or 4
 	local sp=i%2==mod and 129 or 128
 	local s=secs[i]
 	local xx=x+4+s-8
 	spr(sp,x,y)
 	spr(sp,xx-4,y)
 	line(x+3,y+1,xx,y+1,7)
 	rectfill(x+3,y+2,xx,y+4,c)
 	rectfill(x,y+4,x+s,y+menuh+3,c)
 	x+=s
 end
 --assert(x==128)
end
-->8
--notes
--[[

todo
- spiderweb
- rock paper scissors (var dmg)
- tech tree
- ai
- map

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
r=mapw/8

function dmap_find(u,key)
	local x,y=flr(u.x/8),flr(u.y/8)
	local dmap=dmaps[key]
	local wayp={}
	while true do
		local n=g(dmap,x,y)
		local ts=surrounding_tiles(
			x,y,1,mapw/8,maph/8
		)
		local lowest=n
		for t in all(ts) do
			local w=g(dmap,t[1],t[2])
			if (t.diag) w+=0.4
			if w<lowest then
				x=t[1]
				y=t[2]
				lowest=w
			end
		end
		if (lowest>=n) return nil
		add(wayp,{x*8+3,y*8+3})
		if (lowest<1) break
	end
	return wayp,x,y
end
 
function g(a,x,y,rows)
	return a[flr(x)+flr(y)*(rows or r)+1]
end

function s(a,x,y,v,rows)
 a[flr(x)+flr(y)*(rows or r)+1]=v
end

function add_neigh(to,closed,x,y)
	local ts=surrounding_tiles(
		x,y,1,mapw/8,maph/8,true
	)
	for t in all(ts) do
		local xx,yy=t[1],t[2]
		if (
			not (x==xx and y==yy) and
			acc(xx,yy) and
			not g(closed,xx,yy)
		) then
			s(closed,xx,yy,true)
			add(to,{xx,yy})
		end
	end
end

function acc_res(x,y,f)
	return (
 	(f=="d" and g(bldgs,x,y)==bldg_drop) or
 	(f!="d" and fget(mget(x,y),f))
 ) and (
 	acc(x-1,y) or
 		acc(x+1,y) or
 		acc(x,y-1) or
 		acc(x,y+1)
 )
end

function make_dmaps()
	dmaps={
		r=make_dmap(2),
		g=make_dmap(3),
		b=make_dmap(4),
		d=make_dmap("d"),
	}
end

function make_dmap(resf)
	local dmap={}
	local closed,start,open={},{},{}

	--1st pass
	for i=0,(mapw/8*maph)-1 do
		local x,y=i%r,flr(i/r)
		closed[i+1]=false
		dmap[i+1]=9
		if acc_res(x,y,resf) then
			closed[i+1]=true
			dmap[i+1]=0
			add(start,{x,y})
		elseif not acc(x,y) then
		 closed[i+1]=true
		end
	end
	
	--2nd pass
	for st in all(start) do
		add_neigh(open,closed,st[1],st[2])
	end
	
 --3rd pass
	local c=1
 while c<6 and #open>0 do
 	local nxt_open={}
 	for op in all(open) do
 		s(dmap,op[1],op[2],c)
 		add_neigh(nxt_open,closed,op[1],op[2])
 	end
 	open=nxt_open
 	c+=1
 end
 
 --last pass
 for op in all(open) do
		s(dmap,op[1],op[2],c)
	end
	
	return dmap
end

--[[function draw_dmap(res_typ)
	local dmap=dmaps[res_typ]
 for x=0,16 do
		for y=0,16 do
			local n=g(dmap,x+flr(cx/8),y+flr(cy/8))
			n=min(n,9)
			print(n==0 and "-" or n,x*8,y*8,9)
	 end
	end
end]]
__gfx__
00000000d00000000000000000000000000000000000000000000000000000000100010000000000000000000000000000000000000000000000000000000000
000000000d000000d000000000000000000000000000000000000000011000000010100000000000110001100000000011000110000000000000000000000000
00700700005111000d000000dd000000000000000000000000000000111100000010100001110000001010000111000000101000000000000000000000000000
00077000005111100051110000511100000000000000000000000000111101110444400011110111044440001111011104444000000000000001010000000000
000770000001111000511110005111100d5111000000000000000000110144114424200011014411442420001101441144242000011000111014441000000000
00700700000d1d10000d1d100001d1d0d051d1d00000000000000000000544005044000011054400504400001150440504440000111114411415451000000000
00000000000000000000000000000000000000000000000000000000005050050500500000505005050050000505005050050000115054450504400000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000800008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000008008800088050000000000000000000080080000000000000000000000000000000000b00000000000000000000000000000000000000000000
0000110001108800110001100110511011000110000081101100000000000000000000000000000000bbb0000000000000000000000000000000000000000000
11110011001111110011001100110011801108110000001180110000000000000000000000000000011b11000000000000000000000000000000000000000000
00000b0000b000000400004000000000000000000000000000000000000000000000000000000000041114000000000000000000000000000000000000000000
0b00bb000bb004004400044000000000000000000000000000000000000000000000000000000000401110400000000000000000000000000000000000000000
bb001100011044001100011000000000000000000000000000000000000000000000000000000000404040400000000000000000000000000000000000000000
11110011001111110011001101550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05015105005050500050505000505050005050500505050005050500005050500000000000000000000000000000000000000000000000000000000000000000
05015105050151050501510505051105050511505015150050151050050115050005050000000000000000000000000000000000000000000000000000000000
05005005050151055001510550051105500511505015150050151050050115050051515000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d00001100d0000000dd0000000000000011110000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000
11000110d0000110d00001100000000000d1d00000d1d00000000000000000000000000000000000000000000000000000000000000000000000000000000000
0011110011111110111111100d000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001d1d000d1d1d0001d1d1d0d1d1d110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050000005550000000500000005555000000500000555500000000000000000000000000ffffffff0000000000000000ffffffffffffffffffffffffffffffff
575000005775000005750000057777500005750005777750048800000480080004008800ffff6fff0000000000000000ffffffffffffffffffffffffffffffff
577500005677550005755550574755000057775057555575048888000488880004888800ffffffff0000000000000000ffffffffffffffffffffffffffffffff
577750000565400055757575577440000577775055000055048888000488880004888800f6ffffff0000000000000000ffffffffffffffffffffafffffffffff
577775000054440075777775575444005777740054555545040088000408800004880000ffffff6f0000000000000000ffafffffff7fffffffffffffffffffff
577550000050445057777775575044400577444054944945040000000400000004000000ffffffff0000000000000000ffffffffffffffffffffffffffffffff
055750000000050005577750050004450055044554944945141000001410000014100000fff6ffff0000000000000000ffffffffffffffffffffffff7fffffff
000500000000000000055500000000500000005005555550111000001110000011100000ffffffff0000000000000000ffffffffffffffffffffffffffffffff
fff88fffff5555fffffffffffffffffff66ccc1111111111ffff67ccffffffffffffffff000000000000000000000000ffffffffffffffffffffffffffffffff
f887888ff555555ff33fff33fff4f4fff6ccc6111dd11111ffff6cccff776666ffffffff000000000000000000000000ffffffffffffffffffffffffffffffff
8788787855555555f3bff3bbf44ff44ff7cccc1111dd1111fff76cccf76cccccffffffff000000000000000000000000fffffffffffffff7ffffffffffffffaf
8878878855555555ffbbfbffff4f44fff6c6cc1111111111ff67cc6cf6cccccc6666fff6000000000000000000000000fffff7ffffffffffffffffffffffffff
fff77fff55555555fffbbbffff44f4fff66ccc1111111dd1666cccccf6cc6cc6ccc76666000000000000000000000000fffffffffffffffffffffaffffffffff
ff7777ff5555555fffffbffff44fff4fff6c6c1111111111c7ccccc1f66ccc6ccccccccc000000000000000000000000ffffffffffffffffffffffffffffffff
fff77ffff55555ffffffbfffff4f4fffff6cc11111dd1111cccc6cc1ff7cccccc77ccc7c000000000000000000000000ffffffffffffffffffffffffffffffff
fff77ffffff55fffffffbffffffffffff76c611111111111cccccc11ff6c6c11ccccccc7000000000000000000000000fffffffffffffaffffffffffffffffff
fff88fff00000000fffffffffffffffffffffffffffffffff66ccc110000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
f887888f00000000fffffffffffff4ffffffffffffaff7fff6ccc6110000000000000000000000000000000000000000fffffffffffffffffffffffff7ffffff
ff8878f800000000f3bfff3fff4ff44ffffffffffffffffff7cccc110000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
f8788fff00000000fffbfbffff4f44fffffffffff7ffffaff6c6cc110000000000000000000000000000000000000000ffffffffffffffffff7fffffffffffff
fff77fff00000000fffbbbffff44f4fffaff7ff6fffffffff66ccc110000000000000000000000000000000000000000fffaffffffffffffffffffffffffffff
ff77ffff00000000ffffbffff44ffffffffff666ffff7fffff6c6c110000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
fff7ffff00000000ffffbfffff4fffff7ffff6ccffafffffff6cc1110000000000000000000000000000000000000000fffffffff7ffffffffffffffffffafff
fff77fff00000000ffffbfffffffffffffff66ccfffffffff76c61110000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
ffffffff00000000ffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
ffff8fff00000000ffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
ff88f8ff00000000fffffffffffff4ff0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
f8788fff00000000fffffbffff4f44ff0000000000000000000000000000000000000000000000000000000000000000fffffffffffffaffffffffff7fffffff
ffff7fff00000000fffbbfffff44f4ff0000000000000000000000000000000000000000000000000000000000000000f7ffffffffffffffffffffffffffffff
fff7ffff00000000ffffbfffff4fffff0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
fff7ffff00000000ffffbfffffffffff0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
fff77fff00000000ffffbfffffffffff0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
0000000000000000000000000000000000000000000000000000000000000000000000000bb006660040000000000000000000000ffffffff000000000000000
007777000077770000000000000000000000000000000000000000000000000000000000bbb00006004400040000000000000000ffffffffff00000000000000
0744447007ffff7000000000000000000000000000000000000000000000000000000000bb000066444440004000000000000000fff29f9f9f00000000000000
744444477ffffff7000000000000000000000000000000000000000000000000000000000b000006404400404000000000000000ffff29992f00000000000000
44444444ffffffff000000000000000000000000000000000000000000000000000000000b000666407004404000000000000000444f4444ff00000000000000
44444444ffffffff000000000000000000000000000000000000000000000000000000000000000047774444400000000000000044444141ff00000000000000
44444444ffffffff00000000000000000000000000000000000000000000000000000000000000000470044000000000000000004f5f444fff00000000000000
44444444ffffffff0000000000000000000000000000000000000000000000000000000000000000000000400000000000000000f5f5fff5ff00000000000000
00000000000000000500000500000050005002002002000000000000000000000000000008000666004000000000000000000000ffffffffff00000000000000
000200020290909250500050500000050500022d2d220000000000000000000000000000888000060044000000000000000000000ffffffff000000000000000
00002020002999205055555050022225050000ddddd0000000000000000000000000000088800066444440440000000000000000000000000000000000000000
0000404040444400055e5e55002622dddd0d00ddddd0000000000000000000000000000006000006404404040000000000000000000000000000000000000000
44047474444e4e0050555550502266d5d50dd04e4e40000000000000000000000000000006000666404044040000000000000000000000000000000000000000
444044404504400050500050502222dddd0444044400000000000000000000000000000000000000440444440000000000000000000000000000000000000000
05050405505005000005050000505050500050504050000000000000000000000000000000000000000044000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000
0000b000eee7eeeee000000000000000000000000000000000000000000000000000000004000666004000000000000000000000050000055000000000000000
000b3500eee7ee6ee000870000000000000000000000000000000000000000000000000044000006004400000000000000000000505000500500000000000000
00b33350ee6e77e6e087887800000000000000000000000000000000000000000000000004000066444440440000000000000000505555505000000000000000
0b444445e6e76e7ee078888800000000000000000000000000000000000000000000000004400006404400004000000000000000055353550500000000000000
00411d40eee7e676e343775334000000000000000000000000000000000000000000000004000666404000404000000000000000505555505000000000000000
00411d40e77e77eee453773345000000000000000000000000000000000000000000000000000000400004404000000000000000505000505000000000000000
00444440eee6ee7ee532772453000000000000000000000000000000000000000000000000000000044044444000000000000000000505000000000000000000
00044400eeeeeee7e342222534000000000000000000000000000000000000000000000000000000000004400000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000010001066000000400000000000000000000000000000000000000000
00500050000000000000000000000000000000000000000000000000000000000000000001010000000000000000000000000000000000000000000000000000
0575057500000000000000000000000000000000000000000000000000000000000000000c1c0006000000000000000000000000000000000000000000000000
0747074700000000000000000000000000000000000000000000000000000000000000000c1c0000000000000000000000000000000000000000000000000000
00400040000000000000000000000000000000000000000000000000000000000000000001110066000000000000000000000000000000000000000000000000
04111114000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04011104000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000b35000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000400000000000000000000b333500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000411000000400000000000b4444450040004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0045114000041100000040000411d400040004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0455445400451140000411000411d400040004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05454545045544540045114004444400044444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000411d400041114000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000004444400044444000044400000000000000000000000000000000000000000000000000000000000000000000000000000000000
00444400000000000000000000414000004140000041400000000000000000000000000000000000000000000000000000000000000000000000000000000000
04411440000440000000000000444000004440000041400000000000000000000000000000000000000000000000000000000000000000000000000000000000
44111144004114000000000000414000004140000041400000000000000000000000000000000000000000000000000000000000000000000000000000000000
41155114041511400004400000414550004040000040400000000000000000000000000000000000000000000000000000000000000000000000000000000000
44155144041111400041440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04411440004114000044440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07711770000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77111177007117000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
71166117071511700007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77166177071111700071770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07711770007117000077770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000345334533353345500000bb034533453345334533453345335534334000000000000000000000000000000000000000000000000
0500050000000000000000004533453343434343434040b045387533453345334533453354435445000000000000000000000000000000000000000000000000
575057500000000000000000533453345543553343b3000058788784533453345338873434535453000000000000000000000000000000000000000000000000
7470747000000000000000003345334534435343044043b037888885334788453387884545343534000000000000000000000000000000000000000000000000
04000400040004000000000034533453333343550300b0b434377453345887533453745353443335000000000000000000000000000000000000000000000000
4111114001111100001110004533453345533453b0b0044045377533453375334537753333553443000000000000000000000000000000000000000000000000
4011104040111040401110405334533445444533b04b400053577534533473345334733434435453000000000000000000000000000000000000000000000000
4040404040404040404040403345334535335543030033b033555545334533453345334545534533000000000000000000000000000000000000000000000000
__gff__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007010b1301010101000000000000000007000b1300000100000000000000000007000b13000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000707070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007070707070707070700000000
__map__
535353535353534f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
535353525353535f5c5d52525c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5353535353536e6f6c525252526d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
535253537c7d7e7f7c525052527d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5352534f4c4d4e4f4c5252524c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5353535f5c5d5e5f5c5d52525c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5353536f506d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
537d7e7f7c7d7e7f7c507e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4c4d4e4f52524e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5d5e5250525e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6d525252526e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c7d7e52527d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
