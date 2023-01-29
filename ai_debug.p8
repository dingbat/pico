tostr[[[[]]
ai_debug=true
if ai_debug then
	--ai in 1,2
	--srand"18"
	--ai in 2,3
	--srand"12"
	
	_update60=_update
	_draw_map,_dr,_pr,_resbar=
		draw_map,_draw,print_res,
		resbar
	function draw_map(o,y)
		if not ai_debug or o==0 then
			_draw_map(o,y)
		end
	end
	function _draw()
		if upcycle and castles then
			castles=1
			castle.p1.atk=3
			castle.p1.aoe=5
			unit(13,298,204,1)
			unit(13,318,180,1)
			unit(13,290,224,1)
			unit(13,280,206,1)
			unit(13,300,184,1)
			unit(13,333,196,1)
		end
		
		_dr()
		if ai_debug and res1 then
		camera()
		local ai=ais[2]
		local secs=res1.t\1%60
		?res.p2.diff,60,107,9
		local b,g=0,0
		for u in all(units) do
			if u.ai==ai then
				if u.typ.ant then
					if (u.rs=="g") g+=1
					if (u.rs=="b") b+=1
				end
			end
		end
		?"\f3"..g.."\f5/\f4"..b,60,114
		?(res1.t\60)..(secs>9 and ":" or ":0")..secs,80,121,1
		local i=ai.boi
		local off=8288+i%32+i\32*128
		local p,pid=peek(off,2)
		local bl={
			"mnd","farm","bar","den","mon","twr","cstl"
		}
		?bl[pid] or pid,80,114,3
		?":\-e#\-e:"..(i/2+1),80,107,2
		camera()
		end
	end
	function print_res(...)
		if (ai_debug) res1=res.p2
		local x=_pr(...)
		res1=res[1]
		return x
	end
	function resbar(...)
		if (ai_debug) res1=res.p2
		_resbar(...)
		res1=res[1]
	end
end
--]]