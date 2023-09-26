local currentID = 1
usedIDs = { }

local function generateUniqueID( )
    local uniqueID
    repeat
        uniqueID = currentID
        currentID = currentID + 1
    until not usedIDs[ uniqueID ]
    usedIDs[ uniqueID ] = true
    currentID = 1
    return uniqueID
end


function assignUniqueID( player )
    local uniqueID = generateUniqueID( )
    setElementData( player, "playerID", uniqueID )
end

addEventHandler( "onPlayerJoin", root, function( )
    assignUniqueID( source )
end )


addEventHandler( "onPlayerQuit", root, function( )
    local playerID = getElementData( source, "playerID" )
    if playerID then
        usedIDs[ playerID ] = nil

    end
end )
