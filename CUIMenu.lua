


----------------------------------------------Отрисовка панели------------------------------------------------------

local screenWidth, screenHeight = guiGetScreenSize( )
local panelWidth = screenWidth * 0.6
local panelHeight = screenHeight * 0.6
local x = ( screenWidth - panelWidth ) / 2
local y = ( screenHeight - panelHeight ) / 2

local isOrgPanelVisible = false
local playerFactionData = nil
local accessLevelplayer = nil


local orgPanel = guiCreateWindow( x, y, panelWidth, panelHeight, "Панель организации", false )
local orgName = "Название организации"
guiSetVisible( orgPanel, false )

local tabPanel = guiCreateTabPanel(0.05, 0.1, 0.9, 0.8, true, orgPanel )
local tabMembers = guiCreateTab( "Список участников", tabPanel )
local tabCity = guiCreateTab( "Управление городом", tabPanel )

local gridlist = guiCreateGridList( 0.05, 0.05, 0.9, 0.8, true, tabMembers )
guiGridListAddColumn( gridlist, "ID", 0.2 )
guiGridListAddColumn( gridlist, "Имя", 0.5 )

local fireButton = guiCreateButton( 0.05, 0.9, 0.2, 0.05, "Уволить", true, tabMembers )
local invButton = guiCreateButton( 0.75, 0.9, 0.2, 0.05, "Пригласить", true, tabMembers )
local inviteEdit = guiCreateEdit( 0.64, 0.9, 0.1, 0.05, "", true, tabMembers )
---------------------------------------------------------------------------------------------------------------------

----------------------------------------Получение данных фракции-----------------------------------------------------

addEvent( "factionDataReceived", true )
addEventHandler( "factionDataReceived", root, function( factionData )
    playerFactionData = factionData
end )

---------------------------------------------------------------------------------------------------------------------

--------------------------------------------Видимость панели---------------------------------------------------------

function toggleOrgPanel( )
    requestPlayerFaction( )
    triggerServerEvent("requestFactionData", localPlayer, localPlayer )
    updateGridList( )
    if accessLevelplayer then
        isOrgPanelVisible = not isOrgPanelVisible
        guiSetVisible( orgPanel, isOrgPanelVisible )
        showCursor( isOrgPanelVisible )
    end
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
            accessLevelplayer = "member"
            guiSetVisible( invButton, false )
            guiSetVisible( fireButton, false )
            guiSetVisible( tabCity, false )
        elseif accessLevel == "leader" then
            accessLevelplayer = "leader"
            guiSetVisible( invButton, true )
            guiSetVisible( fireButton, true )
            guiSetVisible( tabCity, true )
        end
    else
        accessLevelplayer = nil
        outputChatBox( "Вы не состоите в фракции." )
    end
end )

--------------------------------------------------------------------------------------------------------------------

----------------------------------------Заполнение списка участников------------------------------------------------

function updateGridList( )
    guiGridListClear( gridlist )


    local members = playerFactionData.members

    for i, memberID in ipairs( members ) do
        local memberName = getPlayerName( memberID ) or "N/A"
        local memberID = getElementData( memberID, "playerID" ) or "N/A"

        local row = guiGridListAddRow( gridlist )
        guiGridListSetItemText( gridlist, row, 1, memberID, false, false )
        guiGridListSetItemText( gridlist, row, 2, memberName, false, false )

    end
end

--------------------------------------------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------------------------------------------

-----------------------------------------Кнопка "Пригласить"--------------------------------------------------------
local targetPlayer = false
local inviteCooldowns = {}
local inviteCooldown = 60 * 1000



--Отправка приглашения

function sendInvite( )
    local playerID = guiGetText( inviteEdit )
    local factionName = playerFactionData.name
    local lastInviteTime = inviteCooldowns[ playerID ]



---- Проверяем что игрок отправляет приглашение впервые или отправлял более 1 мин назад

    if not lastInviteTime or getTickCount( ) - lastInviteTime >= inviteCooldown then
        inviteCooldowns[ playerID] = getTickCount( )
        triggerServerEvent( "checkID", root, localPlayer, playerID, factionName )
    else
        outputChatBox( "Вы можете отправить инвайт этому игроку только раз в 1 минуту.", 255, 0, 0 )
    end
end

addEventHandler( "onClientGUIClick", invButton, sendInvite, false )

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


--------------------------------------------------------------------------------------------------------------------