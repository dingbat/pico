pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--constants
mapw=256
maph=256
fogtile=8
mvtile=4
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
res={r=12,g=9,b=22}

 --reset every frame
buttons={}
vizmap=nil
hoverunit=nil

function unit(typ,x,y,p)
 return {
		typ=typ,
		x=x,
		y=y,
		st=st_rest,
		dir=1,
		p=p,
		hp=typ.hp
	}
end

function _init()
	--enable mouse & mouse btns
	poke(0x5f2d,0x1|0x2)
	
	units={
		unit(ant,60,65,1),
		unit(spider,48,26,1),
		unit(beetle,40,36,1),
		unit(beetle,60,76,2),
		unit(queen,55,43,1),
		unit(tower,100,100,1)
	}
end

function _draw()
 cls()
 
 draw_map()
 
	foreach(units,draw_unit)
	
	draw_fow()

	--selection box
	if selbox then
		fillp(▒)
		rect(selbox[1],selbox[2],selbox[3],selbox[4],7)
		fillp(0)
	end
	
	camera(0,0)
	
	--menu
	draw_menu()
	
	--mouse
	draw_cursor()
end

function _update()
	fps+=1
	if fps==60 then
		fps=0
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
	port=144,
	fps=1,
	name="ant",

	spd=1,
	los=20,
	hp=10
}
beetle={
	w=7,
	fw=8,
	h=6,
	x=8,
	y=0,
	anim_fr=2,
	fps=3,
	name="beetl",
	port=150,

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
 name="spdr",
 port=148,

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
	name="queen",
	port=146,

	build={
		{typ=ant,t=6,r=2,g=3,b=1}
	},

	spd=0.5,
	los=18,
 hp=25
}

st_rest=1
st_move=2

obj_shr=1
obj_wat=2
obj_pla=3

tower={
	w=7,
	fw=8,
	h=13,
	x=88,
	y=16,
	inert=true,
	los=30,
	hp=50,
	dir=-1,
	restfr=3
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
				move_selected_units(x,y)
			elseif btnp(5) then
				--move camera
				cx=mid(0,x-xoff,mapw-128)
				cy=mid(0,y-yoff,maph-128+menuh)
			end
		end
	 return
	end

	--left click clears selection
 if (btnp(5)) then
 	selection={}
 end
 
 --left drag makes selection
 if (btn(5)) then
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
	
 --right click moves selection
 if (btnp(4)) then
 	move_selected_units(mx,my)
 end
end

function move_selected_units(x,y)
	for u in all(selection) do
		if not u.typ.inert then
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

function surrounding_tiles(x,y,n)
	local st={}
	for dx=-n,n do
	 for dy=-n,n do
	 	local v=(
	 		dx<2 and dx>-2 and
	 		dy<2 and dy>-2)
		 add(st,{x+dx,y+dy,v})
		end
	end
	return st
end

function tick_unit(u)
	update_unit(u)
	
	if u.p==1 then
		update_viz(u)
		
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
		x,y,ceil(u.typ.los/fogtile)
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
	 	if (fget(t,2)) col=8
	 	if (fget(t,3)) col=11
	 	if (fget(t,4)) col=4
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
	end
	if u.obj==obj_shr then
		x+=12
	elseif u.obj==obj_pla then
		y+=4
	elseif u.obj==obj_wat then
		y+=4
		x+=12
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


function update_unit(u)
 if (u.inert) return
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
 	local dx=0
 	local dy=0
 	if abs(xv)>abs(yv) then
 		dx=sgn(xv)
 		dy=abs(yv/xv)*sgn(yv)
 	else
 		dy=sgn(yv)
 		dx=abs(xv/yv)*sgn(xv)
 	end
 	dx/=(6/u.typ.spd)
 	dy/=(6/u.typ.spd)
 	
	 u.dir=sgn(dx)
 	u.x+=dx
 	u.y+=dy
 	mvmt=true
 	
 	local int=nil
 	--[[
 	for i=1,#units do
 	 if u!=units[i] then
	 		local u2=u_rect(units[i])
	 		if intersect(u2,u_rect(u)) then
	 			int=u2
	 			break
	 		end
	 	end
 	end
 	--]]
 	
 	if int then
 		u.x-=dx
 		u.y-=dy
 		--recompute wayp
 	elseif (
 	 abs(u.x-wp[1])<2 and
 	 abs(u.y-wp[2])<2
 	) then
 		delete_wp(u)
 	end
 end
end

function delete_wp(u)
	deli(u.wayp,1)
	if #u.wayp==0 then
		u.wayp=nil
		u.st=st_rest
	end
end

function move(u,x,y)
	u.wayp=get_wayp(u,x,y)
	if u.wayp then
		u.st=st_move
	end
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

function neighbor(ns,x,y)
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
	neighbor(ns,n[1]-1,n[2])
	neighbor(ns,n[1]  ,n[2]-1)
	neighbor(ns,n[1]  ,n[2]+1)
	neighbor(ns,n[1]+1,n[2])
	
	if false then
	neighbor(ns,n[1]-1,n[2]+1)
	neighbor(ns,n[1]+1,n[2]-1)
	neighbor(ns,n[1]+1,n[2]+1)
	neighbor(ns,n[1]-1,n[2]-1)
	end
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

--typ="b/g/r"
function draw_resource(typ,val,x,y)
 local sy,c=64,11 --g
	if (typ=="r") sy,c=72,8
 if (typ=="b") sy,c=80,4

	local _x=x
	local w=0
	local s=""..val
	for i=0,#s do
		if i==0 then
			w=4
			rectfill(x,y-1,x+w,y+6,7)
 		sspr(72,sy,3,5,x,y)
		elseif s[i]=="1" then
			w=2
  	rectfill(x,y-1,x+w,y+6,7)
			line(x,y,x,y+4,c)
		else
			w=4
			rectfill(x,y-1,x+w,y+6,7)
			print(s[i],x,y,c)
		end
		x+=w
	end
	return x-_x+1
end

function draw_port(o)
	local
		typ,x,y,hp,onclick,prog,costs=
		o.typ,o.x,o.y,o.hp,o.onclick,
		o.prog,o.costs
	pal(3,0)
	--use gray port if no resources
	spr(typ.port,x,y,2,2)
	pal(3,3)
	if onclick then
		button(x,y,12,12,onclick)
	end
	y+=12
	if hp then
		local lw=12
		local hp_bg=prog and 5 or 8
		local hp_fg=prog and 12 or 11
		line(x,y,x+lw,y,hp_bg)
		line(x,y,x+round(lw*hp),y,hp_fg)
	elseif costs then
		print_cost(costs,x-1,y)
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
	--cursors requiring viz
	if vget(mx,my) then
		--sword
		if (
			hoverunit and
		 hoverunit.p!=1 and
			#selection>0
		) then
			return 65
		end
		--pick (resource)
		if fget(mget(mx/8,my/8),1) then
			local all_ant=true
			for u in all(selection) do
				if u.typ!=ant then
					all_ant=false
					break
				end
			end
			if (all_ant and #selection>0) return 67
		end
	end
	--default
	return 64
end

function draw_cursor()
 local mspr=cursor_spr()
	local x=flr(mx/mvtile)
	local y=flr(my/mvtile)
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

function draw_menu()
 local sections={17,24,61,26}
 draw_menu_bg(sections)
 
	local y=menuy+2
	if #selection==1 then
		local u=selection[1]
		local typ=u.typ
				
		draw_port({
		 typ=typ,x=1,y=y,
		 hp=u.hp/u.typ.hp
		})
		
		if typ.build then
			for i=1,#typ.build do
				local b=typ.build[i]
				local x=95-i*13
				draw_port({
				 typ=b.typ,x=x,y=y,
				 costs=b,onclick=
					function()
						if res.r<b.r or res.g<b.g or res.b<b.b then
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
	elseif #selection>0 then
		for i=0,#selection-1 do
			local u=selection[i+1]
			local x=3+i*13
			draw_port({
				typ=u.typ,x=x,y=y,hp=0.5,
				onclick=function()
					u.sel=false
				end
			})
		end
	end
	
	--minimap
	draw_minimap()
	
	--resources
	local x=1
	local y=122
	x+=draw_resource("r",res.r,x,y)
	x+=draw_resource("g",res.g,x,y)
	x+=draw_resource("b",res.b,x,y)
	line(0,y-1,0,y+5,7)
	pset(x-1,y-1,5)
	line(0,y-2,x-2,y-2,5)
	line(x,y,x,y+5,5)
end

function draw_menu_bg(secs)
	local x=0
 local y,mh=menuy,menuh
 mh+=3
 for i=1,#secs do
 	local c=i%2==1 and 15 or 4
 	local sp=i%2==1 and 129 or 128
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
__gfx__
00000000d00000000000000000000000004444000000000000000000000000000100010000000000000000000000000000000000000000000000000000000000
000000000d000000d000000000000000044114400000000000000000011000000010100000000000110001100000000011000110000000000000000000000000
00700700005111000d000000dd000000441111440000000000000000111100000010100001110000001010000111000000101000000000000000000000000000
00077000005111100051110000511100411551140000000000000000111101110444400011110111044440001111011104444000000000000000000000000000
00077000000111100051111000511110441551440000000000000000110144114424200011014411442420001101441144242000000000000000000000000000
00700700000d1d10000d1d100001d1d0044114400000000000000000000544005044000011054400504400001150440504440000000000000000000000000000
00000000000000000000000000000000000000000000000000000000005050050500500000505005050050000505005050050000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000800008000006000060000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000
00000000000008008800088060000600006000000000000000000000000000000000000000000000005b50000000000000000000000000000000000000000000
0000011000118800011000110600011000110000000000000000000000000000000000000000000000b5b0000000000000000000000000000000000000000000
01110001000101110001000101110001000100000000000000000000000000000000000000000000011011000000000000000000000000000000000000000000
00000b0000b000000c0000c000000000000000000000000000000000000000000000000000000000041114000000000000000000000000000000000000000000
0b00bb000bb00c00cc000cc000000000000000000000000000000000000000000000000000000000401110400000000000000000000000000000000000000000
bb0001100011cc000110001100000000000000000000000000000000000000000000000000000000404040400000000000000000000000000000000000000000
01110001000101110001000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0050505000000000000000000000000000000000000000000000000000000000007777000000000000000000000b0000000b0060000b00000000000000000000
050151050050505000505050005050500050505005050500050505000050505007711770000000000000000000b3560000b3500000b350000000000000000000
05015105050151050501510505051105050511505015150050151050050115057711117700000000000000000b3335000b3335000b3335000000000000000000
0500500505015105500151055005110550051150501515005015105005011505711661170000000000000000b4444450b4444450b44444500000000000000000
00000000000000000000000000000000000000000000000000000000000000007716617700000000000000000411d4000411d4000411d4000000000000000000
00000000000000000000000000000000000000000000000000000000000000000771177000000000000000000411d4000411d4000411d4000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444440004444400044444000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000411d4000411d4000411d4000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444440004444400044444000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041400000414000004140000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044400000444000004440000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041400000414000004140000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044455000444550004445500000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05000000555000000050000000555500ffffffffffffffffffffffffffffffff00000000000000000000000000000000ffffffffffffffffffffffffffffffff
57500000577500000575000005777750ff776666ffffffffffffffffffaff7ff00000000000000000000000000000000ffffffffffffffffffffffffffffffff
57750000567755000575555057475500f76cccccffffffffffffffffffffffff00000000000000000000000000000000ffffffffffffffffffffffffffffffff
57775000056540005575757557744000f6cccccc6666fff6fffffffff7ffffaf00000000000000000000000000000000ffffffffffffffffffffafffffffffff
57777500005444007577777557544400f6cc6cc6ccc76666faff7ff6ffffffff00000000000000000000000000000000ffafffffff7fffffffffffffffffffff
57755000005044505777777557504440f66ccc6cccccccccfffff666ffff7fff00000000000000000000000000000000ffffffffffffffffffffffffffffffff
05575000000005000557775005000445ff7cccccc77ccc7c7ffff6ccffafffff00000000000000000000000000000000ffffffffffffffffffffffff7fffffff
00050000000000000005550000000050ff6c6c11ccccccc7ffff66ccffffffff00000000000000000000000000000000ffffffffffffffffffffffffffffffff
fff88fffff5555fffffffffffffffffff66ccc1111111111ffff67cc0000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
f887888ff555555ff33fff33fff4f4fff6ccc6111dd11111ffff6ccc0000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
8788787855555555f3bff3bbf44ff44ff7cccc1111dd1111fff76ccc0000000000000000000000000000000000000000fffffffffffffff7ffffffffffffffaf
8878878855555555ffbbfbffff4f44fff6c6cc1111111111ff67cc6c0000000000000000000000000000000000000000fffff7ffffffffffffffffffffffffff
fff77fff55555555fffbbbffff44f4fff66ccc1111111dd1666ccccc0000000000000000000000000000000000000000fffffffffffffffffffffaffffffffff
ff7777ff5555555fffffbffff44fff4fff6c6c1111111111c7ccccc10000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
fff77ffff55555ffffffbfffff4f4fffff6cc11111dd1111cccc6cc10000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
fff77ffffff55fffffffbffffffffffff76c611111111111cccccc110000000000000000000000000000000000000000fffffffffffffaffffffffffffffffff
000000000000000000000000000000000000000000000000f66ccc110000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
000000000000000000000000000000000000000000000000f6ccc6110000000000000000000000000000000000000000fffffffffffffffffffffffff7ffffff
000000000000000000000000000000000000000000000000f7cccc110000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
000000000000000000000000000000000000000000000000f6c6cc110000000000000000000000000000000000000000ffffffffffffffffff7fffffffffffff
000000000000000000000000000000000000000000000000f66ccc110000000000000000000000000000000000000000fffaffffffffffffffffffffffffffff
000000000000000000000000000000000000000000000000ff6c6c110000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
000000000000000000000000000000000000000000000000ff6cc1110000000000000000000000000000000000000000fffffffff7ffffffffffffffffffafff
000000000000000000000000000000000000000000000000f76c61110000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffffffffffffaffffffffff7fffffff
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f7ffffffffffffffffffffffffffffff
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff
0000000000000000000000000000000000000000000000000000000000000000000000000bb006660000000000000000000000000ffffffff000000000000000
007777000077770000000000000000000000000000000000000000000000000000000000bbb00006000000000000000000000000ffffffffff00000000000000
0744447007ffff7000000000000000000000000000000000000000000000000000000000bb000066000000000000000000000000fff29f9f9f00000000000000
744444477ffffff7000000000000000000000000000000000000000000000000000000000b000006000000000000000000000000ffff29992f00000000000000
44444444ffffffff000000000000000000000000000000000000000000000000000000000b000666000000000000000000000000444f4444ff00000000000000
44444444ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444141ff00000000000000
44444444ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004f5f444fff00000000000000
44444444ffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f5f5fff5ff00000000000000
00000000000000000000000000000000000000000000000000000000000000000000000008000666000000000000000000000000ffffffffff00000000000000
000000000000000000000000000000000000000000000000000005000500000000000000888000060000000000000000000000000ffffffff000000000000000
00002000200000000000000000000000050000055000000000000050500000000000000088800066000000000000000000000000000000000000000000000000
00000202000000000990000229090920505000500500000000222250500000000000000006000006000000000000000000000000000000000000000000000000
00000404000000009999000002999200505555505000000002622dddd00000000000000006000666000000000000000000000000000000000000000000000000
44404646400000009999099904444000055353550500000002266d5d500000000000000000000000000000000000000000000000000000000000000000000000
44440444000000009909449944141000505555505000000002222dddd00000000000000000000000000000000000000000000000000000000000000000000000
50505040500000000005440050440000505000505000000005050505000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000050500505005000000505000000000000000000000000000000000004000666000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044000006000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000004000066000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000004400006000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000004000666000000000000000000000000000000000000000000000000
__gff__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000007010b130101010000000000000000000000000000000100000000000000000000000000000000000000000000000000
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
