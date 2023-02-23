pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
poke(0x5f2d,3)

cf=0
mode=0
layers={}
hovbtn={}
sel=nil
seli=nil
menux=0
menudx=0

home={
	fg=0
}

function _draw()
	cls(home.fg)
	buttons={}
	
	preview()

	pal()	
	draw_menu(menux)

	local cursor_spr=1		
	
	if hovbtn.r then
		cursor_spr=2
		if (stat"34">0) cursor_spr=3
		pset(mx-1,my+4,5)
	end
	
	spr(cursor_spr,mx,my)
	
	hovbtn={}
end

function _update()
	cf+=1
	cf%=30
	
	pmx,pmy=mx,my
	mx,my=
		mid(stat"32",127),
		mid(stat"33",127)
		
	foreach(buttons,function(b)
		if int(b.r,{mx,my,mx,my},1) then
			hovbtn=b
		end
	end)
	
	if mode==1 and sel then
		if btnp(⬅️) then
			sel.x-=1
		elseif btnp(➡️) then
			sel.x+=1
		elseif btnp(⬆️) then
			sel.y-=1
		elseif btnp(⬇️) then
			sel.y+=1
		end
	end
	
	key=stat"31"
	if key=="\t" then
		menudx=menux==0 and 5 or -5
		key=""
	end
	
	menux+=menudx
	if menux%50==0 then
		menudx=0
	end

	if not btn"5" then
		dragl=nil
	elseif dragl then
		dragl.x+=mx-pmx
		dragl.y+=my-pmy
	end
	
	if btnp"5" and key=="" then
		if hovbtn and hovbtn.fn then
			hovbtn.fn()			
		elseif not dragl then
			sel,seli=nil
		end
	end

	poke(0x5f30,key=="p" and 1)
end
-->8
mw=42

function draw_menu(x)
	camera(x)
	rectfill(0,0,mw,128,1)
	rectfill(0,0,mw,9,8)
	line(mw+1,0,mw+1,128,5)
	line(mw+1,0,mw+1,9,2)
	
	for i=0,2 do
		local w=mw/3
		button(
			mode==i,
			{i*w,0,i*w+w,9},
			{2,15},
			function()
				mode=i
				if sel and i==2 then
					curs=#sel.txt
				end
			end
		)
		spr(32+i*2,3+i*w,1,2,2)
	end
	
	if mode==0 then
		draw_home()
	elseif mode==1 then
		draw_layers()
	else
		draw_edit()
	end
	
	camera()
end

function draw_home()
	?"preview bg",2,57,6
	color_wheel(64,home,"fg")
end

function draw_layers()
	?"layers",2,13,7
	
	rectfill(0,119,mw,128,8)
	line(mw/2,119,mw/2,128,2)
	button(
		"copy",
		{0,119,mw/2,128},
		{2,15},
		function()
			if sel then
				local copy={}
				for k,v in next,sel do
					copy[k]=v
				end
				seli+=1
				sel=add(layers,copy,seli)
			end
		end
	)
	?"copy",3,121,2
	
	button(
		"del.",
		{mw/2,119,mw,128},
		{2,15},
		function()
			del(layers,sel)
			seli,sel=nil
		end
	)
	?"del.",25,121,2
	
	button(
		"add",
		{34,12,mw,20},
		{6,7},
		function()
			seli=(seli or 0)+1
			sel=add(layers,{
				b=true,
				fg=7,
				txt="txt",
				x=64,
				y=64,
			},seli)
		end
	)
	spr(8,34,12)
	for i,l in inext,layers do
		local h=12
		local y=i*h+9
		rectfill(0,y,mw,y+h,
			sel==l and 2 or 5)
		rect(0,y,mw,y+h,13)
		
		add(buttons,{
			r={0,y,mw,y+h},
			fn=function()
				sel,seli=l,i
			end
		})
		
		pal(6,13)
		if i>1 then
			button(
				"up"..i,
				{0,y,5,y+8},
				{6,10},
				function()
					layers[i],layers[i-1]=
						layers[i-1],l
				end
			)
		end
		spr(10,2,y+2)
		
		pal(6,13)
		if i<#layers then
			button(
				"down"..i,
				{6,y,11,y+8},
				{6,10},
				function()
					layers[i],layers[i+1]=
						layers[i+1],l
				end
			)
		end
		spr(9,8,y+2)
		
		pal()
		
		local txt="\f"..alpha(l.fg)
			..l.txt
		if l.bg then
			txt="\#"..alpha(l.bg)..txt
		end
		?txt,16,y+4
	end
end

function textbox(txt,fn)
	rectfill(1,21,mw-1,31,13)
	rect(1,21,mw-1,31,7)
	?txt,4,24,7
	
	if cf<15 then
		local cx=3+curs*4
		line(cx,23,cx,29,7)
	end
	
	if btnp(⬅️) then
		curs-=1
	elseif btnp(➡️) then
		curs+=1
	end
	
	local chars=split(txt,"")
	if key!="" then
		if key=="\b" then
			deli(chars,curs)
			curs-=1
		else
			curs+=1
			add(chars,key,curs)
		end
		fn(join(chars))
	end
	curs=mid(0,curs,#chars)
end

function draw_edit()
	?"edit layer",2,13,7
	
	if not sel then
		?"no layer\nselected!",2,22,10
		return
	end
	
	textbox(sel.txt,function(txt)
		sel.txt=txt
	end)
	
	?"style",2,36,6
	for i,k in next,{"w","t","s","i","b"} do
		i-=1
		local w,xo,yo=8,1,43
		local dims={xo+i*w,yo,
			xo+w+i*w,yo+8,6}
		rect(unpack(dims))
		button(
			sel[k]==true,
			dims,
			{1,13},
			function()
				sel[k]=not sel[k]
			end
		)
		rectfill(
			xo+1+i*w,yo+1,
			xo-1+w+i*w,yo+7,1)
		pal()
		?k,4+i*w,yo+2,7
	end

	?"fg color",2,56,6
	color_wheel(63,sel,"fg")
	?"bg color",2,93,6
	color_wheel(100,sel,"bg")
end

function color_wheel(yoff,obj,key)
	local val=obj[key]
	local w=6
	rectfill(2,yoff,4*w+3,
		yoff+4*w+1,5)
	for i=0,15 do
		local x,y=i%4,i\4
		local dims={
			3+x*w,
			yoff+1+y*w,
			3+x*w+w-1,
			yoff+1+y*w+w-1,
			i
		}
		rectfill(unpack(dims))
		button(
			i==val,
			dims,
			{i,7},
			function()
				if i==val and key=="bg" then
					i=nil
				end
				obj[key]=i
			end
		)
		if i==val then
			dims[5]=0
			rect(unpack(dims))
		end
	end
end
-->8
function int(r1,r2,e)
	return r1[1]-e<r2[3] and
		r1[3]+e>r2[1] and
		r1[2]-e<r2[4] and
		r1[4]+e>r2[2]
end

function join(arr)
	local str=""
	foreach(arr,function(s)
		str..=s
	end)
	return str
end
-->8
function button(
	name,r,cols,fn,data
)
	pal()
	if
		type(name)=="boolean" and
			name or
		type(name)=="string" and
			hovbtn.name==name then
		pal(unpack(cols))
	end
	add(buttons,{
		r=r,
		name=name,
		fn=fn,
		data=data,
	})
end
-->8
function alpha(c)
	if c>9 then
		return chr(87+c)
	end
	return c
end

function l2cc(l)
	local x,y,ex,ey=
		alpha(l.x\4),
		alpha(l.y\4),
		alpha(l.x%4+16),
		alpha(l.y%4+16)
	
	local cc="⁶j"..x..y
	if ex!=16 and ey!=16 then
		cc..="⁵"..ex..ey
	elseif ex!=16 then
		cc..="³"..ex
	elseif ey!=16 then
		cc..="⁴"..ey
	end
	
	if (l.w) cc..="⁶w"
	if (l.t) cc..="⁶t"
	if (l.s) cc..="⁶="
	if (l.i) cc..="⁶i"
	if (not l.b) cc..="⁶-b"
	
	cc..="ᶜ"..alpha(l.fg)
	if l.bg then
		cc..="²"..alpha(l.bg)
	end
	
	cc..=l.txt
	return cc
end

function preview()
	pal()
	local a={}
	for i=#layers,1,-1 do
		local l=layers[i]
		cursor()
		local x1,y1,x2,y2=l.x,l.y,
			print(l2cc(l))
		
		local r={x1-2,y1-2,x2,y2,7}
		if l==sel or not sel then
			button(
				hovbtn.data==l or dragl==l,
				r,
				{7,10},
				function()
					if not dragl or l==sel
						or not sel then
						sel,seli=l,i
						dragl=l
					end
				end,
				l
			)
		end
		if
			sel==l or dragl==l or
			hovbtn.data==l and not dragl
		then
			rect(unpack(r))
		end
		pal()
	end
end
__gfx__
00000000050000000050000000000000000000000000000000000000000000000666660000000000000000000000000000000000000000000000000000000000
00000000575000000575000000000000000000000000000000000000000000006000006000000000006000000000000000000000000000000000000000000000
00700700577500000575555005555550000000000000000000000000000000006006006000600000066600000000000000000000000000000000000000000000
00077000577750005575757555757575000000000000000000000000000000006066606000600000606060000000000000000000000000000000000000000000
00077000577775007577777575777775000000000000000000000000000000006006006000600000006000000000000000000000000000000000000000000000
00700700577550005777777557777775000000000000000000000000000000006000006060606000006000000000000000000000000000000000000000000000
00000000055750000557775005577750000000000000000000000000000000000666660006660000006000000000000000000000000000000000000000000000
00000000000500000005550000055500000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000022222220000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222200000000000020000020000000000022200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02222220000000002220020020000000000222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222000000002020202020000000002222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02222020000000002020000020000000022222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02202220000000002022222220000000202220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02202220000000002000002000000000200200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000002222222000000000222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
