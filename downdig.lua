local tArgs = { ... }

if #tArgs ~= 2 then
	print( "Usage: downdig <depth_to_dig> <diameter>. Only supplied args: ", #tArgs)
	return
end

local target_depth = tonumber( tArgs[1] )
local target_size = tonumber( tArgs[2] )
local collected = 0
local depth = 0

local xPos,zPos = 0,0
local xDir,zDir = 0,1

local state = { DONE=0, FULL=1, EXCAVATING=2 }

if target_size < 1 then
	print( "Diameter must be positive" )
	return
end

if target_depth < 1 then
	print( "Depth must be positive" )
	return
end

local function collect()
	collected = collected + 1
	if math.fmod(collected, 25) == 0 then
		print( "Mined "..collected.." blocks." )
	end
	
	for n=1,9 do
		if turtle.getItemCount(n) == 0 then
			return true
		end
	end
	
	print( "No empty slots left." )
	return false
end

local function goStraightUp()
  while depth > 0 do
	if turtle.up() then
	  depth = depth - 1
	elseif turtle.digUp() then
	  collect()
	else
	  sleep(0.5)
	end
    end
end

local function getToDepth()
  while not turtle.down() and depth < target_depth do -- while cannot move down
    if turtle.digDown() then -- if it can dig down
      if not collect() then -- try to collect
        return state.FULL
      else
        return state.DONE
      end
    else -- Can't dig down. Probably bedrock or something
      goStraightUp()
    end
  end
  goStraightUp()
end

print( "Going down! Hopefully I return!" )
getToDepth()
