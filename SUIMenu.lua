


---Получение таблицы с использованными Id для поиска активных Id в будущем

local receivedTable = { }

function getTable( )
    receivedTable = call( getResourceFromName( "id_players" ), "exportTable" )
end

setTimer( getTable, 2000,  1 )



--Проверка ранга игрока в фракции и отправка на сторону клиента для дальнейшего использования

function getPlayerFactionStatus( player )
    local faction = getPlayerFaction( player )
    if faction then
        if factions[ faction ].leader == player then
            return "leader"
        end
        for _, member in ipairs(factions[ faction ].members ) do
            if member == player then
                return "member"
            end
        end
    end
    return nil
end

function onCheckPlayerFactionRequest( player )

    local accessLevel = getPlayerFactionStatus( player )

    triggerClientEvent( player, "receiveFactionForAccessLevel", root, accessLevel )
end

addEvent( "checkPlayerFaction", true )
addEventHandler( "checkPlayerFaction", root, onCheckPlayerFactionRequest )



--Отправка информации о фракции игрока для визуализации и использования

function sendFactionDataToClient( player )
    local factionId = getPlayerFaction( player )
    local factionData = factions[ factionId ]
    triggerClientEvent( player, "factionDataReceived", root, factionData )
end

addEvent( "requestFactionData", true )
addEventHandler( "requestFactionData", root, sendFactionDataToClient )



--Обработка кнопки "Уволить"

addEvent( "firePlayerFromFaction", true )
addEventHandler( "firePlayerFromFaction", root, function( player, playerID )
    setPlayerFaction( player, playerID )
end )



--Проверка ID на онлайн и отправка инвайта если игрок онлайн

addEvent( "checkID", true )
addEventHandler( "checkID", root, function( player, ID, factionName )
    cID = tonumber( ID )

--Проверка на онлайн    

    if receivedTable[ cID ] then

        local inviteMessage = getPlayerName( player ) .. " приглашает вас вступить в " .. factionName
        local targetPlayer = getPlayerByID( tostring( cID ) )
        local targetPlayerFaction = getPlayerFaction( targetPlayer )
        local factionIdforInvite = nil

--Проверка что игрок не состоит в фракции приглашения

        if targetPlayerFaction == nil or factions[ targetPlayerFaction ].name ~= factionName then
            for factionID, factionData in pairs( factions ) do
                if factionData.name == factionName then 
                    factionIdforInvite = factionID
                end
            end
            triggerClientEvent( targetPlayer, "onReceiveInvite", resourceRoot, inviteMessage, factionIdforInvite )
            outputChatBox( "Приглашение отправленно", player, 0, 255, 0 )
        else
            outputChatBox("Игрок уже в фракции" .. factionName, player, 255, 0, 0)
        end
    else
        outputChatBox( "Игрок с ID " .. cID .. " не найден.", player, 255, 0, 0)
    end
end )


addEvent( "acceptInvite", true )
addEventHandler( "acceptInvite", root, function( player, playerID, factionID )
    setPlayerFaction( player, playerID, factionID )
end )