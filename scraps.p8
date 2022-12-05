
acct={}
times={}
function flush_time(str,f)
	if acct[str] and (not f or fps%f==0) then
		printh(str..": "..acct[str],"log")
	end
	acct[str]=0
end
function time(str,run_at_fps)
	local s=stat(1)
	if times[str] then
	 local prev,f=unpack(times[str])
	 if f==true or not f or fps%f==0 then
			if f==true then
				acct[str]=acct[str] or 0
				acct[str]+=s-prev
			else
				printh(str..": "..(s-prev),"log")
			end
		end
		times[str]=nil
	else
		times[str]={s,run_at_fps}
	end
end


function draw_dmap(res_typ)
	local dmap=dmaps[res_typ]
 if (not dmap) return
 for x=0,16 do
		for y=0,16 do
			local n=g(dmap,x+flr(cx/8),y+flr(cy/8))
			print(n==0 and "+" or n or "",
				x*8+2,y*8+2,14)
	 end
	end
end
draw=_draw
_draw=function()
	draw()
	draw_dmap("r")
end