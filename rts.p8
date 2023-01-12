pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
--age of ants
--eeooty (dan h)

music(0,2000)

function draw_map(o,y)
	camera(cx%8,cy%8)
	map(cx/8+o,cy/8,0,0,17,y)
end

function _update()
	lclk,rclk,llclk,lrclk=
		llclk and not btn"5",
		lrclk and not btn"4",
		btn"5",btn"4"

	if menu then
		pspl"1,5,3,13,13,13,6,2,6,5,13,13,13,0,5"
		cx+=cvx
		cy+=cvy
		if (cx%256==0) cvx*=-1
		if (cy%127==0) cvy*=-1
		if btnp()<4 then
			ai_diff-=btnp()
			ai_diff%=3
		end
		if lclk then
			new_game()
			tostr[[[[]]
			if (ai_debug)_update=_update60
			--]]
		else
			return
		end
	end

	local total=res1.p+res2.p
	upcycle=total>=100 and 30 or
		total>=75 and 15 or
		total>=40 and 10 or 5

	fps+=1
	fps%=60

	input()
	if to_build then
		to_build.x,to_build.y=
			mx8*8,my8*8
	end

	upc,pos,hbld,t6,
		hoverunit,idle,idle_mil=
		fps%upcycle,{},
		g(bldgs,mx8,my8),
		t()%6<1

	dmap()

	--update minimap
	if fps%30==19 then
		for tx=0,mmw do
		for ty=0,mmh do
			local x,y=tx*mmwratio\8,
				ty*mmhratio\8
			sset(109+tx,72+ty,
				g(exp,x,y) and rescol[
					g(viz,x,y,"e")..
					fget(mget(x,y))
				] or 14)
		end
		end
	end

	if loser then
		poke"24365" --no mouse
		if lclk then
			menu,cx,cy=unspl"63,5,35"
			music"63"
		end
		if rclk then
			hbanner=not hbanner
		end
		return
	end

	res1.t+=0x.0888

	if upc==0 then
		viz,new_viz=new_viz,{}
		for k in next,exp do
			local x,y=k&0x00ff,k\256
			mset(x+mapw8,y,viz[k] and
				0 or mget(x,y))
		end
	end

	foreach(proj,function(p)
		p.x,p.y,_,d=norm(p.to,p,.8)
		if d<0.5 then
			if int(
				del(proj,p).to_unit.r,
				{p.x,p.y,p.x,p.y},0
			) then
				dmg(p.from_typ,p.to_unit)
			end
		end
	end)

	if selx then
		bldg_sel,hu_sel,enemy_sel=nil
	end

	foreach(units,tick)

	if selx then
		selection=hu_sel or
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

	if (upc==0) ai_frame()
end

function _draw()
	draw_map(0,17)
	if menu then
		camera()

		local x=64+t()\0.5%2*16
		pspl"0,5,0,0,0,0,0,0,0,0,0,0,0,0,0"
		sspr(x,unspl"0,16,8,25,28,32,16")
		sspr(x,unspl"0,16,8,74,28,32,16,1")
		pspl"1,0,3,4,4,6,7,8,9,10,11,12,13,14,15"
		sspr(x,unspl"0,16,8,25,27,32,16")
		pspl"2"
		sspr(x,unspl"0,16,8,74,27,32,16,1")

		?"\^j5c\-j\f0\^w\^tage of ants\^j5c\|f\-i\f7age of ants\^-w\^-t\^jcj\-h\f0◀\-z\-p▶\^jcj\|f\f6\-h◀\-z\-p▶\^jag\|h\f0ai difficulty:\^jag\fcai difficulty:\^j8n\|h\f0press ❎ to start\^j8n\f9press ❎ to start\^j2t\|h\f0EEOOTY\^j2t\f6EEOOTY\^jqt\f0V1.0\-0\|f\f6V1.0\^jej\-j\0"
		?split"\f0easy\-0\|f\fbeasy,\f0\-cnormal\-0\-8\|f\fanormal,\f0hard\-0\|f\fehard"[ai_diff+1]
		return
	end

	local bf,af,proj_so={},{},
		fps\5%2*2
	foreach(units,function(u)
		if u.onscr or loser then
			if
				not loser and
				not g(viz,u.x8,u.y8)
				and u.disc
			then
				add(af,u)
			elseif u.typ.bldg then
				draw_unit(u)
			else
				add(bf,u)
			end
		end
	end)

	foreach(bf,draw_unit)
	camera(cx,cy)
	foreach(proj,function(_ENV)
		sspr(
			from_typ.proj_s+proj_so,
			112,2,2,x,y
		)
	end)
	if loser then
		resbar()
		if (hbanner) return
		local secs=res1.t\1%60
		camera()
		rectfill(unspl"0,88,128,107,9")
		unl"6,87,44,87"
		unl"86,87,125,87"
		unl"25,108,105,108"
		line(
			?split"\^j2l\|e\#9\f5 easy ai ,\^j2l\|e\#9\f2 normal ai \|m\^x1 ,\^j2l\|e\#9\f0 hard ai "[res2.diff]
			-3,unspl"80,8,80,9")
		line(
			?"\^jml\#9\|c\|i \|e\f5\^:000e040e1915110e\-h\|i"..(res1.t<600 and "0" or "")..(res1.t\60)..(secs<10 and ":0" or ":")..secs.." "
			-2,unspl"80,88,80,9")
		pspl"1,0"
		sspr(64+
			pack(48,fps\5%3*16)[loser],
			unspl"0,16,8,14,90,32,16")
		?"\^j7r\|i\^y7\#9\|f\-f\f4\^x1\|f \|h\^x4 press ❎ for menu \|f\^x1 \^jen\|h\0"
		?split"\^w\^t\fadefeat\-d\^x2...\^x4\-0\-0\-0\-7\|f\f1defeat\-d\^x2...,\^w\^t\favictory!\-0\-0\-0\-0\|f\f1victory!"[loser]
		return
	end

	pspl"0,5,13,13,13,13,6,2,6,6,13,13,13,0,5"
	if not ai_debug then
	draw_map(mapw8,15) --fog
	end

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
			camera(cx-x*8,cy-y*8)
			if (arr[i-1]) unl"-1,0,-1,7"
			if (arr[i-256]) unl"0,-1,7,-1"
			if (arr[i+256]) unl"0,8,7,8"
			if (arr[i+1]) unl"8,0,8,7"
		end
		if not exp[i] then
			brd(exp)
		elseif not viz[i] then
			brd(viz,
				fget(mget(x,y),7) or 5)
		end
	end
	end

	camera(cx,cy)

	if (selx) rect(unpack(selbox))

	fillp()

	if sel1 and sel1.rx then
		spr(65+fps\5%3,
			sel1.rx-2,sel1.ry-5)
	end

	if hlv then
		local dt=t()-hlt
		if dt>0.5 then
			hlv=nil
		elseif hlv.cx then
			circ(hlv.cx,hlv.cy,
				min(0.5/dt,4),8)
		elseif mid(dt,0.1,0.25)!=dt
			and hlv.r then
			local w,x,y,z=unpack(hlv.r)
			rect(w-1,x-1,y,z,8)
		end
	end

	draw_menu()
	camera()
	pal() --allow pink for alert
	if (hlv) circ(unpack(hlv))
	if to_build then
		camera(cx-to_build.x,
			cy-to_build.y)
		pspl(buildable() or
		"8,8,8,8,8,8,8,8,8,8,8,8,8,8,8"
		)
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

	camera(-amx,-amy)
	spr(
		hovbtn and pset(unspl"-1,4,5")
			and 188 or
		sel1 and sel1.hu and
		((to_build or
			can_build() or
			can_renew(1)) and 190 or
		can_gather() and 189 or
		can_attack() and 187 or
		can_drop() and 191) or 186)
end
-->8
--units

function parse(str,typ,tech,t)
	local p1,p2={},{}
	local obj={p1,p2,p2,
		p1=p1,
		typ=typ,
		tech=tech,
		techt=t or {},
		prod={}}
	foreach(split(str,"\n"),function(l)
		local k,v=unspl(l,"=")
		if v then
			obj[k],p1[k],p2[k]=v,v,v
		end
	end)
	add(obj.idx and typs,obj)
	return obj
end

function init_typs()
ant=parse[[
idx=1
spd=0.286
los=20
hp=6
atk=0.2
def=ant
atk_typ=ant
gr=3

w=4
fw=4
h=4
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
farm_x=32
farm_y=8
farm_fr=2
farm_fps=15
attack_x=40
attack_y=12
attack_fr=4
attack_fps=3.75
dead_x=32
dead_y=12
portx=0
porty=72
dir=1
unit=2
carry=6
ant=1
tmap=-1]]

beetle=parse[[
idx=2
spd=0.19
los=20
hp=20
atk=0.75
def=seige
atk_typ=seige
seige=1

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
portx=27
porty=72
unit=1
dir=1
tmap=-1]]

spider=parse[[
idx=3
spd=0.482
los=30
hp=15
atk=1.667
def=spd
atk_typ=spd

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
portx=18
porty=72
unit=1
dir=1
tmap=-1]]

archer=parse[[
idx=4
spd=0.343
los=33
hp=5
range=28
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
portx=45
porty=72
unit=1
dir=1
proj_xo=-2
proj_yo=0
proj_s=28
tmap=-1]]

warant=parse[[
idx=5
spd=0.33
los=25
hp=10
atk=1
def=ant
atk_typ=ant

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
portx=36
porty=72
unit=1
dir=1
tmap=-1]]

cat=parse[[
idx=6
spd=0.2
los=50
hp=15
range=50
atk=1.5
proj_freq=60
def=seige
atk_typ=seige
seige=1

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
move_fps=7.5
attack_x=64
attack_y=8
attack_fr=4
attack_fps=15
dead_x=112
dead_y=16
portx=54
porty=72
unit=1
dir=1
proj_xo=1
proj_yo=-4
proj_s=32
cat=1
tmap=-1]]

queen=parse[[
idx=7
los=25
hp=400
atk=1.5
range=23
proj_freq=30
atk_typ=acid
def=queen

w=16
h=8
h8=1
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
portx=9
porty=72
drop=0
bldg=1
proj_xo=-4
proj_yo=2
proj_s=28
breq=0
units=1
queen=1
tmap=-1]]

tower=parse[[
idx=8
los=30
hp=352
const=32
hpr=11
range=30
atk=1.2
proj_freq=30
atk_typ=bld
def=bld

w=8
w8=1
fw=8
h=16
fh=16
rest_x=40
rest_y=96
attack_x=40
attack_y=96
fire=1
dead_x=64
dead_y=96
dead_fr=8
dead_fps=7.5
portx=-1
porty=80
bldg=1
dir=-1
proj_yo=-2
proj_xo=-1
proj_s=24
breq=1
tmap=-1]]

mound=parse[[
idx=9
los=5
hp=100
const=10
hpr=10
def=bld

w=8
fw=8
h=8
fh=8
w8=1
h8=1
rest_x=16
rest_y=96
portx=15
porty=80
fire=1
dead_x=64
dead_y=104
dead_fr=8
dead_fps=7.5
bldg=1
dir=-1
drop=5
breq=2
tmap=-1]]

den=parse[[
idx=10
los=10
hp=250
const=25
hpr=10
def=bld

w=8
fw=8
h=8
fh=8
w8=1
h8=1
rest_x=16
rest_y=104
fire=1
dead_x=64
dead_y=104
dead_fr=8
dead_fps=7.5
portx=49
porty=80
bldg=1
dir=-1
breq=4
units=2
mil=1
tmap=-1]]

barracks=parse[[
idx=11
los=10
hp=200
const=20
hpr=10
def=bld

w=8
fw=8
h=8
fh=8
w8=1
h8=1
rest_x=16
rest_y=112
fire=1
dead_x=64
dead_y=104
dead_fr=8
dead_fps=7.5
portx=7
porty=80
bldg=1
dir=-1
breq=8
units=2
mil=1
tmap=-1]]

local farm=parse[[
idx=12
los=1
hp=48
const=8
hpr=8
def=bld
cycles=5
gr=0.5

w=8
fw=8
h=8
fh=8
w8=1
h8=1
rest_x=16
rest_y=120
fire=1
dead_x=64
dead_y=104
dead_fr=8
dead_fps=7.5
portx=0
porty=88
farm=1
carry=9
bldg=farm
dir=-1
breq=16
tmap=-1]]

castle=parse[[
idx=13
los=45
hp=640
const=80
hpr=8
range=40
atk=1.8
proj_freq=15
atk_typ=bld
def=bld

w=15
fw=16
h=16
fh=16
rest_x=112
rest_y=113
attack_x=112
attack_y=113
fire=1
dead_x=64
dead_y=97
dead_fr=4
dead_fps=15
portx=58
porty=80
bldg=1
dir=-1
proj_yo=0
proj_xo=0
proj_s=24
breq=32
units=1
tmap=-1]]

parse[[
idx=14
spd=0.21
los=18
hp=8
atk=0.47
lady=1
def=ant
atk_typ=ant

w=8
fw=8
h=6
rest_x=88
rest_y=16
rest_fr=2
rest_fps=30
move_x=96
move_y=16
move_fr=2
move_fps=10
attack_x=96
attack_y=64
attack_fr=3
attack_fps=10
dead_x=56
dead_y=8
portx=63
porty=72
unit=1
dir=-1
tmap=-1]]

ant.prod={
	parse([[
r=0
g=0
b=6
breq=0]],mound),
	parse([[
r=0
g=3
b=3
breq=2]],farm),
	parse([[
r=0
g=4
b=15
breq=0]],barracks),
	parse([[
r=0
g=4
b=20
breq=8]],den),
	parse([[
r=0
g=5
b=15
breq=0]],tower),
	parse([[
r=0
g=25
b=60
breq=13]],castle),
}

queen.prod={
	parse([[
t=10
r=5
g=0
b=0
p=
breq=0]],ant),
nil,nil,nil,
	parse([[
t=30
r=20
g=0
b=20
breq=0
tmap=1
idx=]],parse[[
portx=31
porty=80]],function(_ENV)
	carry=12
	spd*=1.25
	gr-=0.5
end,ant),
	parse([[
t=20
r=15
g=15
b=0
breq=32
tmap=2
idx=]],parse[[
portx=40
porty=80]],function()
	mound.p1.units=
		add(mound.prod,parse([[
t=8
r=4
g=0
b=0
p=
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
breq=0]],beetle),
	parse([[
t=13
r=8
g=8
b=0
p=
breq=0]],spider),
nil,nil,
	parse([[
t=20
r=0
g=20
b=0
breq=0
tmap=4
up=0
idx=]],parse[[
portx=18
porty=88]],function(_ENV)
	atk*=1.15
	hp*=1.15
end,beetle),
	parse([[
t=30
r=10
g=10
b=0
breq=0
tmap=8
up=0
idx=]],parse[[
portx=9
porty=88]],function(_ENV)
	atk*=1.2
	hp*=1.2
end,spider),
}

mound.prod={
	parse([[
t=8
r=15
g=15
b=10
breq=0
tmap=16
idx=]],parse[[
portx=76
porty=80]],function(_ENV)
		gr*=1.3
		cycles=10
	end,farm),
}

barracks.prod={
	parse([[
t=8
r=6
g=2
b=0
p=
breq=0]],warant),
	parse([[
t=14
r=3
g=0
b=5
p=
breq=0]],archer),
	parse([[
t=10
r=9
g=6
b=0
breq=0
tmap=32
idx=]],parse[[
portx=67
porty=80]],function(_ENV)
	range+=7
	los+=7
end,archer),
nil,
	parse([[
t=18
r=15
g=7
b=0
breq=0
tmap=64
up=0
idx=]],parse[[
portx=36
porty=88]],function(_ENV)
	atk*=1.333
	los=30
	hp*=1.333
end,warant),
	parse([[
t=10
r=15
g=0
b=9
breq=0
tmap=128
up=0
idx=]],parse[[
portx=27
porty=88]],function(_ENV)
	atk*=1.25
	hp*=1.2
end,archer),
}

castle.prod={
	parse([[
t=18
r=2
g=14
b=14
p=
breq=0]],cat),
nil,nil,nil,
	parse([[
t=40
r=20
g=0
b=0
breq=0
tmap=256
idx=]],parse[[
portx=23
porty=80]],function(_ENV)
	qty=0.5
end,heal),
	parse([[
t=10
r=0
g=10
b=20
breq=0
tmap=512
idx=]],parse[[
portx=85
porty=80]],function()
		foreach(typs,function(_ENV)
			if bldg then
				p1.los+=10
				p1.range=p1.los
			end
		end)
	end),
}
end
-->8
--tick

function rest(u)
	u.st=parse[[t=rest
rest=1
agg=1]]
end

function mvg(units,x,y,agg,rest)
	local lowest=999
	foreach(units,function(u)
		if not rest or
			u.st.rest then
			move(u,x,y,agg)
		end
		lowest=min(u.typ.spd,lowest)
	end)
	foreach(units,function(_ENV)
		st.spd=lowest end)
end

function move(u,x,y,agg)
	u.st={
		t="move",
		wayp=get_wayp(u,x,y,0),
		agg=agg,
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
		tx,ty,
		t="gather",
		res=f2res[fget(mget(tx,ty))],
		wayp=wp or
			get_wayp(u,t.x,t.y),
		target=t,
	}
end

function drop(u,nxt_res,dropu)
	if not dropu then
		wayp,x,y=dmap_find(u,"d")
		dropu=not wayp and units[u.p]
	end
	if dropu then
		wayp=get_wayp(u,dropu.x,
			dropu.y)
	end
	u.st={
		t="drop",
		wayp=wayp,
		res=nxt_res,
		target=dropu or
			tile_as_unit(x,y),
	}
end

function attack(u,e)
	if u.typ.atk and e then
		u.st,u.disc,u.res={
			t="attack",
			target=e,
			wayp=get_wayp(u,e.x,e.y),
		},u.typ.bldg and 1
	end
end

function farm(u,f)
	f.farmer,u.st,u.res=u,{
		t="farm",
		wayp=get_wayp(u,
			f.x+rndspl"-3,-2,-1,0,1,2,3",
			f.y+rndspl"-3,-2,-1,0,1,2,3"
		),
		farm=f
	}
end

function tick(u)
	local typ,targ=u.typ,
		u.st.target
	if not u.const then
		u.hp+=typ.hp-u.max_hp
		u.max_hp=typ.hp
	end

	u.onscr,u.upd,x8,y8=
		int(u.r,{cx,cy,cx+128,cy+104},0),
		u.id%upcycle==upc,
		u.x8,u.y8

	if u.hp<=0 and not u.dead then
		del(selection,u)
		u.dead,u.sel,u.farmer=0
		u.st=
			parse"t=dead",
			typ.bldg and reg_bldg(u),
			u.onscr and
			sfx(typ.bldg and 17 or 62)
		if typ.lady then
			s(ladys,x8,y8,u)
			mset(x8,y8,86)
			s(dmap_st.r or {},x8,y8,
				{x8,y8})
			make_dmaps"r"
			u.dead=61
		end
		local _ENV=res[u.p]
		if typ.drop and not u.const then
			pl-=typ.drop
		elseif typ.unit then
			p-=1
		end
	end

	if u.dead then
		if typ.queen then
			loser,selection,hbanner=
				u.p,{}
			music"56"
		end
		u.dead+=1
		update_viz(u)
		del(u.dead==60 and units,u)
		return
	end

	if not u.fire and
		u.hp<u.max_hp and
		fps==0 then
		u.hp+=heal[u.p].qty
	end

	if int(u.r,{mx,my,mx,my},1)
		and (not hoverunit or
			hoverunit.hu
	) then
		hoverunit=u
	end

	if g(viz,x8,y8,u.disc) then
		if selx then
			u.sel=int(u.r,selbox,0)
			if u.sel then
				if not u.hu then
					enemy_sel={u}
				elseif typ.unit then
					hu_sel=hu_sel or {}
					add(hu_sel,u)
				else
					bldg_sel={u}
				end
			end
		end
		sset(
			109+u.x/mmwratio,
			72+u.y/mmhratio,
			u.sel and 9 or u.p
		)
	end

	if (u.const) return
	if targ and targ.dead then
		if u.st.t=="attack" then
			move(u,targ.x,targ.y,true)
		else
			rest(u)
		end
	end

	if u.hu then
		if typ.ant and
			u.st.rest then
			if (u.st.idle) idle=u
			u.st.idle=1
		elseif typ.mil and not u.q then
			idle_mil=u
		end
	end

	update_unit(u)
	update_viz(u)

	if typ.unit and not u.st.wayp then
		local x,y,c=u.x,u.y
		while g(pos,x\4,y\4) and
			not u.st.adj do
			x+=rndspl"-2,-1,0,1,2"
			y+=rndspl"-2,-1,0,1,2"
			c=1
		end
		u.st.wayp,u.st.adj=
			c and {{x,y}},c
		s(pos,x\4,y\4,1)
	end

	if u.upd and u.st.agg and
		typ.atk then
		agg(u)
	end
	if u.st.t=="attack" then
		fight(u)
	end
	
	if typ.lady and u.st.rest and
		t6 then
		wander(u)
	end
end

function update_viz(u)
	if u.hu and u.upd then
		local los=u.typ.los
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

		foreach(v,function(t)
			local k=u.k+t
			if k<maph8<<8 and k>=0 and
				k%256<mapw8 then
				if bldgs[k] then
					bldgs[k].disc=1
				end
				--"v" to index into rescol
				exp[k],new_viz[k]=1,"v"
			end
		end)
	end
end
-->8
--input

function cam()
	local b=btn()
	if (b>32) b>>=8 --allow esdf
	cx,cy,amx,amy=
		mid(0,
			cx+(b&0x2)-(b&0x1)*2,
			mapw-128
		),
		mid(0,
			cy+(b&0x8)/4-(b&0x4)/2,
			maph-(loser and 128 or 107)
		),
		mid(0,stat"32",126),
		mid(-1,stat"33",126)

	mx,my,hovbtn=amx+cx,amy+cy
	mx8,my8=mx\8,my\8
end

function foreachsel(func,...)
	for u in all(selection) do
		func(u,...)
	end
end

function input()
	cam()

	foreach(buttons,function(b)
		if int(b.r,{amx,amy,amx,amy},1) then
			hovbtn=b
		end
	end)

	local cont,htile,axn=
		action==0,
		tile_as_unit(mx8,my8),action

	if lclk and hovbtn then
		hovbtn.fn()
		if (axn==action) action=0
		return
	end

	if lclk and action>0 then
		rclk,action=1,0
	end

	if amy>104 and not selx then
		local dx,dy=amx-mmx,amy-mmy
		if min(dx,dy)>=0 and
			dx<mmw and dy<mmh+1	then
			local x,y=
				mmwratio*dx,mmhratio*dy
			if rclk and sel1 then
				sfx"0"
				foreachsel(move,x,y,axn==1)
				hilite{amx,amy,2,8}
			elseif axn==0 and btn"5" then
				cx,cy=
					mid(0,x-64,mapw-128),
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
			sfx"1"
			local b=unit(
				to_build.typ,
				to_build.x+to_build.typ.w\2,
				to_build.y+to_build.typ.h\2,
				unspl"1,1,1")
			foreachsel(build,b)
			pay(to_build,-1,res1)
			b.cost,to_build,selx=to_build
		end
		return
	end

	if btnp"5" and hoverunit and
		hoverunit.typ.unit and
		t()-selt<0.2 then
		selection,selx={}
		foreach(units,function(u)
			if u.onscr and
				u.typ==hoverunit.typ then
				add(selection,u).sel=true
			end
		end)
		return
	end

	if rclk and sel1 and sel1.hu
	then
		if can_renew() then
			sfx"0"
			hilite(hbld)
			hbld.sproff,
				hbld.cycles,
				hbld.exp=0,0
			pay(renewcost,-1,res1)
			farm(sel1,hbld)

		elseif can_gather() then
			sfx"0"
			hilite(htile)
			if avail_farm() then
				farm(sel1,hoverunit)
			else
				foreachsel(gather,mx8,my8)
			end

		elseif can_build() then
			sfx"0"
			foreachsel(build,hbld)
			hilite(hbld)

		elseif can_attack() then
			sfx"4"
			foreachsel(attack,hoverunit)
			hilite(hoverunit)

		elseif can_drop() then
			sfx"0"
			foreachsel(drop,nil,hoverunit)
			hilite(hoverunit)

		elseif sel1.typ.unit then
			sfx"1"
			mvg(selection,mx,my,axn==1)
			hilite{cx=mx,cy=my}

		elseif sel1.typ.units then
			if fget(mget(mx8,my8),1) then
				hilite(htile)
				sfx"36"
			else
				sfx"3"
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
			selx,sely,selt=mx,my,t()
		end
		if btn"5" and selx then
			selbox={
				min(selx,mx),
				min(sely,my),
				max(selx,mx),
				max(sely,my),
				7 --col
			}
		else
			selx=nil
		end
	end
end
-->8
--unit

function draw_unit(u)
	local typ,st,res_typ=
		u.typ,u.st,
		u.res and u.res.typ or "_"

	local fw,w,h,stt,hpi,ux,uy=
		typ.fw,typ.w,typ.h,
		st.wayp and "move" or st.t,
		u.max_hp/u.hp,unpack(u.r)

	local sx,sy,ufps,fr,f,selc=
		typ[stt.."_x"]+
			resoffx[res_typ]+
			u.sproff\8*8,
		typ[stt.."_y"]+
			resoffy[res_typ],
		typ[stt.."_fps"],
		typ[stt.."_fr"],
		u.dead or fps,
		count(selection,u)==1 and 9

	camera(cx-ux,cy-uy)

	if u.const and not u.dead then
		fillp"23130.5"--▒
		rect(-1,-1,w,h,
			u==sel1 and 9 or 12)
		fillp()
		local p=u.const/typ.const
		line(fw-1,unspl"0,0,0,5")
		line(fw*p,0,14)
		--switch spr after 0.5
		sx-=fw*ceil(p*2)
		if (p<=0.15) return
	elseif ufps then
		sx+=f\ufps%fr*fw
	end
	pal(typ.farm and 5,selc or 5)
	pal{
		selc or u.p,
		u.p,--qn☉
		[14]=0
	}
	sspr(sx,sy,w,h,0,0,w,h,
		not typ.fire and u.dir==typ.dir)
	pal()
	if not u.dead and hpi>=2 then
		if typ.fire then
			spr(247+f/20,1,-3)
		end
		line(w,unspl"-1,0,-1,8")
		line(w\hpi,-1,11)
	end
end

function update_unit(u)
	local st=u.st
	local t,wayp,nxt,targ=
		st.t,st.wayp,st.res,st.target
	if u.q and fps%15==u.q.fps%15 then
		produce(u)
	end
	if (u.typ.farm) update_farm(u)
	if st.active then
		if (st.farm) farmer(u)
		if t=="build" and fps%30==0 then
			buildrepair(u)
		end
		if (t=="gather") mine(u)
	else
		if
			targ and
			int(targ.r,u.r,st.res and -3 or 0)
		then
			u.dir,st.active,st.fps,
				st.wayp=
				sgn(targ.x-u.x),true,fps
			if t=="drop" then
				if u.res then
					res[u.p][u.res.typ]+=u.res.qty/u.typ.gr
				end
				u.res=nil
				if st.farm then
					farm(u,st.farm)
				else
					rest(u)
					u.st.res=nxt
				end
			end
		elseif st.res and not wayp then
			mine_nxt_res(u,st.res)
		end
	end

	if wayp then
	u.x,u.y,u.dir=norm(wayp[1],u,
		st.spd or u.typ.spd)
	local x,y=unpack(wayp[1])
	if dist(x-u_rect(u).x,y-u.y)<0.5 then
		deli(wayp,1)
		if #wayp==0 then
			st.wayp=nil
		end
	end
	elseif t=="move" then
		rest(u)
	elseif t=="farm" then
		st.active=true
	end
end

function update_farm(u)
	local f=u.farmer
	if not f or f.st.farm!=u
		or u.exp then
		u.farmer=nil
		return
	end
	if f.st.active and
		not u.ready and fps==59 then
		u.fres+=u.typ.gr
		u.sproff+=u.typ.gr*2
		u.ready=u.fres>=9
	end
end

function farmer(u)
	local f=u.st.farm
	if not f.farmer then
		rest(u)
	elseif f.ready and fps==0 then
		f.fres-=1
		f.sproff+=1
		collect(u,"r")
		if f.fres<=0 then
			drop(u)
			f.cycles+=1
			f.exp,f.ready=f.hu and
				f.cycles>=f.typ.cycles
			f.sproff=f.exp and
				(sfx"20" or 32) or 0
		end
		u.st.farm=f
	end
end

function agg(u)
	local targ_d,targ=9999
	for e in all(units) do
		local d=dist(e.x-u.x,e.y-u.y)
		if e.p!=u.p and not e.dead and
			viz[e.k] and
			d<=u.typ.los
		then
			if e.typ.bldg then
				d+=u.typ.seige and e.typ.bldg==1 and -999 or 999
			end
			if d<targ_d then
				targ,targ_d=e,d
			end
		end
	end
	attack(u,targ)
end

function fight(u)
	local typ,e,in_range=
		u.typ,u.st.target,
		u.st.active
	local dx=e.x-u.x
	local d=u.upd and dist(dx,e.y-u.y)
	if typ.range then
		if u.upd then
			in_range=d<=typ.range and
				g(viz,e.x8,e.y8)
		end
		if in_range and
			fps%typ.proj_freq==
			max(typ.cat or
				u.id%typ.proj_freq)
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
	in_range=int(u.r,e.r,0)
		if in_range and fps%30==u.id%30 then
			dmg(typ,e)
		end
	end
	u.st.active=in_range
	if in_range then
		u.dir,u.st.wayp=sgn(dx)
	elseif u.upd then
		if typ.los>=d and typ.unit then
			attack(u,e)
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
		b.max_hp+=b.typ.hpr
		b.hp+=b.typ.hpr
		if b.const>=b.typ.const then
			b.const,b.cost=
				u.hu and sfx"26"
			reg_bldg(b)
			if b.typ.drop then
				r.pl+=5
			elseif b.typ.farm then
				farm(u,b)
			end
		end
	elseif b.hp<b.max_hp and
		r.b>=1 then
		b.hp+=1
		r.b-=0.5
	else
		rest(u)
	end
end

function mine(u)
	local r,x,y=u.st.res,unpack(u.st)
	local t=mget(x,y)
	local full=resqty[fget(t)]
	local n=g(restiles,x,y,full)
	if n==0 then
		mine_nxt_res(u,r)
	elseif fps==u.st.fps then
		collect(u,r)
		if t<112 and
			(n==full\3 or n==full\1.25)
		then
			del(units,g(ladys,x,y))
			mset(x,y,t+16)
		elseif n==1 then
			mset(x,y,68) --exhaust
			s(dmap_st[r],x,y)
			s(dmaps[r],x,y)
			make_dmaps(r)
		end
		s(restiles,x,y,n-1)
	end
end

function produce(u)
	local bld=u.q.b
	u.q.t-=0.5
	if u.q.t<=0 then
		if bld.tech then
			res1.techs|=bld.tmap
			bld.tech(bld.techt.p1)
			sfx"33"
			local _ENV=bld
			if up and up<2 then
				up+=1
				r*=1.75
				g*=2
				b*=2
				t*=1.5
				done=nil
			end
		else
			if (u.onscr and u.hu) sfx"19"
			local new=unit(
				bld.typ,u.x,u.y,u.p)
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
			u.q.t=bld.t
		else
			u.q=nil
		end
	end
end

function mine_nxt_res(u,res)
	local wp,x,y=dmap_find(u,res)
	if wp then
		gather(u,x,y,wp)
	elseif u.res then
		drop(u,res)
	end
end

-->8
--utils

function sel_only(unit)
	sfx"1"
	foreachsel(function(u)
		u.sel=hilite(unit)
	end)
	selection,unit.sel={unit},1
end

function g(a,x,y,def)
	return a[x|y<<8] or def
end

function s(a,x,y,v)
	a[x|y<<8]=v
end

function hilite(v)
	hlt,hlv=t(),v
end

function int(r1,r2,e)
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
	k=x8|y8<<8
	return _ENV
end

function can_pay(costs,_ENV)
	return r>=costs.r and
		g>=costs.g and
		b>=costs.b and
		(not costs.p or
			p<min(pl,99))
		and reqs|costs.breq==reqs
end

function pay(costs,dir,_ENV)
	r+=costs.r*dir
	g+=costs.g*dir
	b+=costs.b*dir
	if costs.p then
		p-=dir
	end
end

-- musurca/freds bbs/?tid=36059
function dist(dx,dy)
	local maskx,masky=dx>>31,dy>>31
	local a0,b0=(dx+maskx)^^maskx,
	(dy+masky)^^masky
	return a0>b0 and
		a0*0.9609+b0*0.3984 or
			b0*0.9609+a0*0.3984
end

function surr(x,y,fn,n,ig_acc)
	local n,exist=n or 1
	for dx=-n,n do
	for dy=-n,n do
		local xx,yy=x+dx,y+dy
		if
			min(xx,yy)>=0 and
			xx<mapw8 and yy<maph8 and
			(ig_acc or acc(xx,yy))
		then
			if (dx|dy!=0) exist=true
			if fn then
				fn{
					xx,yy,
					d=dx&dy!=0 and 1.4 or 1,
					k=xx|yy<<8
				}
			end
		end
	end
	end
	return exist
end

function avail_farm()
	local _ENV=hoverunit
	return _ENV and
		typ.farm and
		not exp and
		not farmer and
		not const
end

function can_gather()
	return (fget(mget(mx8,my8),1)
		or avail_farm()) and
		sel_typ==ant1 and
		g(exp,mx8,my8) and
		surr(mx8,my8)
end

function can_attack()
	return (not sel_typ or
		sel_typ.atk) and hoverunit
		and not hoverunit.dead
		and not hoverunit.hu and
		g(viz,mx8,my8,hoverunit.disc)
end

function can_build()
	return hbld and
		hbld.hp<hbld.typ.hp and
		sel_typ==ant1
end

function norm(it,nt,f)
	local xv,yv=
		it[1]-nt.x,it[2]-nt.y
	local d=dist(xv,yv)+0.0001
	return nt.x+xv*f/d,
		nt.y+yv*f/d,
		sgn(xv),
		d
end

--strict incl farms+const
function acc(x,y,strict)
	local b=g(bldgs,x,y)
	return not fget(mget(x,y),0)
		and (not b or not strict and
			(b.const or b.typ.farm))
end

function buildable()
	local x,y,w8,h8=
		to_build.x/8,
		to_build.y/8,
		to_build.typ.w8,
		to_build.typ.h8
	return	acc(x,y,true) and
		(w8 or acc(x+1,y,true)) and
		(h8 or acc(x,y+1,true)) and
		(h8 or w8 or acc(x+1,y+1,true))
end

function reg_bldg(b)
	local typ,x,y=b.typ,b.x8,b.y8
	function reg(xx,yy)
		s(bldgs,xx,yy,
			not b.dead and b)
		if b.dead then
			s(exp,xx,yy,1)
			s(dmap_st.d,xx,yy)
			if typ.fire and y==yy then
				mset(xx,yy,69)
			end
		elseif	typ.drop then
			s(dmap_st.d,xx,yy,{xx,yy})
		end
	end
	reg(x,y,typ.h8 or reg(x,y-1))
	if not typ.w8 then
		reg(x+1,y,
			typ.h8 or reg(x+1,y-1))
	end
	if not b.const and not typ.farm then
		make_dmaps"d"
		res[b.p].reqs|=typ.breq
	end
end

function wander(u)
	move(u,
		u.x+rndspl"-6,-5,-4,-3,3,4,5,6",
		u.y+rndspl"-6,-5,-4,-3,3,4,5,6",
		true)
end

function dmg(from_typ,to)
	to.hp-=from_typ.atk*dmg_mult[from_typ.atk_typ.."_vs_"..to.typ.def]
	if to.typ.unit and (
		to.st.rest or to.st.res) then
		wander(to)
	end
	if to.onscr then
		poke(0x34a8,rnd"32",rnd"32",rnd"32")
		sfx"10"
		alert=t()
	elseif to.hu and t()-alert>10 then
		sfx"34"
		hilite{
			mmx+to.x/mmwratio,
			mmy+to.y/mmhratio,3,14}
		alert=hlt
		hlt+=2.5
	end
end

function collect(u,res)
	if u.res and u.res.typ==res then
		u.res.qty+=1
	else
		u.res=parse("qty=1",res)
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

function can_renew(t)
	if hbld and
		sel_typ==ant1 and
		hbld.exp then
		print_res(renewcost,10,2)
		rect(unspl"8,0,18,8,4")
		return	can_pay(renewcost,res1) or t
	end
end

function unit(t,_x,_y,_p,
	_const,_disc,_hp)
	local _typ,_id,u=
		typs[t] or t,
		rnd"60"\1,
		add(units,
		parse[[dir=1
sproff=0
lastp=1
cycles=0
fres=0]])
	do
		local ptyp,_ENV=_typ[_p],u
		max_hp=tonum(_const) and
			ptyp.hp/ptyp.const or
			ptyp.hp
		typ,x,y,p,hu,hp,const,
			disc,id,prod=
			ptyp,_x,_y,_p,_p==1,
			--cap hp when loading game
			--that had hp upgrades
			min(_hp or 9999,max_hp),
				tonum(_const),_disc==1,
				_id,_typ.prod
	end
	rest(u_rect(u))
	if (_typ.bldg) reg_bldg(u)
	return u
end

function queue_prod(u,b)
	pay(b,-1,res[u.p])
	if u.q then
		u.q.qty+=1
	else
		u.q={b=b,qty=1,t=b.t,fps=fps-1}
	end
end
-->8
--pathfinding

--dmaps

function dmap_find(u,k)
	local x,y,dmap,wayp,lowest=
		u.x8,
		u.y8,
		dmaps[k],
		{},9
	if (not dmap) return
	while lowest>=1 do
		local orig=max(1,g(dmap,x,y,9))
		surr(x,y,function(t)
			local w=(dmap[t.k] or 9)+t.d-1
			if w<lowest then
				lowest,x,y=w,unpack(t)
			end
		end,1,true)
		if (lowest>=orig) return
		add(wayp,{x*8+3,y*8+3})
	end
	return wayp,x,y
end

function make_dmaps(r)
	queue,asc=split(parse[[r=r,g,b,d
g=g,r,b,d
b=b,g,r,d
d=d,r,g,b]][r]),{}
end

function dmap()
	local q=queue[1]
	if q then
		if #q==1 then
		queue[1]=make_dmap(q)
		else
			dmapcc(q)
			if q.c==9 then
				dmaps[q.k]=
					deli(queue,1).dmap
			end
		end
	end
end

function dmapcc(q)
	for i=1,#q.open do
		if (i>20)	return
		local p=deli(q.open)
		q.dmap[p.k]=q.c
		if q.c<8 then
			surr(p[1],p[2],function(t)
				if not q.closed[t.k] then
					q.closed[t.k]=add(q.nxt,t)
				end
			end)
		end
	end
	q.c+=1
	q.open,q.nxt=q.nxt,{}
end

function make_dmap(k)
	if not dmap_st[k] then
		dmap_st[k]={}
		for x=0,mapw8 do
		for y=0,maph8 do
			if
				fget(mget(x,y),key2resf[k])
			then
				s(dmap_st[k],x,y,{x,y})
			end
		end
		end
	end

	local open={}
	for i,t in next,dmap_st[k] do
		if	surr(unpack(t)) then
			add(open,t).k=i
		end
	end

	return {
		k=k,
		dmap={},
		open=open,
		c=0,
		closed={},
		nxt={},
	}
end

--a*

function nearest_acc(x,y,dx,dy)
	for n=0,16 do
		local best_d,best_t=32767
		surr(x\8,y\8,function(t)
			local d=dist(
				t[1]*8+4-dx,
				t[2]*8+4-dy
			)
			if d<best_d then
				best_t,best_d=t,d
			end
		end,n)
		if (best_t) return best_t,n
	end
end

function get_wayp(u,x,y,tol)
	if u.typ.unit then
		local dest,dest_d=
			nearest_acc(x,y,x,y)	
		local wayp,exists=as(
			nearest_acc(u.x,u.y,x,y),
			dest)
		if exists and
			dest_d<=(tol or 1) then
			deli(wayp)
			add(wayp,{x,y})
		end
		return #wayp>0 and wayp
	end
end

--based on a* by morgan3d
function as(start,goal)
	local k=start.k|goal.k>>16
	local c=asc[k] --cache
	if c then
		--{upk} for new table
		return {unpack(c)},c.e
	end

	local sh,best_table,f={
		last=start,
		cfs=0,
		ctg=32767
	},{},{}
	best_table[start.k]=sh
	function path(s)
		while s.last!=start do
			add(f,{s.last[1]*8+4,
				s.last[2]*8+4},1)
			s=best_table[s.prev.k]
		end
		asc[k]=f
		return f
	end
	local fr,fr_len,closest=
		{sh},1,sh
	while fr_len>0 do
		local cost,index_of_min=32767
		for i=1,fr_len do
			local temp=fr[i].cfs+fr[i].ctg
			if (temp<=cost) index_of_min,cost=i,temp
		end
		sh=fr[index_of_min]
		fr[index_of_min],sh.dead=fr[fr_len],true
		fr_len-=1

		local p=sh.last
		if p.k==goal.k then
			f.e=true
			return path(sh),1
		end
		surr(p[1],p[2],function(n)
			local old_best,ncfs=
				best_table[n.k],
				sh.cfs+n.d
			if not old_best then
				old_best={
					last=n,
					cfs=32767,
					ctg=
					dist(n[1]-goal[1],n[2]-goal[2])
				}
				fr_len+=1
				fr[fr_len],best_table[n.k]=old_best,old_best
			end
			if not old_best.dead and old_best.cfs>ncfs then
				old_best.cfs,old_best.prev=ncfs,p
			end
			if old_best.ctg<closest.ctg then
				closest=old_best
			end
		end)
	end
	return path(closest)
end
-->8
--menu

function print_res(r,x,y,zero)
	tostr[[[[]]
	local res1=ai_debug and res2 or res1
	--]]
	local oop=res1.p>=res1.pl
	for i,k in inext,split"r,g,b,p" do
		local newx,v=0,i!=4 and
			min(r[k]\1,99) or zero and
			"\-b \-i"..res1.p..
				"/\^x9 \^-#\^x1.\|h\#5\^x0 \^x4\^-#\|f\-6"..min(res1.pl,99) or
			oop and r[k] or 0
		if zero and i==3 then
			newx=-2
			v..="\-g \-c\^t\|f\f5\^-#|"
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
	typ,x,y,costs,fn,r,bg,fg,u)
	camera(-x,-y)
	local nopay,axnsel=
		costs and not can_pay(costs,res1),
		typ.portf and action>0
	rect(0,0,10,9,
		u and u.p or
		nopay and 6 or
		costs and 3 or
		axnsel and 10 or
		typ.porto or 1
	)
	rectfill(1,1,9,8,
		nopay and 7 or costs and
		costs.tech and 10 or
		axnsel and 9 or
		typ.portf or 6
	)
	pspl(nopay and "5,5,5,5,5,6,6,13,6,6,6,6,13,6,6,5")
	pal(14,0)
	pal(costs or 6,7)
	sspr(typ.portx,typ.porty,
		unspl"9,8,1,1")
	if costs and costs.up then
		spr(costs.up+182,2,1)
	end
	pal()

	add(fn and buttons,{
		r={x,y,x+10,y+8},
		fn=fn,
		costs=costs,
	})

	if fg then
		color(bg)
		unl"10,11,0,11"
		line(10*r,11,fg)
	end
	camera()
end

function sel_ports(x)
	for i,u in inext,selection do
		x+=13
		if i>5 then
			if (numsel>14) x-=4
			camera(-?"\f1+"..numsel-5,x-15,121)
			unspr"133,1,121"
			return
		end
		draw_port(u.typ,x,107,nil,
			numsel>1 and function()
				del(selection,u).sel=false
			end,
			max(u.hp)/u.max_hp,8,11,u)
	end
end

function single()
	local q=sel1.q
	if sel1.cost then
		draw_port(parse[[
portx=72
porty=72
porto=8
portf=9]],24,107,nil,
			function()
				pay(sel1.cost,1,res1)
				sel1.hp=0
			end,sel1.const/sel_typ.const,
			5,12
		)
		return
	end

	if sel1.typ.farm then
		camera(-?sel1.cycles.."/"..sel_typ.cycles,unspl"45,111,4")
		sspr(unspl"48,96,9,9,2,109")
	end
	for i,b in next,sel1.prod do
		if not b.done then
			i-=1
			draw_port(
				b.typ,
				88-i%4*13,
				106+i\4*11,
				b,
				function()
					if can_pay(b,res1) and (
						not q or
						q.b==b and q.qty<9) then
						if b.typ.bldg then
							to_build=b
							return
						end
						sfx"2"
						queue_prod(sel1,b)
						b.done=b.tech
					else
						sfx"16"
					end
				end
			)
		end
	end
	if q then
		local b=q.b
		draw_port(
			b.typ,
			b.tech and 24 or
				?"X"..q.qty,unspl"32,110,7"
				and 20,
			107,nil,
			function()
				b.done=pay(b,1,res1)
				if q.qty==1 then
					sel1.q=nil
				else
					q.qty-=1
				end
				sfx"18"
			end,q.t/b.t,5,12
		)
	end
	if sel1.typ.units then
		draw_port(parse[[
portx=0
porty=32
porto=15
portf=15
]],42,108,nil,axn)
	end
end

function axn()
	action+=1
	action%=sel_typ and
		sel_typ.units and 2 or 3
end

function draw_menu()
	local x=0
	for i,sec in inext,split(
		sel1 and sel1.hu and
		(sel1.typ.bldg and
			"17,24,61,26" or
			"17,17,68,26") or "102,26")
	do
		pspl(i%2!=0 and "1,2,3,15")
		camera(x)
		unspr"129,0,104"
		spr(129,sec-8,104)
		line(sec-4,unspl"105,3,105,7")
		rectfill(sec-4,unspl"106,3,108,4")
		rectfill(sec,unspl"108,0,128")
		x-=sec
		pal()
	end
	camera()

	if numsel==1 then
		sel_ports(-10)
		if (sel1.hu) single()
	elseif sel_typ==ant1 then
		single()
	else
		sel_ports(24)
	end
	if numsel>1 then
		camera(numsel<10 and -2)
		?"X"..numsel,unspl"5,111,1"
		unspr"133,1,111"
		add(buttons,{
			r=split"0,110,14,119",
			fn=function()
				deli(selection).sel=false
			end
		})
	end

	if sel1 and sel1.hu and
		sel1.typ.unit then
		draw_port(
		action==2 and parse[[
portx=99
porty=72
porto=2
portf=13
]] or sel_typ==ant1 and parse[[
portx=81
porty=72
porto=2
portf=13
]] or parse[[
portx=90
porty=72
porto=2
portf=13
]],20,108,nil,axn)
	end
	
	tostr[[[[]]
	if ai_debug then
		?(res1.t\60)..":"..res1.t\1%60,80,122
	end
	--]]

	camera(-mmx,-mmy)

	sspr(idle and 48 or 56,
		unspl"105,8,6,11,14")
	add(buttons,idle and {
		r=split"116,121,125,128",
		fn=function()
			sel_only(idle)
			cx,cy=idle.x-64,idle.y-64
			cam()
		end
	})

	sspr(idle_mil and 24 or 32,
		unspl"114,8,6,0,14")
	add(buttons,idle_mil and {
		r=split"106,121,113,128",
		fn=function()
			sel_only(idle_mil)
		end
	})
	
	--minimap
	pal(14,0)
	sspr(unspl"109,72,19,12,0,0")
	camera(
		-mmx-ceil(cx/mmwratio),
		-mmy-ceil(cy/mmhratio)
	)
	--7=128/mmwratio+1
	rect(unspl"-1,-1,7,7,10")

	resbar()
	
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
end

function resbar()
	camera()
	tostr[[[[]]
	local res1=ai_debug and res2 or res1
	--]]
	camera(-print_res(res1,
		unspl"1,122,2"))
	unl"-4,120,-128,120,5"
	pset(-3,121)
end
-->8
--const

function comp(f,g)
	return function(...)
		return f(g(...))
	end
end

pspl,rndspl,unspl,spldeli=
	comp(pal,split),
	comp(rnd,split),
	comp(unpack,split),
	comp(split,deli)

unl,ununit,unspr,
	reskeys,f2res,resqty,
	key2resf,rescol,
	resoffx,resoffy,renewcost,
	dmg_mult,
	
	ai_diff,action,
	mapw,maph,mmx,mmy,mmw,mmh,
	mapw8,maph8,
	mmhratio,
	mmwratio,
	menu,cx,cy,cvx,cvy
	=
	comp(line,unspl),
	comp(unit,unspl),
	comp(spr,unspl),
	split"r,g,b,p,pl,reqs,tot,boi,diff,techs,t",
parse[[
6=r
7=r
11=g
19=b]],parse[[
6=55
7=45
11=50
19=40]],parse[[
r=2
g=3
b=4
d=d]],parse[[
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
e33=13]],parse[[
_=0
r=16
g=0
b=16]],parse[[
_=0
r=0
g=4
b=4]],parse[[
r=0
g=0
b=6
breq=0]],parse[[
ant_vs_ant=1
ant_vs_queen=0.7
ant_vs_spd=0.8
ant_vs_seige=1.5
ant_vs_bld=0.5

acid_vs_ant=1
acid_vs_queen=0.6
acid_vs_spd=1.5
acid_vs_seige=0.7
acid_vs_bld=0.25

spd_vs_ant=1.5
spd_vs_queen=1.1
spd_vs_spd=1
spd_vs_seige=1
spd_vs_bld=0.1

seige_vs_ant=0.9
seige_vs_queen=3
seige_vs_spd=0.7
seige_vs_seige=1
seige_vs_bld=12

bld_vs_ant=1
bld_vs_queen=0.75
bld_vs_spd=1.25
bld_vs_seige=0.9
bld_vs_bld=0.1]],
	unspl"0,0,384,256,105,107,19,12,48,32,21.333,20.21,63,0,30,1,1"

-->8
--init

function init()
	poke(0x5f2d,3)
	reload()
	music(unspl"0,0,7")
	menuitem(3,"∧ resign",function() units[1].hp=0 end)

	queue,exp,vcache,dmaps,
	units,restiles,selection,ladys,
		proj,bldgs,new_viz,dmap_st,
		typs,heal,
		res,loser,menu=
		{},{},{},{},
		{},{},{},{},
		{},{},{},{d={}},
		{},parse"qty=0",
		parse[[
r=20
g=10
b=20
p=4
pl=10
tot=4
boi=0
reqs=0
diff=0
techs=0
t=0]]

	init_typs()

	ant1,res1,res2,
	cx,cy,fps,selt,alert=
		ant.p1,res.p1,res[2],
		unspl"0,0,59,0,0"
end

function new_game()
	init()
	res2.diff=ai_diff+1
	foreach(split([[7,55,44,1
7,335,188,2
14,65,150,3
14,170,140,3
14,88,245,3
14,250,32,3
14,138,16,3
1,40,40,1
1,68,43,1
1,50,32,1
5,48,56,1
1,320,184,2
1,348,187,2
1,330,196,2
5,320,170,2
8,268,169,2]],"\n"),ununit)
	ai_init()
end
-->8
--ai

tostr[[[[]]
ai_debug=true
if ai_debug then
	_update60=_update
end
--]]

function ai_init()
	bmins,
		defsqd,offsqd,atksqd,
		ant[2].gr=
		1.25,
		{},{},{},
		5-res2.diff

	make_dmaps"d"
end

function ai_frame()
	if (t6) inv=0
	miners,utyps,bants,uhold,adj=
		{},{},0

	foreach(units,ai_unit1)
	bal=#miners\bmins-bants
	foreach(units,ai_unit2)

	if count(utyps,12)>=7 then
		bmins=1.4
	end
	
	for i=0,res2.boi,2 do
		if inv==0 then
			ai_bld(i)
		end
	end
	if #offsqd>=14 and inv==0 then
		atksqd,offsqd=offsqd,{}
	end
	mvg(atksqd,unspl"48,40,1,1")
end

function ai_unit1(u)
	if u.p==2 then
		add(utyps,u.typ.idx)
		if u.typ.ant then
			local r=u.st.res
			if r=="r" then
				--41,24
				if not dmaps.r[6185] then
					drop(u)
				end
			elseif r then
				add(miners,u)
			elseif u.st.rest then
				mine_nxt_res(u,
					bgnxt and "b" or "r")
				bgnxt=not bgnxt
			end
			if r=="b" then
				bants+=1
				if u.st.rest then
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
			end
		--excludes ants
		elseif u.typ.unit==1 then
			if u.dead then
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

function ai_unit2(u)
	if not u.hu then
		local r=bal>0 and "b" or
			bal<0 and "g"
		if u.st.res!=r and r and
			count(miners,u)>0 and
		 not u.res then
			bal=0
			mine_nxt_res(u,r)
		end
		if u.typ.bldg and
			u.hp<u.max_hp*0.75 or
			u.const
		then
			if not u.w then
				u.w=deli(miners)
				if (u.w) build(u.w,u)
			end
		elseif u.typ.farm and
			not u.const and
			not u.farmer then
			local w=deli(miners)
			if (w) farm(w,u)
		elseif u.typ.queen then
			if count(utyps,1)<res2.diff*12 then
				ai_prod(u)
			end
		elseif u.typ.units and
			res2.p<res2.diff*26 then
			ai_prod(u)
		end
		if u.w and
			u.w.st.t!="build" then
			u.w=nil
		end
	elseif u.st.t=="attack" and
		u.st.active and u.x>232 then
		inv=1
		mvg(defsqd,u.x,u.y,1,1)
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
		can_pay(p,res2) then
		queue_prod(u,p)
		u.lastp%=u.typ.units
		u.lastp+=1
		res2.tot+=1
	end
end

function ai_bld(i)
	local off=0x2060+i%32+i\32*128
	local p,pid=peek(off,2)
	local x,y=peek(off+512,2)
	if not g(bldgs,x,y) then
		local b=ant.prod[pid]
		if res2.tot>=p then
			if can_pay(b,res2) then
				pay(b,-1,res2)
				unit(b.typ,
					x*8+b.typ.w/2,
					y*8+b.typ.h/2,
					2,0)
				if res2.boi==i then
					res2.boi+=2
				end
			else
				uhold=b
			end
		end
	end
end
-->8
--save/load

menuitem(1,"⌂ save to clip",function()
	if (menu) return
	local s=""
	foreach(units,function(_ENV)
		s..=
			typ.idx..","..
			x..","..
			y..","..
			p..","..
			(const or "")..","..
			max(disc)..","..
			hp.."/"
	end)
	for i=1,mapw8*maph8-1 do
		s..=
			mget(i%mapw8,i/mapw8)..","
	end
	s..="/"
	for k in next,exp do
		s..=k..","
	end
	s..="/"
	foreach(reskeys,function(r)
		s..=res1[r]..","..res2[r]..","
	end)
	printh(s,"@clip")
	sfx"33"
end)

menuitem(2,"◆ load pasted",function()
	init()
	local data=split(stat"4","/")
	local r=spldeli(data)
	for i,k in inext,reskeys do
		i*=2
		res1[k],res2[k]=r[i-1],r[i]
	end
	foreach(spldeli(data),function(k)
		--k can be "" (trlng ,)
		exp[k]=tonum(k)
	end)
	for i,t in inext,spldeli(data) do
		mset(i%mapw8,i/mapw8,t)
	end
	foreach(typs,function(b)
		if res1.techs|b.tmap==res1.techs then
			b.tech(b.techt.p1)
			b.up,b.done=b.up and 1,
				not b.up
		end
	end)
	foreach(data,ununit)
	ai_init()
end)
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
11000000110001101100880011000110110001100110511081101100008880000000000003300000000000000000000000d00000000000000d00000000000000
00111111001100110011111100110011801108110011001100110011088e8800000000000011500000d00000000000100d000000000000003310000000000000
0b0000000b0000b004000000040000400000000000000000000000000e88e8ee00000000001300000d0000000001131133100000000000003311310000000000
bb000b00bb000bb044000400440004400000000000001100000000000858586e0dd1311331350000331131131131135033113113113113100011311311311310
1100bb00110001101100440011000110000000000110001011101100000000003311311331105000331131131130500000113113113113110505001311311311
00111111001100110011111100110011015500000011000100010011000000003305005050500000050500505050000000505050505050500000005050505050
00000000000000000000000000000000000000000000000000000000000000000050500000000000000505000888800000000000000000000000000000000000
0505050000000000000000000000000000000000000000000000000000000000050151500050505005501510888e880008888000008888000000000000000000
50151050050505000050505000505050005050500505050005050500000000000501515005015105500d15158e88e8ee888e8800088e88800000000000000000
501510505015105005015105050511050505115050151500501150500050500050d0d005050151050000d50588e8887e8e88e8ee08e8e8ee0000000000000000
50050050501510505001510550051105050511505015150050115050051515000000000505dd000500000005888880008888887e0888887e0000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050500050505000050505000000000000000000
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
00000000000000000000000000000000ffffffffffffffffffffffffffffffff1dd11111dd1111dd113331dd11333311ffffffffffffffffffffffffffffffff
00488000004880000048008000400880ffff6fffffff6ffffffffffffffffdff1511151111121211133831111b333b31ffffffffffffffffffffffffffffffff
00488880004888800048888000488880fffffffffffff5ffff2fffffffffd6df11545111115141513bfbfb1133bbbf33ffffffffffffffffffffffffffffffff
00488880004888800048888000488880f6fffffff6f5fffff292fffffffffd3f111411111115451133bbb33333bbbb83ffffffffffffffffffffafffffffffff
00400880004008800040880000488000ffffff6ffffff5fff32fffffffffff3f115451111111411133bbb33333bbbf33ffafffffff7fffffffffffffffffffff
00400000004000000040000000400000ffffffffff5fff6ff3ffffffffafffff151415111115451133bbb3333b333b11ffffffffffffffffffffffffffffffff
00400000014100000141000001410000fff6fffffff6ffffffffafffffffffff11212111115111511b333b3113333111ffffffffffffffffffffffff7fffffff
00000000011100000111000001110000ffffffffffffffffffffffffffffffffdd1111dd11111dd111333311113331ddffffffffffffffffffffffffffffffff
fff88fffffffff8fffffffffffffbbbfffffffffffffffffffffffffffffffffffffffffffffffff1111d111111d1111ffffffffffffffffffffffffffffffff
f887888ff8fff888f33fff33fffbb3bfff444fffffff44fffffffffffffffff6776fff766fffffff1dd1111111111dd1ffffffffffffffffffffffffffffffff
87887878888ff888f3bff3bbffbb3bbfff444ffff4f4444ffffffffffffff7666cc666cc667fffff1111111cc1111111fffffffffffffff7ffffffffffffffaf
88788788888f8fdfffbbfbffffb3bbbff4494fffff44454fffffffffffff67cccccccccccc76ffff1111cccccccc1111fffff7ffffffffffffffffffffffffff
fff77ffffdf888dffffbbbffffbbbbffff544ffff444544fffaffffffff76ccccc6cc6ccccc67fff111cccccccccc111fffffffffffffffffffffaffffffffff
ff7777fffdd888dfffffbffffffbbfffff9444ff499544fffffffffffff6cccc6ccc6ccccccc6fff1d1cccccccccc1d1ffffffffffffffffffffffffffffffff
fff77fffffdfdfdfffffbffffffbffffff5444ff49944fffffffffffff66cccc7cccc11ccccc66ff111ccc6666ccc111ffffffffffffffffffffffffffffffff
fff77fffffffdfffffffbffffffbffffff445ffff444fffffffffffff6c7ccc1111111111ccc7c6f11ccc667766ccc11fffffffffffffaffffffffffffffffff
fff88ffffffffffffffffffffffffbfffffffffffffffffffffffffff66ccc111111111111ccc66f11ccc667766ccc11ffffffffffffffffffffffffffffffff
f887888ff8fff88fffffffffffffb3fffff4fffffffff4fffffffffff6ccc6111dd11111116ccc6f111ccc6666ccc111fffffffffffffffffffffffff7ffffff
ff8878f8f88ff888f3bfff3fffff3bbffff44ffffff4f44fff8184fff7cccc111166111111cccc7f1d1cccccccccc1d1ffffffffffffffffffffffffffffffff
f8788fff888f8fdffffbfbffffb3fbffff494fffff44454ff288558ff6c6cc111111111111cc6c6f111cccccccccc111ffffffffffffffffff7fffffffffffff
fff77ffffdff88dffffbbbffffbbbbffff544fffff4454fff82518fff66ccc1111111dd111ccc66f1111cccccccc1111fffaffffffffffffffffffffffffffff
ff77ffffffd88fdfffffbffffffbbfffff9444fff495ffffff18818fff6c6cc1111111111cc6c6ff1111111cc1111111ffffffffffffffffffffffffffffffff
fff7ffffffdfdfffffffbffffffbfffffff44fff49944fffffffffffff6cccc111dd11111cccc6ff1dd1111111111dd1fffffffff7ffffffffffffffffffafff
fff77fffffffdfffffffbffffffbfffffffffffff444fffffffffffff76c6c111111111111c6c67f1111d111111d1111ffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffff6c7ccc1111111111ccc7c6fffffff5ffffffff5ffffffffffffffffffffffffffffffff
ffff8ffffffff8ffffffffffffffbfffffffffffffffffffffffffffff66ccccc11cccc7cccc66ff6f555fff6f5555ffffffffffffffffffffffffffffffffff
ff88f8fff8ffff8fffffffffffff3bbffff44ffffff4f4fffffffffffff6ccccccc6ccc6cccc6ffff55555f5f533555fffffffffffffffffffffffffffffffff
f8788ffff88fffdffffffbffffb3fbffff494ffffff4444fff81f8fffff76ccccc6cc6ccccc67ffff555565ff535535ffffffffffffffaffffffffff7fffffff
ffff7ffffdff8ffffffbbfffffffbbfffff44fffff4454fff2885f8fffff67cccccccccccc76fffff565555ff555555ff7ffffffffffffffffffffffffffffff
fff7ffffffd88fdfffffbffffffbfffffff45ffff4944fffff28181ffffff766cc666cc6667ffffff566555ff53555f6ffffffffffffffffffffffffffffffff
fff7ffffffdfdfffffffbffffffbfffffff4ffffff4ffffffffffffffffffff667fff6776fffffffff5555f6ff555fffffffffffffffffffffffffffffffffff
fff77fffffffffffffffbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6ffffff6fffff5fffffffffffffffffffffffffffffffff
0000000000000000080000000bb0000004000000101000000000000000000000000000000000000000000000dd000000000000000088800000000000eeeeeeee
000770000077770088800000bbb0000044000000101000000d000000000000000000000000000000dd600000060000000888000008e88ee000888000eeeeeeee
000770000744447088800000bb00000004000000c1c00000600006600d0000000dd0000000000000005100610510001688e88ee0888e87e0088e8800eeeeeeee
0007700074444447060000000b00000004400000c1c000005100016060000660600006600000000005d100665d1000668e8e87e08e8850000888e8eeeeeeeeee
0007700044444444060000000b00000004000000111000000d16610051166160511661600d000660505d661000d1661088885000885000000505887eeeeeeeee
000000004444444400000000000000000000000000000000001d1d000d1d1d0001d1d1d061d6d1600000d1d005001d10505000005000000000000500eeeeeeee
000770004444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeee
000000004444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeee
00000000000000000005000005000000000000000d0000000000000000000000000000008800550880005555000000005550000000000eeeeeeeeeeeeeeeeeee
00220002202909092050500050500005000500d00d00d220002200000d0000d08e8880000885778800057777500000057750070888800eeeeeeeeeeeeeeeeeee
000020200002999200505555505000005050000d777d00020200000000d00d08888e88000088788500005574750005577f50077000080eeeeeeeeeeeeeeeeeee
000044400404444000055e5e55002222505000075557000444000b0000333308ee888ee5057888500088844775088845f507777788080eeeeeeeeeeeeeeeeeee
440474740444e4e0005055555052622dddd0d0054445044e4e0b000000b33b08ee8e87ee5778884008004845758004845000077088080eeeeeeeeeeeeeeeeeee
4040444004504400005050005052266d5d507d04e4e4040444b0001331333308888887ee0588488408084805758084805000078000080eeeeeeeeeeeeeeeeeee
0505040505050050005005050052222dddd0444044400050b050b01331110005050505000885048858544800508005800000000888800eeeeeeeeeeeeeeeeeee
0000000000000000000500000505050505000505040500000b00000505000000000000008800005880888000000888000000000000000eeeeeeeeeeeeeeeeeee
000b0000000000000000000000000000000000000000200020000000000000000000000008000000ccc00000000800000000000700000eeeeeeeeeeeeeeeeeee
00b3500005000500000000000990990000555000000002020700007070000505050000000880000cc8cc0000008880000300000700600eeeeeeeeeeeeeeeeeee
0b3335005750575000000000988988900500050000000444007444470000040404080808888834cc888cc001188888003330006077060eeeeeeeeeeeeeeeeeee
b4444450747074700004000098888890500000500000474747441144000b004440000000088045c88888c015551800011311060760700eeeeeeeeeeeeeeeeeee
0411d4000400040000411000988888905d8dbd50004004440441111440b3504140000300080053ccc8ccc1d5e5d8000411140007067600000000000000000000
0411d400411111400451140009888900549494500411004004715511473335414004300b000b3345c8c530155518004011104770770000000000000000000000
044444004d111d40455445400098900054949450541140000741551470515044400430000b003453c8c330011100004040404006007000000000000000000000
004440004d404d405454545000090000055555004545440000741144074545444440030000004533ccc340000000000000000060000700000000000000000000
00000000000005000000050000000000000000d00d000000000000000000ccc00001ccc100000000050000005550000000500000005555000000500000555500
000870000500500800505000800000220800d777d080000000000000000cc0cc001cc0cc00000000575000005775000005750000057777500005750005777750
0878878005555088805052288802020088807555788800000000000000cc000c01cc000c00000000577500005677550005755550574755000057775057555575
078888800e5e588888dddd888884440888885444888880000000000000c0000001c0000000000000577750000565400055757575577440000577775055000055
3437753345555008005d5d66820e4eb008004e4e408000000000000000ccc0cc01ccc0cc00000000577775000054440075777775575444005777740054555545
453773345000500800dddd2282044400b800044400800000000000000000c0c00011c0c100000000577550000050445057777775575044400577444054944945
5327724535050008000505008505b05008b0504050800000000000000000c0c00001c0c100000000055750000000050005577750050004450055044554944945
34222253400000000000000000000b000000000000000000000000000000ccc00001ccc100000000000500000000000000055500000000500000005005555550
00000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000b000000440044000000000000000000000000000000000000000000000060000000000000000000000000
000000000000000000040000000000000000000000b3500004444044400000000000000000000000000000000000000000000000000006000000000000000000
00040000000000000041100000000000000000000b33350040440000400000000000000000000000000006000006000000000000000000000000000000000000
0041100000040000045114000000000000000000b444445040400040400000000000000000000000000000000000000000000005000000000000000000000000
04511400004110004554454000000000000000000411d40040000440400000000000000000000000000050000000050000000060000000500000000000000000
45544540045114005454545005000500000000000411d40044404444000000000000000000000000000000600000000000000000000000000000000000000000
00000000000000000000000004444400000000000444440004400440000000000000000000000000000600000000000000000000000000000000000000000000
00000000000000006000060604111400000000000411d40000000040000000000000006000060060000506000005605000000605000005000000000000000000
00000000000000000744447004444400005050000444440009999990055555500006060000056506005605000000056500006060000000060000000000000000
00744070000000007441144000414000004140000041400099299299552552550005656000505050000056500060600000000000000000000000000000000000
07411400000000004411114400444000004140000044400099299299552552550050555000a00500006060000000000000000000000000000000000000000000
04151140000470004715511400414000004140000041400099d44d9955d44d5500a0aa000aaa0aa000a00a0000a0050000000500000000000000000000000000
04111140004144007415514600414000004040000041400099444499554444550a9aa9a50a99a9950a95a9a5059a59a505a65a65007505000075050000750500
07411400004444000741144000000000000000000000000009999990055555505989989559899895598998955a89a895569a69a5057657600576576005765760
00000000000000000000000000000000000000000000000000000000000000002822282228828822228282822522852255285252565765755657657556576575
000000000000000000000000509030b0505500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000500050000000000550500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000005750575009999990055555500000000000000000000000000000000000000000000000000000000000000000000000005050500000505050
05000500000000007470747099799799556556550000000000000000000000000000000000000000000000000000000000000000000000004040400000404040
04000400000000000400040097d77d79565665650000000000000000000000000000000000000000005000000000000000000000000000000444000b00044400
0111110000111000411111409941149955411455000000000000000000000000000000000000000005150000000000000000000000000000041400b350041400
44111440501110504d111d40994444995544445500000000000000000000000000000000000000000414000300000000000000000000000004140b3335041400
40404040404040404d404d4009999990055555500000000000000000000000000000000000000000044403313300000000000000000000000444b33133544400
00000000000000003453345334533453345334533453345303033450000506000000000000060060041405111505000000000000000000000414051115041400
434b4043434040b04533453345334533453875334533453343434345000600000006050000050006041455555554050000000000000000000414555555541400
554355b343b300005334533453345334587887845338733455435533000006000005606000006050044454545454440000000505050000000444545454544400
34435343044043b03345334533478845388888853388884534435340000060000050500000a00000044444444444450000000444444005000444444544444500
3b0b40550300b0b4345334533458885334377453345374530334435500a00a0000a0a000000a0a00045444414444440000005441444055000454445154444400
455b3453b0b0044045334533453375334537753345377533455334530099a0000a9aa9000099a900044444111444540005004411144044000444451115445400
454445b3b04b400053345334533473345357753453577534454445330a889000098890000a899000044544111444440004404411144044000445451115444400
05335540030033b03345334533453345335555453355554505035540009200000029000000280000000000000000000000000000000000000000000000000000
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
000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a100a1a10000000007070b0b13130601210121210000000007070b0b13130621a12121210000000007070b0b131306012101010100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
54545454545454555253525352525352525151545454545454555454535353525353555554546c4f4c4d4e4f475252528f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0501080108030b010c050f021001100211021402150215011604170117021802
545454545554545f47525353535253524c4d545455545554545454555352525353545455546c5e5f5c5352535c5353528f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f19011a061b021d021e021f021f0120042203240127052801290229022a022a02
5454515454546e6f6c535253535252525c5d5e55545454555455545455535352545455546c6d4c5758595350505253528f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f2b012b062d05300131033205340435013502350335053602360239013c054102
545455547c7d7e507c5350505352537f6c6d6e6f555454545454557c7d7e7f7c7d7e7f7c7c7d576b686a5953535352548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f4102410141069601000000000000000000000000000000000000000000000000
5454554f4c4d4e4f4c4d52536e4d4c4f7c7d7e7f5f51525253524f4c4d4e4f4c4d4e4f4c4c4d67684a686952525554548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f2b1b251a28122b15261029182d192a182b182b172b162a1426152b102a162916
54546e5f5c5d7e5f5c5d5e5f5c5d5e5f5c6c6d6e6f5e5253525e5f5c5d5e5f5c5d5e5f5f5c5d6768685a795f535455558f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f271c22112816281728182c182613281428102d0928072f162d182e182c192c1a
54546e51516d6e6f6c6d6e6f6c6d6e6f6c7c7d7e7f6e6e52526e6f6c6d54545454556f6f6c6d777878796e6f6c5554548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f2c0c220b2514211c2908201e2a082a1c2b1a231c26172a1a2a1b2b05221d291b
54557e7f7c7d7e7f517e7f7d7e7f575858597c467e7e7f7c7d7e7f47555454555554547f7c7d7e7f7c7d7e7f7c7d55558f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f291c220823044040000000000000000000000000000000000000000000000000
5452534f4c4d4e4f4c4e4f4d4e466768686a594d4e4e4f4c4d4e4f525254555154544f4f4c4d4e4f4c4d4e4f4c4d54558f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f2c1c261b29132c1627112a192e1a2b192c192c182c172b1527162c112b172a17
525253525c5d5e5f5c5e5f5d57586b684868695d7b5e5f5c5d5e52535352545555555f5f5c475e5f5c5d5e5f5c5e55548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f281d23122917291829192d192714291529112e0a290830172e192f192d1a2d1b
5253525253526e6f6c6e6f6d676868686868697a6e6e6f6c6d6e535253525254544c6c6d6e6f6c5758594e7f6c5554548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f2d0d230c2615221d2a09211f2b092b1d2c1b241d27182b1b2b1c2c06231e2a1c
5252505252527e7f7c7e7f7d67684b68685a797d7e7e7f7c7d7e5353505253534c6f7c7d7e57586b68695e4f7c5253538f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f2a1d230924054040000000000000000000000000000000000000000000000000
52535352524d4e4f4c4e4f47676868686869474d4e4e4f4c4d4e4752535352524d7f4c4d576b686849696e5f4c5352528f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f2d1d271c2a142d1728122b1a2f1b2c1a2d1a2d192d182c1628172d122c182b18
525253535c5d5e5f5c5e5f7a67685a7878795c5d5e5e5f5c5d5e5f5c5252535c5d4f5c4667684b685a797e6f525253538f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f291e24132a182a192a1a2e1a28152a162a122f0b2a0931182f1a301a2e1b2e1c
526d6e6f6c6d6e6f6c6e6f6d7778797b526f6c6d6e7a6f6c6d6e6f6c6d6e6f6c6d5f6c6d6768685a796f4e7f525352538f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f2e0e240d2716231e2b0a22202c0a2c1e2d1c251e28192c1c2c1d2d07241f2b1d
7c7d5346527d7e7f7c7e7f7d7e7f7c7d7a7f7c7d7e7e7f7c467e7f7c7d7e7f7c7d6f7c7b77787879537f5e4f535253538f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f2b1e240a25064040000000000000000000000000000000000000000000000000
4c52575858594e4f4c4d4e4f4c4d4e4f4c4d4e4c464e4f4c4d4e4f7a4d4e4f4c4d7f7f7f7c7d7e4c7c7d7e5f535252538f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f2e1e281d2b152e1829132c1b301c2d1b2e1b2e1a2e192d1729182e132d192c19
505167486869475f5c5d5e5f5c5d5e5f5c5d5e5c5d5e5f5c5d5e5f5c5d5e5f5c5d4f4c4d4e4f4c4d4e4f5e53535353538f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f2a1f25142b192b1a2b1b2f1b29162b172b13300c2b0a3219301b311b2f1c2f1d
515067685a794c4d4e4f4c4d4e4f4c4d4e4f474d4e4f477c7d7e7f7c7d7e527c467e7f7f7c7d6e6f6c6d6e52525053538f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f2f0f250e2817241f2c0b23212d0b2d1f2e1d261f291a2d1d2d1e2e0825202c1e
7c52777879515c5d5e5f53525352535d5e5f5c5d5e5f7f4f4c6d6e5257585858585858597b4d7e7f7c7d5253525350538f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f2c1f250b26074040000000000000000000000000000000000000000000000000
4c545452524d6c6d6e525252535252527a6f6c6d7a6f4e5f5c467b576b6868685a785b6a596d4e4f4c4d4e53535352528f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
5c5d55535c5d7c7d53525352525253527b7f7c7d7e7f5e6f6c7b576b68684a68694d6768696d5e5f5c5d515f525253528f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
476d6e6f6c6d4c4d525252535253525252534c4d4e4f6e7f7c576b68486868686a586b5a797d6e6f6c6d6e6f6c6d6e6f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
527d7e7f7c7d5c5d50535253525252545454535d5e5f7e4f4c676868684968684b6868696c4d7e7f7c7d7e7f7c507e7f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
5252534f4c4d6c6d6e525252525353535454546d6e6f4e5f52775b686868686868686869535d4e4f4c4d4e4f4c4d4e548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
5353525f5c5d7c7d7e535252535454545454557d7e7f5e5250537778785b685a7878787953535e5f5c5d5e5f5c5d55548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
5252516f6c6d4c4d4e505455545455545454554d4e4f6e7f505253535377787953505253527d6e6f51516e6f6c5554548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
525251547c7d5c5d5e5f5454545454545554545d5e5f7e4e4f4d53525353525353525353534d7e7f7c7d7e7f545554548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
5253555554546c6d6e6f6c545554545554546c4c4d4e4f5e5f5d5e5f53525353525d5e5f5c5d4e4f4c4d4e54555455548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
535454545554557d7e7f7c7d7e467c7d7e7f7c5c575858595d5e5f5c5d5e5f5c5d4f4c4d4e4f5e5455545455545454548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
54555455555454556c6d6e6f6c6d6e6f6c6d6e576b68686a596e6f4c4d4c6e6f4d4c4d4c4d6d545454545554545455548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
5454545454545454547d7e7f7c7d7e7f7c7d5d67686849686a597f5c5d5c7e7f5d5c5d5c5d55555455545454555454548f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f0000000000000000000000000000000000000000000000000000000000000000
__sfx__
0104000026043260431f003200032604326043260432603329003290032800327003250032200320003200031f0031e0031e0031f00320003220032400324003210031d0031b0031900317003170030000300003
010400002604326043260331770013700127001270012700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
4d0300001a5502655026550005001a5001a5001a500005001a5001a5001a500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000000000000000000000
490900001a63432625180001a0001a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5d040000260532605332043320330e6000e6000960000300091000000037600091000e6000e6000960000300091000030032600266000e6000e60002600026030910000300376030030037600376003f60000000
79170000091730010032502266000264002611096010030309173000003760009100026400261109601003000917300300326002660002640026110260102603091730030037603003002b6132b6113f60100000
79170000091731d0301c0201a0200264002611096011d02209173180200e532105300264002611096011802009173210201d0202102002640026110260102603091731800028732297312b6132b6113f6011f022
7917000009173185301a5311a5220264002611096011d53009173175301853118522026400261109601135300917317530185301a5320264002611026011d530091731a5301d530215322b6132b6113f60121000
411700000206002060020620206202062020600206002060020600206002062020620206002060020620206002060020600206002062020620206202060020600206202062020600206002062020620206202060
391200000e5640e5600e5500e5520e5420e5300e52500000155541554015542155321552015520155250000013554135401354213532135321353213530135251154411540115451354413540135451554415545
9105000028063286431c0531c60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011700000e5500e5500e5520e5451555015550155401554213550135401354213532135350000011550105500e5500e5420e535105500e5500c55011550135501855018550185421853217550135501055010540
011700000e5500e5520e5520e5400e535000001155011540105501054010535000000e5500e5520e5400c5500e550105501155011540105501055210545105001355013550155611555215545135001155010550
011700001113010137131300e1300e1300e1320c1300c11511130101311012513130131371113011130101310e1301113710130131301313011130111300c1310e1300e1300e1250010011137101300e1370c130
011700000e1301013711130131300e1300e1321513015130131301113011115131301313711130101301813118130151301513015135131371513011130181311813017130171351310011137101300e1370c130
011700000e1501015711150131500e1500e152151501515013150111501b100131501315711150111501015115152151521513015125131571515011150181511815015150001000010011157101500e1570c150
050600001107100001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000052670061710267006171236700617123570161712357016170a157006170d147006170d147006170b047006170b037006170a037006170a727006170b727006170c717006170b117006170811700617
010600000e5511a555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
91040000154400e4501a4600e4201a4600e4501a4400e433164001f400174001440018400154001940016400114001a4001e4001b40018400214001940022400144001d400154001e400164001f4001740020400
01020000016300d6311c63131631146310c6310863105631026350160101605016300d6311c63131631146310c631086310563102635016010060000600006000000000000000000000000000000000000000000
191700000e5600e5600e5620e555180001800018000131300e130111301313015130151321513213130111301313013132131321313511130101300e1370c1300e1300e1320e1320e13511564115601156211555
191700000e5600e5600e5620e55518000180000c0000c1300e1301113013130151301513215132131301113018130181321813218135101301313715130171301a1301a1321a1221a11311564115601156211555
411700000e5600e5600e5620e555180001800018000131300e130111301313015130151321513213130111301313013132131321313511130101300e1370c1300e1300e1320e1320e13511564115601156211555
4117000010552115570e5400e5400e5420e5450c0000c1400e1301113013130151301514215142131401114018140181421814218145101401314715140171401a1401a1421a1421a1421a1321a1230b5500c550
79170000091730e1000e1300e13302640026110960100303091730e1450e1450e14502640026110960111100091730e1450e1450e1450264002611026010e700091730e1450e1450e1452b6132b6110c11100000
49040000131500e140131500e14011150151401a1501a1401a100261001a100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
031900001511617126181461a15718167171571514717143111330e1130e100001000010000100001000010000100001000010000100001000010000100001000010000100001000000000000000000000000000
49190000091730010000000376002b613001002b61300303091730000037600000000264002621376000000009173003002b6132660000000026400261102603091730030037603003002b6132b6102b61500000
01190000020700207002072020720207202070020700207010061100601006210062100601006010062100600c0610c0600c0600c0620c0620c0620c0600c0600b0620b0620b0600b0600b0620b0520b0420b030
b91900000e254102500e257102520e242102400e2300e220152541524015242152421524215230152301523513254132401524217232172321023613230102200c2400c2400e2401324013240132471524015245
011900000207002070020720207202072020700207002070100611006010062100621006010060100621006013051130501305013052110521105212050120500e0520e0520e0500e0500c0520c0520e0620e050
b91900000e254102500e250102520e242102400e2300e2201525415240152421523217227172201722515200132541324015242182361d2321d2321e2301e2200c2400c2400e2401724017247172401524215245
490900001a5561c556265561f55600500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
110b00001f077190771d0771a0671f067210671805719057297002970000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000000000000000000000
c51700000216502165001000010000100001000015000150021650216500100001000010000100001000010002165021650216500100051650210000150001500216502165001000010000100001000010000100
490900001a634326251a634326250960000300091000000037600091000e6000e6000960000300091001f60013600026000e6000e600026000260009100003001f6002b6001f6001f6003f600000000000000000
01170000091630010037500375000264002635026450e6000916300000375000910002640026350960137500091631f625136003750002640026350260137500091630e6340e6350e6000e600026451f62300000
11070000375463754609503005003754637546095030050037500375000950000500005000050000500005001f000210001d000180001f000210001d000180000050000500005000050000500005000050000500
0117000000000000000e050110501505015052150521505215045000001305011050130500e056110501105211052110450c050100501004011050130500e056100500c0500e0500e0500e0520e0520e0500e045
c51700000216502165001000515004150041450015000150021650216500100001000015004155041550010002165021650216500100051650210000150001500216502165001000010000000021550515507155
1117000000000000000e050110501505015052150521505215045000001305011050130500e056110501105211052110450c050100501004011050130500e056100500c0500e0500e0500e0520e0520e0500e045
2917000010552115570e5400e5400e5420e5450c0000c1300e1301113013130151301513215132131301113018130181321813218135101301313715130171301a1301a1321a1321a1321a1221a1131104411052
0d1700001d0401c0471f0401a0401a0401a04218040180251d0401c0411c0351f0401f0471d0401d0401c0411a0401d0471c0401f0401f0401d0401d040180411a0401a0401a035180001d0471c0401a04718040
0d1700001a0401c0471d0401f0401a0401a04221040210401f0401d0401d0251f0401f0471d0401c0401804118040150401504015045210401c0401d0401804118040170401704500000210401c0401f0411f042
191700000e5000e5000e5000e500180001800018000131300e130111301313015130151321513213130111301313013132131321313511130101300e1370c1300e1300e1320e1320e13511564115601156211555
7d1700001105010000130500e0500e0500e0520c0500c045110501005110055130000e0550e0550e055100000e0501105710050130501305011050110500c0510e0500e0500e0450c0000c0550c0550c0000c055
7d1700000e05510000130500e0520e055000021505015052130501105011045130000e0650e065100000c0401005110050100550e0000e0650e000180000c050110511105211055110000e0000e0000e00000000
0117000000000000000e0601106015060150621506215062150550000013060110601806017066150601306213062130650c060100601005011060130601506115062100600e0600e0600e0620e0520e0500e045
1517000000000000000e0501105015050150521505215052150450000013050110501805017056150501305213052130550c050100501004011050130501505115052100500e0500e0500e0520e0420e0400e035
011700000916318060110001500002640026350264518050091631a0500c0500e05002640026351505215052091631f6251360013050026400263517050110500916302644026450c0600b070026450907007070
01170000091630c0503750037500026400263518030180350916300000100500e04002640026350c0500c045091631f62513600130500264002635026010c0000916302644026450c0600b070026450707009070
111700000916318060110001500002640026350264518050091631a0500c0500e05002640026351505215052091631f6251360013050026400263517050110500916302644026450c0600b070026450907007070
11170000091630c0503750037500026400263518030180300916300000100500e04002640026350c0500c045091631f62513600130500264002635026010c0000916302644026450c0600b070026450707009070
791700000e5500e5400e5420e5451554015540155401554213540135401354213532135350050011540105400e5400e5320e525105500e5500c55011550135501855018550185421853217550135501055010540
791700000e5500e5520e5520e54000500005001155011540105501054010535005000e5500e5520e5400c5500e550105501155011540105501055210545105001355013550155611555215545135001156010560
791700000e500025000e500025000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e536105460e55602566
1517000000000000000e0501105015050150521505215055390130000113050110501805017056150501305213053000010c050100501004011050130501505115052100500e0500e0500e0520e0420e0400e035
c5170000021650216500100051501903426031260222602202165021653952300501001500415521042210420216502165021651804218042180221802200150021650216500100025643c001021550515507155
c517000002165021650010005150160041803118022180220216502165395230050100150041552103221032021650216502165180421f0421f0321f03500150021650216500100025643c001021550515507155
a91900000e244102400e247102420e232102300e2200e210152341523015232152321523215220152250020013244132301523217221172221722013220132250c2300c2300e2301323113232132321522015220
a91900000e244102400e240102420e232102300e2200e2101524415230152321522217217172101721515200132441323015232182201d2211d2221d2221d2100c2300c2300e2301a23017231172301723217235
05060000230531d0510e1710e073003000e0730e07300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 05084c44
01 05080b44
00 05080c44
00 19080b44
00 19080c44
00 05081544
00 05081644
00 05081744
00 05081844
00 06080b44
00 07080c44
00 06080b44
00 07080c44
00 05080d44
00 05080e44
00 19080d44
00 19080e44
00 19082d44
00 05081644
00 19081744
00 05082a44
00 19082b44
00 19082c44
00 25082e44
00 25082f44
00 25234344
00 25284344
00 25232744
00 25282944
00 25233044
00 25283144
00 25237244
00 25284344
00 32232744
00 33283044
00 34232944
00 35283144
00 343b2944
00 353a3944
00 19237244
00 19283844
00 05233644
02 05283744
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 1b1c5844
01 1c5e1d44
00 1c481f44
00 1c3c1d44
00 1c3d1f44
00 1c1e1d44
02 1c201f44
03 08484b44

