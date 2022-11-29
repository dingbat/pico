fillp(▒)
 for i in pairs(vizmap) do
		i-=1
 	local xx,yy=i%(mapw/4),i\(mapw/4)
		if xx>=cx\8 and xx<cx\8+16 and
			yy>=cy\8 and yy<cx\8+16 then
			local x,y=xx*8,yy*8
			map(xx,yy,x,y,1,1)
			if not g(vizmap,xx-1,yy) then
	 		line(x,y,x,y+7,nil)
			end
			if not g(vizmap,xx,yy-1) then
	 		line(x,y,x+7,y,nil)
			end
			if not g(vizmap,xx,yy+1) then
	 		line(x,y+7,x+7,y+7,nil)
			end
			if not g(vizmap,xx+1,yy) then
	 		line(x+7,y,x+7,y+7,nil)
			end
		end
	end
	fillp()