local sensorInfo = {
	name = "TransporterID",
	desc = "Returns ids of scouts. It can return {}",
	author = "Patik",
	date = "2018-05-11",
	license = "notAlicense",
}


-- get madatory module operators
VFS.Include("modules.lua") -- modules table
VFS.Include(modules.attach.data.path .. modules.attach.data.head) -- attach lib module

-- get other madatory dependencies
attach.Module(modules, "message") -- communication backend load

local EVAL_PERIOD_DEFAULT = 0 -- acutal, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end


-- @description return current wind statistics
return function(data)
  for i = 1, #data do 
    if (Script.LuaUI('exampleDebug_update')) then
			Script.LuaUI.exampleDebug_update(
				unitID, -- key
				{	-- data
					startPos = data[i]["end"], 
					endPos = data[i]["end"] + Vec3(0,0,100)
				}
			)
	end
  end 
  return 0
end