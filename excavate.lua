
local tArgs = { ... }
if #tArgs ~= 1 then
	print( "Usage: excavate <diameter>" )
	return
end

-- Mine in a quarry pattern until we hit something we can't dig
local size = tonumber( tArgs[1] )
if size < 1 then
	print( "Excavate diameter must be positive" )
	return
end
	
local depth = 0
local collected = 0

local xPos,zPos = 0,0
local xDir,zDir = 0,1

local state = { DONE=0, FULL=1, EXCAVATING=2 }

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

local function tryForwards()
	while not turtle.forward() do
		if turtle.dig() then
			if not collect() then
				return state.FULL
			end
	    else
			-- give sand a chance to fall
 			sleep(0.8)
	    	    if turtle.dig() then
	    	        if not collect() then
					return state.FULL
				end
	    	    else
		        	return state.DONE
		    end
	    end
	end
	xPos = xPos + xDir
	zPos = zPos + zDir
	return state.EXCAVATING
end

local function tryDown()
	if not turtle.down() then
		if turtle.digDown() then
			if not collect() then
				return state.FULL
			end
	    end
		if not turtle.down() then
			return state.DONE
		end
	end
	depth = depth + 1
	if math.fmod( depth, 10 ) == 0 then
		print( "Descended "..depth.." metres." )
	end
	return state.EXCAVATING
end

local function turnLeft()
	turtle.turnLeft()
	xDir, zDir = -zDir, xDir
end

local function turnRight()
	turtle.turnRight()
	xDir, zDir = zDir, -xDir
end

local function goToStart()
    print( "Returning to surface..." )

    -- Return to where we started
    while depth > 0 do
    	if turtle.up() then
		    depth = depth - 1
	    elseif turtle.digUp() then
		    collect()
	    else
		    sleep( 0.5 )
	    end
    end

    if xPos > 0 then
	    while xDir ~= -1 do
		    turnLeft()
	    end
	    while xPos > 0 do
		    if turtle.forward() then
			    xPos = xPos - 1
		    elseif turtle.dig() then
			    collect()
		    else
			    sleep( 0.5 )
		    end
	    end
    end

    if zPos > 0 then
	    while zDir ~= -1 do
		    turnLeft()
	    end
	    while zPos > 0 do
		    if turtle.forward() then
			    zPos = zPos - 1
		    elseif turtle.dig() then
			    collected = collected + 1
		    else
			    sleep( 0.5 )
		    end
	    end
    end
    while zDir ~= 1 do
	    turnLeft()
    end
end

-- go to start
-- go two back
-- drop everything
-- go back to start
local function dropAll()
    goToStart()
    
    turnLeft()
    turnLeft()
    
    tryForwards()
    tryForwards()
    
    print( "Dropping everything" )
    if turtle.detectDown() then
        turtle.digDown()
    end
    
    for i=1,9 do
        turtle.select(i)
        turtle.drop()
    end
    
    while zDir ~= 1 do
        turnLeft()
    end
    while zPos < 0 do
        tryForwards()
    end
end

print( "Excavating..." )

local reseal = false
if turtle.digDown() then
	reseal = true
end

local alternate = 0
local done = false
local full = false
local curState = state.EXCAVATING
while not done do
while not full do
	for n=1,size do
		for m=1,size-1 do
		    curState = tryForwards();
			if curState == state.DONE then
				done = true
				break
			elseif curState == state.FULL then
			    full = true
			    break
			end
		end
		if done or full then
			break
		end
		if n<size then
			if math.fmod(n + alternate,2) == 0 then
				turnLeft()
				curState = tryForwards()
				if curState == state.DONE then
					done = true
					break
				elseif curState == state.FULL then
				    full = true
				    break
				end
				turnLeft()
			else
				turnRight()
				curState = tryForwards()
				if curState == state.DONE then
					done = true
					break
				elseif curState == state.FULL then
				    full = true
				    break
				end
				turnRight()
			end
		end
	end
	if done or full then
		break
	end
	
	if size > 1 then
		if math.fmod(size,2) == 0 then
			turnRight()
		else
			if alternate == 0 then
				turnLeft()
			else
				turnRight()
			end
			alternate = 1 - alternate
		end
	end
	
	if not tryDown() then
		done = true
		break
	end
end
if not done then
    -- go back to surface, drop items, go back down, continue excavating
    print( "Turtle is full" )
    local curDepth = depth
    
    dropAll()
    
    while depth < curDepth do
        tryDown()
    end
    
    full = false
end
end

dropAll()

-- Seal the hole
if reseal then
	turtle.placeDown()
end

print( "Mined "..collected.." blocks total." )
