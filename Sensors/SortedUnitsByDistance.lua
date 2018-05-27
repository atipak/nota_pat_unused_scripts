local sensorInfo = {
	name = "SortedUnitsByDistance",
	desc = "Sorts units by distance from basicPosition",
	author = "Patik",
	date = "2018-05-11",
	license = "notAlicense",
}

local EVAL_PERIOD_DEFAULT = 0 -- acutal, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT 
	}
end


local head = nil

function insertNode(vector, distance, unitId)
  local node = head 
  local nextNode = nil
  if node ~= nil then 
    nextNode = node.next
  end
  while nextNode ~= nil and nextNode.distance <= distance do
    node = nextNode
    nextNode = node.next 
  end
  if node ~= nil then 
    node.next = {next = nextNode, distance = distance, vector = vector, unitId = unitId}
  else 
    head = {next = nextNode, distance = distance, vector = vector, unitId = unitId} 
  end 
end


function vectorsDistance(positionOne, positionTwo) 
  return math.sqrt(math.pow(positionOne.x - positionTwo.x, 2) + math.pow(positionOne.z - positionTwo.z, 2))
end

-- @description ff 
return function(basicPosition, unitsIds)
  if #unitsIds == 0 or basicPosition == nil then 
    return {}
  end
  -- sort units by distance from basic position
  head = nil 
  for index = 1, #unitsIds do
    local unitId = unitsIds[index]
    local lx, ly, lz = Spring.GetUnitPosition(unitId)
    local posVec = Vec3(lx,ly,lz)
    local distance = vectorsDistance(basicPosition, posVec)
    insertNode(posVec, distance, unitId)  
  end          
  -- iterate over units with distance and return only units IDs
  ids = {}
  local node = head
  local index = 1
  while node ~= nil do
    ids[index] = node.unitId
    node = node.next
    index = index + 1
  end
  return ids
end                                      


