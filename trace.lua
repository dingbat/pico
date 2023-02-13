tostr[[[[]]
thresh=0.5
freq=0.5
last_t=0
targ_t=0
frame={name="_",chld={}}
function trace_fn(name)
	local orig=_𝘦𝘯𝘷[name]
	_𝘦𝘯𝘷[name]=function(...)
		return trace(name,orig,...)
	end
end

function trace(name,fn,...)
 if t()~=last_t then
  last_t=t()
		run_tr=t()>targ_t and (
			cf==59 or cf==29)
		run_tr=true
		if run_tr then
			targ_t=t()+freq
		end
	end
	local s,fr=stat(1)
	
	if run_tr then
		local lc=frame.chld[#frame.chld]
		if lc and lc.name==name then
			fr=lc
			fr.n=fr.n+1
		else
			fr=add(frame.chld,{
				name=name,
				parent=frame,
				chld={},
				t=0,
				n=1
			})
		end
		frame=fr
	end
	
	local r=fn(...)
	
	if run_tr then
		fr.t=fr.t+stat(1)-s
		frame=frame.parent
		if frame.name=="_" then
		 if fr.t>thresh then
				printh("\ncf:"..cf,"log")
				print_frame(frame,-1)
			end
			frame.chld={}
		end
	end
	
	return r
end

function print_frame(f,n)
	if f.t then
		for i=1,n do
			printh("  \0","log")
		end
		local name=f.name
		if f.n>1 then
			name=name.." ("..f.n..")"
		end
		printh(name..": "..f.t,"log")
	end
	for c in all(f.chld) do
		print_frame(c,n+1)
	end
end

trace_fn"_update"
trace_fn"tick"
trace_fn"dmap"
trace_fn"ai_frame"
trace_fn"dist"
--]]