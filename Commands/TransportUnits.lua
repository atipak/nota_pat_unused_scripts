function getInfo()
	return {
		onNoUnits = SUCCESS,
		parameterDefs = {
      { 
				name = "transUnitsPairs",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "{}"
			}, 
      { 
				name = "safePosition",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "{}"
			},
      { 
				name = "safeRadius",
				variableType = "expression",
				componentType = "editBox",
				defaultValue = "{}"
			}
		}
	}
end

local alreadyLaunch = false
local transportersStates = {}
local threshold = 10
local moveThereState, moveBackState, loadUnitState, unloadUnitState, endedState = "moveThere", "moveBack", "loadUnit", "unloadUnit", "ended"



function Run(self, unitIds, parameter) 
  -- creating keyset from parameter.transUnitsPairs
  local units ={}
  local n=0
  tup = parameter.transUnitsPairs 
  
  for k,v in pairs(tup) do
    n=n+1
    units[n]=k
  end
  
  if #units == 0 then
    return SUCCESS
  end
  
  
  -- iterating over units a finding their states 
  for index = 1, #units do
    local unitID = units[index]
    local transporteeID = tup[unitID] 
    if isUnitOK(unitID) and isUnitOK(transporteeID) then
      if transportersStates[unitID] == nil then
        -- no record in table -> the task wasn't started
        local lx, ly, lz = Spring.GetUnitPosition(transporteeID) 
        moveOnPosition(unitID, Vec3(lx, ly, lz))
        transportersStates[unitID] = moveThereState
      end
      -- moveThere
      if transportersStates[unitID] == moveThereState then
        -- no record in table -> the task wasn't started
        Spring.Echo("there")
        local lx, ly, lz = Spring.GetUnitPosition(transporteeID) 
        if moveOnPosition(unitID, Vec3(lx, ly, lz)) then
          transportersStates[unitID] = loadUnitState
        end
      end
      -- load
      if transportersStates[unitID] == loadUnitState then
        Spring.Echo("loading")
        if loadUnit(unitID, transporteeID) then
          transportersStates[unitID] = moveBackState
        end
      end
      -- moveBack
      if transportersStates[unitID] == moveBackState then
        Spring.Echo("back")
        if moveOnPosition(unitID, parameter.safePosition) then
          transportersStates[unitID] = unloadUnitState
        end
      end
      -- unload
      if transportersStates[unitID] == unloadUnitState then
        Spring.Echo("unload")
        if unloadUnit(unitID, transporteeID, parameter.safeRadius - 20) then
          transportersStates[unitID] = endedState
        end
      end
    end
  end
  Spring.Echo(transportersStates)
  if unended(transportersStates) > 0 then
    Spring.Echo("Running")
    return RUNNING
  else 
    Spring.Echo("success")
    return SUCCESS
  end
end

-- check function
function isUnitOK(unitID)
  if not Spring.ValidUnitID(unitID) or Spring.GetUnitIsDead(unitID) then
    transportersStates[unitID] = endedState
    return false
  else
    return true
  end
end


-- functions for first, third step
function moveOnPosition(transporterID, targetPosition) 
  local onPos = isOnPosition (transporterID, targetPosition) 
  if onPos == false then 
    Spring.GiveOrderToUnit(transporterID, CMD.INSERT, {-1, CMD.MOVE, CMD.OPT_SHIFT, targetPosition.x, targetPosition.y, targetPosition.z}, {"alt"})
    --Spring.GiveOrderToUnit(transporterID, CMD.MOVE, targetPosition:AsSpringVector(), {})
    return false
  else
    if onPos then 
      return true
    else
      return false
    end
  end
end   

function isOnPosition(transporterID, targetPosition) 
  local tranPosX, tranPosY, tranPosZ = Spring.GetUnitPosition(transporterID)
  if math.abs(tranPosX - targetPosition.x) > threshold or math.abs(tranPosZ - targetPosition.z) > threshold then 
      return false  
  end 
  return true
end

-- functions for second step
function loadUnit(transporterID, transporteeID) 
  local loaded = isLoaded(transporterID, transporteeID) 
  if loaded == false then 
    Spring.GiveOrderToUnit(transporterID, CMD.INSERT, {-1, CMD.LOAD_UNITS, CMD.OPT_SHIFT, transporteeID}, {"alt"})
    return false
  else
    if loaded then 
      return true
    else
      return false
    end
  end
end

function isLoaded(transporterID, transporteeID)
  -- transporterId 
  local tranID = Spring.GetUnitTransporter(transporteeID)
  return nil ~= tranID and tranID == transporterID
end

-- functions for fourth step
function unloadUnit(transporterID, transporteeID, radius) 
  local unloaded = isUnloaded(transporterID, transporteeID) 
  Spring.Echo(#Spring.GetUnitCommands(transporterID))
  Spring.Echo(Spring.GetUnitCommands(transporterID))
  if unloaded == false then 
    local lx, ly, lz = Spring.GetUnitPosition(transporterID)
    local actualHeight = Spring.GetGroundHeight(lx, lz)  
    Spring.GiveOrderToUnit(transporterID, CMD.INSERT, {-1, CMD.UNLOAD_UNITS, CMD.OPT_SHIFT, lx, actualHeight, lz, radius}, {"alt"})  
    --Spring.GiveOrderToUnit(parameter.transporterId, CMD.UNLOAD_UNITS, {lx, actualHeight, lz, radius} , {})  
    return false
  else
    if unloaded then 
      return true
    else
      return false
    end
  end
end

function isUnloaded(transporterID, transporteeID)
  return nil == Spring.GetUnitTransporter(transporteeID)
end

function unended(tup)
  local undedCount = 0
  for k,v in pairs(tup) do
    if v ~= endedState then 
      undedCount = undedCount + 1
    end
  end
  return undedCount
end
 
  