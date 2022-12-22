pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
function _draw()
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

function _update()
	trace("bit",function()
		for i=0,2000 do
			dist_bit(13,29)
		end
	end)
	trace("trig",function()
		for i=0,2000 do
			dist_trig(13,29)
		end
	end)

end
-->8
a=[[[[]]
freq=1
last_t=0
targ_t=0
frame={name="_",chld={}}
function trace_fn(name)
	local orig=_ENV[name]
	_ENV[name]=function(...)
		return trace(name,orig,...)
	end
end

function trace(name,fn,...)
 if t()~=last_t then
		run=t()>targ_t
		if run then
			printh("","log")
		end
	end
	local s,fr
	
	if run then
		s,fr=stat(1)
		local lc=frame.chld[#frame.chld]
		if lc and lc.name==name then
			fr=lc
		else
			fr=add(frame.chld,{
				name=name,
				parent=frame,
				chld={},
				t=0
			})
		end
		frame=fr
		targ_t,last_t=t()+freq,t()
	end
	
	local r=fn(...)
	
	if run then
		local diff=stat(1)-s
		fr.t=fr.t+diff
		frame=frame.parent
		if frame.name=="_" then
			print_frame(frame,-1)
			frame.chld={}
		end
	end
	
	return r
end

function print_frame(f,n)
	if f.t then
		for i=1,n do
			printh(" \0","log")
		end
		printh(f.name..": "..f.t,"log")
	end
	for c in all(f.chld) do
		print_frame(c,n+1)
	end
end

trace_fn("_draw")
trace_fn("_update")
trace_fn("cls")
trace_fn("sqrt")
--]]

__gfx__
00000000022222000000000006666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000022ddd2200000000066555660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070022ddd2200000000066555660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000222d22200000000066656660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000222222200000000066666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070022ddd2200000000066555660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000022ddd2200000000066555660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000222d22200000000066656660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000022222000000000006666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
