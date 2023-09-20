


--Назначения лидера фракции

function setFactionLeader( player, playerID, factionID )
    local playerTarget = getPlayerByID( playerID )
    
    if factions[ factionID ] and playerTarget then
        local currentFaction = getPlayerFaction( playerTarget )
        if not currentFaction or currentFaction == factionID then
            factions[ factionID ].leader = playerTarget

            if not table.contains( factions[ factionID ].members, playerTarget ) then
                table.insert( factions[ factionID ].members, playerTarget )
            end

            outputChatBox( getPlayerName( playerTarget ) .. " назначен лидером фракции " .. factionID, player )
        else
            outputChatBox( getPlayerName( playerTarget ) .. " уже состоит в другой фракции", player )
        end
    else
        outputChatBox( "Фракция или игрок не указаны", player )
    end
end


---Вступление в организацию или выход из неё если не указанно id фракции

function setPlayerFaction( player, playerID, factionID )
    local playerTarget = getPlayerByID( playerID )
    local currentFaction = getPlayerFaction( playerTarget )



---Вступление     

    if factions[ factionID ] and playerTarget then
        if not currentFaction then
            table.insert( factions[ factionID ].members, playerTarget )
            outputChatBox( getPlayerName( playerTarget ) .. " вступил(a) в фракцию " .. factionID, player )
        elseif currentFaction == factionID then
            outputChatBox( getPlayerName( playerTarget ) .. " уже состоит в этой фракции", player )
        else
            outputChatBox( getPlayerName( playerTarget ) .. " уже состоит в другой фракции", player )
        end



----Выход      

    elseif not factionID and playerID then
        if currentFaction then
            local faction = factions[ currentFaction ]
            for i, member in ipairs( faction.members ) do
                if member == playerTarget then
                    if playerTarget == factions[ currentFaction ].leader then
                        factions[ currentFaction ].leader = nil
                        outputChatBox( getPlayerName( playerTarget ) .. " снят с поста лидера " .. currentFaction, player )
                    end
                    table.remove( faction.members, i ) 
                    outputChatBox( getPlayerName( playerTarget ) .. " исключен из фракции " .. currentFaction, player )
                    break
                end
            end
        else
            outputChatBox( getPlayerName( playerTarget ) .. " не состоите в фракции", player )
        end
    else
        outputChatBox( "Игрока с таким ID нет", player )
    end
end



---Получение фракции игрока 

function getPlayerFaction( player )

    for factionID, factionData in pairs( factions ) do
        if table.contains( factionData.members, player ) then
            return factionID
        end
    end
    return nil
end



---Получение userdata игрока по ID игрока

function getPlayerByID( playerID )
    local players = getElementsByType( "player" )
    for _, player in ipairs( players ) do
        local storedID = getElementData( player, "playerID" )
        if storedID == tonumber( playerID ) then
            return player
        end
    end
    return nil
end



addCommandHandler( "set_player_faction_leader", function( player, cmd, targetPlayerID, factionID )
    
    if targetPlayerID then
        setFactionLeader( player, targetPlayerID, factionID )
    else
        outputChatBox( "Игрок не найден", player )
    end
end )




addCommandHandler( "set_player_faction", function( player, cmd, targetPlayerID, factionID )
    
    if targetPlayerID then
        setPlayerFaction( player, targetPlayerID, factionID )
    else
        outputChatBox( "Игрок не найден", player )
    end
end )



function table.contains( table, element )
    for _, value in pairs( table ) do
        if value == element then
            return true
        end
    end
    return false
end

