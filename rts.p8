pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--constants
debug=false

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

selbox=nil
selection={}
units={}
unit_sel=false
--0.1 so res displays in readout
--but is also essentially 0
res={r=10.1,g=10.1,b=4.1,p=7.1}
p1q=nil
restiles={}
dmaps={}
proj={} --projectiles
bldgs={}

--reset every frame
buttons={}
vizmap=nil
hoverunit=nil
hilite=nil
to_build=nil

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
		--unit(spider,48,16,1),
		--unit(warant,58,30,1),
		--unit(beetle,40,36,1),
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
 
 local above_fog,below_fog={},{}
 for u in all(units) do
 	if u.const and u.p==1 then
 		add(above_fog,u)
 	else
	 	add(below_fog,u)
	 end
 end
 
	foreach(below_fog,draw_unit)
	draw_projectiles()
	draw_fow()
	foreach(above_fog,draw_unit)

	--selection box
	if selbox then
		fillp(▒)
		rect(selbox[1],selbox[2],selbox[3],selbox[4],7)
		fillp(0)
	end
	
	if (hilite) draw_hilite()
	
	draw_to_build()
	
	camera(0,0)
	
	if (show_dmap) draw_dmap("d")
	
	--menu
	draw_menu()
	
	if hilite and hilite.px then
		circ(hilite.px,hilite.py,2,8)
	end
	
	--mouse
	draw_cursor()
	
	if debug then
		local s=selection[1]
		if s and s.st.t=="gather" then
			local x=g(restiles,s.st.tx,s.st.ty)
			print(x,0,0,7)
		end
	end
end

function _update()
	if debug and btnp(🅾️) and btnp(❎) then
		show_dmap=not show_dmap
	end

	fps+=1
	if fps==60 then
		fps=0
 end
 
 if hilite then
  if t()-hilite.t>=0.5 then
  	hilite=nil
  end
 end
	
 handle_input()
 
 vizmap={}
 hoverunit=nil
 buttons={}
 unit_sel=false
 update_projectiles()
 foreach(units,tick_unit)
end

function draw_hilite()
	local dt=t()-hilite.t
	if hilite.x then
		circ(hilite.x,hilite.y,min(1/dt/2,4),8)
	else
		if (dt>0.1 and dt<0.25) return
		local tx,ty,u=hilite.tx,hilite.ty,hilite.unit
		if tx then
			rect(
				tx*8-1,ty*8-1,
				tx*8+8,ty*8+8,8)
		elseif u then
			rectaround(u,8)
		end
	end
end

function draw_to_build()
	if to_build and amy<menuy then
		local b=buildable()
		local typ=to_build.typ
 	local w,h=typ.w,typ.h
		local x,y=to_build.x,to_build.y
	 if amy<menuy then
 		rectfill(
	 		x-1,y-1,
	 		x+w,y+h,
	 		b and 3 or 8
	 	)
 	end
 	sspr(typ.x,typ.y,w,h,x,y)
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
x=0
y=8
deadx=24
deady=12
anim_fr=2
portx=0
porty=72
fps=1

spd=1
los=20
hp=10
]])
beetle=parse([[
w=7
fw=8
h=6
x=8
y=0
deadx=32
anim_fr=2
fps=3
portx=26
porty=72
portw=9

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
x=0
y=16
deadx=66
anim_fr=7
fps=10
portx=16
porty=72
portw=9
has_q=1

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
x=0
y=25
deadx=24
anim_fr=2
fps=3
portx=35
porty=72
portw=9

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
x=56
y=0
deadx=104
anim_fr=2
fps=2
dir=-1
portx=8
porty=72
has_q=1

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
x=24
y=96
portx=0
porty=80
inert=1
los=30
hp=40
dir=-1
restfr=1
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
h=5
x=0
y=99
inert=1
los=5
hp=20
dir=-1
restfr=1
const=12
]])
web=parse([[
w=8
fw=8
h=8
x=0
y=99
portx=8
porty=80
portw=9
inert=1
los=5
hp=5
dir=-1
restfr=1
const=12
]])
spden=parse([[
w=8
fw=8
h=6
x=0
y=114
inert=1
los=10
hp=20
dir=-1
restfr=1
const=20
has_q=1
]])
btden=parse([[
w=8
fw=8
h=6
x=0
y=106
inert=1
los=10
hp=20
dir=-1
restfr=1
const=20
has_q=1
]])
barracks=parse([[
w=7
fw=8
h=7
x=0
y=121
inert=1
los=10
hp=20
dir=-1
restfr=1
const=20
has_q=1
]])
farm=parse([[
w=8
fw=8
h=8
x=24
y=120
portx=17
porty=80
portw=9
inert=1
los=0
hp=10
dir=-1
restfr=1
const=6
]])
ant.prod={
	{typ=mound,b=2},
	{typ=tower,g=3,b=8},
	{typ=spden,b=2},
	{typ=btden,g=3,b=8},
	{typ=barracks,g=5,b=10},
	{typ=farm,g=3,r=1},
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
	u.st={
		t="gather",
		tx=tx,
		ty=ty,
		res=tile2res(tx,ty),
		wayp=wp,
		target=target_tile(tx,ty),
	}
end

function drop(u,res)
	local wayp,x,y=dmap_find(u,"d")
	u.st={
		t="drop",
		wayp=wayp,
		nxt=res,
		target=target_tile(x,y),
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
-->8
--update

function hoverbutton()
	for b in all(buttons) do
		if (
			amx>=b.x and amx<=b.x+b.w and
			amy>=b.y and amy<=b.y+b.h
		) then
			return b
		end
	end
end

function handle_click()
	--check left click on button
	if btnp(5) then
		local hb=hoverbutton()
		if hb then
			hb.handle()
			return
		end
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
 
	--left click clears selection
 if btnp(5) then
 	selection={}
 end
 
 --left drag makes selection
 if btn(5) and not to_build then
 	if selbox==nil then
 		selbox={mx,my,mx,my}
 	else
	 	selbox[3]=mx
	 	selbox[4]=my
 	end
 	selection={}
 else
 	selbox=nil
 end
	
 --right click
	local sel1=selection[1]
 if btnp(4) and sel1 and sel1.p==1 then
	 if can_gather() then
	 	--gather resources
	 	local x=flr(mx/8)
	 	local y=flr(my/8)
	  hilite={t=t(),tx=x,ty=y}
	  for u in all(selection) do
				gather(u,x,y)
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
  elseif sel_carry() and hoverunit==p1q then
	 	for u in all(selection) do
				drop(u)
  	end
  	hilite={t=t(),unit=hoverunit}
  elseif not sel1.typ.inert then
	 	for u in all(selection) do
				move(u,mx,my)
  	end
  	hilite={t=t(),x=mx,y=my}
  elseif sel1.typ.prod then
  	sel1.rx,sel1.ry=mx,my
  end
 end
end

function sel_carry()
 for u in all(selection) do
		if (u.res) return true
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
 
 handle_click()
 
 if to_build then
	 to_build.x=flr(mx/8)*8
	 to_build.y=flr(my/8)*8
	end
end

function update_sel(u)
 local no_other=(not unit_sel and #selection==0)
	local s=(
		intersect(selbox,u_rect(u)) and
		(not u.typ.inert or no_other) and
		(u.p==1 or no_other)
	)
	u.sel=s
	if (s) then
		if (not u.typ.inert) then
			unit_sel=true
			for i=1,#selection do
				if (
					selection[i].typ.inert or
					selection[i].p!=1) then
					selection[i].sel=false
					deli(selection,i)
					i-=1
				end
			end
		end
		add(selection,u)
	end
end

function tick_unit(u)
	if u.dead then
		if (u.dead==fps) del(units,u)
		return
	end
	if u.hp<=0 and not u.dead then
		u.dead=fps
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
	
	local mbox={mx-1,my-1,mx+2,my+2}
	if intersect(u_rect(u),mbox) then
		hoverunit=u
	end
	
	if (selbox) update_sel(u)
	if (u.const) return

	update_unit(u)
	
	if u.p==1 then
		update_viz(u)
	end
end

function update_viz(u)
	local tiles=mapw/fogtile
	
	local x=flr(u.x/fogtile)
	local y=flr(u.y/fogtile)
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
			vizmap[xx*tiles+yy+1]=true
		end
	end
end

function update_projectiles()
 for p in all(proj) do
 	local dx,dy=norm(p.to,p)
  p.x+=dx/1.25
  p.y+=dy/1.25
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
	 	local mapx=x+xoff
	 	local mapy=y+yoff
	 	local drawx=x-cx%fogtile
	 	local drawy=y-cy%fogtile
	 	if not vget(mapx,mapy) then
	 		darken(drawx,drawy)
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
	
	if debug then
		if u.st.wayp then
			for i=1,#u.st.wayp do
				pset(u.st.wayp[i][1],u.st.wayp[i][2],8)
			end
		end
		if (u.sel) then
			circ(u.x,u.y,u.typ.los,8)
			if u.typ.range then
				circ(u.x,u.y,u.typ.range,9)
			end
		end
	end
	local ut=u.typ
	local w=ut.fw or ut.w
	local h=ut.h
	
	if u.const then
		fillp(▒)
		rectaround(u,12)
		fillp(0)
		local x=u.x-flr(w/2)
		local y=u.y-flr(h/2)-1
		local p=u.const/u.typ.const
		local w=u.typ.w-1
		line(x,y,x+w,y,5)
		line(x,y,x+w*p,y,14)
		if (u.const<=1) return
	end
	
	local x=ut.x
	local y=ut.y
	
	local ufps=ut.fps or 1
	local restfr=ut.restfr or 2
	if (u.st.t=="rest") ufps=restfr/2
	if (u.st.t=="build") ufps*=2
	local anim=flr(fps/(30/ufps))
	local move_anim=u.st.wayp or u.st.t=="gather" or u.st.t=="attack"
	
	if u.dead then
		x=ut.deadx
		y=ut.deady or y
	elseif u.st.t=="rest" or u.typ.inert then
		if (u.typ==ant) anim+=1
		x+=(anim%restfr)*w
	elseif move_anim then
		x+=w+(anim%(ut.anim_fr))*w
	elseif u.st.t=="build" then
		x=24+(anim%(ut.anim_fr))*w
	end
	if u.res then
		if u.res.typ=="r" then
			x+=12
		elseif u.res.typ=="g" then
			y+=4
		elseif u.res.typ=="b" then
			y+=4
			x+=12
		end
	end
	if u.const then
		local prog=u.const/u.typ.const
		if prog<0.5 then
			x+=u.typ.fw*2
		else
			x+=u.typ.fw
		end
	end
	local col=u.p==1 and 1 or 2
	pal(2,col)
	if (u.sel) col=9
	pal(1,col)
	local sdir=u.typ.dir or 1
	sspr(x,y,w,h,u.x-w/2,u.y-h/2,w,h,u.dir==sdir)
	pal()
	
	if (u.sel and u.rx) draw_rally(u)
end

function check_dead_target(u)
	local t=u.st.target
	if t and (t.dead or (
		u.st.t=="build" and
		not t.const and
		t.hp==t.typ.hp
	)) then
		rest(u)
	end
end

function update_unit(u)
	check_dead_target(u)
	if (u.st.t=="attack") fight(u)
	if (u.st.t=="rest") aggress(u)
 if (u.q) produce(u)
 if (u.typ.inert) return
 if (u.st.t=="build") buildrepair(u)
 if (u.st.t=="gather") mine(u)
 check_target_col(u)
 step(u)
end

function aggress(u)
	if (not u.typ.atk) return
	for e in all(units) do
		if e.p!=u.p and not e.dead then
			local d=dist(e.x-u.x,e.y-u.y)
			if d<=u.typ.los then
				attack(u,e)
				break
			end
		end
	end
end

function fight(u)
	local e=u.st.target
	local in_range=false
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
		u.res.qty+=1
		mine_res(x,y,r)
		if (u.res.qty==9) drop(u,r)
	end
end

function produce(u)
	if fps%15==u.q.fps15 then
		u.q.t-=0.5
		if u.q.t==0 then
			local new=unit(u.q.b.typ,u.x,u.y,1)
			add(units,new)
			move(new,u.rx or u.x+5,u.ry or u.y+5)
			if u.q.qty>1 then
				u.q.qty-=1
				u.q.t=u.q.b.t
			else
				u.q=nil
			end
		end
	end 
end

function check_target_col(u)
	if (u.st.active) return
	local t=u.st.target
	if (
		t and
		intersect(u_rect(u),u_rect(t))
	) then
		u.st.wayp=nil
		u.st.active=true
		if u.st.t=="gather" then
			u.st.fps=fps
			local q=0
			if u.res and u.res.typ==u.st.res then
				q=u.res.qty
			end
			u.res={typ=u.st.res,qty=q}
		elseif u.st.t=="drop" and u.res then
			local q=u.res.qty/3
			if u.res.typ=="r" then
				res.r=min(res.r+q,99)
			elseif u.res.typ=="g" then
				res.g=min(res.g+q,99)
			elseif u.res.typ=="b" then
				res.b=min(res.b+q,99)
			end
			u.res=nil
			if (
				not u.st.nxt or
				not mine_nxt_res(u,u.st.nxt)
			) then
				rest(u)
			end
		end
	end
end

function step(u)
	if u.st.wayp then
 	local wp=u.st.wayp[1]
 	local dx,dy=norm(wp,u)
 	dx*=u.typ.spd/3.5
 	dy*=u.typ.spd/3.5
 	
	 u.dir=sgn(dx)
 	u.x+=dx
 	u.y+=dy	
		
 	if adj(u.x,u.y,wp[1],wp[2],2) then
 		if (#u.st.wayp==1) then
				rest(u)
			else
			 deli(u.st.wayp,1)
			end
 	end
 end
end

function draw_rally(u)
	spr(69+(fps/5)%3,u.rx-2,u.ry-5)
end
-->8
--utils

function intersect(r1,r2,e)
	e=e or 0
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
	 	if (
	 		x+dx>=0 and y+dy>=0 and
	 		x+dx<maxx and y+dy<maxy
	 	) then
	 		if (
	 			not cut
	 			or corner_cuttable(x,y,dx,dy)
	 		) then
			 	local v=(
			 		dx<2 and dx>-2 and
			 		dy<2 and dy>-2)
				 add(st,{
				  x+dx,y+dy,v,
				 	diag=(dx!=0 and dy!=0)
				 })
				end
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
 return nil
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

function can_gather()
	if (not vget(mx,my)) return
	if fget(mget(mx/8,my/8),1) then
		return all_ants()
	end
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
	if (
		hoverunit and
		hoverunit.typ.inert and
		hoverunit.p==1 and
		(hoverunit.const or
			hoverunit.hp<hoverunit.typ.hp)
	) then
		return all_ants()
	end
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
		local s=mget(x,y)
		mset(x,y,s+16)
	end
	if n==0 then
		mset(x,y,72)
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
	local tiles=mapw/fogtile
	x=flr(x/fogtile)
 y=flr(y/fogtile)
 if (x<0 or y<0) return true
 return vizmap[x*tiles+y+1]
end

function norm(it,nt)
	local xv=it[1]-nt.x
	local yv=it[2]-nt.y
	local norm=1/(abs(xv)+abs(yv))
	return xv*norm,yv*norm
end

--strict=f to ignore farms+const
function acc(x,y,strict)
	local b=g(bldgs,x,y)
	if	not strict and (
		b==bldg_farm or b==bldg_const
	) then
		b=nil
	end
	return not (
		b or fget(mget(x,y),0)
	)
end

function buildable()
	local x,y=to_build.x/8,to_build.y/8
	local w,h=to_build.typ.w,to_build.typ.h
	return (
		acc(x,y,true) and
		(w<9 or acc(x+1,y,true)) and
		(h<9 or acc(x,y+1,true))
	)
end

function bldg_type(b)
	if (b.dead) return
	if (b.const) return bldg_const
	if (typ==mound) return bldg_drop
	if (typ==farm) return bldg_farm
	return bldg_other
end

function register_bldg(b)
	local typ=b.typ
	local w,h=typ.w,typ.h
	local x,y=flr((b.x-2)/8),flr((b.y-2)/8)

	local v=bldg_type(b)

	s(bldgs,x,y,v)
	if (w>8) s(bldgs,x+1,y,v)
	if (h>8) s(bldgs,x,y+1,v)
	if (w>8 and h>8) s(bldgs,x+1,y+1,v)
	if not b.const then
		make_dmaps()
	end
end

function deal_dmg(from,to)
	--todo: rps
	to.hp-=1
end
-->8
--get_wayp

function get_wayp(u,x,y)
	if (u.typ.inert) return
 local nodes=find_path(
		{flr(u.x/mvtile),flr(u.y/mvtile)},
		{flr(x/mvtile),flr(y/mvtile)},
		estimate,
  neighbors,
  node_to_id
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

function estimate(n1,n2,g)
 return dist(n1[1]-n2[1],n1[2]-n2[2])
end

function obstacle(x,y)
	x=flr(x*(mvtile/8))
	y=flr(y*(mvtile/8))
	return not acc(x,y)
end

function neighbor(ns,n,dx,dy)
	if (
		dx!=0 and dy!=0 and
		not corner_cuttable(n[1],n[2],dx,dy)
	) then
		return
	end
	local x,y=n[1]+dx,n[2]+dy
 if (
 	x<0 or x>=mapw/mvtile or
		y<0 or y>=maph/mvtile or
		obstacle(x,y)
	) then
		return
	end
	add(ns,{x,y})
end

function neighbors(n,g)
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

function node_to_id(node,g)
	return node[1]..","..node[2]
end

--a*
--https://t.co/nasud3d1ix

function find_path
(start,
 goal,
 estimate,
 neighbors, 
 node_to_id)
 
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
		((not c.typ.inert and res.p<1) and
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
	local outline=costs and 11 or 1
	if (u and u.p!=1) outline=2
	pal(14,0)
	if costs and not can_pay(costs) then
		outline=5
		pal(split("5,5,5,5,5,6,7,13,6,7,7,6,13,6,7,5"))
	end
	rect(x,y,x+10,y+9,outline)
	x+=1
	y+=1
	rectfill(x,y,x+8,y+7,costs and 12 or 6)
	if typ.portx then
		sspr(typ.portx,typ.porty,typ.portw or 8,8,x,y)
	else
		local yoff=flr((9-typ.h)/2)
		local xoff=flr((9-typ.w)/2)
		sspr(typ.x-xoff,typ.y-yoff,typ.w+xoff,typ.h+yoff,x,y)
	end
	x-=1
	y-=1
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
	for b in all(buttons) do
		if (
			amx>=b.x and amx<=b.x+b.w and
			amy>=b.y and amy<=b.y+b.h
		) then
			return 66
		end
	end
	if #selection>0 and
		selection[1].p==1 then
	 --build cursor
		if (to_build or can_build()) then
			return 68
		end
		--pick
		if (can_gather())	return 67
		 --sword
		if (can_attack()) return 65
	end
	--default
	return 64
end

--[[function xing_tiles(x,y,w,h)
	local tiles={}
	local xx,yy=flr(x/8),flr(y/8)
	for dx=0,ceil(w/8) do
		for dy=0,ceil(h/8) do
			add(tiles,{xx+dx,yy+dy})
		end
	end
	return tiles
end]]

function draw_cursor()
	if to_build and amy>=menuy then
		local typ=to_build.typ
 	local w,h=typ.w,typ.h
 	sspr(typ.x,typ.y,w,h,amx-3,amy-3)
	end
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
		local onclick=nil
		if #selection>1 then
			onclick=function()
				u.sel=false
				del(selection,u)
			end
		end
		draw_port(u.typ,x,y+1,nil,onclick,nil,u)
	end
end

function draw_unit_section(sel)
	local y=menuy+2
	if sel==1 then
		local u=selection[1]
		local typ=u.typ
		local hp=u.hp/u.typ.hp
		
		if #selection<3 then
			draw_sel_ports(y)
		else
			draw_port(typ,3,y+2,nil,
				function()
					selection[1].sel=false
					deli(selection,1)
				end)
			print("\88"..#selection,16,y+5,7)
		end
		
		if (u.p!=1) return
		
		if #selection==1 and u.res then
			for i=0,8 do
				local xx=20+(i%3)*3
				local yy=y+2+flr(i/3)*3
				rect(xx,yy,xx+3,yy+3,7)
				local col=5
				if u.res.qty>i then
					if (u.res.typ=="g") col=11
					if (u.res.typ=="r") col=8
					if (u.res.typ=="b") col=9
				end
				rect(xx+1,yy+1,xx+2,yy+2,col)
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
						if (u.q and (u.q.b!=b or u.q.qty==9)) then
							return
						end
						res.r-=b.r or 0
						res.g-=b.g or 0
						res.b-=b.b or 0
						res.p-=1
						if u.q then
							u.q.qty+=1
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
	x+=draw_resource("b",res.b,x,y,1)
	x-=1
	
	line(x,y-1,x,y+5,5)
	x+=1
	line(x,y-1,x,y+5,res.p<1 and 10 or 7)
	x+=2
	x+=draw_resource("p",res.p,x,y,1)
	x-=1

	pset(x-1,y-1,5)
	line(0,y-2,x-2,y-2,5)
	line(x,y,x,y+5,5)
	
	local hb=hoverbutton()
	if hb and hb.hover then
		local b=hb.hover
		local w=cost_len(b)
		local h=8
		local x=hb.x-(w-hb.w)/2
		local y=hb.y-h
		rectfill(x,y,x+w,y+h,7)
		local rx=x+2
		rx+=draw_resource("r",b.r,rx,y+2)
		rx+=draw_resource("g",b.g,rx,y+2)
		rx+=draw_resource("b",b.b,rx,y+2)
		if res.p<1 and not b.typ.inert then
			rx+=draw_resource("p",1,rx,y+2)
		end
		rect(x,y,x+w+1,y+h,1)
		pal(5,0)
		line(x-1,y+1,x-1,y+h+1,5)
		line(x,y+h+1,x+w,y+h+1,5)
		pal()
		--[[line(x+1,y-1,x+w,y-1,5)
		line(x+1,y+h+1,x+w,y+h+1,5)
		line(x,y,x,y+h,5)
		line(x+w+1,y,x+w+1,y+h,5)
		pset(x+1,y,5)
		pset(x+w,y,5)
		pset(x+1,y+h,5)
		pset(x+w,y+h,5)]]
	end
end

function draw_menu_bg(secs)
	local mod=1
	if (#secs==3) mod=0
 local x,y,mh=0,menuy,menuh+3
 for i=1,#secs do
 	local c=i%2==mod and 15 or 4
 	local sp=i%2==mod and 129 or 128
 	local s=secs[i]
 	spr(sp,x,y)
 	spr(sp,x+s-8,y)
 	line(x+3,y+1,x+4+s-8,y+1,7)
 	rectfill(x+3,y+2,x+4+s-8,y+4,c)
 	rectfill(x,y+4,x+s,y+mh,c)
 	x+=s
 end
 --assert(x==128)
end
-->8
--notes
--[[

todo
- units adjst when in same spot
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
 
function g(a,x,y)
	return a[x+y*r+1]
end

function s(a,x,y,v)
 a[x+y*r+1]=v
end

function add_neigh(to,closed,x,y)
	local ts=surrounding_tiles(
		x,y,1,mapw/8,maph/8,true
	)
	for t in all(ts) do
		if (
			not (x==t[1] and y==t[2]) and
			acc(t[1],t[2]) and
			not g(closed,t[1],t[2])
		) then
			s(closed,t[1],t[2],true)
			add(to,{t[1],t[2]})
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

function draw_dmap(res_typ)
	local dmap=dmaps[res_typ]
	local r=mapw/8
 for x=0,16 do
		for y=0,16 do
			local n=g(dmap,x+flr(cx/8),y+flr(cy/8))
			n=min(n,9)
			print(n==0 and "-" or n,x*8,y*8,9)
	 end
	end
end
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
00000000000008008800088050000000000000000000000000000000000000000000000000000000000b00000000000000000000000000000000000000000000
0000110001108800110001100110511000000000000000000000000000000000000000000000000000bbb0000000000000000000000000000000000000000000
11110011001111110011001100110011000000000000000000000000000000000000000000000000011b11000000000000000000000000000000000000000000
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
0500000055500000005000000055550000005000000000000000000000000000ffffffffffffffff0000000000000000ffffffffffffffffffffffffffffffff
5750000057750000057500000577775000057500048800000480080004008800ffffffffffff6fff0000000000000000ffffffffffffffffffffffffffffffff
5775000056775500057555505747550000577750048888000488880004888800ffffffffffffffff0000000000000000ffffffffffffffffffffffffffffffff
5777500005654000557575755774400005777750048888000488880004888800fffffffff6ffffff0000000000000000ffffffffffffffffffffafffffffffff
5777750000544400757777755754440057777400040088000408800004880000ffffffffffffff6f0000000000000000ffafffffff7fffffffffffffffffffff
5775500000504450577777755750444005774440040000000400000004000000ffffffffffffffff0000000000000000ffffffffffffffffffffffffffffffff
0557500000000500055777500500044500550445141000001410000014100000fffffffffff6ffff0000000000000000ffffffffffffffffffffffff7fffffff
0005000000000000000555000000005000000050111000001110000011100000ffffffffffffffff0000000000000000ffffffffffffffffffffffffffffffff
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
0000000000000000000000000000000000000000000000000000000000000000000000000bb006660000000000000000000000000ffffffff000000000000000
007777000077770000000000000000000000000000000000000000000000000000000000bbb00006000000000000000000000000ffffffffff00000000000000
0744447007ffff7000000000000000000000000000000000000000000000000000000000bb000066000000000000000000000000fff29f9f9f00000000000000
744444477ffffff7000000000000000000000000000000000000000000000000000000000b000006000000000000000000000000ffff29992f00000000000000
44444444ffffffff000000000000000000000000000000000000000000000000000000000b000666000000000000000000000000444f4444ff00000000000000
44444444ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444141ff00000000000000
44444444ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004f5f444fff00000000000000
44444444ffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f5f5fff5ff00000000000000
00000000000000000500000500000050005002002002000000000000000000000000000008000666000000000000000000000000ffffffffff00000000000000
000200020290909250500050500000050500022d2d220000000000000000000000000000888000060000000000000000000000000ffffffff000000000000000
00002020002999205055555050022225050000ddddd0000000000000000000000000000088800066000000000000000000000000000000000000000000000000
0000404040444400055e5e55002622dddd0d00ddddd0000000000000000000000000000006000006000000000000000000000000000000000000000000000000
44047474444e4e0050555550502266d5d50dd04e4e40000000000000000000000000000006000666000000000000000000000000000000000000000000000000
444044404504400050500050502222dddd0444044400000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05050405505005000005050000505050500050504050000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000b000eee7eeeee000000000000000000880000000000000000000000000000000000004000666000000000000000000000000050000055000000000000000
000b3500eee7ee6ee000870000000000088788800000000000000000000000000000000044000006000000000000000000000000505000500500000000000000
00b33350ee6e77e6e087887800000000878878780000000000000000000000000000000004000066000000000000000000000000505555505000000000000000
0b444445e6e76e7ee078888800000000887887880000000000000000000000000000000004400006000000000000000000000000055353550500000000000000
00411d40eee7e676e343775334000000000770000000000000000000000000000000000004000666000000000000000000000000505555505000000000000000
00411d40e77e77eee453773345000000007777000000000000000000000000000000000000000000000000000000000000000000505000505000000000000000
00444440eee6ee7ee532772453000000000770000000000000000000000000000000000000000000000000000000000000000000000505000000000000000000
00044400eeeeeee7e342222533000000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000010001066000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000001010000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000c1c0006000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000c1c0000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000001110066000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000b35000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000b333500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000000000000000000b4444450040004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0041100000040000000000000411d400040004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0451140000411000000400000411d400040004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45544540045114000041100004444400044444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5454545045544540045114000411d400041114000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000004444400044444000044400000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000414000004140000041400000000000000000000000000000000000000000000000000000000000000000000000000000000000
00444400000000000000000000444000004440000041400000000000000000000000000000000000000000000000000000000000000000000000000000000000
04411440000000000000000000414000004140000041400000000000000000000000000000000000000000000000000000000000000000000000000000000000
44111144000000000000000000414550004040000040400000000000000000000000000000000000000000000000000000000000000000000000000000000000
41155114000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44155144000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04411440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07711770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77111177000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
71166117000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77166177000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07711770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000345334533333433400000bb034533453345334530000000000000000000000000000000000000000000000000000000000000000
0500050000000000000000004533453334435445030030b045387533453345330000000000000000000000000000000000000000000000000000000000000000
575057500000000000000000533453343453345303b3000058788784533453340000000000000000000000000000000000000000000000000000000000000000
7470747000000000000000003345334545343534003003b037888885334788550000000000000000000000000000000000000000000000000000000000000000
04000400040004000000000034533453534433350300b0b334377453345887530000000000000000000000000000000000000000000000000000000000000000
4111114001111100001110004533453333553443b0b0030045377533453375330000000000000000000000000000000000000000000000000000000000000000
4011104040111040401110405334533434433453b03b000053277234533272340000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040403345334545534533030000b033222245334523450000000000000000000000000000000000000000000000000000000000000000
__gff__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007010b1301010101000000000000000007000b1300000100000000000000000007000b13000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000707070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007070707070700000000000000
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
