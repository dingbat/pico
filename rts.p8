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

--global state
cx=0
cy=0
mx=0
my=0
fps=0

selbox=nil
selection={}
units={}
res={r=22,g=23,b=22,p=99}
p1q=nil
restiles={}
dmaps={}

 --reset every frame
buttons={}
vizmap=nil
hoverunit=nil
hilite=nil
build=nil

function unit(typ,x,y,p,const)
 return {
		typ=typ,
		x=x,
		y=y,
		st=st_rest,
		dir=1,
		p=p,
		hp=typ.hp,
		const=const,
	}
end

function _init()
	--enable mouse & mouse btns
	poke(0x5f2d,0x1|0x2)
	
	p1q=unit(queen,55,43,1)
	units={
		unit(ant,29,34,1),
		unit(ant,35,39,1),
		unit(ant,35,42,1),
		unit(spider,48,26,1),
		unit(beetle,40,36,1),
		unit(beetle,60,76,2),
		p1q,
		unit(tower,100,100,1)
	}
 make_dmaps()
end

function _draw()
 cls()
 
 draw_map()
 
 local built={}
 local building={}
 for u in all(units) do
 	if (u.const) add(building,u)
 	if (not u.const) add(built,u)
 end
 
	foreach(built,draw_unit)
	draw_fow()
	foreach(building,draw_unit)

	--selection box
	if selbox then
		fillp(▒)
		rect(selbox[1],selbox[2],selbox[3],selbox[4],7)
		fillp(0)
	end
	
	if hilite then
		if hilite.typ=="gather" then
			local w=hilite.w or 8
			local h=hilite.h or 8
			rect(
				hilite.x-1,hilite.y-1,
				hilite.x+w,hilite.y+h,8)
		elseif hilite.typ=="build" then
			rectaround(hilite.unit,8)
		end
	end
	
	camera(0,0)
	
	if (show_dmap) draw_dmap("b")
	
	--menu
	draw_menu()
	
	--mouse
	draw_cursor()
end

function _update()
	if btnp(🅾️) and btnp(❎) then
		show_dmap=not show_dmap
	end

	fps+=1
	if fps==60 then
		fps=0
 end
 
 if hilite and hilite.t%20==fps%20 then
 	hilite=nil
 end
	
 handle_input()
 
 vizmap={}
 hoverunit=nil
 buttons={}
 foreach(units,tick_unit)
end


-->8
--unit defs

ant={
	w=4,
	h=4,
	x=0,
	y=8,
	anim_fr=2,
	portx=0,
	porty=72,
	fps=1,
	
	spd=1,
	los=20,
	hp=10,
}
beetle={
	w=7,
	fw=8,
	h=6,
	x=8,
	y=0,
	anim_fr=2,
	fps=3,
	portx=26,
	porty=72,
	portw=9,

	spd=1.5,
	los=25,
	hp=20
}
spider={
 w=7,
 fw=8,
 h=4,
 x=0,
 y=16,
 anim_fr=7,
 fps=10,
	portx=16,
	porty=72,
	portw=9,
	has_q=true,

 spd=2,
 los=30,
	hp=15
}
queen={
	w=14,
	h=7,
	fw=16,
	x=56,
	y=0,
	anim_fr=2,
	fps=2,
	dir=-1,
	portx=8,
	porty=72,
	has_q=true,

	spd=0.5,
	los=18,
 hp=25,
}

st_rest=1
st_move=2
st_build=3

tower={
	w=7,
	fw=8,
	h=13,
	x=24,
	y=96,
	portx=0,
	porty=80,
	inert=true,
	los=30,
	hp=50,
	dir=-1,
	restfr=1,
	const=20,
}
mound={
	w=7,
	fw=8,
	h=5,
	x=0,
	y=99,
	inert=true,
	los=5,
	hp=20,
	dir=-1,
	restfr=1,
	const=12,
}

ant.prod={
	{typ=mound,t=8,r=0,g=0,b=2},
	{typ=tower,t=12,r=0,g=3,b=8},
	{typ=mound,t=8,r=0,g=0,b=2},
	{typ=tower,t=12,r=0,g=3,b=8},
	{typ=tower,t=12,r=0,g=3,b=8},
	{typ=tower,t=12,r=0,g=3,b=8},
}
spider.prod={
	{typ=mound,t=4,r=0,g=2,b=0},
}
queen.prod={
	{typ=ant,t=6,r=2,g=3,b=1}
}
-->8
--update

function handle_click()
	--check buttons
	for b in all(buttons) do
		if (
			btnp(5) and
			amx>=b.x and amx<=b.x+b.w and
			amy>=b.y and amy<=b.y+b.h
		) then
			b.handle()
			return
		end
	end
	
	--left click in menu
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
				move_units(selection,x,y)
			elseif btnp(5) then
				--move camera
				cx=mid(0,x-xoff,mapw-128)
				cy=mid(0,y-yoff,maph-128+menuh)
			end
		end
	 return
	end

 --left click places building
 if btnp(5) and build then
  if (not buildable()) return
 	res.r-=build.r
		res.g-=build.g
		res.b-=build.b
		local new=unit(build.typ,mx,my,1,0)
		add(units,new)
 
		--make selected units build it
		for u in all(selection) do
		 send_build(u,new)
		end
		
		build=nil
 end
 
	--left click clears selection
 if btnp(5) then
 	selection={}
 end
 
 --left drag makes selection
 if btn(5) and not build then
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
 if (btnp(4)) then
	 if can_gather() then
	 	--gather resources
	 	local x=flr(mx/8)
	 	local y=flr(my/8)
	  hilite={
	  	typ="gather",t=fps,
	  	x=x*8,y=y*8
	  }
		 move_units(selection,mx,my,{x,y})
  elseif can_build() then
  	for u in all(selection) do
  		send_build(u,hoverunit)
  	end
  	hilite={
	  	typ="build",t=fps,unit=hoverunit
	  }
  else
	  --move selection
   move_units(selection,mx,my)
  end
 end
end

function move_units(un,x,y,gt)
	for u in all(un) do
		if not u.typ.inert then
			if gt then
				u.gather={
					tile=gt,
					res=tile2res(gt[1],gt[2]),
				}
			else
				u.gather=nil
			end
		 move(u,x,y)
		end
	end
end

function handle_input()
 --map scroll
 local oldcx,oldcy=cx,cy
 if (btn(⬅️) or btn(⬅️,1))cx-=2
 if (btn(⬆️) or btn(⬆️,1))cy-=2
 if (btn(➡️) or btn(➡️,1))cx+=2
 if (btn(⬇️) or btn(⬇️,1))cy+=2
 cx=mid(0,cx,mapw-128)
 cy=mid(0,cy,maph-128+menuh)
 
 amx=mid(0,stat(32),128-2)
	amy=mid(-1,stat(33),128-2)
 mx=amx+cx
 my=amy+cy
 
 handle_click()
end

function tick_unit(u)
	update_unit(u)
	
	if u.p==1 then
		if u.const==nil then
			update_viz(u)
		end
		
		if selbox then
			local s=intersect(selbox,u_rect(u))
			if (s) add(selection,u)
			u.sel=s
		end
	end
	
	local mbox={mx-1,my-1,mx+2,my+2}
	if intersect(u_rect(u),mbox) then
		hoverunit=u
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
	pal(1,1)
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
		local ux=(u.x/mapw)*w
		local uy=(u.y/maph)*h
		local col=u.p==1 and 1 or 2
		if (u.sel) col=9
		
		pset(x+ux,y+uy,col)
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
	pal(1,1)
	
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
-->8
--units

function draw_unit(u)
	if not u.p then
		return
	end
 local cr={cx,cy,cx+128,cy+128}
	if not intersect(u_rect(u),cr) then
		return
	end
	
	if u.wayp then
		for i=1,#u.wayp do
			pset(u.wayp[i][1],u.wayp[i][2],8)
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
		local y=u.y-flr(h/2)-2
		local p=u.const/u.typ.const
		local w=u.typ.w-1
		line(x,y,x+w,y,5)
		line(x,y,x+w*p,y,14)
		if (u.const<=1) return
	end
	
	local x=ut.x
	local y=ut.y
	
	local ufps=ut.fps
	local restfr=ut.restfr or 2
	if (u.st==st_rest) ufps=restfr/2
	local anim=flr(fps/(30/ufps))
	if u.st==st_rest then
		x+=(anim%restfr)*w
	elseif u.st==st_move then
		x+=w+(anim%(ut.anim_fr))*w
	elseif u.st==st_build then
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
	pal(1,1)
	pal(2,2)
end

function mine_res(t)
	local idx=t[1]*mapw/8+t[2]+1
	local n=restiles[idx] or 12
	n-=1
	if n==4 or n==9 then
		local s=mget(t[1],t[2])
		mset(t[1],t[2],s+16)
	end
	if n==0 then
		mset(t[1],t[2],72)
		make_dmaps()
	end
	restiles[idx]=n
	return n
end

function update_unit(u)
 if (u.inert) return
 if u.build and u.build.active then
 	local b=u.build.u
 	if b.const and fps%30==0 then
 		b.const+=1
 		if b.const==b.typ.const then
 			b.const=nil
 		end
 	end
 	--poss another worker finished
 	if not b.const then
 		u.build=nil
 		u.st=st_rest
 	end
 end
 if u.gather then
 	local tile=u.gather.tile
 	if not u.gather.drop then
	 	--if tile is no longer there
	 	--move on to the next one
	 	local f=res2flag(u.gather.res)
	 	if not fget(mget(tile[1],tile[2]),f) then
 			mine_nxt_res(u)
 		elseif fps==u.gather.t then
	 		u.res.qty+=1
	 		local rem=mine_res(tile)
	 		if u.res.qty==9 then
	 			u.gather.drop=true
	 			move(u,p1q.x,p1q.y)
	 			u.follow=p1q
	 		end
	 	end
	 end
 end
 if u.q then
 	if fps%15==u.q.to then
 		u.q.t-=0.5
 		if u.q.t==0 then
 			add(units,
 			 unit(u.q.b.typ,u.x+5,u.y+5,1)
 			)
 			if u.q.qty>1 then
 				u.q.qty-=1
 				u.q.t=u.q.b.t
 			else
 				u.q=nil
 			end
 		end
 	end
 end
 if u.wayp then
 	local wp=u.wayp[1]
 	local xv=wp[1]-u.x
 	local yv=wp[2]-u.y
 	local norm=1/(abs(xv)+abs(yv))
 	local dx=xv*norm
 	local dy=yv*norm
 	dx*=u.typ.spd/3.5
 	dy*=u.typ.spd/3.5
 	
	 u.dir=sgn(dx)
 	u.x+=dx
 	u.y+=dy
			
 	local int=nil
 	
 	if int then
 		--u.x-=dx
 	--	u.y-=dy
 		--recompute wayp
 	elseif adj(u.x,u.y,wp[1],wp[2]) then
 		delete_wp(u)
 	end
 	
 	if u.build then
 		if not u.build.u.const then
 		 u.wayp=nil
 		 u.build=nil
 		 u.st=st_rest
 		elseif intersect(
 			u_rect(u),
 			u_rect(u.build.u)
 		) then
 			u.wayp=nil
 			u.build.active=true
 			u.st=st_build
 		end
 	end
 end
end

function adj(x1,y1,x2,y2)
	return (
	 abs(x1-x2)<2 and abs(y1-y2)<2
	)
end

function delete_wp(u)
	deli(u.wayp,1)
	if #u.wayp==0 then
		u.wayp=nil
		u.st=st_rest
		
		local g=u.gather
		if g then
			local gt=g.tile
			local gr={
				gt[1]*8,gt[2]*8,gt[1]*8+7,gt[2]*8+7
			}
			if intersect(u_rect(u),gr) then
				u.st=st_move
				local s=mget(gt[1],gt[2])
				if (fget(s,2)) typ="r"
				if (fget(s,3)) typ="g"
				if (fget(s,4)) typ="b"
				u.gather.t=fps
				local q=0
				if u.res and u.res.typ==typ then
					q=u.res.qty
				end
				u.res={typ=typ,qty=q}
			end
		end
	end
	local f=u.follow
	if f then
	 if intersect(u_rect(u),u_rect(f)) then
	 	u.follow=nil
	 	u.st=st_rest
	 	u.wayp=nil

			if (
			 u.res and u.p==f.p
			 and f.typ==queen
			) then
				local q=u.res.qty/3
				if u.res.typ=="r" then
					res.r=min(res.r+q,99)
				elseif u.res.typ=="g" then
					res.g=min(res.g+q,99)
				elseif u.res.typ=="b" then
					res.b=min(res.b+q,99)
				end
				u.res=nil
				if u.gather then
					mine_nxt_res(u)
				end
			end
			
		else
		 --recalc the follow
		 move(u,f.x,f.y)
		 if (#u.wayp>1) deli(u.wayp,1)
		 u.follow=f
		end
	end
end

function setwayp(u,wayp)
	u.st=st_move
	u.wayp=wayp
	u.follow=nil
	u.build=nil
end

function move(u,x,y)
	local wayp=get_wayp(u,x,y)
	if u.gather and not u.gather.drop then
		local gt=u.gather.tile
		add(wayp,{8*gt[1]+3,8*gt[2]+3})
	end
	setwayp(u,wayp)
end

-->8
--utils

function intersect(r1,r2)
	local r1_x1=min(r1[1],r1[3])
	local r1_x2=max(r1[1],r1[3])
	local r1_y1=min(r1[2],r1[4])
	local r1_y2=max(r1[2],r1[4])
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

function mag(v1,v2)
  local d = max(abs(v1),abs(v2))
  local n = min(abs(v1),abs(v2)) / d
  return sqrt(n*n + 1) * d
end

function dist(dx,dy)
 local maskx,masky=dx>>31,dy>>31
 local a0,b0=(dx+maskx)^^maskx,(dy+masky)^^masky
 if a0>b0 then
  return a0*0.9609+b0*0.3984
 end
 return b0*0.9609+a0*0.3984
end

function round(n)
 if (n<0) return flr(n-0.5)
 return flr(n+0.5)
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

function mine_nxt_res(u)
	u.st=st_move
	local x,y=flr(u.x/8),flr(u.y/8)
	local res=u.gather.res
	local dmap=dmaps[res]
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
		if (lowest>=n) return
		add(wayp,{x*8+3,y*8+3})
		if (lowest<1) break
	end
	setwayp(u,wayp)
	u.gather={tile={x,y},res=res}
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

function can_build()
	if (
		hoverunit and
		hoverunit.p==1 and
		hoverunit.const
	) then
		return all_ants()
	end
end

function rectaround(u,c)
	local w=u.typ.fw or u.typ.w
	local h=u.typ.h
	rect(
		u.x-flr(w/2)-1,
		u.y-flr(h/2)-1,
		u.x+ceil(w/2)-1,
		u.y+ceil(h/2)-1,
		c
	)
end

function send_build(u,b)
	u.res=nil
	u.gather=nil
	move(u,b.x,b.y)
	u.build={u=b}
end
-->8
--get_wayp


function get_wayp(u,x,y)
 local nodes=find_path(
		{flr(u.x/mvtile),flr(u.y/mvtile)},
		{flr(x/mvtile),flr(y/mvtile)},
		estimate,
		edge_cost,
  neighbors,
  node_to_id,
  nil
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

function edge_cost(n1,n2,g)
	return 1
end

function obstacle(x,y)
	x=flr(x*(mvtile/8))
	y=flr(y*(mvtile/8))
	local t=mget(x,y)
	if (fget(t,0)) return true
	return nil
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
 edge_cost,
 neighbors, 
 node_to_id, 
 graph)
 
 -- the final step in the
 -- current shortest path
 local shortest, 
 -- maps each node to the step
 -- on the best known path to
 -- that node
 best_table = {
  last = start,
  cost_from_start = 0,
  cost_to_goal = estimate(start, goal, graph)
 }, {}

 best_table[node_to_id(start, graph)] = shortest
	--dh
	closest=shortest

 -- array of frontier paths each
 -- represented by their last
 -- step, used as a priority
 -- queue. elements past
 -- frontier_len are ignored
 local frontier, frontier_len, goal_id, max_number = {shortest}, 1, node_to_id(goal, graph), 32767.99

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
  
  if node_to_id(p, graph) == goal_id then
   -- we're done.  generate the
   -- path to the goal by
   -- retracing steps. reuse
   -- 'p' as the path
   p = {goal}

   while shortest.prev do
    shortest = best_table[node_to_id(shortest.prev, graph)]
    add(p, shortest.last)
   end

   -- we've found the shortest path
   return p
  end -- if

  -- consider each neighbor n of
  -- p which is still in the
  -- frontier queue
  for n in all(neighbors(p, graph)) do
   -- find the current-best
   -- known way to n (or
   -- create it, if there isn't
   -- one)
   local id = node_to_id(n, graph)
   local old_best, new_cost_from_start =
    best_table[id],
    shortest.cost_from_start + edge_cost(p, n, graph)
   
   if not old_best then
    -- create an expensive
    -- dummy path step whose
    -- cost_from_start will
    -- immediately be
    -- overwritten
    old_best = {
     last = n,
     cost_from_start = max_number,
     cost_to_goal = estimate(n, goal, graph)
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
  closest = best_table[node_to_id(closest.prev, graph)]
  add(p, closest.last)
 end
 return p
	--dhend
end
-->8
--menu/cursor

function print_cost(costs,x,y)
	if costs.r then
		print(costs.r,x,y,8)
		x+=4
	end
	if costs.g then
		print(costs.g,x,y,11)
		x+=4
	end
	if costs.b then
		print(costs.b,x,y,4)
		x+=4
	end
end

--typ="b/g/r/p"
function draw_resource(typ,val,x,y)
 local sy,c=64,11 --g
	if (typ=="r") sy,c=72,8
 if (typ=="b") sy,c=80,4
 if (typ=="p") sy,c=88,1

	local _x=x
	local w=0
	local s=""..val
	for i=0,#s do
		if i==0 then
			w=typ=="p" and 6 or 4
			rectfill(x-1,y-1,x+w,y+6,7)
 		sspr(72,sy,5,5,x,y)
		elseif s[i]=="1" then
			w=2
  	rectfill(x-1,y-1,x+w,y+6,7)
			line(x,y,x,y+4,c)
		else
			w=4
			rectfill(x-1,y-1,x+w,y+6,7)
			print(s[i],x,y,c)
		end
		x+=w
	end
	return x-_x+2
end

function can_pay(costs)
 return (
 	res.r>=costs.r and
 	res.g>=costs.g and
 	res.b>=costs.b
 )
end

function draw_port(o)
	local
		typ,x,y,hp,onclick,prog,costs=
		o.typ,o.x,o.y,o.hp,o.onclick,
		o.prog,o.costs
		
	local bg=costs and 3 or 1
	pal(14,0)
	if costs and not can_pay(costs) then
		bg=5
		pal({1,1,5,5,5,6,7,13,6,7,7,6,13,6,7,1})
	end
	rect(x,y,x+10,y+9,bg)
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
		button(x,y,10,10,onclick)
	end
	y+=11
	if hp then
		local lw=10
		local hp_bg=prog and 5 or 8
		local hp_fg=prog and 12 or 11
		line(x,y,x+lw,y,hp_bg)
		line(x,y,x+round(lw*hp),y,hp_fg)
	elseif costs then
		print_cost(costs,x,y)
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
 --build cursor
	if (build or can_build()) then
		return 68
	end
	--cursors requiring viz
	if vget(mx,my) then
		if can_gather() then
			return 67 --pick
		elseif (
			hoverunit and
		 hoverunit.p!=1 and
			#selection>0
		) then
			return 65 --sword
		end
	end
	--default
	return 64
end

function xing_tiles(x,y,w,h)
	local tiles={}
	local xx,yy=flr(x/8),flr(y/8)
	for dx=0,ceil(w/8) do
		for dy=0,ceil(h/8) do
			add(tiles,{xx+dx,yy+dy})
		end
	end
	return tiles
end

function buildable()
	local typ=build.typ
	local w,h=typ.w,typ.h
	local xo,yo=flr(w/2),flr(h/2)
 if amy<menuy then
 	local xing=xing_tiles(
 		mx-xo,my-yo,w,h
 	)
 	for t in all(xing) do
 		if fget(mget(t[1],t[2]),0) then
 			return false,xo,yo
 		end
 	end
 	return true,xo,yo
 end
 return false,xo,yo
end

function draw_cursor()
 local mspr=cursor_spr()
	if build then
		local typ=build.typ
 	local w,h=typ.w,typ.h
		local b,xo,yo=buildable()
	 if amy<menuy then
		 local w,h=typ.w,typ.h
 		rectfill(
	 		amx-xo-1,amy-yo-1,
	 		amx+w-xo,amy+h-yo,
	 		b and 3 or 8
	 	)
 	end
 	sspr(typ.x,typ.y,w,h,amx-xo,amy-yo)
	end
 spr(mspr,amx,amy)
	if mspr==66 then --pointer
		pset(amx-1,amy+4,5)
	end
end

buttons={}
function button(x,y,w,h,handle)
	add(buttons,{
		x=x,y=y,w=w,h=h,handle=handle
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
		local hp=u.hp/u.typ.hp
		local onclick=nil
		if #selection>1 then
			onclick=function()
				u.sel=false
				del(selection,u)
			end
		end
		draw_port({
			typ=u.typ,x=x,y=y+1,hp=hp,
			onclick=onclick
		})
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
 
 local sections={35,67,26}
 if sel==1 and selection[1].typ.has_q then
  sections={17,24,61,26}
 end
 if (sel==2) sections={102,26}
 draw_menu_bg(sections)
 
	local y=menuy+2
	if sel==1 then
		local u=selection[1]
		local typ=u.typ
		local hp=u.hp/u.typ.hp
		
		if #selection<3 then
			draw_sel_ports(y)
		else
			draw_port({typ=typ,x=3,y=y+2})
			print("\88"..#selection,15,y+5,7)
		end
		
		if u.res then
			print(u.res.typ.." \88"..u.res.qty,20,y+2,7)
		end
		
		if typ.prod then
			for i=1,#typ.prod do
				local b=typ.prod[i]
				local x=102-i*14
				local yy=y+1
				if (#typ.prod>4) yy-=1
				if i>4 then
					x+=4*14
					yy+=11
				end
				draw_port({
				 typ=b.typ,x=x,y=yy,
				 costs=nil,onclick=
					function()
						if (not can_pay(b)) return
						if b.typ.inert then
							build=b
							return
						end
						if (u.q and u.q.b!=b) return
						res.r-=b.r
						res.g-=b.g
						res.b-=b.b
						if u.q then
							u.q.qty+=1
						else
							u.q={
								b=b, qty=1, t=b.t,
								to=max(fps%15-1,0)
							}
						end
					end
				})
			end
			if u.q then 
				local b=u.q.b
				local qty=u.q.qty
				local x=20
				draw_port({
					typ=b.typ,x=x,y=y,
					hp=u.q.t/b.t,
					prog=true,
					onclick=function()
						res.r+=b.r
						res.g+=b.g
						res.b+=b.b
						if qty==1 then
							u.q=nil
						else
							u.q.qty-=1
						end
					end
				})
				print("\88"..qty,x+13,y+4,7)
			end
		end
	elseif sel==2 then
		draw_sel_ports(y)
	end
	
	--minimap
	draw_minimap()
	
	--resources
	local x=1
	local y=122
	local pop=2
	x+=draw_resource("r",res.r,x,y)
	x+=draw_resource("g",res.g,x,y)
	x+=draw_resource("b",res.b,x,y)
	x-=1
	
	--not (sel==1 and selection[1].typ==ant)
	if true then
		line(x,y-1,x,y+5,5)
		x+=1
		line(x,y-1,x,y+5,7)
		x+=1
		line(x,y-1,x,y+5,7)
		x+=1
		x+=draw_resource("p",res.p-pop,x,y)
		x-=1
	end
	pset(x-1,y-1,5)
	line(0,y-2,x-2,y-2,5)
	line(x,y,x,y+5,5)
end

function draw_menu_bg(secs)
	local mod=1
	if (#secs==3) mod=0
	local x=0
 local y,mh=menuy,menuh
 mh+=3
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
 assert(x==128)
end
-->8
--notes
--[[

perf:
- when no units are on screen
 (bottom right), perplexingly
 cpu skyrockets. should go down
 
- adding more units kills perf,
 need to cut down on unit loops
 (aim to make a single unit pass,
 computing viz,cursor,mvmt,etc)

spider: can build "web", spans
limited length but is just a
white line. spider must station
on the web. takes time to do and
undo web. if any enemy crosses
the web, they are stuck and
spider takes time to eat them.

spider: requires egg to create.
first egg must be found on map.
spider can build "den", which
allows sacrificing a spider
to generate x eggs.

- dbl click to select same units

]]
-->8
r=mapw/8
 
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
			not fget(mget(t[1],t[2]),0)
			and not g(closed,t[1],t[2])
		) then
			s(closed,t[1],t[2],true)
			add(to,{t[1],t[2]})
		end
	end
end

function acc_res(x,y,f)
 if fget(mget(x,y),f) then
 	return not (
 		(x==0 or fget(mget(x-1,y),0)) and
 		(x==r-1 or fget(mget(x+1,y),0)) and
 		(y==0 or fget(mget(x,y-1),0)) and
 		(y==r-1 or fget(mget(x,y+1),0))
 	)
 end
 return false
end

function make_dmaps()
	dmaps={
		r=make_dmap(2),
		g=make_dmap(3),
		b=make_dmap(4),
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
		elseif fget(mget(x,y),0) then
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
			print(n==0 and "-" or n,x*8+2,y*8+2,9)
	 end
	end
end
__gfx__
00000000d00000000000000000000000000000000000000000000000000000000100010000000000000000000000000000000000000000000000000000000000
000000000d000000d000000000000000000000000000000000000000011000000010100000000000110001100000000011000110000000000000000000000000
00700700005111000d000000dd000000000000000000000000000000111100000010100001110000001010000111000000101000000000000000000000000000
00077000005111100051110000511100000000000000000000000000111101110444400011110111044440001111011104444000000000000000000000000000
00077000000111100051111000511110000000000000000000000000110144114424200011014411442420001101441144242000000000000000000000000000
00700700000d1d10000d1d100001d1d0000000000000000000000000000544005044000011054400504400001150440504440000000000000000000000000000
00000000000000000000000000000000000000000000000000000000005050050500500000505005050050000505005050050000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000800008000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000
00000000000008008800088066000000000000000000000000000000000000000000000000000000005b50000000000000000000000000000000000000000000
0000011000118800011000110611661100000000000000000000000000000000000000000000000000b5b0000000000000000000000000000000000000000000
01110001000101110001000100016001000000000000000000000000000000000000000000000000011011000000000000000000000000000000000000000000
00000b0000b000000400004000000000000000000000000000000000000000000000000000000000041114000000000000000000000000000000000000000000
0b00bb000bb004004400044000000000000000000000000000000000000000000000000000000000401110400000000000000000000000000000000000000000
bb000110001144000110001100000000000000000000000000000000000000000000000000000000404040400000000000000000000000000000000000000000
01110001000101110001000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05015105005050500050505000505050005050500505050005050500005050500000000000000000000000000000000000000000000000000000000000000000
05015105050151050501510505051105050511505015150050151050050115050000000000000000000000000000000000000000000000000000000000000000
05005005050151055001510550051105500511505015150050151050050115050000000000000000000000000000000000000000000000000000000000000000
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
0500000055500000005000000055550000005000ffffffffffffffffffffffffffffffff000000000000000000000000ffffffffffffffffffffffffffffffff
5750000057750000057500000577775000057500ffffffffffffffffffaff7ffffffffff000000000000000000000000ffffffffffffffffffffffffffffffff
5775000056775500057555505747550000577750ffffffffffffffffffffffffffffffff000000000000000000000000ffffffffffffffffffffffffffffffff
57775000056540005575757557744000057777506666fff6fffffffff7ffffafffffffff000000000000000000000000ffffffffffffffffffffafffffffffff
5777750000544400757777755754440057777400ccc76666faff7ff6ffffffffffffffff000000000000000000000000ffafffffff7fffffffffffffffffffff
5775500000504450577777755750444005774440ccccccccfffff666ffff7fffffffffff000000000000000000000000ffffffffffffffffffffffffffffffff
0557500000000500055777500500044500550445c77ccc7c7ffff6ccffafffffffffffff000000000000000000000000ffffffffffffffffffffffff7fffffff
0005000000000000000555000000005000000050ccccccc7ffff66ccffffffffffffffff000000000000000000000000ffffffffffffffffffffffffffffffff
fff88fffff5555fffffffffffffffffff66ccc1111111111ffff67ccffffffff00000000000000000000000000000000ffffffffffffffffffffffffffffffff
f887888ff555555ff33fff33fff4f4fff6ccc6111dd11111ffff6cccff77666600000000000000000000000000000000ffffffffffffffffffffffffffffffff
8788787855555555f3bff3bbf44ff44ff7cccc1111dd1111fff76cccf76ccccc00000000000000000000000000000000fffffffffffffff7ffffffffffffffaf
8878878855555555ffbbfbffff4f44fff6c6cc1111111111ff67cc6cf6cccccc00000000000000000000000000000000fffff7ffffffffffffffffffffffffff
fff77fff55555555fffbbbffff44f4fff66ccc1111111dd1666cccccf6cc6cc600000000000000000000000000000000fffffffffffffffffffffaffffffffff
ff7777ff5555555fffffbffff44fff4fff6c6c1111111111c7ccccc1f66ccc6c00000000000000000000000000000000ffffffffffffffffffffffffffffffff
fff77ffff55555ffffffbfffff4f4fffff6cc11111dd1111cccc6cc1ff7ccccc00000000000000000000000000000000ffffffffffffffffffffffffffffffff
fff77ffffff55fffffffbffffffffffff76c611111111111cccccc11ff6c6c1100000000000000000000000000000000fffffffffffffaffffffffffffffffff
fff88fff00000000ffffffffffffffff0000000000000000f66ccc110000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
f887888f00000000fffffffffffff4ff0000000000000000f6ccc6110000000000000000000000000000000000000000fffffffffffffffffffffffff7ffffff
ff8878f800000000f3bff3bfff4ff44f0000000000000000f7cccc110000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
f8788fff00000000fffbfbffff4f44ff0000000000000000f6c6cc110000000000000000000000000000000000000000ffffffffffffffffff7fffffffffffff
fff77fff00000000fffbbbffff44f4ff0000000000000000f66ccc110000000000000000000000000000000000000000fffaffffffffffffffffffffffffffff
ff77ffff00000000ffffbffff44fffff0000000000000000ff6c6c110000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
fff7ffff00000000ffffbfffff4fffff0000000000000000ff6cc1110000000000000000000000000000000000000000fffffffff7ffffffffffffffffffafff
fff77fff00000000ffffbfffffffffff0000000000000000f76c61110000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
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
00000000000000000500000500000050005000000000000000000000000000000000000008000666000000000000000000000000ffffffffff00000000000000
000200022290909250500050500000050500000000000000000000000000000000000000888000060000000000000000000000000ffffffff000000000000000
00002020002999205055555050022225050000000000000000000000000000000000000088800066000000000000000000000000000000000000000000000000
0000404040444400055e5e55002622dddd0000000000000000000000000000000000000006000006000000000000000000000000000000000000000000000000
440464644441410050555550502266d5d50000000000000000000000000000000000000006000666000000000000000000000000000000000000000000000000
444044404504400050500050502222dddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05050405505005000005050000505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000b000000000000000000000000000000000000000000000000000000000000000000004000666000000000000000000000000050000055000000000000000
000b3500000000000000000000000000000000000000000000000000000000000000000044000006000000000000000000000000505000500500000000000000
00b33350000000000000000000000000000000000000000000000000000000000000000004000066000000000000000000000000505555505000000000000000
0b444445000000000000000000000000000000000000000000000000000000000000000004400006000000000000000000000000055353550500000000000000
00411d40000000000000000000000000000000000000000000000000000000000000000004000666000000000000000000000000505555505000000000000000
00411d40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505000505000000000000000
00444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505000000000000000000
00044400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
__gff__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007010b1301010101000000000000000007000b1300000100000000000000000007000b13000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
504d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4e4f4c4d4c4d4e4f4c4d4e4f4c4f4c4d4e4f4c4d4e4f4c4d4e4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c525252525d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5e5f5c5d5c5d5e5f5c5d5e5f5c5f5c5d5e5f5c5d5e5f5c5d5e5f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5252526f6c6d6e6f53536e53536d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6e6f6c6d6c6d6e6f6c6d6e6f6c6f6c6d6e6f6c6d6e6f6c6d6e6f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
525253507c7d7e7f7c7d535353537e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7e7f7c7d7c7d7e7f7c7d7e7f7c7f7c7d7e7f7c7d7e7f7c7d7e7f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5353534f4c4d4e4f4c53535353534e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4f4c4d4e4f4c4d4e4f4c4d4e4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c50535f5c5d5e5f5c53535353535e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5f5c5d5e5f5c5d5e5f5c5d5e5f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6f6c6d6e6f6c6d6e6f6c6d6e6f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7f7c7d7e7f7c7d7e7f7c7d7e7f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4f4c4d4e4f4c4d4e4f4c4d4e4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5f5c5d5e5f5c5d5e5f5c5d5e5f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6f6c6d6e6f6c6d6e6f6c6d6e6f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7f7c7d7e7f7c7d7e7f7c7d7e7f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4e4f4c4d4e4f4c4d4e4f4c4d4e4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5e5f5c5d5e5f5c5d5e5f5c5d5e5f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6e6f6c6d6e6f6c6d6e6f6c6d6e6f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7e7f7c7d7e7f7c7d7e7f7c7d7e7f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4f4c4d4e4f4c4d4e4f4c4d4e4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5f5c5d5e5f5c5d5e5f5c5d5e5f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6f6c6d6e6f6c6d6e6f6c6d6e6f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7f7c7d7e7f7c7d7e7f7c7d7e7f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4c4d4e4f4c4d4e4f4c4d4e4f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5c5d5e5f5c5d5e5f5c5d5e5f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6c6d6e6f6c6d6e6f6c6d6e6f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7c7d7e7f7c7d7e7f7c7d7e7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4c4d4e4f4c4d4e4f4c4d4e4f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5c5d5e5f5c5d5e5f5c5d5e5f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6c6d6e6f6c6d6e6f6c6d6e6f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7c7d7e7f7c7d7e7f7c7d7e7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4d4e4f4c4c4d4e4f4c4d4e4f4c4d4e4f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5d5e5f5c5c5d5e5f5c5d5e5f5c5d5e5f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6d6e6f6c6c6d6e6f6c6d6e6f6c6d6e6f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7d7e7f7c7c7d7e7f7c7d7e7f7c7d7e7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
