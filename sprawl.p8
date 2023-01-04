pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
--sprawlopolis
--h

deck={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18}

function _init()
 placed={}
 hand={}
 hand_sel=1
	obj_sel=0
	last_alt=false
	prepare_card_sprites()
	rot_anim=false
	objs={}
 menu_mode=true
	game_over=false
	playing=false
	show_controls=false
	frozen=false
	start_anim=nil
	scores={0,0,0,0,0,0,0,0}
	score_sel=0
	music(0)
end

function start_game()
	playing=true
	show_controls=false
	--freeze until cards are dealt
	frozen=true
	deal={anim=0,obj=0,card=0}
end

function hlen()
 return rawlen(hand)
end

function pick_obj()
 local num=rnd(deck)
 add(objs,num)
 del(deck,num)
end

function pick_card(idx)
 local num=rnd(deck)
 local i=idx or hand_sel
 if num==nil then
  --just del the current card
  del(hand,hand[i])
	else
		hand[i]=num
 	del(deck,num)
	end
end

function set_active_card(x,y)
	n=hand[hand_sel]
	if n then
		cc={
		 n=n,
		 x=(x or hand_sel*4-1),
		 y=(y or 3),
		 f=false
		}
	else
		cc=nil
	end
end

function total_score()
	local score=0
	for i=1,#scores do
	 score+=scores[i]
	end
	return score
end

function goal()
 return objs[1]+objs[2]+objs[3]
end

function handle_menu()
 if game_over then
 	if btnp(⬅️) and score_sel>1 then
 	 score_sel-=1
		end
		if btnp(➡️) and score_sel<8 then
		 score_sel+=1
		end
		if btnp(⬇️) then
			if score_sel>=5 then
			 scores[score_sel]-=1
			elseif scores[score_sel]>0 then
				scores[score_sel]-=1
			end
		end
		if btnp(⬆️) then
			if score_sel!=5 then
			 scores[score_sel]+=1
			elseif scores[score_sel]<0 then
				scores[score_sel]+=1
			end
			if total_score()==goal() then
				sfx(2)
			end
		end
		return
 end
	if (btnp(⬅️)) then
		if hand_sel>1 then
		 hand_sel-=1
		elseif hand_sel==1 then
			hand_sel=0
			show_controls=true
		elseif show_controls then
		 obj_sel=3
		 show_controls=false
		elseif obj_sel>1 then
			obj_sel-=1
		else
			obj_sel=0
			hand_sel=hlen()
		end
	end
	if (btnp(➡️)) then
		if hand_sel>0 and hand_sel==hlen() then
		 hand_sel=0
		 obj_sel=1
		elseif hand_sel>0 then
		 hand_sel+=1
		elseif obj_sel==3 then
		 show_controls=true
			obj_sel=0
		elseif show_controls then
			hand_sel=1
		 show_controls=false
		elseif obj_sel<3 then
			obj_sel+=1
		end
	end
	if hand_sel>0 and btnp(⬇️) then
		menu_mode=false
		set_active_card()
	end
end

function handle_placement()
	if (btnp(⬅️)) cc.x-=1
 if (btnp(➡️)) cc.x+=1
 if (btnp(⬇️)) cc.y+=1
 cc.x=mid(0,cc.x,14)
 cc.y=mid(0,cc.y,15)
 if (btnp(⬆️)) then
  cc.y-=1
  if cc.y <= 2 then
   menu_mode=true
   cc=nil
  end
 elseif btnp(🅾️) then
  sfx(1)
	 rot_anim=1
	 if last_alt==false then
		 last_alt=time()
		else
		 new_hs=hand_sel+1
		 if (new_hs>hlen()) new_hs=1
		 rot_anim=false
		 swap={
		 	from_hs=hand_sel,
		  to_hs=new_hs,
		  x=cc.x,
		  y=cc.y,
		  f=0
		 }
	  last_alt=false
	 end
	elseif btnp(❎) then
		sfx(0)
		add(placed,cc)
		pick_card()
		menu_mode=true
		cc=nil
	 if hlen()==0 then
   game_over=true
			score_sel=1
			obj_sel=0
			hand_sel=0
  elseif hand_sel>hlen() then
  	hand_sel=hlen()
  end
	end
end

function _update60()
 if deal then
  deal.anim+=0.05
  if deal.anim>=1 then
  	deal.anim=0
  	if #objs<3 then
  	 pick_obj()
  	 deal.obj+=1
  	elseif #hand<3 then
  	 pick_card(#hand+1)
  	 deal.card+=1
  	 deal.obj=nil
  	else
  	 deal=nil
  	 frozen=false
  	end
  end
 end
 if (frozen) return
	if start_anim then
		start_anim-=0.1
 end
 if swap then
  swap.f+=0.1
 	if swap.f>=1 then
 	 hand_sel=swap.to_hs
  	set_active_card(swap.x,swap.y)
  	swap=nil
  end
  return
 end
	if rot_anim!=false then
		rot_anim+=15
	end
 if rot_anim and rot_anim>=180 then
  rot_anim=false
		if cc then
		 cc.f=not cc.f
 	 set_card_sprite(cc.n,cc.f)
 	end
 end
 if last_alt!=false and time()-last_alt>0.3 then
	 last_alt=false
	end
	if playing then
		if menu_mode then
			handle_menu()
		elseif not game_over then
		 handle_placement()
		end
	else
		if start_anim and start_anim<=0 then
			start_anim=nil
			start_game()
		elseif btnp(❎) then
			--dissolve logo
			start_anim=1
		end
		--intro menu screen
		if not game_over then
			intro_anim_update()
			if btnp(🅾️) then
				show_controls=not show_controls
			end
		end
	end
end

-->8
--drawing

rounded=true
cardw=8
cardh=6
objw=8
objh=5.5

menu_selectable_col=13

function draw_outline(x,y,col,w,h,empty)
 w=w or cardw
 h=h or cardh
 if not rounded then
	 if not empty then
	  rectfill(x-1,y,x+w*2,y+h*2+1,col)
  else
   rect(x-1,y,x+w*2,y+h*2+1,col)
  end
 else
 	if not empty then
   rectfill(x,y+1,x+w*2-1,y+h*2,col)
 	end
 	pset(x,y+1,col)
 	pset(x+w*2-1,y+1,col)
 	pset(x,y+h*2,col)
 	pset(x+w*2-1,y+h*2,col)
  --top
  line(x,y,x+w*2-1,y,col)
  --bottom
  line(x,y+h*2+1,x+w*2-1,y+h*2+1,col)
  --left
  line(x-1,y+1,x-1,y+h*2,col)
  --right
  line(x+w*2,y+1,x+w*2,y+h*2,col)
 end
end

function draw_card(c,anim)
	local card=cards[c.n]
	local x=c.x
	local y=c.y
	local s=card_spr(c.n)
	if anim and swap then
	 local destx=swap.from_hs*4-1
	 local desty=1
		x-=swap.f*(x-destx)
		y-=swap.f*(y-desty)
	end
	x*=cardw
	y*=cardh
 if anim and rot_anim then
  putspr(s,x-1,y-2,rot_anim,pset,2,2)
 else
  spr(s,x,y,2,2)
	end
end

function draw_bg()
 --bg
 for x=0,7 do
	 for y=0,7 do
	 	spr(64,x*16,y*16,2,2)
	 end
 end
 --table
 x1=2
 x2=118
 y1=20
 y2=95
 spr(66,x1,y1)
 for i=1,(x2-x1)/8 do
  spr(67,2+i*8,y1)
 end
 spr(68,x2,y1)
 for i=1,(y2-y1)/8 do
  spr(113,2,y1+i*8)
 end
 spr(82,x1,y2)
 for i=1,(x2-x1)/8 do
  spr(83,2+i*8,y2)
 end
 spr(84,x2,y2)
 rectfill(x1+1,y1+2,x2+7,y2,4)
 --legs
 for i=1,4 do
  spr(99,x1+3,y2+8+(4-i)*7)
	 spr(99,x2-3,y2+8+(4-i)*7)
 end
 --logo
 if not playing then
	 draw_logo(10,27,start_anim or 1)
	end
end

function draw_hand()
	for i=1,hlen() do
	 local col=menu_selectable_col
	 if i==hand_sel and cc==nil then
	 	col=8
	 end
	 local dy=0
		if deal and deal.card==i then
			dy=-10+deal.anim*10
		end
	 draw_outline((i*4-1)*cardw,0.5*cardh+dy,col)
	 if (i==hand_sel or (swap and i==swap.to_hs)) and cc!=nil then
	  draw_outline((i*4-1)*cardw,0.5*cardh+dy,6,cardw,cardh,true)
		end
		if cc==nil or i!=hand_sel then
		 local x=i*4-1
		 local y=0.5+dy/cardh
			if swap and swap.to_hs==i then
				x-=swap.f*(x-swap.x)
				y-=swap.f*(y-swap.y)
			end
			draw_card({n=hand[i],x=x,y=y})
		end
	end
end

function draw_obj(i)
 local obj=objs[i]
 local snum=obj_num_spr[obj]
 local x=i*42-30
 local tx=x-8
 local y=108
 if deal and i==deal.obj then
 	y+=20-deal.anim*20
 end
 local sel=obj_sel
 if obj_sel==0 and score_sel>0 then
  sel=score_sel<6 and 999 or score_sel-5
 end
 if (sel>0) then
 	x=50+i*20
 	y-=1
 end
 if sel==0 then
		local txt_wid=34
		local txt=obj_shrt[obj]
 	rectfill(tx,y+13,tx+txt_wid,127,1)
 	ctr=flr((txt_wid-#txt*4)/2)+1
  print(txt,tx+ctr,y+14,7)
 end
 pal(1,0)
 draw_outline(x+1,y,1,objw,objh)
 if sel>0 then
  draw_outline(x-1,y-2,1,objw+1,objh+1)
 else
  rectfill(x,y,x+16,y+10,1)
 end
 pal(1,1)
 local col=menu_selectable_col
 if (sel==i) col=8
 draw_outline(x,y-1,col,objw,objh,true)
 spr(8,x,y,2,2)
 spr(snum,x+1,y+1)
end

function draw_deck()
 local deckx,decky=115,5
	draw_outline(deckx,decky-1,2,8,5.5)
	pal(5,7)
	spr(40,deckx,decky,2,2)
	pal(5,5)
	local cnt=#deck<10 and "0"..#deck or #deck
	print(cnt,deckx+3,decky+3,2)
end

function draw_fade(o)
 if (not o) return
	local x,y=3,22
 local height=78
 local width=123
 local totalpx=width*height
 local mod=flr(o*10)
 for i=0,totalpx-1 do
  if i%mod==0 then
  	local dx=i%width
   local dy=flr(i/width)
   pset(x+dx,y+dy,4)
  end
 end
end

score_colors={12,11,9,6,5,10,10,10}
score_tcolors={12,11,9,13,5,10,10,10}
score_names={
 "commercial",
 "parks",
 "residential",
 "industrial",
 "road penalty",
}
score_desc={
 "+1/blk in largest commrcl group",
 "+1/blk in largest park group",
 "+1/blk in largest resdntl group",
 "+1/blk in largest indstrl group",
 "-1/road",
}

function draw_score(x,i)
	local y=6
 local boxh=8
 local boxw=12
 local s=i==score_sel and 117 or 115
 spr(s,x+3,y-6)
	spr(s+1,x+3,y+boxh+2)
	local col=score_colors[i]
	draw_outline(x+1,y,col,boxw/2-0.5,boxh/2-0.5)
	if i==score_sel then
		draw_outline(x+1,y,8,boxw/2-0.5,boxh/2-0.5,true)
	end
	local sc=""..scores[i]
	local tw=#sc>2 and 11 or (#sc>1 and 7 or 3)
	local tx=x+(boxw-tw)/2+1
	local tc=i<=5 and 7 or 1
	pal(1,0)
	print(scores[i],tx,y+2,tc)
	pal(1,1)
end

function draw_scoring()
	for i=1,#scores do
		draw_score(5+15*(i-1),i)
	end
	
	rectfill(0,103,67,111,2)
	
	pal(5,0)
	line(0,102,67,102,5)
	pset(67,103,5)
	pset(68,103,5)
	pset(68,104,5)
	pset(68,105,5)
	pal(5,5)
	
	local score=total_score()
	local g=goal()
	local win=score>=g
	local emo=win and "★" or ""
	local txt="score: "..score.."/"..g.." "..emo
	local tcol=win and 10 or 7
	print(txt,2,105,tcol)
end

function _draw()
	cls()
	draw_bg()
	foreach(placed,draw_card)
	if playing and not game_over then
	 draw_hand()
	 if show_controls then
	  spr(109,4,5,2,2)
	 else
	  spr(77,4,5,2,2)
	 end
	end
	if cc then
		if rot_anim or swap then
		 draw_outline(cc.x*cardw,cc.y*cardh,2,cardw,cardh)
		end
		draw_outline(cc.x*cardw,cc.y*cardh,7,cardw,cardh,true)
		draw_card(cc,true)
	end
	if obj_sel>0 or score_sel>0 then
	 local i=obj_sel
	 if obj_sel==0 then
	  i=score_sel-5
	 end
		pal(1,0)
 	rectfill(0,112,127,127,1)
		pal(1,1)
	 local title,subt,tcol="","",10
	 if score_sel>0 and score_sel<6 then
	 	title=score_names[score_sel]
	 	subt=score_desc[score_sel]
	 else
	  local obj=objs[i]
	 	title=obj_names[obj]
			subt=obj_desc[obj]
		end
		if score_sel>0 then
		 tcol=score_tcolors[score_sel]
		end
		print(title,1,114,tcol)
		printdesc(subt,0,121)
	end
	if playing then
 	if not show_controls then
			for i=1,3 do
				if objs[i] then
			 	draw_obj(i)
				end
			end
		end
		if game_over then
			draw_scoring()
	 else
			draw_deck()
		end
	elseif not game_over then
		intro_anim_draw()
		draw_fade(start_anim)
	end
	if show_controls then
		y=playing and 98 or 90
		draw_instructions(5,y,playing)
	end
end
-->8
--putspr
--cmode = cornermode
--⬆️⬅️, ⬆️➡️, ⬇️⬅️, ⬇️➡️
--y-top (1px dead space in spr)
yt=1
yb=6
function putspr(s,x,y,a,func,w,h,cmode)
 sw=(w or 1)*8
 sh=(h or 1)*8
 sx=(s*8)%128
 sy=flr(s/16)*8
 x0=flr(0.5*sw)
 y0=flr(0.5*sh)
 a=a/360
 sa=sin(a)
 ca=cos(a)
 for ix=sw*-1,sw+4 do
  for iy=sh*-1,sh+4 do
   dx=ix-x0
   dy=iy-y0
   xx=flr(dx*ca-dy*sa+x0)
   yy=flr(dx*sa+dy*ca+y0)
   if (xx>=0 and xx<sw and yy>=0 and yy<=sh-1) then
    corner=rounded and ( 
        (xx==0 and yy==yt and cmode==1)
     or (xx==sw-1 and yy==yt and cmode==2)
     or (xx==0 and yy==yb and cmode==3)
     or (xx==sh-1 and yy==yb and cmode==4)
    )
				if not corner then
	    local col=sget(sx+xx,sy+yy)
	    if col != 0 then
	     func(x+ix,y+iy,col)
	    end
	   end	
   end
  end
 end
end
-->8
--objectives
obj_num_spr={
 10,
 11,
 12,
 13,
 14,
 15,
 26,
 27,
 28,
 29,
 30,
 31,
 42,
 43,
 44,
 45,
 46,
 47
}

obj_names={
 "the outskirts",
 "bloom boom",
 "go green",
 "block party",
 "stax & scrapers",
 "master planned",
 "central perks",
 "the 'burbs",
 "concrete jungle",
 "the strip",
 "mini marts",
 "superhighway",
 "park hopping",
 "looping lanes",
 "skid row",
 "morning commute",
 "tourist traps",
 "sprawlopolis",
}

obj_shrt={
 "outskrts",
 "bloomboom",
 "gogreen",
 "blkprty",
 "stx&scrp",
 "m.planned",
 "centralp",
 "burbs",
 "concrete",
 "strip",
 "minimarts",
 "superhwy",
 "parkhop",
 "looping",
 "skidrow",
 "commute",
 "tourist",
 "sprawl",
}

obj_desc={
"+1/road inside, -1/road outside",
"+1/row & col w/3 parks, -1 w/o 3",
"+1/park blk, -3/industrial blk",
"-8 pts. +3 per 2x2-blk (up to 5)",
"+2/ind next to only com & ind",
"+1/largest res. -1/largest ind",
"+1/park inside. -2/park outside",
"+1/prk,-2/ind adj to biggest res",
"+1/ind that shares corner w/ind",
"+1/com in a chosen row or col",
"+2/com between 2 res on one road",
"+1/every 2 rd in longest road",
"+3/road begins & ends at park",
"+1/road segment in looped rds",
"+2/res next to 2 or more ind",
"+2/road with res and com",
"+1/com on edge, or +2 if corner",
"+1/block in longest row & col",
}
-->8
--cards

i_nw=1
i_ne=2
i_se=3
i_sw=4
i_h=5
i_v=6
r_nw=17
r_ne=18
r_se=19
r_sw=20
r_h=21
r_v=22
c_nw=49
c_ne=50
c_se=51
c_sw=52
c_h=53
c_v=54
p1=33
p2=34
p3=35
p4=36
p5=37
p6=38
p7=71
p8=72
p9=73
p10=74
p11=75
p12=76
p13=87
p14=88
p15=89
p16=90
p17=91
p18=92

-- cards are in objective order
-- flipped horizontally
-- blocks ⬆️⬅️, ⬆️➡️, ⬇️⬅️, ⬇️➡️
cards={
 { r_h, i_sw, p1, c_v },  -- 1
 { c_h, r_h, p2, i_se },  -- 2
 { r_h, i_h, p3, c_se },  -- 3
 { i_se, r_h, c_v, p4 },  -- 4
 { i_h, c_sw, p5, r_v },  -- 5
 { r_v, p6, c_v, i_se },  -- 6
 { c_h, i_h, r_sw, p7 },  -- 7
 { r_v, c_ne, i_v, p8 },  -- 8
 { c_se, i_h, r_v, p9 },  -- 9
 { r_h, c_h, i_sw, p10 }, -- 10
 { i_h, r_h, c_sw, p11 }, -- 11
 { c_v, i_ne, r_v, p12 }, -- 12
 { i_v, p13, r_v, c_se }, -- 13
 { r_se, c_h, i_v, p14 }, -- 14
 { c_v, p15, i_v, r_se }, -- 15
 { i_h, c_h, p16, r_se }, -- 16
 { i_v, r_ne, c_v, p17 }, -- 17
 { c_h, r_sw, p18, i_v }  -- 18
}

--write entire card to sprite
function set_card_sprite(num,f)	
	local card=cards[num]
	num-=1
	local x=(num*2%16)*8
 local y=(8+flr(num*2/16)*2)*8
 local a=f and 180 or 0
 local c1,c2,c3,c4=1,2,3,4
 if f then
  x-=1
  y-=1
  c1,c2,c3,c4=4,3,2,1
 end
 putspr(card[c1],x,y,a,sset,1,1,c1)
	putspr(card[c2],x+cardw,y,a,sset,1,1,c2)
	putspr(card[c3],x,y+cardh,a,sset,1,1,c3)
	putspr(card[c4],x+cardw,y+cardh,a,sset,1,1,c4)
end

function prepare_card_sprites()
	for i=1,18 do
		set_card_sprite(i,false)
	end
end

function card_spr(num)
	num-=1
	col=num*2%16
 row=flr(num*2/16)*2
 return 128+row*16+col
end
-->8
--logo/instructions

_s=100
_p=101
_r=102
_a=103
_w1=104
_w2=105
_l=106
_o=107
_i=108

function sprawlopolis(x,y,shadow)
 pal(5,shadow and 0 or 6)
 pal(6,shadow and 0 or 7)
 spr(_s,x,y); x+=8
 spr(_p,x,y); x+=8
 spr(_r,x,y); x+=8
 spr(_a,x,y); x+=8
 spr(_w1,x,y); x+=8
 spr(_w2,x,y); x+=6
 spr(_l,x,y); x+=6
 pal(5,5)
 
 --blue
 pal(5,shadow and 0 or 12)
 pal(6,shadow and 0 or 6)
 spr(_o,x,y); x+=8
 spr(_p,x,y); x+=8
 spr(_o,x,y); x+=8
 spr(_l,x,y); x+=7
 spr(_i,x,y); x+=2
 spr(_s,x,y)
	pal(5,5)
 pal(6,6)
end

function draw_instructions(x,y,in_game)
 spr(96,x,y)
 for i=1,13 do
 	spr(97,x+i*8,y)
 end
 for i=1,5 do
 	spr(112,x,y+i*8)
 	spr(114,x+110,y+i*8)
 end
 spr(98,x+110,y)
	rectfill(x+2,y+2,x+116,y+50,6)
	x+=3
	y+=4
	local c1,c2=1,5
 print("⬅️/➡️: \0",x,y,c1)
 print("select card/objective",c2)
 y+=6
 print("arrow keys: \0",x,y,c1)
 print("move active card",c2)
 y+=6
	print("❎: \0",x,y,c1)
	print("place card  \0",c2)
	print("🅾️/z: \0",c1)
	print("rotate",c2)
	y+=6
	
	print("🅾️🅾️/zz: \0",x,y,c1)
	--dont print newline, otherwise
	--console will scroll
	print("quickly switch card\0",c2)
	if not in_game then
		y+=8
		print(smallcaps("select ").."?"..smallcaps(" in game to see this"),x,y,13)
	end
end

byline1="designed by steven aramini,"
byline2="danny devine, paul kluka"
function draw_logo(x,y,opacity)
 if (opacity<=0) return
	
	local orig_x,orig_y=x,y
	-- center logo over text
	x+=5
	
	--logo bg
	local lw,lh=93,7
	--rectfill(x-3,y-3,x+lw+3,y+lh+4,2)
 
 sprawlopolis(x+1,y+1,true)
 sprawlopolis(x,y)
 
 --road
 y+=11
 line(0,y+4,128,y+4,6)
 line(0,y+20,128,y+20,6)
 for i=0,7 do
 	spr(69,x-15+i*16,y+5,2,2)
 end
 
	x=orig_x
	y+=26
 prints("original card game",x+17,y,7)
 y+=5
 prints(byline1,x,y,7)
 y+=5
	prints(byline2,x+5,y,7)
	y+=11
	prints("get it at:",x+35,y,9)
	y+=7
 print("www.buttonshygames.com",x+9,y,9)

	y+=14
	rectfill(0,y,128,y+16,2)
	y+=2
	print("press    to start",x+20,y,10)
	if flr(time())%2==0 then
	 print("      ❎",x+20,y,10)
	end
	y+=8
	print(smallcaps("press ").."z/🅾️"..smallcaps(" for controls"),x+8,y,9)
end
-->8
--smallcaps
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

function prints(txt,x,y,col)
 txt=smallcaps(txt)
 if not y then
 	print(txt,x)
 elseif not col then
  print(txt,x,y)
 else
  print(txt,x,y,col)
 end
end
-->8
--anims
flyx=0

traf_lr={}
traf_rl={}

bu1={s={224},w=2,d=1,sp=0.125,stp=150,stps=214,pstps=248}
bu2={s={240},w=4,d=1,sp=0.125,stp=175}
sch={s={250},w=2,d=1,sp=0.12,stp=250,stps=198,pstps=226}
bik={s={228,244,246,230},sp=0.125,w=1.25,d=-1,st=true}
tra={s={232},w=8,d=1,sp=0.15}
tx1={s={202},w=1,d=1,sp=0.125,stp=100,stps=201,pstps=200}
tx2={s={200},w=1,d=1,sp=0.125,stp=100,stps=201,pstps=202}
ca1={s={203},w=1,d=1,sp=0.125}
ca2={s={204},w=1,d=1,sp=0.15}
ca3={s={205},w=1,d=1,sp=0.125}
tr1={s={206},w=1,d=1,sp=0.11}
tr2={s={222},w=1,d=1,sp=0.125}
pu1={s={207},w=1,d=1,sp=0.125}
pu2={s={223},w=1,d=1,sp=0.13}
sco={s={218},w=5/8,d=-1,sp=0.1,st=true}
sk8={s={219,219,219,219,219,219,220},sp=0.095,w=5/8,d=-1,st=true}

all_traffic={
 bu1,bu1,
 --bu2,
 sch,
 tra,
 bik,bik,bik,bik,bik,
 tr1,tr2,
 tx1,tx2,
 ca1,ca2,ca3,pu1,pu2,
 sco,
 sk8
}
function intro_anim_draw()
	foreach(traf_lr,draw_traf)
	foreach(traf_rl,draw_traf)
	
 for i=1,18 do
 	local wid=(cardw*2+5)
 	local off=-i*wid
		local mx=18*wid
		local s=card_spr(i)
 	local x=(flyx+off)%mx-wid
 	local y=3
 	draw_outline(x,y,13,cardw,cardh,true)
 	if false and i==4 then
   --rotae
   putspr(s,x-1,y-2,flyx*2%360,pset,2,2)
 	else
 	 spr(s,x,y,2,2)
  end
		
		--bottom marquee
		if false then
			x=i*(-cardw*2-5)+flyx
	 	y=109
	 	draw_outline(x,y,13,cardw,cardh,true)
	 	spr(s,x,y,2,2)
 	end
 end
end

function draw_traf(t)
 local rx=t.d==1 and 0 or 128-t.s.w*8
 local ry=t.d==1 and 43 or 51
 local s=t.s.s[t.a]
 if t.s.stps and t.stp and t.stp>0 then
 	s=t.s.stps
 end
 if t.stp==0 and t.s.pstps then
 	s=t.s.pstps
 end
 pal(5,0)
 if t.st then
  pal(15,4)
 end
 spr(s,rx+t.x,ry,t.s.w,1,t.d!=t.s.d)
	pal(5,5)
	if t.st then
		pal(15,15)
	end
end

function advance_traf(arr)
 local stopped=false
 for i=1,#arr do
 	if i>#arr then
 	 return
 	end
		local t=arr[i]
		if t.stp and t.stp>0 then
		 t.stp-=1
		elseif not t.stp and t.s.stp and abs(t.x)>t.stpt then
			t.stp=t.s.stp
		else
			local d1=(i==1 or t.d==1 and
			 t.x+t.s.w*8+3<arr[i-1].x)
			local d2=(i==1 or t.d==-1 and
			 t.x-t.s.w*8-3>arr[i-1].x)
			if d1 or d2 then
				t.x+=t.s.sp*t.d
			 t.a=(flr(t.x)%(#t.s.s))+1
	 	end
	 end
	 if abs(t.x)>130 then
	 	del(arr,t)
	 end
	end
end

function add_traf(d,arr)
	local t=rnd(all_traffic)
	local last=#arr>0 and arr[#arr].s
	while (
	 t==last or
		(t==bu1 and last==bu2) or
		(t==bu2 and last==bu1)
	) do
		t=rnd(all_traffic)
	end
	local st=t.st and flr(rnd(2))==0
	tr={
	 s=t,x=t.w*8*-d,d=d,a=1,
	 st=st,stpt=50+flr(rnd(40))
	}
	add(arr,tr)
end

function intro_anim_update()
	--fly
	flyx+=0.5
	
	--road
	advance_traf(traf_lr)
	advance_traf(traf_rl)
	
	if #traf_lr==0 then
	 add_traf(1,traf_lr)
 end
	if #traf_rl==0 then
	 add_traf(-1,traf_rl)
 end

	if traf_lr[#traf_lr].x>7+rnd(15)*2 then
	 add_traf(1,traf_lr)
	end
	if traf_rl[#traf_rl].x<-7-rnd(15)*2 then
	 add_traf(-1,traf_rl)
	end
end

-->8
keywords={
	{k="-1/",c="red"},
	{k="-2/",c="red"},
	{k="-3/",c="red"},
	{k="-8 pts.",c="red"},
	
	--'shares' has 'res' in it
	{k="shares"},
	
 {k="commrcl",c=1},
 {k="com",c=1},
 
 {k="parks",c=2},
 {k="park",c=2},
 {k="prk",c=2},
 
 {k="resdntl",c=3},
 {k="res",c=3},
 
 {k="industrial",c=4},
 {k="indstrl",c=4},
 {k="ind",c=4},
}
function printdesc(s,x,y)
	local base_col=7
	print("\0",x,y,base_col)
	local i=1
	
	while i<=#s do
		local col=base_col
		local j=i
		for k=1,#keywords do
			local kw=keywords[k].k
		 local ss=sub(s,i,i+#kw-1)
		 if ss==kw then
		 	local ci=keywords[k].c
		 	if ci=="red" then
		 	 col=8
		 	elseif ci then
		 	 col=score_tcolors[ci]
		 	end
		 	j+=#kw-1
		 	break
		 end
		end
		print(sub(s,i,j).."\0",col)
		i+=j-i+1
	end
end
__gfx__
000000000000000000000000000000000000000000000000000000000000000006666666666666600aaaaa000aaaaa000aaaaa000aaaaa000aaaaa000aaaaa00
00000000666556666665566666666666666666666666666666655666000000006665555566666666aa00aaa0aa000aa0aa000aa0aa0a0aa0aa000aa0aa000aa0
0070070066555ff66dd555666ff6ddd66ff6ddd66ff6ddd66ff55dd6000000006600000056666666aaa0aaa0aaaa0aa0aaaa0aa0aa0a0aa0aa0aaaa0aa0aaaa0
00077000555556666dd555556f76555555556dd65555555566655666000000006500000005666666aaa0aaa0aa000aa0aaa00aa0aa000aa0aa000aa0aa000aa0
0007700055556dd66666555566755555555556665555555567d557d6000000005500000005555555aaa0aaa0aa0aaaa0aaaa0aa0aaaa0aa0aaaa0aa0aa0a0aa0
0070070067766dd667f6fdd666755566665557766ddd67d66dd55ff6000000007500000005775775aa000aa0aa000aa0aa000aa0aaaa0aa0aa000aa0aa000aa0
000000006666666666666666666556666665566666666666666556660000000055000000055555550aaaaa000aaaaa000aaaaa000aaaaa000aaaaa000aaaaa00
00000000000000000000000000000000000000000000000000000000000000006500000005666666000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000066500000566666660aaaaa000aaaaa000aaaaa000aaaaa000aaaaa000aaaaa00
00000000999559999995599999999999999999999999999999955999000000006665555566666666aa000aa0aa000aa0aa000aa0a0a000a0aa0a0aa0a0a000a0
00000000995558a99495559994aa98899aa894a99aa989499aa55849000000000666666666666660aaaa0aa0aa0a0aa0aa0a0aa0a0a0a0a0aa0a0aa0a0aaa0a0
0000000055555a89949555559aa955555555944955555555944558a9000000000000000000000000aaaa0aa0aa000aa0aa000aa0a0a0a0a0aa0a0aa0a0a000a0
00000000555598a99449555594a5555555555a895555555599955a89000000000000000000000000aaaa0aa0aa0a0aa0aaaa0aa0a0a0a0a0aa0a0aa0a0a0aaa0
0000000094499a899889aaa994a5559999555a8998889aa998855aa9000000000000000000000000aaaa0aa0aa000aa0aa000aa0a0a000a0aa0a0aa0a0a000a0
000000009999999999999999999559999995599999999999999559990000000000000000000000000aaaaa000aaaaa000aaaaa000aaaaa000aaaaa000aaaaa00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000ff5ff5ff5ff5ff00aaaaa000aaaaa000aaaaa000aaaaa000aaaaa000aaaaa00
00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000ff5ff5ff5ff5ff5fa0a000a0a0a0a0a0a0a000a0a0a000a0a0a000a0a0a000a0
00000000b333b3bbbff4ff5bb33b3b3bbccc7c3bbb4443bbb677776b00000000f5ff5ff5ff5ff5ffa0aaa0a0a0a0a0a0a0a0aaa0a0a0aaa0a0aaa0a0a0a0a0a0
00000000b433b43bb7f6f75bb337b3bbbcccccbbb44c444bbf3b3bfb000000005ff5ff5ff5ff5ff5a0aa00a0a0a000a0a0a000a0a0a000a0a0aaa0a0a0a000a0
00000000bb33334bb7f6f75bbb7337bbb4b4b43bb4ccc34bbfb3b3fb00000000ff5ff5ff5ff5ff5fa0aaa0a0a0aaa0a0a0aaa0a0a0a0a0a0a0aaa0a0a0a0a0a0
00000000bb4433bbbff4ff5bb3b33b3bb33b3b3bb34444bbb677776b00000000f5ff5ff5ff5ff5ffa0a000a0a0aaa0a0a0a000a0a0a000a0a0aaa0a0a0a000a0
00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000005ff5ff5ff5ff5ff50aaaaa000aaaaa000aaaaa000aaaaa000aaaaa000aaaaa00
0000000000000000000000000000000000000000000000000000000000000000ff5ff5ff5ff5ff5f000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000f5ff5ff5ff5ff5ff000000000000000000000000000000000000000000000000
00000000ccc55cccccc55cccccccccccccccccccccccccccccc55ccc000000005ff5ff5ff5ff5ff5000000000000000000000000000000000000000000000000
00000000cc55511cc2c555ccc22c1cecceeecdccc2eec11cc1c55eec000000000f5ff5ff5ff5ff50000000000000000000000000000000000000000000000000
00000000555551ecc1c55555ce2c55555555cd2c55555555cec5522c000000000000000000000000000000000000000000000000000000000000000000000000
000000005555eeccce2c5555cec5555555555e2c55555555cec551cc000000000000000000000000000000000000000000000000000000000000000000000000
00000000cceee2ccce1cc2ecc1c555cccc555eccc11cc22cc1c5522c000000000000000000000000000000000000000000000000000000000000000000000000
00000000ccccccccccccccccccc55cccccc55cccccccccccccc55ccc000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
111161111111111100222222222222222222220055555555555555550000000000000000000000000000000000000000000000000000ddd00000000000000000
11111111111111110244444444444444444444205555555555555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00dd666dd000000000000000
11111116111161112444444444444444444444445555555555555555b37b22bbb44433bbb33b373bb33333bbb433333bb333bbbb0d6655566d00000000000000
11111111111111115444444444444444444444445555555555555555b332222bb4cc433bb333b33bb44b443bb434443bb333bb3b0d6566656d00000000000000
11111111111111115444444444444444444444445555555555555555b3b2442bb44ccc4bbb7337bbb433b34bb444344bbb4b3b4bd666666566d0000000000000
61111111111111115444444444444444444444445555555555555555bb3b443bb334434bb3b3733bbb4433bbb333334bbb4b4bbbd666655666d0000000000000
11111111111111115444444444444444444444445555555555555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbd666656666d0000000000000
111111111111111154444444444444444444444455777775555555550000000000000000000000000000000000000000000000000d6666666d00000000000000
111111111116111154444444444444444444444455555555555555550000000000000000000000000000000000000000000000000d6665666d00000000000000
11116111111111115444444444444444444444445555555555555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00dd666dd000000000000000
11111111111111115444444444444444444444445555555555555555bbeeeebbbb11b83bb6b6b33bbb7bbbbbbb9bbabbbbbe8bdb0000ddd00000000000000000
11111111111111115444444444444444444444445555555555555555beb7b7ebb1cc1b3bb6b6b44bb7e7babbb9d9a2abbbe8e8bb000000000000000000000000
11111111111116115444444444444444444444445555555555555555be7b7bebb1cc18bbb6b6b44bb37ba1abbb9bbabbbbb7fbbb000000000000000000000000
116111111111111154444444444444444444444f5555555555555555bbeeeebbbb11b33bb6b6b33bb3bbba3bbb3bb3bbb44ff44b000000000000000000000000
11111111111111110544444444444444444444f05555555555555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000
11111111111111160055ffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777776555555555555550052222220005656505655555056555550000556500550000000056500565000000065650065600000000088800000000000000000
07666666666666666666665054444440055000565650005556500055005555650550000000056500565000000565655065600000008866688000000000000000
76666666666666666666666554444440055000005650005556500055005505650555005500556500565000006560055565600000086622266800000000000000
76666666666666666666666554444440055650005650005556500055055505565055005500565000565000006500005565600000086266626800000000000000
76666666666666666666666554444440000656565655555056555550055555565055555555565000565000006500005565600000866666626680000000000000
76666666666666666666666554444440000000565650000056505500555000556505555555650000565000006560055565600000866662266680000000000000
76666666666666666666666554444440055000565650000056500550550000056505550555650000565555500565655065600000866662666680000000000000
76666666666666666666666554444440005656505650000056500055550000056500550056500000565555500065650065600000086666666800000000000000
76666666544444446666666500060000777777700002000088888880000000000000000000000000000000000000000000000000086662666800000000000000
76666666544444446666666500676000677777600028200028888820000000000000000000000000000000000000000000000000008866688000000000000000
76666666544444446666666506777600067776000288820002888200000000000000000000000000000000000000000000000000000088800000000000000000
76666666544444446666666567777760006760002888882000282000000000000000000000000000000000000000000000000000000000000000000000000000
76666666544444446666666577777770000600008888888000020000000000000000000000000000000000000000000000000000000000000000000000000000
76666666544444446666666500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666544444446666666500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666544444446666666500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000008800000000000000880000000000000088000000000000008800000000000000880000000000000088000000000000008800000000000000880000000
00000008800000000000000880000000000000088000000000000008800000000000000880000000000000088000000000000008800000000000000880000000
00000008800000000000000880000000000000088000000000000008800000000000000880000000000000088000000000000008800000000000000880000000
00000008800000000000000880000000000000088000000000000008800000000000000880000000000000088000000000000008800000000000000880000000
00000008800000000000000880000000000000088000000000000008800000000000000880000000000000088000000000000008800000000000000880000000
00000008800000000000000880000000000000088000000000000008800000000000000880000000000000088000000000000008800000000000000880000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000008800000000000000880000000000000088000000000000008800000000000000880000000000000088000000000000008800000000000000880000000
00000008800000000000000880000000000000088000000000000008800000000000000880000000000000088000000000000008800000000000000880000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000008800000000000000880000000000000088000000000000008800000000000000880000000000000088000000000000008800000000000000880000000
00000008800000000000000880000000000000088000000000000008800000000000000880000000000000088000000000000008800000000000000880000000
00000008800000000000000880000000000000088000000000000008800000000000000880000000000000088000000000000008800000000000000880000000
00000008800000000000000880000000000000088000000000000008800000000000000880000000000000088000000000000008800000000000000880000000
00000008800000000000000880000000000000088000000000000008800000000000000880000000000000088000000000000008800000000000000880000000
00000008800000000000000880000000000000088000000000000008800000000000000880000000000000088000000000000008800000000000000880000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000008800000000000000880000000000000088000000000000008800000000000000880000000000000088000000000000008800000000000000880000000
00000008800000000000000880000000000000088000000000000008800000000000000880000000000000088000000000000008800000000000000880000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000aaaaaaaaaaaaa0000066000000990000009900000000000000000000000000004444400000000000
000000088000000000000008800000000000000000000000666a666a666a66000aaaaa000aaaaa000aaaaa000bbbbb00088888000ccccc004444422000011100
000000088000000000000008800000000000000000000000666af64af68dd400a66a6600adda6600a66a6600b66b660086686600c66c66004444426000016600
000000088000000000000008800000000000000000000000aaaaaaaaaa8dda00aaaaaaaaaddaaaaaaaaaaaaabbbbbbbb88888888cccccccc4444422200011111
000000088000000000000008800000000000000000000000aaaaaaaaaaadd700aaaaaaaaaddaaaaaaaaaaaaabbbbbbbb88888888cccccccc2222222911111111
00000008800000000000000880000000000000000000000005005000050050000500005005000050050000500500005005000050050000500500005005000050
00000008800000000000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000008800000000000000880000000000000000000000000000000000000000000000000000000000f000000f000000f000000000000001111100000000000
000000088000000000000008800000000000000000000000666666666666666000000000000000001f3300000030000000300000000000001111166000bbbb00
00000000000000000000000000000000000000000000000067776777677767700000000000000000010300000030000000300000000000001111167000bb6600
0000000000000000000000000000000000000000000000006f77647f6477ddf00000000000000000010c000000c0000000c000000000000011111666bbbbbbbb
000000000000000000000000000000000000000000000000666666666666dd600000000000000000011c100044c44000444c4000000000006666666abbbbbbbb
000000000000000000000000000000000000000000000000656656666656d5a000000000000000000500500005050000050c0000000000000500005005000050
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000
6666666666666660aaaaaaaaaaaaa00000000f000000000000000f00000000000000000000000000000000000000000000000000000000000000000000002000
6777677767776770666a666a666a6600000f330000000000000f33000000000000000dddddddd202ddddddddddddd202ddddddddddddd202ddddddddddddd200
6f77647f647767f0466af64af6886400055803055000000005580305500000000000d666d666d222d666d666d666d222d666d666d666d222d666d666d666d660
6666666666666660aaaaaaaaaa88aa0050858c58650000005685cc5805000000000ddf64df66d222df66d46fd466d222df66d46fd466d222df66d46fd466d6f0
66666666666666a0aaaaaaaaaaaaa70056050c56050000005065c0506500000000ddddddddddd222ddddddddddddd222ddddddddddddd222ddddddddddddddd0
0500500000500500050050000500500005500c0550000000055000055000000000ddddddddddd202ddddddddddddd202ddddddddddddd202dddddddddddddda0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6666666666666101666666666666666000000f000000000000000f00000000006666666666666660aaaaaaaaaaaaa00000000000000000000000000000000000
67776777677761116777677767776770000f330000000000000f3300000000006777677767776770666a666a666a660000000000000000000000000000000000
6f77647f647761116f77647f647767f0055803055000000005580305500000006f77647f647467f0666af64af688640000000000000000000000000000000000
6666666666666111666666666666666056858c58050000005085cc58650000006666666666666660aaaaaaaaaa88aa0000000000000000000000000000000000
666666666666610166666666666666a050650c50650000005605c0560500000066666666666666a0aaaaaaaaaaaaa70000000000000000000000000000000000
0500500005005000050050000050050005500c055000000005500005500000000500500000500500050050000500500000000000000000000000000000000000
__label__
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd

__sfx__
000200002e0502e05033750337503300033000330003300033000220001b0001800016000160001f0002700027000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000d0500e050100501105011000100000e0000c0000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002d0512d050137001370013700227002d0502d05024500245002d0502d0500050000500005000050039050390503905239052390523905239055005000050000500005000050000500000000000000000
01120000091730010037600266000e643003000917300300091730030000300091000e643003003f10000300091730030032600266000e6430030032600266000917300300376130030037613003003f10000000
01120000091730010037613266000e643003000917300300091730030000300091000e643003003f11100300091730030032600266000e6430030032631266000917300300376130030037613003003f11300000
491200000433204332043250b3000b3420b3420e3320e3220b3000b30010342103320b300003000e3420e3310e3410e3310b3420b331103421034110332103210b3420b3420b3420b3320b322003000234202332
491200000433204332043250b3000b3420b3320e3420e3320b3000b30012342123310b30000300103421034110332103220b3000b3000b3420b3000b3320b3000e3420e3320b3000b30012342123321034110332
011200002806228062280622c0222d0222d022250522505225052250522d0002d0002c0222d0222d0222d0222c0522c0522c0522a0522806228062280622806228062280622a0002a00025052250522a0522a052
01120000217322173121731217220070000700007000070021732217222373123732237322373123721237221a7001a7001a7001a7001a7001a7001a7001a7001a7001a7001c7001c7001c7001c7001c7001c700
01120000197321973119731197220070000700007000070019732197221a7311a7321a7321a7311a7211a7221e7001e7001e7001e7001e7001e70000700007001e7001e700207002070020700207002070020700
011200001a7421a7421a7421a7321a7001a7001a7001a7001a7421a7321c7411c7421c7411c7411c7321c735000000000000000000001e7321e7321e7321e722207312073220732207251e7311e7321e7321e722
011200001e7421e7421e7421e73200700007001e7001e7001e7421e73220741207422074120741207322073500000000000000000000217322173221732217222373123732237322372521731217322173221722
__music__
01 03454344
00 03054344
00 04064344
00 04050a0b
00 04060809
00 04050a0b
00 04060809
00 04050a0b
00 04060809
00 04050a0b
00 04060809
00 03054344
00 03064344
00 03454344
00 03420a0b
00 04420809
00 04050a0b
00 04060809
00 04050a0b
00 04060809
00 04054344
02 04064344

