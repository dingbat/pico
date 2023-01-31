tostr[[[[]]
srand"18"
_dr=_draw

function palp(k,p)
	pal()
	if (btn(k,p)) pal(5,9)
end

function _draw()
	_dr()
	campal()
	if mound then
		mound.portx=-1
		mound.porty=103
		mound.rest_x=16
		mound.rest_y=96
		mound.p1.rest_x=16
		mound.p1.rest_y=96
		brks.portx=7
		brks.porty=104
		mon.portx=15
		mon.porty=103
	else
		return
	end
	
	local mx,my=
		max(amx)/42-1,
		max(amy)/42-1
	local c=dget"0"
	if c==3 then
		local s=202
		if (btn"5") s=204
		if (btn"4") s=206
		spr(200,115+mx,4+my,2,2)
		spr(s,115+mx,10+my,2,2)
		
		palp(⬆️,1)
		spr(196,98,19)
		palp(⬆️)
		?"⬆️",98,5,5
		
		palp(⬅️,1)
		spr(197,90,25)
		palp(⬅️)
		?"⬅️",90,11,5
		
		palp(⬇️,1)
		spr(212,98,25)
		palp(⬇️)
		?"⬇️",98,11,5
		
		palp(➡️,1)
		spr(213,106,25)
		palp(➡️)
		?"➡️",106,11,5
		pal()
	end
	if c==2 then
		local dx,dy=0,0
		if (btn(⬅️)) dx=-1
		if (btn(➡️)) dx=1
		if (btn(⬆️)) dy=-1
		if (btn(⬇️)) dy=1
		spr(234,108,1,2,2)
		spr(236,108+dx,1+dy,2,2)
		palp(❎)
		?"❎",109,23,5
		palp(🅾️)
		?"🅾️",115,18,5
		pal()
	end
	if c==1 then
		local s,fs=48,228
		if (btn"5") s,fs=64,226
		if (btn(⬅️)) mx,my=-2,2
		if (btn(➡️)) mx,my=0,2
		if (btn(⬆️)) mx,my=-1,1
		if (btn(⬇️)) mx,my=-1,3
		spr(224,105,5,2,2)
		spr(fs,107+mx*2,7+my*2,2,2)
		sspr(s,112,16,16,
			max(amx)-10,max(amy)-10,20,20)
	end
	
	cursor(3,5,7)
	
	if sel1 and sel1.st.move then
		moved=true
	end
	if cy==151 then
		done_pan=true
	end
	if res1.b<20 then
		built=true
	end
	
	if not done_pan then
		if c==3 then
			?"use ⬅️➡️⬆️⬇️ (arrows)"
			?"or          (esdf)"
			?"to pan around the map"
			pal(5,7)
			spr(196,15,11)
			spr(197,23,11)
			spr(212,31,11)
			spr(213,39,11)
		elseif c==2 then
			?"move the cursor with the"
			?"\f9dpad\f7 to the screen edges"
			?"to pan around the map"
		elseif c==1 then
			?"use the dpad to pan"
			?"around the map"
		end
	elseif nsel==1 and seltyp.idx==5 then
		if c==3 then
			?"with a unit selected,"
			?"\9right-click\7 to attack"
			?"an enemy (or wild) unit"
		elseif c==2 then
			?"with a unit selected,"
			?"press 🅾️ to attack"
			?"an enemy (or wild) unit"
		elseif c==1 then
			if (act>0) color(6)
			?"with a unit selected,"
			?"tap the action button,"
			if act>0 then
				color(7)
				?"then tap an enemy (or"
				?"wild) unit to attack"
			end
		end
	elseif nsel==2 and amy>90 or to_bld then
		if c==3 then
			?"to build, click on a"
			?"building and click"
			?"somewhere to place it"
		elseif c==2 then
			?"to build, press ❎ on"
			?"a building and press ❎"
			?"somewhere to place it"
		elseif c==1 then
			?"to build, tap on a"
			?"building, then tap"
			?"somewhere to place it"
		end
	elseif nsel==3 and moved then
		if c==3 then
			?"with worker ants"
			?"selected, \f9right-click"
			?"on a resource to",7
			?"begin gathering it"
		elseif c==2 then
			?"with worker ants selected,"
			?"press \f9🅾️\f7 on a resource"
			?"to begin gathering it"
		elseif c==1 then
			if (act>0) color(6)
			?"with worker ants selected,"
			?"tap the action button,"
			if act>0 then
				color(7)
				?"then tap a resource to"
				?"begin gathering it"
			end
		end
	elseif nsel==3 then
		if c==3 then
			?"\f9right-click\f7 to move"
			?"the selected units"
		elseif c==2 then
			?"press \f9🅾️\f7 to move the"
			?"selected units"
		elseif c==1 then
			if (act>0) color(6)
			?"with units selected,"
			?"tap the action button,"
			if act>0 then
				color(7)
				?"then tap somewhere to"
				?"move them"
			end
		end
	elseif not moved then
		if c==3 then
			?"left-click and drag to"
			?"draw a selection box"
			?"around your units"
		elseif c==2 then
			?"press ❎ and use the dpad"
			?"to draw a selection box"
			?"around your units"
		elseif c==1 then
			?"drag a selection box"
			?"around your units"
		end
	elseif built then
		if c==3 then
			?"to build a unit,"
		elseif c==2 then
			?"to build a unit,"
		elseif c==1 then
			?"to build a unit,"
		end
	end
	
	pal()
end

--]]