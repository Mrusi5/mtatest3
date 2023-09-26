
FACTIONS = { }

function createFaction( factionID, factionName )
    FACTIONS[ factionID ] = {
        name = factionName,
        leader = nil,
        members = { },
    } 
end

createFaction( "city_mayor", "Мэрия города" )
