pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
--wysiwyg ctrlcode editor
--eeooty

--devkit
poke(0x5f2d,3)

--prevent scrolling when
--printing text near the
--bottom of the screen
poke(0x5f36,0x40)

cf=0
curs=0
mode=0
scroll=0
layers={}
hovbtn={}
sel=nil
seli=nil
menux=0
menudx=0

home={
	fg=0
}

default_layer={
	b=true,
	xs=4,
	ys=6,
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

	if ins then
		local win={mw+1,24,
			mw+70,111,1}
		add(buttons,{
			name="inswin",
			r=win,
		})
		local wx,wy=unpack(win)
		rectfill(unpack(win))
		win[5]=5
		rect(unpack(win))
		?"insert:",wx+3,wy+3,6

		for i,c in next,split"¹,²,³,⁴,⁵,⁶,ᵇ,ᶜ" do
			local s=specials[c]
			local y=wy+4+i*8
			local b={wx+3,y-1,wx+7,y+5,13}
			button(
				"insert"..c,
				b,
				{13,2},
				function()
					type_txt(c)
					ins=false
				end
			)
			rectfill(unpack(b))
			spr(s[1],wx+4,y)
			pal()
			?s.d,wx+12,y,13
		end

		local paste={wx+3,wy+76,
			wx+45,wy+84,13}
		button(
			"paste text",
			paste,
			{13,2},
			function()
				type_txt(stat"4")
				ins=false
			end
		)
		rectfill(unpack(paste))
		?"paste text",wx+5,wy+78,7
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

	if hovbtn.name=="inswin" then
		hovbtn={win=true}
	end
	if load_error then
		if hovbtn.name!="ok" then
			hovbtn={}
		end
		load_cc()
	end

	if (mode<2 or menux!=0) and sel then
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

	--height of viewport: 93
	--content height: layers*12
	local s=stat"36"
	if mode==1 and mx<mw then
		scroll-=s*2
		scroll=mid(
			scroll,
			#layers*12-90)
	end

	key=stat"31"
	if key=="\t" then
		if menudx==0 then
			menudx=menux==0 and 6 or -6
			ins=false
		end
		key=""
	elseif key=="\r" then
		key="\n"
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
		if hovbtn.fn then
			hovbtn.fn()
		elseif not dragl and not
			hovbtn.win and
			(menux>0 or mx>mw)
		then
			sel,seli=nil
		end
	end

	poke(0x5f30,(key=="p" or key=="\n") and 1)
end
-->8
mw=42

function edit(l)
	mode=2
	curs=#l.txt
	ins=false
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
				ins=false
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
	-- :-)
	?"⁶j28⁵iiᶜ0editor⁶j28⁵ihᶜdeditor⁶j16⁵iiᶜ0ctrlcode⁶j16⁵ihᶜdctrlcode⁶j23⁴h⁶tᶜ0wysiwyg⁶j23⁴h⁶=ᶜ8wysiwyg⁶j23⁴hᶜ9⁶y4wysiwyg⁶j23⁴hᶜa⁶y3wysiwyg⁶j23⁴hᶜb⁶y2wysiwyg⁶j23⁴hᶜc⁶y1wysiwyg\0"

	local yo=43

	local saved={2,yo,mw-2,yo+14,13}
	if not savet then
		button(
			"save",
			saved,
			{13,2},
			function()
				local txt=save(layers)
				txt="?\""..txt.."\\0\""
				printh(txt,"@clip")
				savet=time()
			end
		)
		savetxt=" \fbsave\f7 to\nclipboard"
	else
		saved[5]=3
		if time()-savet>1 then
			savet=nil
		end
		savetxt="\|j copied!"
	end
	rectfill(unpack(saved))
	?savetxt,4,yo+2,7

	yo+=17

	local loadd={2,yo,mw-2,yo+14,13}
	if not loadt then
		button(
			"load",
			loadd,
			{13,2},
			function()
				load_cc()
				if not load_error then
					loadt=time()
				end
			end
		)
		loadtxt="\fcload\f7 from\nclipboard"
	else
		loadd[5]=12
		if time()-loadt>1 then
			loadt=nil
		end
		loadtxt="\|j loaded!"
	end
	rectfill(unpack(loadd))
	?loadtxt,4,yo+2,7

	?"editor\nbackground",2,79,6
	color_wheel(92,home,"fg")

	?"tab\^x2 \^x4to\^x2 \^x4hide",2,121,13
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
			sel=add(layers,
				clone(default_layer),seli)
			sel.fg=7
			sel.txt="txt"
			sel.x=64
			sel.y=64
		end
	)
	spr(8,34,12)
	camera(menux,scroll)
	for i,l in inext,layers do
		clip(0,21,mw+1,93)
		local h=12
		local y=i*h+9
		local by=y-scroll
		--row
		rectfill(0,y,mw,y+h,
			sel==l and 13 or 5)
		rect(0,y,mw,y+h,13)

		if menux==0 then
			add(buttons,{
				r=clip_rect{0,by,mw,by+h},
				fn=function()
					sel,seli=l,i
				end
			})
		end

		if i>1 then
			button(
				"up"..i,
				clip_rect{0,by,5,by+8},
				{6,10},
				function()
					layers[i],layers[i-1]=
						layers[i-1],l
				end
			)
			spr(10,2,y+2)
		end

		if i<#layers then
			button(
				"down"..i,
				clip_rect{6,by,11,by+8},
				{6,10},
				function()
					layers[i],layers[i+1]=
						layers[i+1],l
				end
			)
			spr(9,8,y+2)
		end

		pal()

		clip(-menux,y-scroll,mw,h,true)
		local txt="\f"..alpha(l.fg)
			..gsub(l.txt,"\n","■")
		if l.bg then
			txt="\#"..alpha(l.bg)..txt
		end
		?txt,16,y+4
		clip()
	end
end

function textbox(y)
	local ptext=gsub(
		sel.txt,"\n","■")
	local wid=max(
		print_esc(ptext,0,150)+4,
		mw-2
	)
	rectfill(1,y,1+wid,y+10,13)
	rect(1,y,1+wid,y+10,7)

	print_esc(ptext,4,y+3,nil,7)

	if cf<15 then
		--calculate cursor based off
		--printing in case there are
		--wide chars like ▒🐱●
		local s=sub(ptext,1,curs)
		local cx=3+print_esc(s,0,150)
		line(cx,y+2,cx,y+8,7)
	end

	if menux==0 then
		if btnp(⬅️) then
			curs-=1
		elseif btnp(➡️) then
			curs+=1
		end
	end

	type_txt(key)
end

function type_txt(inp)
	local chars=split(sel.txt,"")
	for c in all(split(inp,"")) do
		if c=="\b" then
			deli(chars,curs)
			curs-=1
		else
			curs+=1
			if puny then
				local ko=ord(c)
				if ko>=ord"a" and ko<=ord"z" then
					c=chr(ko-32)
				end
			end
			add(chars,c,curs)
		end
		sel.txt=join(chars)
	end
	curs=mid(0,curs,#chars)
end

function draw_edit()

	if not sel then
		?"no layer\nselected\nto edit!",2,12,10
		return
	end

	if menux<40 then
		textbox(12)
	end

	local punyd={1,26,6,31,7}
	button(
		"puny",
		{1,26,23,31},
		{7,10},
		function()
			puny=not puny
		end
	)
	if puny then
		spr(11,1,26)
	else
		rect(unpack(punyd))
	end
	pal()
	?"PUNY",9,26,hovbtn.name=="puny" and 7 or 6

	local insd={27,25,mw-1,32,13}
	button(
		"ins",
		insd,
		{13,2},
		function()
			ins=not ins
		end
	)
	rectfill(unpack(insd))
	?"INS",29,26,7

	for i,k in next,split"w,t,=,i,b" do
		i-=1
		local w,xo,yo=8,1,44
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

	number(1,36,"x","xs")
	number(24,36,"y","ys")

	?"fg color",2,57,6
	color_wheel(64,sel,"fg")
	?"bg color",2,93,6
	color_wheel(100,sel,"bg")
end

function number(x,y,label,k)
	local def=k=="xs" and sel[k]==4
		or k=="ys" and sel[k]==6
	?label,x+5,y,6
	local fx=?sel[k],x+10,y,def and 13 or 10
	button(
		k.."-",
		{x,y,x+4,y+5},
		{6,7},
		function()
			sel[k]=max(sel[k]-1)
		end
	)
	?"◀",x,y,6
	x=fx
	button(
		k.."+",
		{x,y,x+4,y+5},
		{6,7},
		function()
			sel[k]=min(sel[k]+1,32)
		end
	)
	?"▶",x+1,y,6
	pal()
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

function clip_rect(r1)
	local r2={0,21,mw+1,21+93}
	if not int(r1,r2,0) then
		return {-1,-1,-1,-1}
	end

	local x1,x2=
		max(r2[1],r1[1]),
		min(r2[3],r1[3])
	local y1,y2=
		max(r2[2],r1[2]),
		min(r2[4],r1[4])
	return {x1,y1,x2,y2}
end

function gsub(str,old,new)
	local s=""
	for i=1,#str do
		if str[i]==old then
			s..=new
		else
			s..=str[i]
		end
	end
	return s
end
-->8
function button(
	name,r,cols,fn,data,non_menu
)
	pal()
	if
		type(name)=="boolean" and
			name or
		type(name)=="string" and
			hovbtn.name==name then
		pal(unpack(cols))
	end
	if non_menu or menux==0 then
		add(buttons,{
			r=r,
			name=name,
			fn=fn,
			data=data,
		})
	end
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
	elseif k=="xs" then
		return "⁶x"..alpha(n)
	elseif k=="ys" then
		return "⁶y"..alpha(n)
	end
end

function l2cc(l,prev)
	prev=prev or default_layer
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

	if #split(l.txt,"\n")>1 then
		--has newline, so we have
		--to set a home point so
		--the line starts at the
		--right x-offset
		cc..="⁶h"
	end

	foreach({
		"w","t","=","i","b",
		"fg","bg","xs","ys"
	},function(k)
		cc..=diff(k,prev,l)
	end)

	cc..=l.txt

	return cc
end

function save(layers)
	local out=""
	local prev
	for i=#layers,1,-1 do
		local l=layers[i]
		local cc=l2cc(l,prev)
		out..=cc
		--re-parse generated text
		--to include any cc's entered
		--in the text field
		local sofar=parse(out)
		prev=sofar[1].extra
	end
	out=gsub(out,"\n","\\n")
	out=gsub(out,"\"","\\\"")
	return out
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
				l,true
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

function parse(str)
	local i=1
	local layer={
		extra=default_layer
	}
	local layers={}
	
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
	
	local function check_cc(l)
		while
			nxt("⁶",true) or
			nxt("ᶜ",true) or
			nxt("²",true)
		do
			if nxt"⁶" then
				if nxt"-" then
					local k=c"1"
					if (k=="#") k="bg"
					l[k]=false
				elseif nxt"x" then
					l.xs=unalpha(c"1")
				elseif nxt"y" then
					l.ys=unalpha(c"1")
				else
					l[c"1"]=true
				end
			end
			if nxt"ᶜ" then
				l.fg=unalpha(c"1")
			end
			if nxt"²" then
				l.bg=unalpha(c"1")
			end
		end
	end
	
	while i<=#str do
		--ignore \0 and \^h, they
		--get auto-added
		nxt"\\0"
		nxt"⁶h"
		if nxt"⁶j" then
			--if not the default layer...
			if layer.x then
				add(layers,layer,1)
			end
			layer=clone(layer.extra)
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

			check_cc(layer)
			layer.extra=clone(layer)
		else
			local j=i
			
			--put any cc's found in txt
			--into layer.extra
			check_cc(layer.extra)
			
			--add back whatever we
			--consumed into the original
			--layer (don't care about
			--extra)
			if i!=j and layer.extra then
				layer.txt..=sub(str,j,i-1)
			end
		
			local t
			if nxt"\\n" then
				t="\n"
			elseif nxt"\\\"" then
				t="\""
			else
				t=c"1"
			end
			layer.txt..=t
		end
	end
	add(layers,layer,1)
	
	return layers
end

function load_cc()
	local str=stat"4"
	sel,seli=nil

	--trim trailing "\n"
	if str[#str]=="\n" then
		str=sub(str,1,#str-1)
	end
	if sub(str,1,2)=="?\"" then
		-- trim trailing "
		str=sub(str,3,#str-1)
	end

	if sub(str,1,2)!="⁶j" then
		load_error=1
		return
	end
	
	layers=parse(str)

	return true
end
-->8
specials={
	["⁶"]={56,10,1,d="\\^ (special)"},
	["⁵"]={55,9,2,d="\\+ (move x/y)"},
	["⁴"]={54,9,1,d="\\| (move y)"},
	["³"]={53,9,1,d="\\- (move x)"},
	["²"]={52,10,1,d="\\# (bg col)"},
	["¹"]={51,10,2,d="\\* (repeat)"},
	["ᵇ"]={57,10,2,d="\\v (decorate)"},
	["ᶜ"]={58,10,1,d="\\f (fg col)"},
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
			if count({"-","x","y"},str[i+1])==1 then
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
		if xlim and cx>=xlim then
			cx,cy=x,cy+6
		end
	end
	return cx,cy
end
-->8
--tests

local i=0
function example(expected)
	--assert that parsing and
	--saving gives us back the
	--same result
	i+=1
	local got=save(parse(expected))

	if got!=expected then
		cls()
		?"example "..i.." failed!",6
		local x,y=0,14
		?"got:",0,y,7
		y+=7
		x,y=print_esc(got,0,y,128,6)
		y+=7
		?"exp:",0,y+7,7
		print_esc(expected,0,y+14,128,6)
		?""
		assert(
		false)
	end
end

example"⁶jgh³h⁶wᶜ21⁶jhe⁴h⁶-w2⁶jf7⁴iᶜ73"
example"⁶jgh³h⁶wᶜ21⁶jhe⁴h⁶-w2aᶜ7x⁶jf7⁴i3"
example"⁶j59⁵ji⁶w⁶tᶜ0a⁶j78⁵jj⁶-w⁶-t⁶y7b⁶x3 .⁶x2⁶jea⁵ii⁶x4⁶y6c"
example"⁶j59⁵ji⁶w⁶tᶜ0age of ants⁶j78⁵jj⁶-w⁶-t⁶y7.     .       ⁶x3 .⁶x2     .⁶jea⁵ii⁶x4⁶y6.           .⁶j59⁵ih⁶w⁶tᶜ7age of ants⁶jea⁵hh⁶-w⁶-t.           .⁶j78⁵ii⁶y7.     .       ⁶x3 .⁶x2     .⁶jbf³iᶜ0⁶x4⁶y6difficulty:⁶jbe⁵ijᶜcdifficulty:⁶j8mᶜ0press ❎ to start⁶j8l⁴jᶜ9press ❎ to start⁶jqt⁴hᶜ0v1.5⁶jqtᶜ6v1.5⁶j2t⁴hᶜ0eeooty⁶j2tᶜ6eeooty⁶j8pᶜ0pause for options⁶j8o⁴jᶜapause for options⁶jeh⁵jiᶜ6"
__gfx__
00000000050000000050000000000000000000000000000000000000000000000666660000000000000000007777770000000000000000000000000000000000
00000000575000000575000000000000000000000000000000000000000000006000006000000000006000007333370000000000000000006666000000000000
00700700577500000575555005555550000000000000000000000000000000006006006000600000066600007333370000000000000000006006000000000000
00077000577750005575757555757575000000000000000000000000000000006066606000600000606060007333370000000000000000006066660000000000
00077000577775007577777575777775000000000000000000000000000000006006006000600000006000007333370000000000000000006060060000000000
00700700577550005777777557777775000000000000000000000000000000006000006060606000006000007777770000000000000000006660060000000000
00000000055750000557775005577750000000000000000000000000000000000666660006660000006000000000000000000000000000000060060000000000
00000000000500000005550000055500000000000000000000000000000000000000000000600000000000000000000000000000000000000066660000000000
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
00000000000000000000000077000000770000007770000070700000077000007000000077000000777000000000000000000000000000000000000000000000
00000000000000000000000007000000070000000770000077700000070000007770000077700000700000000000000000000000000000000000000000000000
00000000000000000000000077700000077000007770000000700000770000007770000077700000777000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000077700000777000007770000077700000777000007770000077700000777000000000000000000000000000000000000000000000
