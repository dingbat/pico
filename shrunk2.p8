pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
--age of ants
--eeooty

music(63,2000)

function draw_map(o,y)
	camera(cx%8,cy%8)
	map(cx/8+o,cy/8,0,0,17,y)
end

function _update()
	lclk,rclk,llclk,lrclk=
		llclk and not btn"5",
		lrclk and not btn"4",
		btn"5",btn"4",
		stat"121" and loadgame()

	if menu then
		pspl"1,5,3,13,13,13,6,2,6,5,13,13,13,0,5"
		cx+=cvx
		cy+=cvy
		if (cx%256==0) cvx*=-1
		if (cy%127==0) cvy*=-1
		if btnp"0" or btnp"1" then
			diff+=btnp()^^-2
			diff%=5
		end
		if btnp"4" then
			add(pcol,deli(pcol,1))
		end
		if lclk then
			init()
			for k,r in inext,res do
				r.pos,r.npl,r.diff,r.col=
					del(posidx,rnd(posidx)),
					2+diff\3,
					split"1,2,3,2,3"[diff+1],
					pcol[k]
			end
			foreach(split([[7,64,64
1,49,64
1,77,59
1,59,52
5,61,76]],"\n"),function(s)
				for p=1,res1.npl do
					local u,x,y=unspl(s)
					local dx,dy=unspl(
						stp[res[p].pos],":")
					unit(u,x+dx,y+dy,p)
				end
			end)
			start()
		else
			return
		end
	end

	cf+=1
	cf%=60

	input()

	if loser then
		poke"24365"
		if lclk then
			menu,cx,cy=unspl"63,5,35"
			music"63"
		end
		if rclk then
			ban^^=240
		end
		return
	end

	dmap()
	upcycle=
		split"5,10,15,30,60,60,60"[tot\50]

	upc,pos,hbld,t6,
		sele,selh,selb,
		hunit,idl,idlm=
		cf%upcycle,{},
		g(bldgs,mx8,my8,{}),
		t()%6<1,{}

	res1.t+=.03333

	if cf%30==19 then
		for tx=0,mmw do
		for ty=0,mmh do
			local x,y=tx*mmwr\8,ty*mmhr\8
			sset(109+tx,72+ty,
				g(exp,x,y) and rescol[
					g(viz,x,y,"e")..
					fget(mget(x,y))
				] or 14)
		end
		end
	end

	if upc==0 then
		viz,new_viz=new_viz,{}
		for k in next,exp do
			local x,y=k&255,k\256
			mset(x+mapw,y,viz[k] or
				mget(x,y))
		end
	end

	foreach(prj,function(b)
		local typ=b.typ
		if norm(b,b,typ.prj_spd)<1
		then
			del(prj,b)
			for u in all(units) do
				if u.ap~=b.ap and int(
					u.r,
					{b.x,b.y,b.x,b.y},
					typ.aoe
				) then
					dmg(typ,u)
					if (typ.aoe==0) break
					if hlv.var then
						hilite(p([[f=2
c=13]],b.x,b.y))
					end
				end
			end
		end
	end)

	foreach(units,tick)

	if selx then
		sel=selh or selb or sele
	end
	sel1,nsel,seltyp=sel[1],#sel
	fsel(function(s)
		seltyp=(not seltyp or
			s.typ==seltyp) and s.typ
			or {}
	end)

	for i=2,npl do
		if upc==i and units[i].alive then
			ai_frame(ais[i])
		end
	end
end

function bnr(a,t,st,cx)
	camera(cx)
	local s=res1.t\1%60
	rectfill(unspl"0,88,128,107,9")
	unl"6,87,44,87"
	unl"82,87,121,87"
	unl"25,108,105,108"
	line(
	print(split",⁶j2l⁴e²9ᶜ5 ,⁶j2l⁴e²9ᶜ0 2X "[res1.npl]..split"easy ai ,normal ai ⁴m⁶x1 ,hard ai "[res.p2.diff])-3,unspl"80,8,80,9")
	?"⁶jll²9⁴c⁴i ᶜ5⧗³h"..(res1.t<600 and "0" or "")..res1.t\60..(s<10 and ":0" or ":")..s.." "
	unl"119,80,84,80,9"
	pal{res1.col,[14]=0}
	sspr(64+
		pack(48,cf\5%3*16)[a],
		unspl"0,16,8,12,90,32,16")
	?"⁶j7r⁴i⁶y7²9⁴f³fᶜ4⁶x1⁴f ⁴h⁶x4 "..st
	?"⁶jdn⁴h⁶w⁶tᶜa"..t
end

function _draw()
	draw_map(0,17)
	if menu then
		camera()

		local x=64+t()\.5%2*16
		pspl"0,5,0,0,0,0,0,0,0,0,0,0,0,5"
		sspr(x,unspl"0,16,8,25,28,32,16")
		sspr(x,unspl"0,16,8,74,28,32,16,1")
		pspl"1,14,3,4,4,6,7,8,9,10,11,12,13,0"
		pal{pcol[1]}
		sspr(x,unspl"0,16,8,25,27,32,16")
		pal{pcol[2]}
		sspr(x,unspl"0,16,8,74,27,32,16,1")

		?"⁶j5c³jᶜ0⁶w⁶tage of ants⁶j5c⁴f³iᶜ7age of ants⁶-w⁶-t⁶jcg³e⁴hᶜ0difficulty:⁶jcg³eᶜcdifficulty:⁶j8n⁴hᶜ0press ❎ to start⁶j8nᶜ9press ❎ to start⁶j2t⁴hᶜ0EEOOTY⁶j2tᶜ6EEOOTY⁶jqtᶜ0V1.0³0⁴fᶜ6V1.0⁶jej³j\0"
		camera(split"8,12,8,18,14"[diff+1])
		?"ᶜ0◀⁴f³cᶜ7◀⁴h "..split"ᶜ0easy³0⁴fᶜbeasy,ᶜ0normal³0³8⁴fᶜanormal,ᶜ0hard³0⁴fᶜ9hard,ᶜ02 normals³0³0³c⁴fᶜ22 normals,ᶜ02 hards³0³4⁴fᶜ82 hards"[diff+1].." ⁴hᶜ0▶⁴f³cᶜ7▶"
		return
	end

	local bf,af,prj_so={},{},
		cf\5%2*2
	foreach(units,function(u)
		if u.onscr or loser then
			if
				not loser and
				not g(viz,u.x8,u.y8)
				and u.disc
			then
				add(af,u)
			elseif u.bldg or u.dead then
				draw_unit(u)
			else
				add(bf,u)
			end
		end
	end)

	foreach(bf,draw_unit)
	camera(cx,cy)
	foreach(prj,function(_ENV)
		sspr(
			typ.prj_s+prj_so,
			96,2,2,x,y
		)
	end)
	if loser then
		resbar()
		bnr(loser,split"defeat⁶x2....⁶x4⁶jdnᶜ1defeat⁶x2....,victory!⁶jdnᶜ1victory!"[loser],
			"press ❎ for menu ⁴f⁶x1 ",ban)
		return
	end

	pspl"0,5,13,13,13,13,6,2,6,6,13,13,13,0,5"
	draw_map(mapw,15)

	_pal,pal=pal,max
	foreach(af,draw_unit)
	pal,btns=_pal,{}
	pal()

	fillp"23130.5"

	for x=cx\8,cx\8+16 do
	for y=cy\8,cy\8+13 do
		local i=x|y<<8
		local function b(a,col)
			color(col)
			camera(cx-x*8,cy-y*8)
			if (a[i-1]) unl"-1,0,-1,7"
			if (a[i-256]) unl"0,-1,7,-1"
			if (a[i+256]) unl"0,8,7,8"
			if (a[i+1]) unl"8,0,8,7"
		end
		if not exp[i] then
			b(exp)
		elseif not viz[i] then
			b(viz,
				fget(mget(x,y),7) or 5)
		end
	end
	end

	camera(cx,cy)

	if (selx) rect(unpack(selbox))

	fillp()

	if sel1 and sel1.rx then
		spr(64+cf\5%3,
			sel1.rx-2,sel1.ry-5)
	end

	local dt=t()-hlt
	if dt>.5 then
		p"var=hlv"
	elseif hlv.f then
		circ(hlv.typ,hlv.x,
			min(hlv.f/dt,4),hlv.c)
	elseif mid(dt,.1,.25)~=dt
		and hlv.r then
		local w,x,y,z=unpack(hlv.r)
		rect(w-1,x-1,y,z,8)
	end

	draw_menu()
	campal()
	if hlv[4] then
		circ(unpack(hlv))
	end
	if to_bld then
		camera(cx-mx8*8,cy-my8*8)
		pspl(bldable() or
		"8,8,8,8,8,8,8,8,8,8,8,8,8,8,8"
		)
		if amy>=104 then
			camera(4-amx,4-amy)
		else
			fillp"23130.5"
			rect(to_bld.fw,
				to_bld.fh,
				unspl"-1,-1,3")
			fillp()
		end
		local _ENV=to_bld
		sspr(rest_x,rest_y,fw,h)
		pal()
	end

	camera(-amx,-amy)
	spr(
		hbtn and pset(unspl"-1,4,5")
			and 188 or
		sel1 and sel1.hu and
		((to_bld or
			can_bld() or
			can_renew"1") and 190 or
		can_gather() and 189 or
		can_drop() and 191 or
		can_atk() and (seltyp.monk
			and 185 or 187)) or 186)
end
-->8
--init

function start()
	npl,hq,cx,cy=res1.npl,
		units[1],
		unspl(stp[res1.pos],":")

	qdmaps"d"
end

function init()
	poke(24365,3)
	reload()
	
	music(unspl"0,0,7")
	menuitem(2,"⌂ save",save)
	menuitem(3,"∧ resign",
		function()hq.hp=0 end)

	p[[var=res
r=20
g=10
b=20
p=4
pl=10
tot=4
reqs=0
diff=0
techs=0
t=0
npl=0]]

	res1,dq,exp,vcache,dmaps,
	units,restiles,sel,ladys,
		prj,bldgs,new_viz,dmap_st,
		typs,ais,
		posidx,
		cf,selt,alert,ban,
		amx,amy,tot,
		loser,menu=
		res.p1,
		{},{},{},{},
		{},{},{},{},
		{},{},{},{d={}},
		{},{},
		split"1,2,3,4",
		unspl"59,0,0,0,64,64,50"

	for i=2,4 do
		ais[i]=p("boi=0",i)
	end

p[[var=heal
qty=.05
]]

p[[var=ant
idx=1
spd=.286
los=20
hp=6
range=0
atk_freq=30
atk=.2
conv=0
def=ant
atk_typ=ant
gr=3
cap=6

t=10
r=5
g=0
b=0
breq=0

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
bld_x=40
bld_y=8
bld_fr=2
bld_fps=15
farm_x=32
farm_y=8
farm_fr=2
farm_fps=15
atk_x=40
atk_y=12
atk_fr=4
atk_fps=3.75
dead_x=32
dead_y=12
portx=0
porty=72
dir=1
unit=1
ant=1
sfx=10
const=1
tmap=-1
d=0]]

p[[var=beetle
idx=2
spd=.19
los=20
hp=20
range=0
atk_freq=30
atk=.75
conv=0
def=sg
atk_typ=sg
sg=1

t=13
r=0
g=10
b=10
breq=0

const=1
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
atk_x=40
atk_y=0
atk_fr=3
atk_fps=10
dead_x=32
dead_y=0
portx=27
porty=72
unit=1
sfx=10
dir=1
tmap=-1
d=0]]

p[[var=spider
idx=3
spd=.482
los=30
hp=15
range=0
atk_freq=30
atk=1.667
conv=0
def=spider
atk_typ=spider

t=13
r=8
g=8
b=0
breq=0

const=1
w=8
fw=8
h=5
rest_x=0
rest_y=16
rest_fr=2
rest_fps=30
atk_x=64
atk_y=16
atk_fr=3
atk_fps=10
move_x=8
move_y=16
move_fr=6
move_fps=2
dead_x=56
dead_y=16
portx=18
porty=72
unit=1
sfx=10
dir=1
tmap=-1
d=0]]

p[[var=archer
idx=4
spd=.343
los=33
hp=5
range=28
atk=.667
conv=0
atk_freq=30
aoe=0
prj_spd=1
atk_typ=acid
def=ant

t=14
r=3
g=0
b=5
breq=0

const=1
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
atk_x=32
atk_y=24
atk_fr=2
atk_fps=10
dead_x=24
dead_y=25
portx=45
porty=72
unit=1
sfx=10
dir=1
prj_xo=-2
prj_yo=0
prj_s=52
tmap=-1
d=0]]

p[[var=warant
idx=5
spd=.33
los=25
hp=10
range=0
atk_freq=30
atk=1
conv=0
def=ant
atk_typ=ant

t=10
r=6
g=2
b=0
breq=0

const=1
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
atk_x=80
atk_y=64
atk_fr=2
atk_fps=10
dead_x=72
dead_y=64
portx=36
porty=72
unit=1
sfx=10
dir=1
tmap=-1
d=0]]

p[[var=cat
idx=6
spd=.2
los=50
hp=15
range=50
atk=1.5
conv=0
atk_freq=60
aoe=2
prj_spd=.72
def=sg
atk_typ=sg
sg=1

t=18
r=2
g=14
b=14
breq=0

const=1
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
atk_x=64
atk_y=8
atk_fr=4
atk_fps=15
dead_x=112
dead_y=16
portx=54
porty=72
unit=1
sfx=10
dir=1
prj_xo=1
prj_yo=-4
prj_s=56
tmap=-1
d=0]]

p[[var=queen
idx=7
los=25
hp=400
range=23
atk=1.5
conv=0
atk_freq=30
aoe=0
prj_spd=1
atk_typ=acid
def=queen

const=1
w=16
h=8
h8=1
fw=16
rest_x=64
rest_y=-1
rest_fr=2
rest_fps=30
atk_x=80
atk_y=-1
atk_fr=2
atk_fps=15
dead_x=112
dead_y=0
portx=9
porty=72
drop=0
bldg=1
bldrs=15
sfx=10
prj_xo=-4
prj_yo=2
prj_s=52
bmap=0
units=1
queen=1
dir=-1
tmap=-1
d=61]]

p[[var=tower
idx=8
los=30
hp=352
const=32
hpr=11
range=30
atk=1.2
conv=0
atk_freq=30
aoe=0
prj_spd=.9
atk_typ=bld
def=bld

r=0
g=5
b=15
breq=0

w=8
w8=1
fw=8
h=16
fh=16
rest_x=40
rest_y=96
atk_x=40
atk_y=96
fire=1
dead_x=64
dead_y=96
dead_fr=8
dead_fps=7.5
portx=-1
porty=0
bldg=1
bldrs=2
sfx=10
prj_yo=-2
prj_xo=-1
prj_s=48
bmap=1
dir=-1
tmap=-1
d=0]]

p[[var=mound
idx=9
los=5
hp=100
const=10
hpr=10
def=bld

r=0
g=0
b=6
breq=0

w=8
fw=8
h=8
fh=8
w8=1
h8=1
rest_x=16
rest_y=104
portx=15
porty=103
fire=1
dead_x=64
dead_y=104
dead_fr=8
dead_fps=7.5
bldg=1
bldrs=1
drop=5
bmap=2
dir=-1
tmap=-1
d=0]]

p[[var=den
idx=10
los=10
hp=250
const=25
hpr=10
def=bld

r=0
g=4
b=20
breq=8

w=8
fw=8
h=8
fh=8
w8=1
h8=1
rest_x=16
rest_y=96
fire=1
dead_x=64
dead_y=104
dead_fr=8
dead_fps=7.5
portx=97
porty=80
bldg=1
bldrs=2
bmap=4
units=2
idl=1
mil=1
dir=-1
tmap=-1
d=0]]

p[[var=barracks
idx=11
los=10
hp=200
const=20
hpr=10
def=bld

r=0
g=4
b=15
breq=0

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
portx=15
porty=112
bldg=1
bldrs=1
bmap=8
units=2
idl=1
mil=1
dir=-1
tmap=-1
d=0]]

p[[var=farm
idx=12
los=1
hp=48
const=8
hpr=8
def=bld
cycles=5
gr=.5

r=0
g=3
b=3
breq=2

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
portx=52
porty=88
farm=1
bldg=farm
bldrs=1
bmap=16
dir=-1
tmap=-1
d=0]]

p[[var=renew
r=0
g=0
b=6
breq=0]]

p[[var=castle
idx=13
los=45
hp=640
const=80
hpr=8
range=40
atk=1.8
conv=0
atk_freq=15
aoe=0
prj_spd=.8
atk_typ=bld
def=bld

r=0
g=25
b=60
breq=13

w=15
fw=16
h=16
fh=16
rest_x=112
rest_y=113
atk_x=112
atk_y=113
fire=1
dead_x=64
dead_y=97
dead_fr=4
dead_fps=15
portx=42
porty=80
bldg=1
bldrs=3
sfx=10
prj_yo=0
prj_xo=0
prj_s=48
bmap=32
units=1
mil=1
dir=-1
tmap=-1
d=0]]

p[[idx=14
spd=.21
los=18
hp=8
range=0
atk_freq=30
atk=.47
conv=0
lady=1
def=ant
atk_typ=ant

const=1
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
atk_x=96
atk_y=64
atk_fr=3
atk_fps=10
dead_x=56
dead_y=8
portx=63
porty=72
unit=1
sfx=10
dir=-1
tmap=-1
d=61]]

p[[var=mon
idx=25
los=25
hp=300
const=16
hpr=8
def=bld

r=0
g=10
b=15
breq=4

w=8
fw=8
h=8
fh=8
w8=1
h8=1
rest_x=40
rest_y=112
fire=1
dead_x=64
dead_y=104
dead_fr=8
dead_fps=7.5
portx=39
porty=111
bldg=1
bldrs=2
units=1
bmap=64
mil=1
dir=-1
tmap=-1
d=0]]

p[[var=monk
idx=26
spd=.25
los=45
hp=6
range=42
atk_freq=60
atk=0
conv=2
atk_typ=ant
def=ant
monk=65

t=30
r=0
g=12
b=0
p=
breq=0

const=1
w=8
fw=8
h=8
rest_x=48
rest_y=112
rest_fr=2
rest_fps=30
move_x=56
move_y=112
move_fr=2
move_fps=15
atk_x=0
atk_y=80
atk_fr=2
atk_fps=15
gather_x=0
gather_y=80
gather_fr=2
gather_fps=15
dead_x=72
dead_y=112
portx=87
porty=80
unit=1
sfx=63
dir=-1
tmap=-1
d=0]]

ant.prod={
	mound,
	farm,
	barracks,
	den,
	mon,
	tower,
	castle
}

mon.prod={
	monk,
	nil,nil,nil,nil,
	p([[t=30
r=10
g=20
b=0
breq=0
tmap=1024
up=-1
idx=27
portx=62
porty=88]],monk,function(_ENV)
	spd=.286
	hp*=1.25
	conv*=1.2
end)
}

queen.prod={
	ant,
	nil,nil,nil,nil,
	p([[t=25
r=20
g=0
b=20
breq=0
tmap=1
up=-1
idx=15
portx=24
porty=80]],ant,function(_ENV)
	cap\=.72
	spd*=1.12
	gr*=.9
end),
	p([[t=20
r=10
g=10
b=10
breq=2
tmap=2
idx=24
portx=33
porty=80]],{},function()
	mound.p1.units=
		add(mound.prod,ant)
end)
}

den.prod={
	beetle,
	spider,
	nil,nil,nil,
	p([[t=20
r=0
g=20
b=0
breq=0
tmap=4
up=-1
idx=16
portx=25
porty=88]],beetle,function(_ENV)
	atk*=1.15
	hp*=1.15
end),
	p([[t=30
r=10
g=10
b=0
breq=0
tmap=8
up=-1
idx=17
portx=16
porty=88]],spider,function(_ENV)
	atk*=1.2
	hp*=1.2
end)
}

mound.prod={
	p([[t=12
r=15
g=15
b=10
breq=0
tmap=16
up=-1
idx=18
portx=60
porty=80]],farm,function(_ENV)
		gr*=1.15
		cycles\=.6
	end)
}

barracks.prod={
	warant,
	archer,
	p([[t=10
r=9
g=6
b=0
breq=0
tmap=32
idx=19
portx=51
porty=80]],archer,function(_ENV)
	los,range=40,35
end),
	nil,nil,
	p([[t=18
r=15
g=7
b=0
breq=0
tmap=64
up=-1
idx=20
portx=43
porty=88]],warant,function(_ENV)
	atk*=1.333
	los=30
	hp*=1.333
end),
	p([[t=10
r=15
g=0
b=9
breq=0
tmap=128
up=-1
idx=21
portx=34
porty=88]],archer,function(_ENV)
	atk*=1.25
	hp*=1.2
end)
}

castle.prod={
	cat,
	nil,
	p([[t=30
r=0
g=25
b=30
breq=0
tmap=2048
idx=28
portx=78
porty=80]],castle,function(_ENV)
	aoe,prj_s,atk=1,60,2
end),
	nil,nil,
	p([[t=40
r=20
g=0
b=0
breq=64
tmap=256
idx=22
portx=16
porty=80]],heal,function(_ENV)
	qty+=.5
end),
	p([[t=10
r=0
g=10
b=20
breq=0
tmap=512
idx=23
portx=69
porty=80]],castle,function(_ENV)
	los,range=55,50
end)
}
end
-->8
--tick

function rest(u)
	u.st=p[[t=rest
rest=0
agg=1]]
end

function mvg(units,x,y,agg,frc)
	local l=999
	foreach(units,function(u)
		if frc or u.st.rest then
			move(u,x,y,agg)
		end
		l=min(u.typ.spd,l)
	end)
	foreach(units,function(_ENV)
		st.spd,grp=l,agg end)
end

function move(u,x,y,agg)
	u.st=p("t=move",
		path(u,x,y,0))
	u.st.agg=agg
end

function bld(u,b)
	u.st,u.res=p([[t=bld
in_bld=1
]],path(u,b.x,b.y),b)
end

function gather(u,tx,ty,wp)
	local t=tile_unit(tx,ty)
	u.st=p("t=gather",
		wp or path(u,t.x,t.y),
		t,p[[7=r
11=g
19=b
39=r]][fget(mget(tx,ty))],tx,ty)
end

function drop(u,nxt_res,dropu)
	local wayp
	if not dropu then
		wayp,x,y=dmap_find(u,"d")
		dropu=not wayp and units[u.p]
	end
	u.st=p([[t=drop
in_bld=1]],
		wayp or
			path(u,dropu.x,dropu.y),
		dropu or tile_unit(x,y),
		nxt_res)
end

function atk(u,e)
	if u.typ.atk and e then
		u.st,u.disc,u.res=
			p("t=atk",
				path(u,e.x,e.y),e),
			e.hu and u.bldg
	end
end

function gofarm(u,f)
	f.farmer,u.st,u.res=u,p([[t=farm
in_bld=1]],path(u,
		f.x+rndspl"-2,-1,0,1,2",
		f.y+rndspl"-2,-1,0,1,2"))
	u.st.farm=f
end

function tick(u)
	local typ,targ,agg_d,agg_u=
		u.typ,u.st.x,9999

	box(u).onscr,u.upd,x8,y8=
		int(u.r,{cx,cy,cx+128,cy+104},0),
		u.id%upcycle==upc,
		u.x8,u.y8

	if u.hp<=0 and u.alive then
		del(sel,u)
		tot-=1
		u.dead,u.farmer,u.alive=typ.d
		u.st=
			p"t=dead",
			typ.bldg and reg_bldg(u),
			u.onscr and
				sfx(typ.bldg and 17 or 62)
		if typ.lady then
			s(ladys,x8,y8,u)
			mset(x8,y8,86)
			s(dmap_st.r or {},x8,y8,
				{x8,y8})
			qdmaps"r"
		elseif typ.queen then
			npl-=1
			if npl==1 or u==hq then
				loser,sel=min(u.p,2),{}
				music"56"
			end
		else
			if typ.drop and not u.const then
				u.pres.pl-=typ.drop
			elseif typ.unit then
				u.pres.p-=1
			end
		end
	end

	if u.dead then
		u.dead+=1
		del(u.dead==60 and units,u)
		return
	end

	if not u.fire and u.dmgd and
		cf==0 then
		u.hp+=heal[u.p].qty
	end

	if int(u.r,{mx,my,mx,my},1)
		and (not hunit or hunit.hu
	) then
		hunit=u
	end

	if g(viz,x8,y8,u.disc) then
		if selx and int(u.r,selbox,0)
		then
			if not u.hu then
				sele={u}
			elseif typ.unit then
				selh=selh or {}
				add(selh,u)
			else
				selb={u}
			end
		end
		sset(109+u.x/mmwr,72+u.y/mmhr,
			u.pres.col)
	end

	if (u.const) return
	if targ and targ.dead then
		rest(u)
	end
	if u.st.rest then
		if typ.lady and t6 then
			wander(u)
		end
		if u.hu then
			if typ.ant then
				u.st.rest+=1
				if (u.st.rest>30) idl=u
			elseif typ.idl and not u.q
			then
				idlm=u
			end
		end
	end

	update_unit(u)

	local x,y,adj=u.x,u.y
	if u.upd then
		if u.hu then
			local xo,yo,l=x%8\2,y%8\2,
				ceil(typ.los/8)
			local k=xo|yo*16|typ.los*256
			if not vcache[k] then
				vcache[k]={}
				for dx=-l,l do
				for dy=-l,l do
					add(
						dist(xo*2-dx*8-4,
							yo*2-dy*8-4)<typ.los
						and vcache[k],dx+dy*256)
				end
				end
			end
	
			foreach(vcache[k],function(t)
				local k=u.k+t
				if k<maph<<8 and k>=0 and
					k%256<mapw then
					if bldgs[k] then
						bldgs[k].disc=1
					end
					exp[k],new_viz[k]=128,"v"
				end
			end)
		end
		
		if u.st.agg and typ.atk then
			for e in all(units) do
				if e.ap~=u.ap or
					typ.monk and e.dmgd and
					not e.bldg
				then
					local d=dist(x-e.x,y-e.y)
					if e.alive and
						d<=typ.los then
						if e.bldg then
							d+=typ.sg and
								e.bldg==1 and
								-999 or 999
						end
						if d<agg_d then
							agg_u,agg_d=e,d
						end
					end
				end
			end
			atk(u,agg_u)
		end
	end

	if typ.unit and not u.st.typ then
		while g(pos,x\4,y\4,
			not u.st.in_bld and
			g(bldgs,x\8,y\8,{}).bldg==1) and
			not u.st.adj do
			x+=rndspl"-1,-.5,0,0,.5,1"
			y+=rndspl"-1,-.5,0,0,.5,1"
			adj={{x,y}}
		end
		u.st.typ,u.st.adj=adj,adj
		s(pos,x\4,y\4,1)
	end
end
-->8
--input

function cam()
	local b=btn()
	if (b>255) b>>=8
	local dx,dy=(b&2)-(b&1)*2,
		(b&8)/4-(b&4)/2
	if dget"0"==0 or loser then
		amx,amy=stat"32",stat"33"
	else
		amx+=dx
		amy+=dy
		dx,dy=amx\128*2,amy\128*2
	end
	cx,cy,amx,amy=
		mid(cx+dx,256),
		mid(cy+dy,
			loser and 128 or 149),
		mid(amx,126),
		mid(amy,126)

	mx,my,hbtn=amx+cx,amy+cy
	mx8,my8=mx\8,my\8
end

function fsel(func,...)
	for u in all(sel) do
		func(u,...)
	end
end

function input()
	cam()

	foreach(btns,function(b)
		if int(b.r,{amx,amy,amx,amy},1) then
			hbtn=b
		end
	end)

	local cont,htile,axn,clk=
		act==0,
		tile_unit(mx8,my8),act,
		lclk or rclk

	if clk and hbtn then
		hbtn.fn(rclk)
		if (axn==act) act=0
		return
	end

	if lclk and act>0 then
		rclk,act=1,0
	end

	if amy>104 and not selx then
		local dx,dy=amx-mmx,amy-mmy
		if min(dx,dy)>=0 and
			dx<mmw and dy<mmh+1	then
			local x,y=mmwr*dx,mmhr*dy
			if rclk and sel1 then
				sfx"0"
				fsel(move,x,y,axn==1)
				hilite{amx,amy,2,8}
			elseif axn==0 and btn"5" then
				cx,cy=x-64,y-64
				cam()
			end
		end
		if (clk) to_bld=nil
		return
	end

	if to_bld then
		if clk and bldable() then
			sfx"1"
			local b=unit(
				to_bld,
				mx8*8+to_bld.w\2,
				my8*8+to_bld.h\2,
				unspl"1,1,1")
			fsel(bld,b)
			pay(to_bld,-1,res1)
			b.cost,to_bld,selx=to_bld
		end
		return
	end

	if btnp"5" and hunit and
		hunit.typ.unit and
		t()-selt<.2 then
		sel,selx={}
		foreach(units,function(u)
			add(u.onscr and
				u.typ==hunit.typ and
				sel,u)
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
			pay(renew,-1,res1)
			gofarm(sel1,hbld)

		elseif can_gather() then
			sfx"0"
			hilite(htile)
			if avail_farm() then
				gofarm(sel1,hbld)
			else
				fsel(gather,mx8,my8)
			end

		elseif can_bld() then
			sfx"0"
			fsel(bld,hbld)
			hilite(hbld)

		elseif can_atk() then
			sfx"4"
			fsel(atk,hunit)
			hilite(hunit)

		elseif can_drop() then
			sfx"0"
			fsel(drop,nil,hbld)
			hilite(hbld)

		elseif sel1.typ.unit then
			sfx"1"
			mvg(sel,mx,my,axn==1,1)
			hilite(p([[f=.5
c=8]],mx,my))

		elseif sel1.typ.units then
			if fget(mget(mx8,my8),1) then
				hilite(htile)
			end
			sfx"3"
			sel1.rx,sel1.ry,
				sel1.rtx,sel1.rty=
				mx,my,mx8,my8
		else
			cont=1
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
				7
			}
		else
			selx=nil
		end
	end
end
-->8
--unit

function draw_unit(u)
	local typ,st,r=
		u.typ,u.st,
		u.res and u.res.typ or "_"

	local fw,w,h,stt,ihp,ux,uy=
		typ.fw,typ.w,typ.h,
		st.typ and "move" or st.t,
		u.max_hp/u.hp,unpack(u.r)

	local sx,sy,ufps,fr,f,selc=
		typ[stt.."_x"]+resx[r]+
			u.sproff\8*8,
		typ[stt.."_y"]+resy[r],
		typ[stt.."_fps"],
		typ[stt.."_fr"],
		u.dead or (cf-u.id)%60,
		count(sel,u)==1 and 9

	camera(cx-ux,cy-uy)

	if u.const and u.alive then
		fillp"23130.5"
		rect(-1,-1,w,h,
			u==sel1 and 9 or 12)
		fillp()
		local p=u.const/typ.const
		line(fw-1,unspl"0,0,0,5")
		line(fw*p,0,14)
		sx-=fw*ceil(p*2)
		if (p<=.15) return
	elseif ufps then
		sx+=f\ufps%fr*fw
	end
	pal{
		selc or u.pres.col,
		[14]=pal(typ.farm and 5,selc or 5)
	}
	sspr(sx,sy,w,h,0,0,w,h,
		not typ.fire and u.dir==typ.dir)
	pal()
	if u.alive and ihp>=2 then
		if typ.fire then
			spr(247+f/20,w\3)
		end
		line(w,unspl"-1,0,-1,8")
		line(w\ihp,-1,11)
	end
end

function update_unit(u)
	local st=u.st
	local t,wayp,nxt,targ=
		st.t,st.typ,st.y,st.x
	if u.q and cf%15==u.q.y%15 then
		produce(u)
	end
	if u.typ.farm then
		update_farm(u,cf)
	end
	if t=="atk" then
		fight(u)
	end
	if st.active then
		if (st.farm) farmer(u)
		if t=="bld" and cf%30==0 then
			bldrepair(u)
		end
		if (t=="gather") mine(u)
	elseif targ and
		int(targ.r,u.r,-2) then
		u.dir,st.active,st.frame,
			st.typ=
			sgn(targ.x-u.x),1,cf
		if t=="drop" then
			if u.res then
				u.pres[u.res.typ]+=
					u.res.qty/u.typ.gr
			end
			u.res=nil
			if st.farm then
				gofarm(u,st.farm)
			else
				rest(u)
				u.st.y,u.st.agg=nxt
			end
		end
	elseif st.y and not wayp then
		mine_nxt(u,st.y)
	end

	if wayp then
		if norm(wayp[1],u,
			st.spd or u.typ.spd)<.5
		then
			deli(wayp,1)
			st.typ=#wayp>0 and wayp
		end
	elseif t=="move" then
		rest(u)
	elseif t=="farm" then
		st.active=1
	end
end

function update_farm(_ENV,cf)
	if not farmer or
		farmer.st.farm~=_ENV
		or exp then
		farmer=nil
	elseif farmer.st.active and
		not ready and cf==59 then
		fres+=typ.gr
		sproff+=typ.gr*2
		ready=fres>=9
	end
end

function farmer(u)
	local _ENV,g=u.st.farm,_ENV
	if not farmer then
		g.rest(u)
	elseif ready and g.cf==0 then
		fres-=1
		sproff+=1
		g.collect(u,"r")
		if fres<=0 then
			g.drop(u)
			cycles+=1
			exp,ready=hu and
				cycles>=typ.cycles
			sproff=exp and
				(g.sfx"36" or 32) or 0
		end
		u.st.farm=_ENV
	end
end

function fight(u)
	local typ,e=u.typ,u.st.x
	if u.upd then
		local dx=e.x-u.x
		local d=dist(dx,e.y-u.y)
		if typ.range>=d
			or int(u.r,e.r,0)
		then
			if not u.st.adj then
				u.st.typ=nil
			end
			if cf%typ.atk_freq==
				u.id%typ.atk_freq
			then
				if e.ap==u.ap then
					if typ.monk and e.dmgd then
						e.hp+=1
						if (u.onscr) sfx"20"
					else
						rest(u)
					end
				else
					u.dir=sgn(dx)
					add(prj,typ.prj_s and {
						e.x,e.y,
						typ=typ,
						ap=u.ap,
						x=u.x-u.dir*typ.prj_xo,
						y=u.y+typ.prj_yo
					} or dmg(typ,e))
					if e.conv>=e.max_hp then
						e.pres.p-=1
						u.pres.p+=1
						e.p,e.conv=u.p,0
						del(e.sqd,e)
						sfx"38"
					end
				end
			end
		else
			if u.hu and viz[e.k] or
				typ.los>=d then
				atk(u,e)
			end
			if not u.st.typ then
				rest(u)
			end
		end
	end
end

function bldrepair(u)
	local _ENV,g=u.st.x,_ENV
	if const then
		const+=1
		max_hp+=typ.hpr
		hp+=typ.hpr
		if const>=typ.const then
			const,cost=
				u.hu and g.sfx"26"
			g.reg_bldg(_ENV)
			if typ.drop then
				pres.pl+=5
			elseif typ.farm then
				g.gofarm(u,_ENV)
			end
		end
	elseif dmgd and
		pres.b>=1 then
		hp+=2
		pres.b-=.1
	else
		g.rest(u)
	end
end

function mine(u)
	if u.typ.monk then
		res1.g+=.00318
		return
	end
	local r,x,y=u.st.y,
		unpack(u.st.p1)
	local t=mget(x,y)
	local f=p[[7=45
11=50
19=40
39=60]][fget(t)]
	local n=g(restiles,x,y,f)
	if not f then
		if not mine_nxt(u,r) then
			drop(u,r)
		end
	elseif cf==u.st.frame then
		collect(u,r)
		if t<112 and
			(n==f\3 or n==f\1.25)
		then
			del(units,g(ladys,x,y))
			mset(x,y,t+16)
		elseif n==1 then
			mset(x,y,68)
			s(dmap_st[r],x,y)
			s(dmaps[r],x,y,.55)
			qdmaps(r)
		end
		s(restiles,x,y,n-1)
	end
end

function produce(u)
	local _ENV,gl=u,_ENV
	local bld=q.typ
	q.x-=.5
	if q.x<=0 then
		if bld.x then
			local _ENV=bld
			gl.res1.techs|=tmap
			x(typ.p1)
			gl.sfx"33"
			if up and up<1 then
				up+=1
				r*=1.75
				g*=2
				b*=2
				t*=1.5
				done=nil
			end
		else
			local new=gl.unit(bld,x,y,p),
				onscr and hu and gl.sfx"19"
			if bld.ant and
				rtx and
				fget(mget(rtx,rty),1)
			then
				gl.gather(new,rtx,rty)
			else
				gl.move(new,rx or x+5,
					ry or y+5)
			end
		end
		if q.qty>1 then
			q.qty-=1
			q.x=bld.t
		else
			q=nil
		end
	end
end

function mine_nxt(u,res)
	local wp,x,y=dmap_find(u,res)
	if wp then
		gather(u,x,y,wp)
		return res
	end
end

-->8
--utils

function p(str,typ,x,y,...)
	local p1,p2,p3={...},{},{}
	local obj={p1,p2,p3,p2,
		p1=p1,
		p2=p2,
		p3=p3,
		typ=typ,
		x=x,
		y=y}
	foreach(split(str,"\n"),function(l)
		local k,v=unspl(l,"=")
		if v then
			foreach(obj,function(o)
				obj[k],o[k]=v,v end)
		end
		if k=="idx" then
			typs[v]=obj
		end
	end)
	_ENV[tostr(obj.var)]=obj
	return obj
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

function tile_unit(tx,ty)
	return box(p([[p=0
ais=
hp=0
max_hp=0
const=1]],p[[w=8
h=8]],tx*8+4,ty*8+4
	))
end

function box(u)
	local _ENV,ais,rz=u,ais,res
	local w2,h2=typ.w/2,typ.h/2
	r,x8,y8,dmgd,ai,ap,pres=
		{x-w2,y-h2,x+w2,y+h2},
		x\8,y\8,
		hp<max_hp,
		ais[p],p&6,rz[p]
	k,hu=x8|y8<<8,not ai
	if not const then
		hp+=typ.hp-max_hp
		max_hp=typ.hp
	end
	return u
end

function can_pay(typ,_ENV)
	return r>=typ.r and
		g>=typ.g and
		b>=typ.b and
		(not typ.unit or p<min(pl,99))
		and reqs|typ.breq==reqs
end

function pay(typ,dir,_ENV)
	r+=typ.r*dir
	g+=typ.g*dir
	b+=typ.b*dir
	if typ.unit then
		p-=dir
	end
end

--credit on bbs
function dist(dx,dy)
	local x,y=dx>>31,dy>>31
	local a0,b0=dx+x^^x,
		dy+y^^y
	return a0>b0 and
		a0*.9609+b0*.3984 or
			b0*.9609+a0*.3984
end

function surr(fn,x,y,n,na)
	local n,e=n or 1
	for dx=-n,n do
	for dy=-n,n do
		local xx,yy=x+dx,y+dy
		if
			min(xx,yy)>=0 and
			xx<mapw and yy<maph and
			(na or acc(xx,yy))
		then
			if (dx|dy~=0) e=1
			if fn then
				fn{
					xx,yy,
					d=dx&dy~=0 and 1.4 or 1,
					k=xx|yy<<8
				}
			end
		end
	end
	end
	return e
end

function avail_farm()
	local _ENV=hbld
	return typ and
		typ.farm and
		not exp and
		not farmer and
		not const
end

function can_gather()
	local f=fget(mget(mx8,my8))
	return (seltyp.ant and
		(f&2==2 or avail_farm())
		or seltyp.monk==f)
		and g(exp,mx8,my8)
		and surr(nil,mx8,my8)
end

function can_atk()
	return sel1.typ.atk
		and hunit
		and hunit.alive
		and (not hunit.hu or
			seltyp.monk and
			hunit.dmgd and not
			hunit.bldg)
		and
		g(viz,mx8,my8,hunit.disc)
end

function can_bld()
	return hbld.hu and
		hbld.hp<hbld.typ.hp and
		seltyp.ant
end

function norm(it,nt,f)
	local dx,dy=
		it[1]-nt.x,it[2]-nt.y
	d,nt.dir=dist(dx,dy)+.0001,
		sgn(dx)
	nt.x+=dx*f/d
	nt.y+=dy*f/d
	return	d
end

function acc(x,y,strict)
	local _ENV=g(bldgs,x,y)
	return not fget(mget(x,y),0)
		and (not _ENV or not strict
			and (const or typ.farm))
end

function bldable()
	return	acc(mx8,my8,1) and
		(to_bld.h8 or
			acc(mx8,my8+1,1)) and
		(to_bld.w8 or
			acc(mx8+1,my8,1) and
			acc(mx8+1,my8+1,1))
end

function reg_bldg(b)
	local typ,x,y=b.typ,b.x8,b.y8
	local function reg(xx,yy)
		s(bldgs,xx,yy,b.alive and b)
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
		qdmaps"d"
		b.pres.reqs|=typ.bmap
	end
end

function wander(u)
	move(u,
		u.x+rndspl"-6,-5,-4,-3,3,4,5,6",
		u.y+rndspl"-6,-5,-4,-3,3,4,5,6",
		1)
end

function dmg(typ,to)
	to.hp-=typ.atk*
		dmg_mult[typ.atk_typ..
			to.typ.def]
	if to.typ.unit and
		to.st.rest or to.st.y then
		wander(to)
	end
	to.conv+=typ.conv
	if to.ai and to.grp~="atk" then
		to.ai.safe=
			mvg(to.ai.p1,to.x,to.y,1)
	end
	if to.onscr then
		poke(13480,rnd"32",rnd"32")
		sfx(typ.sfx)
		alert=t()
	elseif to.hu and t()-alert>10 then
		sfx"34"
		hilite{
			mmx+to.x/mmwr,
			mmy+to.y/mmhr,3,14}
		alert=hlt
		hlt+=2.5
	end
end

function collect(u,res)
	if u.res and u.res.typ==res then
		u.res.qty+=1
	else
		u.res=p("qty=1",res)
	end
	if u.res.qty>=u.typ.cap then
		drop(u,res)
	end
end

function can_drop()
	for u in all(sel) do
		if u.res then
			return hbld.hu and
				hbld.typ.drop
		end
	end
end

function can_renew(t)
	if hbld.exp and seltyp.ant then
		pres(renew,10,2)
		rect(unspl"8,0,18,8,4")
		return	can_pay(renew,res1) or t
	end
end

function unit(t,_x,_y,_p,
	_const,_disc,_hp)
	local _typ=typs[t] or t
	do
		local _ENV=add(units,
			p([[var=u
dir=1
lastp=1
sproff=0
cycles=0
fres=0
conv=0]],_typ[_p],rnd"60"\1))
		max_hp=typ.hp/typ.const
		id,x,y,p,hp,const,
			disc,alive,prod,bldg=
			x,_x,_y,_p,
			min(_hp or 9999,max_hp),
			max(_const)>0 and _const,
			_disc==1,1,
			_typ.prod or {},typ.bldg
	end
	tot+=1
	rest(box(u))
	if (u.bldg) reg_bldg(u)
	return u
end

function prod(u,b,m)
	pay(b,-1,u.pres)
	if u.q then
		u.q.qty+=1
	else
		u.q=p("qty=1",b,b.t*m,cf)
	end
end
-->8
--paths

function dmap_find(u,k)
	local x,y,tk,dmap,p,l=
		u.x8,
		u.y8,
		u.k,
		dmaps[k] or {},
		{},9
	while l>=.5 do
		local o=dmap[tk] or 9
		surr(function(t)
			local w=(dmap[t.k] or 9)+t.d-1
			if w<l and (u.ai or exp[t.k]) then
				l,tk,x,y=w,t.k,unpack(t)
			end
		end,x,y,1,1)
		if l>=o then
			dmap[tk]=min(l+1,9)
			return
		end
		add(p,{x*8+3,y*8+3})
	end
	return p,x,y
end

function qdmaps(r)
	dq,asc=split(p[[r=r,g,b,d
g=g,r,b,d
b=b,g,r,d
d=d,r,g,b]][r]),{}
end

function dmap()
	local q=dq[1]
	if q then
		if q.c then
			for i=1,#q.typ do
				if (i>20) return
				local pt=deli(q.typ)
				q.p1[pt.k]=q.c
				if q.c<8 then
					surr(function(t)
						q.p3[t.k]=
							q.p3[t.k] or
							add(q.p2,t)
					end,unpack(pt))
				end
			end
			q.c+=1
			q.typ,q.p2=q.p2,{}
			if q.c==9 then
				dmaps[q.x]=deli(dq,1).p1
			end
		else
			local o,f={},p[[r=2
g=3
b=4]][q]
			if not dmap_st[q] then
				dmap_st[q]={}
				for x=0,mapw do
				for y=0,maph do
					if fget(mget(x,y),f) then
						s(dmap_st[q],x,y,{x,y})
					end
				end
				end
			end

			for i,t in next,dmap_st[q] do
				if	surr(nil,unpack(t)) then
					add(o,t).k=i
				end
			end
			dq[1]=p("c=0",o,q)
		end
	end
end

function path(u,x,y,tol)
	local function nearest(gx,gy)
		for n=0,16 do
			local best_d,best_t=32767
			surr(function(t)
				local d=dist(
					t[1]*8+4-x,
					t[2]*8+4-y
				)
				if d<best_d then
					best_t,best_d=t,d
				end
			end,gx\8,gy\8,n)
			if (best_t) return best_t,n
		end
	end
	if u.typ.unit then
		local dest,dest_d=nearest(x,y)
		local wayp,e=as(
			nearest(u.x,u.y),dest)
		if e and
			dest_d<=(tol or 1) then
			deli(wayp)
			add(wayp,{x,y})
		end
		return #wayp>0 and wayp
	end
end

--credit on bbs
function as(st,g)
	local k=st.k|g.k>>16
	local c=asc[k]
	if c then
		return {unpack(c)},c.e
	end

	local sh,t,f={cfs=0,
		last=st,ctg=32767},{},{}
	t[st.k]=sh
	local function path(s)
		while s.last~=st do
			add(f,{s.last[1]*8+4,
				s.last[2]*8+4},1)
			s=t[s.prev.k]
		end
		asc[k]=f
		return f
	end
	local fr,frl,cl={sh},1,sh
	while frl>0 do
		local cost,iom=32767
		for i=1,frl do
			local t=fr[i].cfs+fr[i].ctg
			if (t<=cost) iom,cost=i,t
		end
		sh=fr[iom]
		fr[iom],sh.dead=fr[frl],1
		frl-=1

		local pt=sh.last
		if pt.k==g.k then
			f.e=1
			return path(sh),1
		end
		surr(function(n)
			local ob,ncfs=t[n.k],sh.cfs+n.d
			if not ob then
				ob={
					cfs=32767,last=n,
					ctg=dist(n[1]-g[1],n[2]-g[2])
				}
				frl+=1
				fr[frl],t[n.k]=ob,ob
			end
			if not ob.dead and ob.cfs>ncfs then
				ob.cfs,ob.prev=ncfs,pt
			end
			if ob.ctg<cl.ctg then
				cl=ob
			end
		end,unpack(pt))
	end
	return path(cl)
end
-->8
--menu

function pres(r,x,y,z)
	local oop=res1.p>=res1.pl
	for i,k in inext,split"r,g,b,p" do
		local newx,v=0,i~=4 and
			min(r[k]\1,99) or z and
			"³b ³i"..res1.p..
				"/⁶x9 ⁶-#⁶x1.⁴h²5⁶x0 ⁶x4⁶-#⁴f³6"..min(res1.pl,99) or
			oop and r[k] or 0
		if z and i==3 then
			newx=-2
			v..="³g ³c⁶t⁴fᶜ5⁶-#|"
		end
		pspl(
			(i==4 and oop or
			res1[k]<flr(v))
			and "1,2,3,4,5,6,10")
		if v~=0 or z then
			newx+=print("²7 "..v,x,y,rescol[k])
			spr(129+i,x,y)
			x=newx+(z or 1)
		end
	end
	return x-1
end

function draw_port(
	typ,fn,x,y,r,bg,fg,u,cost)
	camera(-x,-y)
	local nopay,axnsel=
		cost and not can_pay(typ,res1),
		typ.portf and act>0
	rect(0,0,10,9,
		u and u.p or
		nopay and 6 or
		cost and 3 or
		axnsel and 10 or
		typ.porto or 1
	)
	rectfill(1,1,9,8,
		nopay and 7 or
		cost and cost.x and 10 or
		axnsel and 9 or
		typ.portf or 6
	)
	pspl(
		nopay and "5,5,5,5,5,6,6,13,6,6,6,6,13,6,0,5"
		or "1,2,3,4,5,7,7,8,9,10,11,12,13,0")
	sspr(typ.portx,typ.porty,
		unspl"9,8,1,1")
	sspr((typ.up or -1)*8,unspl"88,8,8,2,1")

	add(fn and btns,{
		r={x,y,x+10,y+8},
		fn=fn,
		costs=cost
	})

	if fg then
		color(bg)
		unl"10,11,0,11"
		line(10*r,11,fg)
	end
	campal()
end

function sel_ports(x)
	foreach(sel,function(u)
		x+=13
		if x>100 then
			unspr"133,84,121"
			?"⁶jmu⁴fᶜ1⁶x2...\0"
		else
			draw_port(u.typ,
				nsel>1 and function(r)
					del(sel,u)
					if r then
						sel={u}
					end
				end,
				x,107,
				max(u.hp)/u.max_hp,8,11,u
			)
		end
	end)
end

function single()
	local q=sel1.q
	if sel1.cost then
		draw_port(p[[portx=72
porty=72
porto=8
portf=9]],
			function()
				pay(sel1.cost,1,res1)
				sel1.hp=0
			end,24,107,
			sel1.const/seltyp.const,
			5,12
		)
		return
	end

	if sel1.typ.farm then
		?"ᶜ4⁶jbr⁴i"..sel1.cycles.."/"..seltyp.cycles.."⁴e³h⁶:040c1e0d05010706³c⁴h⁶:0c1c1014160f0604"
	end
	for i,b in next,sel1.prod do
		if not b.done then
			draw_port(
				b,
				function()
					if can_pay(b,res1) and (
						not q or
						q.typ==b and q.qty<9) then
						if b.bldg then
							to_bld=b~=to_bld and b
							return
						end
						sfx"2"
						prod(sel1,b,1)
						b.done=b.x
					else
						sfx"16"
					end
				end,
				split"88,76,64,52,40,88,76,64"[i],
				split"106,106,106,106,106,117,117,117"[i],
				nil,nil,nil,nil,b
			)
		end
	end
	if q then
		local b=q.typ
		draw_port(
			b,
			function()
				b.done=pay(b,1,res1)
				if q.qty==1 then
					sel1.q=nil
				else
					q.qty-=1
				end
				sfx"18"
			end,
			b.x and 24 or
				print("ᶜ7⁶j8r⁴iX"..q.qty)
				and 20,
			107,
			q.x/b.t,5,12
		)
	end
	if sel1.typ.units then
		draw_port(p[[portx=120
porty=64
porto=15
portf=15
]],function()
	act+=1
	act%=2
end,42,108)
	end
end

function draw_menu()
	local x=0
	for i,sec in inext,split(
		sel1 and sel1.hu and
		(sel1.bldg and
			"17,24,61,26" or
			"17,17,68,26") or "102,26")
	do
		pspl(i%2~=0 and "1,2,3,15")
		camera(x)
		unspr"129,0,104"
		spr(129,sec-8,104)
		line(sec-4,unspl"105,3,105,7")
		rectfill(sec-4,unspl"106,3,108,4")
		rectfill(sec,unspl"108,0,128")
		x-=sec
		pal()
	end

	if nsel==1 then
		sel_ports(-10)
		if (sel1.hu) single()
	elseif seltyp and seltyp.ant then
		single()
	else
		sel_ports(24)
	end
	if nsel>1 then
		camera(nsel<10 and -2)
		?"ᶜ1⁶j1r⁴j³hX"..nsel
		unspr"133,1,111"
		add(btns,{
			r=split"0,110,14,119",
			fn=function()
				deli(sel)
			end
		})
	end

	if sel1 and sel1.hu and
		sel1.typ.unit then
		draw_port(
			act==2 and p[[portx=99
porty=72
porto=2
portf=13
]] or seltyp.ant and p[[portx=81
porty=72
porto=2
portf=13
]] or p[[portx=90
porty=72
porto=2
portf=13
]],function()
	act+=1
	act%=3
end,20,108)
	end

	camera(-mmx,-mmy)

	sspr(
		add(btns,idl and {
			r=split"116,121,125,128",
			fn=function()
				sfx"1"
				hilite(idl)
				sel={idl}
				cx,cy=idl.x-64,idl.y-64
				cam()
			end
		}) and 48 or 56,
		unspl"105,8,6,11,14")

	sspr(
		add(btns,idlm and {
			r=split"106,121,113,128",
			fn=function()
				hilite(idlm)
				sel={idlm}
			end
		}) and 48 or 56,
		unspl"98,8,6,0,14")

	pal(14,0)
	sspr(unspl"109,72,19,12,0,0")
	camera(
		-mmx-ceil(cx/mmwr),
		-mmy-ceil(cy/mmhr)
	)
	rect(unspl"-1,-1,7,7,10")

	resbar()

	if hbtn and hbtn.costs and
		res1.reqs|hbtn.costs.breq==
			res1.reqs then
		local len=pres(
			hbtn.costs,0,150)
		camera(
			len/2-4-hbtn.r[1],
			8-hbtn.r[2]
		)
		pres(hbtn.costs,2,2)
		rect(len+2,unspl"0,0,8,1")
	end
end

function resbar()
	camera()
	rectfill(unspl"0,120,30,128,7")
	camera(-pres(res1,
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

pspl,rndspl,unspl,spldeli,campal=
	comp(pal,split),
	comp(rnd,split),
	comp(unpack,split),
	comp(split,deli),
	comp(camera,pal)

unl,unspr,stp,resk,pcol,
	hlt,diff,act,
	mmx,mmy,mmw,mmh,
	mapw,maph,mmhr,mmwr,
	menu,cx,cy,cvx,cvy
	=
	comp(line,unspl),
	comp(spr,unspl),
	split"-9:-20,263:-20,263:148,-9:148",
	split"r,g,b,p,pl,reqs,tot,diff,techs,t,pos,npl,col",
	split"1,2,0,3,1,0,2,1,3,0",
	unspl"-10,0,0,105,107,19,12,48,32,21.333,20.21,63,0,30,1,1"

p[[var=rescol
r=8
g=3
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

p[[var=resx
_=0
r=16
g=0
b=16]]

p[[var=resy
_=0
r=0
g=4
b=4]]

p[[var=dmg_mult
antant=1
antqueen=.7
antspider=.8
antsg=1.5
antbld=.5

acidant=1
acidqueen=.6
acidspider=1.5
acidsg=.7
acidbld=.25

spiderant=1.5
spiderqueen=1.1
spiderspider=1
spidersg=1
spiderbld=.1

sgant=.9
sgqueen=3
sgspider=.7
sgsg=1
sgbld=12

bldant=1
bldqueen=.75
bldspider=1.25
bldsg=.9
bldbld=.1]]
-->8
--save

function save()
	local ptr,foreach=0,foreach
	bnr(2,"savefile⁶jdnᶜ1savefile","drag+drop to load ⁴f⁶x1 ")
	campal()
	local function draw(v)
		for i=0,8,4 do
			pset(ptr%128,ptr\128,
				max(v)>>i&15)
			ptr+=1
		end
	end
	for x=0,47 do
		for y=0,31 do
			draw(mget(x,y)|g(exp,x,y,0))
		end
	end
	foreach(resk,function(k)
		foreach(res,function(r)
			draw(r[k])
		end)
	end)
	draw(#units)
	foreach(units,function(_ENV)
		foreach({typ.idx,x,y,p,const,
			disc,hp},draw)
	end)
	extcmd("screen",1)
end

function loadgame()
	init()
	pal()
	loaded,ptr=
		serial(unspl"0x802,0x9000,0x4000"),
		36868
	local function px(n)
		n-=1
		if n>=0 then
			local v1,v2,v3=peek(ptr,3)
			ptr+=3
			return v1|v2<<4|v3<<8,px(n)
		end
	end
	for x=0,47 do
		for y=0,31 do
			local v=px"1"
			mset(x,y,v&127,
				v>127 and s(exp,x,y,128))
		end
	end
	foreach(resk,function(k)
		foreach(res,function(r)
			r[k]=px"1"
		end)
	end)
	for i=1,px"1" do
		unit(px"7")
	end
	local techs=res1.techs
	foreach(typs,function(_ENV)
		if techs|tmap==techs then
			x(y.p1)
			up,done=up and 0,not up
		end
	end)
	start()
end
-->8
--ai

function miner(u,r)
	u.rs=mine_nxt(u,r)
	if not u.rs and nxtres[r] then
		move(u,unpack(nxtres[r]))
	end
end

function ai_frame(ai)
	if (t6) ai.safe=1
	avail,nxtres,miners,
		ants,res2,uhold=
		{},{},{},0,res[ai.typ]

	for i=0,ai.boi,2 do
		local off=8288+i%32+i\32*128
		local x,y=
			peek(off+res2.pos*768,2)
		local curr,x8,y8,p,pid=
			ai.boi==i,
			x*8,y*8,
			peek(off,2)
		local r,b,bld=
			chr(pid),ant.prod[pid],
			g(bldgs,x,y)
		if b then
			curr=curr and bld and bld.hu
			if not bld and
				res2.tot>=p and ai.safe then
				if can_pay(b,res2) then
					pay(b,-1,res2)
					curr=unit(b,
						x8+b.w/2,
						y8+b.h/2,
						ai.typ,1)
				else
					uhold=b
				end
			end
		else
			if pid>90 then
				if (res2.diff<=p) break
				nxtres[r]=nxtres[r] or
					g(dmaps[r] or {},x,y) and
					{x8,y8}
			elseif curr then
				if pid==10 then
					if not loaded and ai.typ==2 then
						unit(p,x8,y8,4)
					end
				elseif pid==11 then
					bgrat=split"2.75,2.35,2"[p]
				elseif res2.diff>=p then
					typs[pid].x(
						typs[pid].typ[ai.typ])
				end
			end
		end
		if curr then
			ai.boi+=2
		end
	end

	foreach(units,function(u)
		if u.ai==ai then
			if u.typ.ant then
				ants+=1
				if u.st.rest then
					miner(u,bgnxt and "b" or "r")
					bgnxt=not bgnxt
				end
				del(u.bld and
					not u.st.in_bld and
					u.bld.p1,u)
				add(add(miners,u.rs) and
					not u.res and avail,u)
			elseif u.typ.unit then
				if u.dead then
					del(u.sqd,u)
				elseif not u.sqd then
					u.sqd=(#ai.p1>#ai.p2 or
						u.typ.sg) and
						ai.p2 or ai.p1
					add(u.sqd,u)
				end
			end
		end
	end)

	bal=(#miners-count(miners,"r"))
		\bgrat-count(miners,"g")

	foreach(units,function(u)
		local typ=u.typ
		local function go(fn)
			if #u.p1<typ.bldrs then
				local w=add(u.p1,deli(avail))
				if w then
					w.bld,w.rs=u,fn(w,u)
				end
			end
		end
		if u.ai==ai then
			local r=bal>0 and "g" or
				bal<0 and "b"
			if u.rs~=r and r and
				del(avail,u) then
				bal=0
				miner(u,r)
			end
			if bldg and u.dmgd or u.const
			then
				go(bld)
			elseif typ.farm and
				not u.farmer then
				go(gofarm)
			elseif
				typ.queen and
				ants<res2.diff*12 or
				typ.mil and
				res2.p<res2.diff*26
			then
				local b,hold=u.prod[u.lastp]
				foreach(split"r,g,b",function(k)
					hold=hold or uhold and
						b[k]~=0 and
						res2[k]-b[k]<uhold[k]
				end)
				if not u.q and not hold and
					can_pay(b,res2) then
					prod(u,b,
						split"5,1,1"[res2.diff])
					u.lastp%=typ.units
					u.lastp+=1
					res2.tot+=1
				end
			end
		end
	end)

	if #ai.p2>=res2.diff*5 and
		ai.safe
	then
		ai.p3,ai.p2=ai.p2,{}
	end
	mvg(ai.p3,hq.x,hq.y,"atk")
end
-->8
cartdata"age_of_ants"

menuitem(1,"● toggle mouse",
	function()dset(0,~dget"0")end)

__gfx__
000b0000d000000000000000000000000000000000d0000000000000000000000000000000100010000000000000000000000000011000110000000000000000
00b330000d000000d00000000000000000000000000d00000d011100000000000011000000010100000000000110001100000000000101000000000000000000
0b333300005111000d000000dd0000000000000000005110d05111100d0000000111100000010100001110000001010000111000004444000000000000001010
b44444500051111000511100005111000000000000005111005d1110d01111000111101110444400011110111044440001111011104e4e000011000111014441
0411d4000001111000511110005111100d51110000000d11000000d005111d0001101441144e4e0001101441144e4e000110144114044000011111441141e4e1
0411d400000d1d10000d1d100001d1d0d051d1d00000000d0000000005d110000000544005044000011054400504400001105440505005000115054450504400
04444400000000000000000000000000000000000000000000000000000000000005050050500500000505005050050000050500000000000000000000000000
00444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000800000008000080000000000000000000000000000000000000000010050000000000000000000000000000000000000000000000000000
000000000000000088000800880008800000000050000000000080000000000000000000115000000000000000000000000000000000000000d0000000000000
11000000110001101100880011000110110001100110511081101100008880000000000003300000000000000000000000d00000000000000d00000000000000
00111111001100110011111100110011801108110011001100110011088e8800000000000011500000d00000000000100d000000000000003310000000000000
0b0000000b0000b004000000040000400000000000000000000000000e88e8ee00000000001300000d0000000001131133100000000000003311310000000000
bb000b00bb000bb044000400440004400000000000001100000000000858586e0dd1311331350000331131131131135033113113113113100011311311311310
1100bb00110001101100440011000110000000000110001011101100000000003311311331105000331131131130500000113113113113110505001311311311
00111111001100110011111100110011015500000011000100010011000000003305005050500000050500505050000000505050505050500000005050505050
00000000000000000000000000000000000000000000000000000000000000000005050000505000000000000888800000000000000000000000000000000000
0505050000000000000000000000000000000000000000000000000000000000055015100501515000505050888e880008888000008888000000000000000000
5015105005050500005050500050505000505050050505000505050000000000500d151505015150050151058e88e8ee888e8800088e88800000000000000000
50151050501510500501510505051105050511505015150050115050005050000000d50550d0d0050501510588e8887e8e88e8ee08e8e8ee0000000000000000
5005005050151050500151055005110505051150501515005011505005151500000000050000000505dd0005888880008888887e0888887e0000000000000000
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
000000000000000000000000eeeeeeeeffffffffffffffffffffffffffffffffffffffffffffffff113331dd11111dd1ffffffffffffffffffffffffffffffff
004880000048008000400880eeeeeeeeffff6fffffff6ffffffffffffffffdffffbffffffff33fff1338311111511151ffffffffffffffffffffffffffffffff
004888800048888000488880eeeeeeeefffffffffffff5ffff2fffffffffd6dffffbf3ffff3993ff3bfbfb1111154511ffffffffffffffffffffffffffffffff
004888800048888000488880eeeeeeeef6fffffff6f5fffff292fffffffffd3ffffb3fffffbaabff33bbb33311114111ffffffffffffffffffffafffffffffff
004008800040880000488000eeeeeeeeffffff6ffffff5fff32fffffffffff3ffffb3fffffbaabff33bbb33311154511ffafffffff7fffffffffffffffffffff
004000000040000000400000eeeeeeeeffffffffff5fff6ff3ffffffffafffffffffffffffbbbbff33bbb33311514151ffffffffffffffffffffffffffffffff
014100000141000001410000eeeeeeeefff6fffffff6ffffffffaffffffffffffffffafff333333f1b333b3111121211ffffffffffffffffffffffff7fffffff
011100000111000001110000eeeeeeeeffffffffffffffffffffffffffffffffffffffffffffffff11333311dd1111ddffffffffffffffffffffffffffffffff
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
0000000000000000080000000330000004000000101000000000000000000000000000000000000000000000dd00000000000000008880000000000000000000
0007700000777700888000003330000044000000101000000d000000000000000000000000000000dd600000060000000888000008e88ee00088800000488000
0007700007444470888000003300000004000000c1c00000600006600d0000000dd0000000000000005100610510001688e88ee0888e87e0088e880000488880
0007700074444447060000000300000004400000c1c000005100016060000660600006600000000005d100665d1000668e8e87e08e8850000888e8ee00488880
0007700044444444060000000300000004000000111000000d16610051166160511661600d000660505d661000d1661088885000885000000505887e00400880
000000004444444400000000000000000000000000000000001d1d000d1d1d0001d1d1d061d6d1600000d1d005001d1050500000500000000000050000400000
00077000444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400000
00000000444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000005000005000000000000000d0000000000000000000000000000008800550880005555000000005550000000000eeeeeeeeeeeeeeeeeee
00220002202909092050500050500005000500d00d00d220002200000d0000d08e8880000885778800057777500000057750070888800eeeeeeeeeeeeeeeeeee
000020200002999200505555505000005050000d777d00020200000000d00d08888e88000088788500005574750005577f50077000080eeeeeeeeeeeeeeeeeee
000044400404444000055e5e55002222505000075557000444000b0000333308ee888ee5057888500088844775088845f507777788080eeeeeeeeeeeeeeeeeee
440474740444e4e0005055555052622dddd0d0054445044e4e0b000000b33b08ee8e87ee5778884008004845758004845000077088080eeeeeeeeeeeeeeeeeee
4040444004504400005050005052266d5d507d04e4e4040444b0001331333308888887ee0588488408084805758084805000078000080eeeeeeeeeeeeeeeeeee
0505040505050050005005050052222dddd0444044400050b050b01331110005050505000885048858544800508005800000000888800eeeeeeeeeeeeeeeeeee
0000000000000000000500000505050505000505040500000b00000505000000000000008800005880888000000888000000000000000eeeeeeeeeeeeeeeeeee
000dd0dd00dd0dd00000000000000000000002000200000000000000080000000000000000080000077000000dd000dd0000000000000eeeeeeeeeeeeeeeeeee
0003252000325200009909900005558000000020200005050500000008800000008000000088805050676000000d0d000600006060000eeeeeeeeeeeeeeeeeee
0013050001305000098898890050088800000044400004040408080888885334588850011888884040406600002232000074444700000eeeeeeeeeeeeeeeeeee
0130b0000130bbb0098888890500888880000474740b004440000000088033458888801555180004440699600b2232000744114400000eeeeeeeeeeeeeeeeeee
013b0bb0013b000b0988888905d8db850004004440b350414000030008003453348331d5e5d8000414069890b533300004411114400000000000000000000000
1350b00b1300b0bb009888900549498500411004003335414004300b000b453345834015551800041400988b35bb0bb004715511470000000000000000000000
3350b0b0335bb00000098900054949850541140000515044400430000b0053345384500111000004440000033300b00b07415514600000000000000000000000
350b000035050000000090000055555004545440004545444440030000003345334530000000004444440003500bb0bb00741144070000000000000000000000
0000ccc00001ccc100005000000050000000000000000d00d0000000000000d000dd000000333033050000005550000000500000005555000000500000555500
000cc0cc001cc0cc500500800505000800000220800d777d080000087000000d0d00800003bbb3b3575000005775000005750000057777500005750005777750
00cc000c01cc000c555508880505228880202008880755578880087887800022320888003bb3bbb3577500005677500005755550574755000057775057555575
00c0000001c00000e5e588888dddd88888444088888544488888078888800022328888803b303b30577750000567755055757575577440000577775055000055
00ccc0cc01ccc0cc5555008005d5d66820e4eb008004e4e40800343775334033300080003b303b30577775000056540075777775575444005777740054555545
0000c0c00011c0c1000500800dddd2282044400b8000444008004537733450bb0bb080003b300300577550000005444057777775575044400577444054944945
0000c0c00001c0c15050008000505008505b05008b0504050800532772453000b00b800003b30000055750000005044505577750050004450055044554944945
0000ccc00001ccc100000000000000000000b00000000000000034222253400bb0bb000000300000000500000000005000055500000000500000005005555550
000000000000000060000606000000000000000000000000509030b0505599880000000000000000000000000000000000000000000000000000000000000000
0000000000000000074444700000000000000000000b000000000000550599880000000000000000000000000000000000000060000000000000000000000000
007440700000000074411440000000000000000000b3300009999990055555500000000000000000000000000000000000000000000006000000000000000000
07411400000000004411114400000000000000000b33330099799799556556550000000000000000000006000006000000000000000000000000000000000000
0415114000047000471551140000000000000000b444445097d77d79565665650000000000000000000000000000000000000005000000000000000000000000
04111140004144007415514600000000000000000411d40099411499554114550000000000000000000050000000050000000060000000500000000000000000
07411400004444000741144005000500000000000411d40099444499554444550000000000000000000000600000000000000000000000000000000000000000
00000000000000000000000004444400000000000444440009999990055555500000000000000000000600000000000000000000000000000000000000000000
00000000000000000000000004111400000000000411d40000000000000000000000006000060060000506000005605000000605000005000000000000000000
00000000000000000000000004444400005050000444440009999990055555500006060000056506005605000000056500006060000000060000000000000000
00000000000000000004000000414000004140000041400099299299552552550005656000505050000056500060600000000000000000000000000000000000
00040000000000000041100000444000004140000044400099299299552552550050555000a00500006060000000000000000000000000000000000000000000
00411000000400000451140000414000004140000041400099d44d9955d44d5500a0aa000aaa0aa000a00a0000a0050000000500000000000000000000000000
04511400004110004554454000414000004040000041400099444499554444550a9aa9a50a99a9950a95a9a5059a59a505a65a65007505000075050000750500
45544540045114005454545000000000000000000000000009999990055555505989989559899895598998955a89a895569a69a5057657600576576005765760
00000000000000000000000000000000000000000000000000000000000000002822282228828822228282822522852255285252565765755657657556576575
00000000000000000000000000000000000000000000000000000d0d000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000500050000000000000000000b030b0000000d0d00000d0d0000000000000000000000000000000000000000000000000000000000000000
0000000000000000575057500000000000000000b03330b00001325200000d0d0000d0d000000000000000000000000000000000000000005050500000505050
0500050000000000747074700b030b0000000000b11311b0001330500011325200000d0d00000000000000000000000000000000000000004040400000404040
04000400000000000400040004111400000b0000041114000133bb00013330500113325200000000005000000000000000000000000000000444000b00044400
01111100001110004111114040111040001110004011104013300b001333b0001333305001113d0d05150000000000000000000000000000041400b350041400
44111440501110504d111d404040404004404400404040401350b00013500b003535b0000353b2520414000300000000000000000000000004140b3335041400
40404040404040404d404d40000000000000000000000000350500003505bb00505bb000353bb050044403313300000000000000000000000444b33133544400
00000000000000003453345334533453345334533453345303033450000600000006050000050006041405111505000000000000000000000414051115041400
434b4043434040b04533453345334533453875334533453343434345000006000005606000006050041455555554050000000000000000000414555555541400
554355b343b300005334533453345334587887845338733455435533000060000050500000a00000044454545454440000000505050000000444545454544400
34435343044043b0334533453347884538888885338888453443534000a00a0000a0a000000a0a00044444444444450000000444444005000444444544444500
3b0b40550300b0b434533453345888533437745334537453033443550099a0000a9aa9000099a900045444414444440000005441444055000454445154444400
455b3453b0b0044045334533453375334537753345374533455334530a889000098890000a899000044444111444540005004411144044000444451115445400
454445b3b04b40005334533453347334534773345347733445444533009200000029000000280000044544111444440004404411144044000445451115444400
05335540030033b03345334533453345335333453353334505035540000000000000000000000000000000000000000000000000000000000000000000000000
__map__
7f5454547f4e5c4c6e4c52534d6e5455557a7b7a7a7a7a7a7a6768686869504d545455555c4d6c4f7e55545454545454434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343010b0e0a0e0a0e0a0e0a0e0a0e0a0e0a0e0a0e0a006200620067006700670067
5455545455545c5c47525353534c6d5454557b7b7a7b7b7b576b68685a79525d5f55555d4e5f5e5f5c7e545454515455434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343030f03160314031503100311031203170501080108030b010c060f021001020f
5454515454546e6f6c535052534d4e7f7e6c6d517a7b7a7a674b684a695252526e6f6c6c5e464c7c7d5c5d5554545454434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343100210021002100215011604021217011702180219011a0701991b021d021e02
55545554547d7e507c5352524d4c4f4d4e7c525253537a7b6768685a795253537e7f7c7c6e7d4f504d6c6d6e7c5455544343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343431f021f011f05020b0215021620032204240127072801030b290229022a022a02
545455554c4d4e4f4c4d52534f4d4c5d484c535253534e50777878794653534f4c4d4e4f7e4c5f5c5d7c7d51516d54544343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343432b012b070217021102122d063001039900000000000000000000000000000000
7f54545f5c5d7e5f5c5d5e5f5c5d5e6d6e6c4d52524c4d4e5352524e485f5c5d5e5f475c4e5d5c6c6d6e6f5f7c7d54554343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000
4d4e6e51516d6e6f6c6d6e4c4d4e477d7e4c4c4e4c7c7e7e7d7e4c4d4e4f4c4d4d4f6f6f6c6d7f7c7d7e7f7f5252525443434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434300000f0518072005161111161d181116280f081004050b090803110512090a0d
4d4c7e7f7c7d7e7f517e7f5c5d5e5f5c5d5c5d5e5f7c7d7e7f7e5c5d5e5f5c5d5e5f4d7f7c7d7e7f7c507e52525053524343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343430000000000000000000000000000000004040802090709040b06060605030000
4c4d4e5c5e5f7d4f4c4e4f6c6d6e4f4c6d6c6d6e6f4e57585858596d6e6f476d6e4d4e4d4c4d4e4f4c4d4e52525252524343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343430604070405050506030509060000090005040603000508090000080408050706
7c5353465d7d7e5f5c5e5f7c4d5454544d7c7d7e7f48674a6868694d4e4f7c7d4f55545455475e5f5c5d5e7f5352524f434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343080601080707000000000000080807080b0a0d05110400000702080107010905
545252575858596f6c6e6f5e5455545554524f4c4d4867685a78795d5e4c4d4e5454555454554c4d4e4f4e6f6c6d6f6e434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343100904080000000000000c080a0e000000000000000000000000000000000000
545447674b68697f7c7e7f5454545554545353527f7e77787951556d6e5c53535454545454545c5d5e465e4f5c5d5e5f4343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000
5d545467685a794f4c4e4f5554545758585953537e4e4f4c4d4e7c7d7e525253525455575859506d6e6f6e5f5353504843434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434300000f0518072005161111161d181116280f08102a0324072a0720041d0a2711
5d4e52777879515f5c5e5f4d46516768686a5953525e5f5c5d5f7e7f7c5352525247576b686a59487e7f7e5352575858434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343000000000000000000000000000000002a022b0626062c032405290424080000
4c5d5d52524d6c6f6c6e6f5357586b684b6869467b4d5f48476f6d6e5257585858586b684a68694d4e4f4c52576b686843434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434328042a042a0529062001260500002d05270527042d0a27080000270427052706
5c505e535c487c7f7c7e5253676868686868697a6e7e4849487f467b576b68684b686868685a795d5e5f5c52674b4b6843434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434328061f0a2604000000000000250725041c0522052a0c00002a062b052c052902
7c7d534652517e4f4c4d525367684a68685a79477e4e4e46484f7b576b6868684a68685a7879524d4e4f6c46674b4b68434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343271026020000000000002a082903000000000000000000000000000000000000
4c52505758594e5f5c5d5253775b6868686953534e5e5f5c5d5f576b684b686868684b695352525d5e5f7c50775b68684343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000
4d55576b6869474d4e4f4c5455777878787952535e4f4c7c4c47674b68685a787878787953536c6d6e6f4c545477787843434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434300000f0518072005161111161d181116280f0810291c22172917201d26132a0e
545467684a694c5d4c4d5454555554505252526d6e5f7f4f5c5e775b685a795554545450534d4e4f484f5c5d46545448434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343000000000000000000000000000000002a172a1c251922162319291b241d0000
5452777878795c6d5c5d55545454547d7a537c7d4d5758596c6e527778795454555454545c5d5e5f5e5f6c5252534e6f4343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343432a1a2a1b2a1929192c1a251a00002a142819281b1d17271500002719271a271b
4c545452524d6c7d6c6d4d545554554f4c7f7c7d576b68697c7e535252525454545455556c6d6e6f6e6f52535252527f4343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343432a181f1d261900000000000025172417251321192a0f000029182b192c192d19
5c5d55535c487c4d7c7d6e4d54545d5f4c4d4e4f676868694c4d4e5353515c5554554d4c4d4e4f7f7e7f52535053526f4343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343432a1f26170000000000001d192b18000000000000000000000000000000000000
4c4d4e4f7c7d5c5d4c4d5c5f6c6c6e6f5c5d5e5f777878795c5d5e5f5c4e7c5e6d4d4e5c5d5e5f7f7c7d7e5253524f7f4343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000
5c5d5e5f4c4d6c6d5c5d5e5f7c7d7e487a7b6e6f7e48484c6c6d6e6f6c6d6e4c4d4e4f6c476e6f504c4d4e4c4c4d4e4f43434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434300000f0518072005161111161d181116280f0810061c0a160a1b121b12150a12
6c6d6e51515d7c7d4d504c4d4e4f4c4d487d7e7f4c7f5e5c7c7d7e7f7c7d7e5c5d5e5f7c7d7e7f5f5c5d5e5c5c5d5e5f434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343000000000000000000000000000000000a1c041b091702170c18051a0a150000
7c557e4d4e6d4c4d7c7d5c5d5e5f5c5d6c466e6f4e4f6e7f487b4d4f4c4d4e6c6d466f5d5e5f6e6f4d4e6e504c555455434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343051906190719051b051c0a170000021a061b071b0e1c07140000081b081a0819
555454557c7d5c5d5e5f6c6d6e6f6c6d7c7d6d7e525352575858595d4d525c6c6d4e7f6d6e6f7e7f7c7d7e4c54545554434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343041a0f15091800000000000007160717121c0e1909110000031a091c091b0218
54555454544c4d514f487c5252527c7d7e7f7d5253535367686869465253537c7d5c7c7d7e7f51514d4e4f545454545443434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434312140a1900000000000005160614000000000000000000000000000000000000
5454515454555d5e5f7f52535052537d7e7f7d525357586b684b6a595252535d5e7d7e7f4e4f5e5c5d5e5554545154544343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000
5454545554556d6e6f6d52535352526f6c6d5052576b68684a68686952505d6d6e4c5353534e5d486d6e5454555454544343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000
7c555454547c7d7e7f7d7e5252537e7f475758586b6868686868686a58594c7d4652535252536d7c487e7f545554557f4343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041a1a10000000007070b0b13132701210121210000000007070b0b13132721a12121210000000007070b0b131327012101010100000000
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
010a00000e7140e7120e7220e7220e7320e7320e7420e7420e7420e7420e7320e7320e7220e7220e7120e715147000c7000870005700027000170000700007000070000700007000070000700007000070000700
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
490900001a644326351a644326350960000300091000000037600091000e6000e6000960000300091001f60013600026000e6000e600026000260009100003001f6002b6001f6001f6003f600000000000000000
01170000091630010037500375000264002635026450e6000916300000375000910002640026350960137500091631f625136003750002640026350260137500091630e6340e6350e6000e600026451f62300000
110500002b5462b54609503005002b5462b546095030050037500375000950000500005000050000500005001f000210001d000180001f000210001d000180000050000500005000050000500005000050000500
0117000000000000000e050110501505015052150521505215045000001305011050130500e056110501105211052110450c050100501004011050130500e056100500c0500e0500e0500e0520e0520e0500e045
c51700000216502165001000515004150041450015000150021650216500100001000015004155041550010002165021650216500100051650210000150001500216502165001000010000000021550515507155
1117000000000000000e050110501505015052150521505215045000001305011050130500e056110501105211052110450c050100501004011050130500e056100500c0500e0500e0500e0520e0520e0500e045
2917000010552115570e5400e5400e5420e5450c0000c1300e1301113013130151301513215132131301113018130181321813218135101301313715130171301a1301a1321a1321a1321a1221a1131104411052
0d1700001d0401c0471f0401a0401a0401a04218040180251d0401c0411c0351f0401f0471d0401d0401c0411a0401d0471c0401f0401f0401d0401d040180411a0401a0401a035180001d0471c0401a04718040
0d1700001a0401c0471d0401f0401a0401a04221040210401f0401d0401d0251f0401f0471d0401c0401804118040150401504015045210401c0401d0401804118040170401704500000210401c0401f0411f042
191700000e5000e5000e5000e500180001800018000131300e130111301313015130151321513213130111301313013132131321313511130101300e1370c1300e1300e1320e1320e13511564115601156211555
7d1700001105010000130500e0500e0500e0520c0500c045110501005110055130000e0550e0550e055100000e0501105710050130501305011050110500c0510e0500e0500e0450c0000c0550c0550c0000c055
7d1700000e05510000130500e0520e055000021505015052130501105011045130000e0750e075100000c0401005110050100550e0000e0750e000180000c050110511105211055110000e0000e0000e00000000
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
a90600001f7601f760007001f7601f760007001c7601c7601c7621c7621c7621c7601c7601c7601c7601c76500700007000070000700007000070000700007000070000700007000070000700007000000000000
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