pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- cpu cycle profiler v1.1
--  by pancelor
--  based on code by samhocevar:
--   https://www.lexaloffle.com/bbs/?pid=60198#p

--[[
writing code:
* put code you want to measure inside analyze()
  * see the existing examples
  * feel free to delete everything inside analyze()
* use log("your msg here") to add lines to the log
* to automatically measure one snippet relative
  to another "baseline" snippet, search for the
  example that uses "local dat=profile(" and
  "{compare=dat}"

running:
* run the cart; the results will be printed to the
  screen and also to the printh output, if you have
  a setup that lets you view it
  (e.g. https://www.lexaloffle.com/bbs/?tid=42367 )
* the output tells you how many lua and system cycles
  it took to execute the body of that function
* scroll the results with the arrow keys
  or the mouse wheel

see the second tab for an explanation of the
calculation that figures out how many cycles
the given code takes
]]

function dist1(dx,dy)
	local x,y=dx>>31,dy>>31
	local a0,b0=dx+x^^x,dy+y^^y
	return max(a0,b0)*.9609+
		min(a0,b0)*.3984
end

function dist2(dx,dy)
	local x,y=dx>>31,dy>>31
	local a0,b0=dx+x^^x,dy+y^^y
	return a0>b0 and
		a0*.9609+b0*.3984 or
		b0*.9609+a0*.3984
end

a={}
for i=0,20 do
	add(a,2)
end

heal={{qty=1}}
u={hp=1,p=1}

function fsel(a,func,...)
	for u in all(a) do
		func(u,...)
	end
end

function xx()
end

cartdata"abc"
function analyze()
  profile("inext", function()
  	for _,u in inext,a do
  		xx(u)
			end
  end)
  profile("all()", function()
  	for u in all(a) do
  		xx(u)
			end
  end)
end

function dist_trig(dx,dy)
	local ang=atan2(dx,dy)
	return dx*cos(ang)+dy*sin(ang)
end

function dist_bit(dx,dy)
 local maskx,masky=dx>>31,dy>>31
 local a0,b0=(dx+maskx)^^maskx,
 	(dy+masky)^^masky
 return a0>b0 and
 	a0*0.9609+b0*0.3984 or
  b0*0.9609+a0*0.3984
end
-->8
-- profiler
printh"====="
cls()

function profile_one(func, opts)
  opts=opts or {}
  local compare=opts.compare or {lua=0,sys=0,tot=0}
  local n = opts.n or 0x400
  local args = opts.args or {}

  -- n must be larger than 256, or m will overflow
  assert(n>0x100)

  -- we want to type
  --   local m = 0x80_0000/n
  -- but 8mhz is too large a number to handle in pico-8,
  -- so we do (0x80_0000>>16)/(n>>16) instead
  -- (n is always an integer, so n>>16 won't lose any bits)
  local m = 0x80/(n>>16)

  assert(stat(8)==30) --target fps
  local function cycles(t0,t1,t2) return (t0+t2-2*t1)*m/30 end
  -- given three timestamps (pre-calibration, middle, post-measurement),
  --   calculate how many more cpu cycles func() took compared to nop()
  -- derivation:
  --   t := ((t2-t1)-(t1-t0))/n (frames)
  --     this is the extra time for each func call, compared to nop
  --     this is measured in #-of-frames (at 30fps) -- it will be a small fraction for most ops
  --   f := 1/30 (seconds/frame)
  --     this is just the framerate that the tests run at, not the framerate of your game
  --     can get this programmatically with stat(8) if you really wanted to
  --   m := 256*256*128 = 8mhz (cycles/second)
  --     (pico-8 runs at 8mhz; source: https://www.lexaloffle.com/bbs/?tid=37695)
  --   cycles := t frames * f seconds/frame * m cycles/second
  -- optimization / working around pico-8's fixed point numbers:
  --   t2 := t*n = (t2-t1)-(t1-t0)
  --   m2 := m/n := m (e.g. when n is 0x1000, m is 0x800)
  --   cycles := t2*m2*f

  -- calibrate, then measure
  local nop=function() end -- this must be local, because func is local
  flip()
  local atot,asys=stat(1),stat(2)
  for i=1,n do nop(unpack(args)) end
  local btot,bsys=stat(1),stat(2)
  for i=1,n do func(unpack(args)) end
  local ctot,csys=stat(1),stat(2)

  -- report
  local lua=cycles(atot-asys,btot-bsys,ctot-csys)
  local sys=cycles(asys,bsys,csys)
  local tot=lua+sys
  return {
    lua=lua-compare.lua,
    sys=sys-compare.sys,
    tot=tot-compare.tot,
  }
end
function report(name,dat, opts)
  opts=opts or {}
  local srel=opts.compare and "+" or " "
  local s=name.." :"
    ..srel..leftpad(dat.lua,2)
    .." +"..leftpad(dat.sys,2)
    .." ="..srel..leftpad(dat.tot,2)
    .." (lua+sys)"
  log(s)
end
function profile(name,func, opts)
  local dat=profile_one(func,opts)
  report(name,dat,opts)
  return dat
end

-->8
-- helpers
function leftpad(s,n, ch)
 ch=ch or " "
 s=tostr(s)
 while #s<n do
  s=ch..s
 end
 return s
end

logs={}
function log(s)
  printh(s)
  add(logs,s)
end

-->8
-- game loop
function _init()
  -- setup

  poke(0x5f2d,1) --mouse

  local dat=profile_one(function() end)
  assert(dat.lua==0,dat.lua)
  assert(dat.sys==0,dat.sys)
  -- report("nop",dat)

  x=0
  y=0
  xtarget=0
  ytarget=0
  xmax=64
  ymax=0
  fc=0

  cls()
  print("profiling...")
  flip()
  analyze()
  log""
  log"\f5press x to copy log"
end

function _draw()
  fc+=1
  cls()

  -- copy
  if btnp(5) then
    local s=""
    for i=1,#logs-2 do
      s..=logs[i].."\n"
    end
    printh(s,"@clip")
    logs[#logs]="\f5log copied to clipboard"
  end

  -- camera
  xtarget+=8*(tonum(btn(1))-tonum(btn(0)))
  if xtarget<0 then xtarget*=.65 end
  if xtarget>xmax then xtarget+=(xmax-xtarget)*.65 end
  x+=(xtarget-x)*.65

  ytarget+=8*(-stat(36)+tonum(btn(3))-tonum(btn(2)))
  if ytarget<0 then ytarget*=.65 end
  if ytarget>ymax then ytarget+=(ymax-ytarget)*.65 end
  y+=(ytarget-y)*.65

  camera(x,y)

  if fc<=#logs then sfx(0) end --clickety clickety

  for i=1,min(fc,#logs) do
    local x=print(logs[i],1,i*6,6)
    xmax=max(xmax,x-96)
    ymax=i*6-64
  end
  ymax=max(-16,ymax)

  if ytarget<1 and #logs>20 then
    print("⬆️\n  \n⬇️",120,106,time()%2<1 and 1 or 5)
  end
end


__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
