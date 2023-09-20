


factions = { }


function createFaction( factionID, factionName )
    factions[ factionID ] = {
        name = factionName,
        leader = nil,
        members = { },
    } 
end



createFaction( "city_mayor", "Мэрия города" )
