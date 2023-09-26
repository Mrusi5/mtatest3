----------------------------------------------Отрисовка панели------------------------------------------------------

local screenWidth, screenHeight = guiGetScreenSize( )
local panelWidth = screenWidth * 0.6
local panelHeight = screenHeight * 0.6
local x = ( screenWidth - panelWidth ) / 2
local y = ( screenHeight - panelHeight ) / 2

local isOrgPanelVisible = false
local playerFactionData = nil
local accessLevelplayer = nil


local orgPanel = nil

----------------------------------------Получение данных фракции-----------------------------------------------------
addEvent( "factionDataReceived", true )
addEventHandler( "factionDataReceived", root, function( factionData )
    playerFactionData = factionData
end )
--------------------------------------------Видимость панели---------------------------------------------------------
function toggleOrgPanel( )
    requestPlayerFaction( )
    triggerServerEvent( "requestFactionData", localPlayer, localPlayer )
    setTimer( function( )
        if accessLevelplayer then
            if not orgPanel then
                orgPanel = guiCreateWindow( x, y, panelWidth, panelHeight, "Панель организации", false )
                guiSetVisible( orgPanel, true )
                showCursor( true )
                
                orgName = "Название организации"
        
        
                tabPanel = guiCreateTabPanel( 0.05, 0.1, 0.9, 0.8, true, orgPanel )
                tabMembers = guiCreateTab( "Список участников", tabPanel )
        
                gridlist = guiCreateGridList( 0.05, 0.05, 0.9, 0.8, true, tabMembers )
                guiGridListAddColumn( gridlist, "ID", 0.2 )
                guiGridListAddColumn( gridlist, "Имя", 0.5 )
    
                if accessLevelplayer == "leader" then
                    tabCity = guiCreateTab( "Управление городом", tabPanel )
                    fireButton = guiCreateButton( 0.05, 0.9, 0.2, 0.05, "Уволить", true, tabMembers )
                    invButton = guiCreateButton( 0.75, 0.9, 0.2, 0.05, "Пригласить", true, tabMembers )
                    inviteEdit = guiCreateEdit( 0.64, 0.9, 0.1, 0.05, "", true, tabMembers )
--------------------------------------------Кнопка "Уволить"--------------------------------------------------------
                    addEventHandler( "onClientGUIClick", fireButton, function( )
                        local selectedRow, selectedCol = guiGridListGetSelectedItem( gridlist )
                        
                        if selectedRow and selectedCol then
                            local playerID = guiGridListGetItemText( gridlist, selectedRow, 1 )
                            if playerID ~= "" then
                                triggerServerEvent( "firePlayerFromFaction", root, localPlayer, playerID )
                            else
                                outputChatBox( "Выберите игрока из списка, чтобы уволить его.", 255, 0, 0 )
                            end
                    
                        end
                    end, false )
                    -----------------------------------------Кнопка "Пригласить"--------------------------------------------------------
                    function sendInvite( )
                        local playerID = guiGetText( inviteEdit )
                        local factionName = playerFactionData.name
                        triggerServerEvent( "checkID", root, localPlayer, playerID, factionName )
                    end
                    
                    addEventHandler( "onClientGUIClick", invButton, sendInvite, false )
                    updateGridList()
                end
            else
                orgPanel = nil
                showCursor(false)
            end
        end
    end, 100, 1 )
end

bindKey( "p", "down", toggleOrgPanel )

function requestPlayerFaction( )
    triggerServerEvent( "checkPlayerFaction", localPlayer, localPlayer )
end 
-- Проверка доступа панели
addEvent( "receiveFactionForAccessLevel", true )
addEventHandler( "receiveFactionForAccessLevel", root, function( accessLevel )
    if accessLevel then
        if accessLevel == "member" then
            if orgPanel then
                destroyElement(orgPanel)
                showCursor(false)
            end
            accessLevelplayer = "member"
        elseif accessLevel == "leader" then
            if orgPanel then
                destroyElement(orgPanel)
                showCursor(false)
            end
            accessLevelplayer = "leader"
        end
    else
        accessLevelplayer = nil
        if orgPanel then
            destroyElement(orgPanel)
            showCursor(false)
            orgPanel = nil
        end
        outputChatBox( "Вы не состоите в фракции." )
    end
end )

----------------------------------------Заполнение списка участников------------------------------------------------
function updateGridList( )
    guiGridListClear( gridlist )


    local members = playerFactionData.members

    for i, memberID in pairs( members ) do
        local memberName = getPlayerName( memberID ) or "N/A"
        local memberID = getElementData( memberID, "playerID" ) or "N/A"

        local row = guiGridListAddRow( gridlist )
        guiGridListSetItemText( gridlist, row, 1, memberID, false, false )
        guiGridListSetItemText( gridlist, row, 2, memberName, false, false )

    end
end

local inviteWindow = nil
--Окно приглашения

function receiveInvite( inviteMessage, factionIdforInvite )
    if not isElement( inviteWindow ) then
        inviteWindow = guiCreateWindow( 0.3, 0.3, 0.4, 0.2, "Приглашение", true )
        local inviteLabel = guiCreateLabel( 0.1, 0.2, 0.8, 0.3, inviteMessage, true, inviteWindow )
        local acceptButton = guiCreateButton( 0.2, 0.7, 0.3, 0.2, "Принять", true, inviteWindow )
        local declineButton = guiCreateButton( 0.5, 0.7, 0.3, 0.2, "Отказаться", true, inviteWindow )

        guiSetInputEnabled( true )
---------Обработка нажатия кнопки "Принять"
        addEventHandler( "onClientGUIClick", acceptButton, function( )

            local playerID = getElementData( localPlayer, "playerID" )

            triggerServerEvent( "acceptInvite", localPlayer, localPlayer, playerID, factionIdforInvite )

            destroyElement( inviteWindow )

            guiSetInputEnabled( false )
        end, false )
---------Обработка нажатия кнопки "Отказаться"
        addEventHandler( "onClientGUIClick", declineButton, function( )
            destroyElement( inviteWindow )

            guiSetInputEnabled( false )
        end, false )
    end
end

addEvent( "onReceiveInvite", true )
addEventHandler( "onReceiveInvite", resourceRoot, receiveInvite )
