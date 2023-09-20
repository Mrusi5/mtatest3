


function sendFactionMessage( player, message )
    local factionID = getPlayerFaction( player )
    
    if factionID and factions[ factionID ] then
        local factionName = factions[ factionID ].name
        local formattedMessage = string.format( "[%s] %s: %s", factionName, getPlayerName( player ), message )
        
        for _, member in ipairs( factions[ factionID ].members ) do
            if isElement( member ) and getElementType( member ) == "player" then
                outputChatBox( formattedMessage, member, 146, 110, 174 )
            end
        end
    else
        outputChatBox( "Вы не состоите в фракции", player, 255, 0, 0 )
    end
end


addCommandHandler( "f", function( player, cmd, ... )

    local message = table.concat( { ... }, " " )

    if message and message ~= "" then
        sendFactionMessage( player, message )
    else
        outputChatBox( "Используйте: /f [текст сообщения]", player, 255, 0, 0 )
    end

end )