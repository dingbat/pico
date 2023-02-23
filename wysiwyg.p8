pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
poke(0x5f2d,3)

cf=0
curs=0
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
	
	if load_error then
		rectfill(10,10,118,118,5)
		rect(10,10,118,118,6)
		?"oh no! the clipped string",13,13,7
		?"wasn't generated here!\n"
		?"if the string below isn't"
		?"right, press \f9ctrl-v\f7.\n"
		
		print_esc(stat"4",13,50,116,11)
		
		local xo=45
		local yo=105
		local ok={xo,yo,xo+30,yo+8,13}
		button(
			"ok",
			ok,
			{13,2},
			function()
				load_error=nil
			end
		)
		rectfill(unpack(ok))
		?"  ok",xo+4,yo+2,7
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
	
	if load_error then
		if hovbtn.name!="ok" then
			hovbtn={}
		end
		load_cc()
	end
	
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
		if menudx==0 then
			menudx=menux==0 and 6 or -6
		end
		key=""
	end
	
	menux+=menudx
	menudx/=1.1
	if menux>45 or menux<0 then
		menux=menudx>0 and 45 or 0
		menudx=0
	end
	
	newclk=btnp"5" and not lastclk
	lastclk=btn"5"
	if not btn"5" then
		dragl=nil
	elseif dragl then
		dragl.x+=mx-pmx
		dragl.y+=my-pmy
	end
	
	if btnp"5" and key=="" then
		if hovbtn and hovbtn.fn then
			hovbtn.fn()			
		elseif not dragl and (
			menux>0 or mx>mw)
		then
			sel,seli=nil
		end
	end

	poke(0x5f30,key=="p" and 1)
end
-->8
mw=42

function edit(l)
	mode=2
	curs=#l.txt
	if menux!=0 then
		menudx=-6
	end
end

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
					edit(sel)
				end
			end
		)
		spr(16+i*2,3+i*w,1,2,2)
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
	camera(menux+56,50)
	?"⁶jhk⁵ghᶜ7codes⁶jgi⁵gjᶜ7control⁶jgg⁵gg⁶t⁶=ᶜ7wysiwyg"
	camera(menux)
	
	local yo=45
	local loadd={2,yo,mw-2,yo+14,13}
	button(
		"load",
		loadd,
		{13,2},
		function()
			load_cc()
		end
	)
	rectfill(unpack(loadd))
	?"load from\nclipboard",4,yo+2,7
	
	yo+=20
	
	local saved={2,yo,mw-2,yo+14,13}
	if not savet then
		button(
			"save",
			saved,
			{13,2},
			save
		)
		savetxt=" save to\nclipboard"
	else
		saved[5]=3
		if time()-savet>1 then
			savet=nil
		end
		savetxt="\|j copied!"
	end
	rectfill(unpack(saved))
	?savetxt,4,yo+2,7

	?"editor\nbackground",2,87,6
	color_wheel(100,home,"fg")
end

function clone(obj)
	local copy={}
	for k,v in next,obj do
		copy[k]=v
	end
	return copy
end

function draw_layers()
	?"layers",2,13,7
	
	local cyo=117
	local copy={1,cyo,mw/2-2,cyo+8,13}
	if sel then
		button(
			"copy",
			copy,
			{13,2},
			function()
				local copy=clone(sel)
				seli+=1
				sel=add(layers,copy,seli)
			end
		)
	else
		pal(7,6)
		pal(13,5)
	end
	rectfill(unpack(copy))
	?"copy",3,cyo+2,7
	
	local cyo=117
	local dell={mw/2,cyo,mw-2,cyo+8,13}
	if sel then
		button(
			"del",
			dell,
			{13,2},
			function()
				del(layers,sel)
				seli,sel=nil
			end
		)
	end
	rectfill(unpack(dell))
	?"\-jdel",mw/2+2,cyo+2,7
	
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
		
		clip(-menux,y,mw,h)
		local txt="\f"..alpha(l.fg)
			..l.txt
		if l.bg then
			txt="\#"..alpha(l.bg)..txt
		end
		?txt,16,y+4
		clip()
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
			if puny then
				key=smallcaps(key)
			end
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
	
	local punyd={2,34,7,39,7}
	button(
		"puny",
		punyd,
		{7,10},
		function()
			puny=not puny
		end
	)
	if puny then
		spr(11,2,34)
	else
		rect(unpack(punyd))
	end
	pal()
	?"PUNYFONT",10,34,6
	for i,k in next,{"w","t","=","i","b"} do
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

function unalpha(c)
	local o=ord(c)
	if o>57 then
		return o-87
	end
	return tonum(c)
end

function diff(k,prev,new)
	local p=prev[k] or false
	local n=new[k] or false
	if k=="bg" then
		k="#"
	end
	
	if p==n then
		return ""
	elseif p and not n then
		return "⁶-"..k
	elseif type(n)=="boolean" then
		return "⁶"..k
	elseif k=="fg" then
		return	"ᶜ"..alpha(n)
	elseif k=="#" then
		return "²"..alpha(n)
	end
end

function l2cc(l,prev)
	prev=prev or {b=true}
	local x,y,ex,ey=
		alpha(l.x\4),
		alpha(l.y\4),
		alpha(l.x%4+16),
		alpha(l.y%4+16)
	
	local cc="⁶j"..x..y
	if ex!="g" and ey!="g" then
		cc..="⁵"..ex..ey
	elseif ex!="g" then
		cc..="³"..ex
	elseif ey!="g" then
		cc..="⁴"..ey
	end
	
	cc..=diff("w",prev,l)
	cc..=diff("t",prev,l)
	cc..=diff("=",prev,l)
	cc..=diff("i",prev,l)
	cc..=diff("b",prev,l)
	cc..=diff("fg",prev,l)
	cc..=diff("bg",prev,l)
	cc..=l.txt
	
	return cc
end

function save()
	local out="?\""
	local prev
	for i=#layers,1,-1 do
		local l=layers[i]
		out..=l2cc(l,prev)
		prev=l
	end
	out..="\\0\""
	printh(out,"@clip")
	savet=time()
end

function preview()
	pal()
	local a={}
	for i=#layers,1,-1 do
		local l=layers[i]
		cursor()
		local x1,y1,x2,y2=l.x,l.y,
			print(l2cc(l).."\0")
		
		local r={x1-2,y1-2,x2,y2,7}
		if l==sel or not sel then
			button(
				hovbtn.data==l or dragl==l,
				r,
				{7,10},
				function()
					if not dragl or l==sel
						or not sel then
						if sel==l and selt and
							t()-selt<.4 and newclk then
							edit(l)
						end
						if newclk then
							selt=t()
						end
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

function load_cc()
	load_error=1
	local str=stat"4"
	layers={}
	
	local i=1
	function nxt(match,keep)
		local s=sub(str,i,i+#match-1)
		if match==s then
			if (not keep) c(#match)
			return s
		end
	end
	function c(n)
		local s=sub(str,i,i+n-1)
		i+=n
		return s
	end
	
	local layer={b=true}
	
	if nxt"?\"" then
		-- remove trailing "
		str=sub(str,1,#str-1)
	end
	
	if sub(str,i,i+1)!="⁶j" then
		load_error=1
		return
	end
	
	while i<=#str do
		nxt"\\0"
		if nxt"⁶j" then
			prev=layer
			if layer.x then
				add(layers,layer,1)
			end
			layer=clone(prev)
			layer.txt=""
			local x,y=
				unalpha(c"1")*4,
				unalpha(c"1")*4
			
			local ax,ay=16,16
			if nxt"⁵" then
				ax,ay=
					unalpha(c"1"),
					unalpha(c"1")
			elseif nxt"³" then
				ax=unalpha(c"1")
			elseif nxt"⁴" then
				ay=unalpha(c"1")
			end
			
			layer.x,layer.y=
				x+ax-16,y+ay-16
			
			while
				nxt("⁶",true) or
				nxt("ᶜ",true) or
				nxt("²",true)
			do
				if nxt"⁶" then
					if nxt"-" then
						local k=c"1"
						if (k=="#") k="bg"
						layer[k]=false
					else
						layer[c"1"]=true
					end
				end			
				if nxt"ᶜ" then
					layer.fg=unalpha(c"1")
				end
				if nxt"²" then
					layer.bg=unalpha(c"1")
				end
			end
		else
			layer.txt..=c"1"
		end
	end
	add(layers,layer,1)
	return true
end
-->8
specials={
	["⁶"]={56,10,1},
	["⁵"]={55,9,2},
	["⁴"]={54,9,1},
	["³"]={53,9,1},
	["²"]={52,10,1},
	["ᶜ"]={51,10,1},
}

function print_esc(str,x,y,xlim,col)
	local cx,cy=x,y
	local crn,c=0
	for i=1,#str do
		local sp=specials[str[i]]
		if sp then
			sp,c,crn=unpack(sp)
			if sp==56 and str[i+1]=="j" then
				crn,c=3,8
			end
			if str[i+1]=="-" then
				crn=2
			end
			pal(7,c)
			spr(sp,cx,cy)
			cx+=4
		else
			if crn>0 then
				crn-=1
				pal(col,c)
			end
			cx=print(str[i],cx,cy,col)
		end
		pal()
		if cx>=xlim then
			cx,cy=x,cy+6
		end
	end
end
-->8
--smallcaps
--by felice
--https://www.lexaloffle.com/bbs/?pid=24069#p
function smallcaps(s)
  local d=""
  local l,c,t=false,false
  for i=1,#s do
    local a=sub(s,i,i)
    if a=="^" then
      if(c) d=d..a
      c=not c
    elseif a=="~" then
      if(t) d=d..a
      t,l=not t,not l
    else 
      if c==l and a>="a" and a<="z" then
        for j=1,26 do
          if a==sub("abcdefghijklmnopqrstuvwxyz",j,j) then
            a=sub("\65\66\67\68\69\70\71\72\73\74\75\76\77\78\79\80\81\82\83\84\85\86\87\88\89\90\91\92",j,j)
            break
          end
        end
      end
      d=d..a
      c,t=false,false
    end
  end
  return d
end
__gfx__
00000000050000000050000000000000000000000000000000000000000000000666660000000000000000007777770000000000000000000000000000000000
00000000575000000575000000000000000000000000000000000000000000006000006000000000006000007333370000000000000000000000000000000000
00700700577500000575555005555550000000000000000000000000000000006006006000600000066600007333370000000000000000000000000000000000
00077000577750005575757555757575000000000000000000000000000000006066606000600000606060007333370000000000000000000000000000000000
00077000577775007577777575777775000000000000000000000000000000006006006000600000006000007333370000000000000000000000000000000000
00700700577550005777777557777775000000000000000000000000000000006000006060606000006000007777770000000000000000000000000000000000
00000000055750000557775005577750000000000000000000000000000000000666660006660000006000000000000000000000000000000000000000000000
00000000000500000005550000055500000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000
00000000000000000022222220000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222200000000000020000020000000000022200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02222220000000002220020020000000000222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222000000002020202020000000002222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02222020000000002020000020000000022222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02202220000000002022222220000000202220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02202220000000002000002000000000200200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000002222222000000000222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000077700000770000007770000070700000077000007000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000070000000770000077700000070000007770000000000000000000000000000000000000000000000000000000000000
00000000000000000000000077700000077000007770000000700000770000007770000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000077700000777000007770000077700000777000007770000000000000000000000000000000000000000000000000000000000000
