inviteCooldowns = { }
inviteCooldown = 60 * 1000
--Проверка ранга игрока в фракции и отправка на сторону клиента для дальнейшего использования
function getPlayerFactionStatus( player )
    local faction = getPlayerFaction( player )
    if faction then
        if FACTIONS[ faction ].leader == player then
            return "leader"
        end
        for _, member in pairs(FACTIONS[ faction ].members ) do
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
    local factionData = FACTIONS[ factionId ]
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
    if getPlayerByID(ID) then

        local inviteMessage = getPlayerName( player ) .. " приглашает вас вступить в " .. factionName
        local targetPlayer = getPlayerByID( tostring( cID ) )
        local targetPlayerFaction = getPlayerFaction( targetPlayer )
        local factionIdforInvite = nil

--Проверка что игрок не состоит в фракции приглашения
        if targetPlayerFaction == nil or FACTIONS[ targetPlayerFaction ].name ~= factionName then
            local lastInviteTime = inviteCooldowns[ targetPlayer ]
            if not lastInviteTime or getTickCount() - lastInviteTime >= inviteCooldown then
                inviteCooldowns[ targetPlayer ] = getTickCount( )
                for factionID, factionData in pairs( FACTIONS ) do
                    if factionData.name == factionName then 
                        factionIdforInvite = factionID
                    end
                end
                triggerClientEvent( targetPlayer, "onReceiveInvite", resourceRoot, inviteMessage, factionIdforInvite )
                outputChatBox( "Приглашение отправленно", player, 0, 255, 0 )
            else
                outputChatBox( "Игрок не может получать приглашения больше 1 раза в минуту", player, 255, 0, 0 )
            end
        else
            outputChatBox("Игрок уже в фракции " .. factionName, player, 255, 0, 0)
        end
    else
        outputChatBox( "Игрок с ID " .. cID .. " не найден.", player, 255, 0, 0)
    end
end )

addEvent( "acceptInvite", true )
addEventHandler( "acceptInvite", root, function( player, playerID, factionID )
    setPlayerFaction( player, playerID, factionID )
end )
