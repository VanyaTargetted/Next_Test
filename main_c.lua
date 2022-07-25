local DGS = exports.dgs
tUIElements = {}

local sx, sy = guiGetScreenSize()

SIZE_X, SIZE_Y = sx * 8 / 10, sy * 8 / 10

OFFSET_X, OFFSET_Y = sx * 1 / 10, sy * 1 / 10

MIN_LIMIT_TO_DATA_PAR = 1
MAX_LIMIT_TO_DATA_PAR = 10

SIZE_OF_PAGE = 4

local count_downloaded_pages = 0

local tCashInfoUsers = {}

local function recurseSetPostGUI( element )
	local tElements = DGS:dgsGetChildren( element )

	for i = 1, #tElements do
		recurseSetPostGUI( tElements[i] )
	end

	DGS:dgsSetPostGUI( element, false )
end

addEventHandler( "onClientRender", root, function()
	if not isElement( tUIElements.tab_for_players ) then return end

	local tabSelected = DGS:dgsGetSelectedTab( tUIElements.tab_for_players )

	if not isElement( tabSelected ) then return end

	local newState = true
	if DGS:dgsGridListGetSelectedItem( DGS:dgsGetChild( tabSelected, 1 ) ) == -1 then
		newState = false
		DGS:dgsSetVisible( tUIElements.window_for_conf, false )
	end

	DGS:dgsSetEnabled( tUIElements.button_to_change, newState )
	DGS:dgsSetEnabled( tUIElements.button_to_del, newState )
end )

local function getActualGridList()
	local selected_tab_panel = DGS:dgsGetSelectedTab( tUIElements.tab_for_players )
	local list = DGS:dgsGetChild( selected_tab_panel, 1 )
	return list
end

local function getLastGridList()
	local list = DGS:dgsTabPanelGetTabFromID( tUIElements.tab_for_players, count_downloaded_pages )
	list = DGS:dgsGetChild( list, 1 )
	return list
end

local function getSpecificGridList( number )
	number = tonumber( number )
	if not number then return end

	local list = DGS:dgsTabPanelGetTabFromID( tUIElements.tab_for_players, number )
	list = DGS:dgsGetChild( list, 1 )
	return list
end

local function searchRowInGridList( rowData )
	if not tCashInfoUsers[rowData] then return end

	local list_to_search = getSpecificGridList( tCashInfoUsers[rowData] )
	local tTmpTable = {}

	for i = 1, DGS:dgsGridListGetRowCount( list_to_search ) do
		tTmpTable.name = DGS:dgsGridListGetItemText( list_to_search, i, 1 )
		tTmpTable.surname = DGS:dgsGridListGetItemText( list_to_search, i, 2 )
		tTmpTable.adress = DGS:dgsGridListGetItemText( list_to_search, i, 3 )
		if toJSON( tTmpTable ) == rowData then
			return list_to_search, i
		end
	end
end

local function createNewList()
	local length = #DGS:dgsGetChildren( tUIElements.tab_for_players )
	local tabElement = DGS:dgsCreateTab( tostring( length + 1 ) .. " page", tUIElements.tab_for_players )
	local list = DGS:dgsCreateGridList( 0.01, 0.01, 0.95, 0.95, true, tabElement )

	DGS:dgsGridListAddColumn( list, "Имя", 0.33, nil, "center" )
	DGS:dgsGridListAddColumn( list, "Фамилия", 0.33, nil, "center" )
	DGS:dgsGridListAddColumn( list, "Адрес", 0.33, nil, "center" )
	DGS:dgsSetPostGUI( list, false )
	return list
end

local function fillInNeededList( list, tData, is_necessary_to_add_new )
	for i = 1, #tData do
		local row = DGS:dgsGridListAddRow( list )
		if tData[i] ~= 0 then
			local tInfoCurrentUser = fromJSON( tData[i] )
			DGS:dgsGridListSetItemText( list, row, 1, tInfoCurrentUser.name )
			DGS:dgsGridListSetItemText( list, row, 2, tInfoCurrentUser.surname )
			DGS:dgsGridListSetItemText( list, row, 3, tInfoCurrentUser.adress )
			tCashInfoUsers[tData[i]] = count_downloaded_pages
		end
	end

	if is_necessary_to_add_new then
		createNewList()
	end
end

local function fillInLists( tData, create_one_more_page )
	local listToAdd = createNewList()

	count_downloaded_pages = 1
	fillInNeededList( listToAdd, tData, create_one_more_page )
end

local function initUI( tData, boolPar )
	tUIElements.main_window = DGS:dgsCreateWindow ( OFFSET_X, OFFSET_Y, SIZE_X, SIZE_Y, 
		"Окно управления данными", false, 0xFFFFFFFF )

	DGS:dgsCreateLabel( 0.01, 1 - 0.4, 0.1, 0.05, "Имя", true, tUIElements.main_window )
	DGS:dgsCreateLabel( 0.01, 1 - 0.3, 0.1, 0.05, "Фамилия", true, tUIElements.main_window )
	DGS:dgsCreateLabel( 0.01, 1 - 0.2, 0.1, 0.05, "Адрес", true, tUIElements.main_window )
	tUIElements.edit_name = DGS:dgsCreateEdit( 0.15, 1 - 0.4, 0.2, 0.05, "", true, tUIElements.main_window )
	tUIElements.edit_surname = DGS:dgsCreateEdit( 0.15, 1 - 0.3, 0.2, 0.05, "", true, tUIElements.main_window )
	tUIElements.edit_adress = DGS:dgsCreateEdit( 0.15, 1 - 0.2, 0.2, 0.05, "", true, tUIElements.main_window )
	tUIElements.edit_search = DGS:dgsCreateEdit( 0.4, 1 - 0.42, 0.2, 0.05, "", true, tUIElements.main_window )

	DGS:dgsEditSetMaxLength( tUIElements.edit_name, MAX_LIMIT_TO_DATA_PAR )
	DGS:dgsEditSetMaxLength( tUIElements.edit_surname, MAX_LIMIT_TO_DATA_PAR )
	DGS:dgsEditSetMaxLength( tUIElements.edit_adress, MAX_LIMIT_TO_DATA_PAR )
	DGS:dgsEditSetMaxLength( tUIElements.edit_search, MAX_LIMIT_TO_DATA_PAR )

	tUIElements.button_to_add = DGS:dgsCreateButton( 0.01, 1 - 0.1, 0.1, 0.05, "Добавить", 
		true, tUIElements.main_window )

	tUIElements.button_to_change = DGS:dgsCreateButton( 0.13, 1 - 0.1, 0.1, 0.05, "Редактировать", 
		true, tUIElements.main_window )

	tUIElements.button_to_del = DGS:dgsCreateButton( 0.38, 1 - 0.3, 0.1, 0.1, "Удалить", 
		true, tUIElements.main_window )

	tUIElements.button_to_search = DGS:dgsCreateButton( 0.7, 1 - 0.42, 0.1, 0.05, "Поиск", 
		true, tUIElements.main_window )

	tUIElements.tab_for_players = DGS:dgsCreateTabPanel( 0.01, 0.01, 0.95, 0.53, true, tUIElements.main_window )

	tUIElements.window_for_conf = DGS:dgsCreateWindow( 0.55, 1 - 0.35, 0.3, 0.3, "Окно подтверждения удаления", true )
	DGS:dgsSetParent( tUIElements.window_for_conf, tUIElements.main_window )
	tUIElements.button_conf_delete = DGS:dgsCreateButton( 0.1, 0.3, 0.2, 0.2, "Ага!", true, tUIElements.window_for_conf )
	tUIElements.button_no_conf_delete = DGS:dgsCreateButton( 0.5, 0.3, 0.2, 0.2, "Нет", 
		true, tUIElements.window_for_conf )

	DGS:dgsSetPostGUI( tUIElements.main_window, false )
	DGS:dgsSetPostGUI( tUIElements.tab_for_players, false )

	fillInLists( tData, boolPar )

	recurseSetPostGUI( tUIElements.main_window )

	addEventHandler( "onDgsWindowClose", tUIElements.main_window, function()
		cancelEvent()
		destroyElement( tUIElements.main_window )
		tUIElements = {}
		showCursor( false )
		tCashInfoUsers = {}
		triggerServerEvent( "onSettingTableIndexUI", resourceRoot )
	end )

	addEventHandler( "onDgsMouseClickUp", tUIElements.button_to_change, function()
		local list = getActualGridList()
		local selected_row = DGS:dgsGridListGetSelectedItem( list )
		if selected_row < 0 then return end

		local tTmpData = {
			name = DGS:dgsGetText( tUIElements.edit_name ),
			surname = DGS:dgsGetText( tUIElements.edit_surname ),
			adress = DGS:dgsGetText( tUIElements.edit_adress )
		}

		local tOldData = {
			name = DGS:dgsGridListGetItemText( list, selected_row, 1 ),
			surname = DGS:dgsGridListGetItemText( list, selected_row, 2 ),
			adress = DGS:dgsGridListGetItemText( list, selected_row, 3 ),
		}
		
		for key, value in pairs( tTmpData ) do
			if key ~= "adress" then
				tTmpData[key] = value:gsub( " ", "" )
			end

			value = tTmpData[key]
			if not value or value:len() < MIN_LIMIT_TO_DATA_PAR then
				outputChatBox( "Неверный ввод параметра " .. key )
				return
			end
		end
		local dataToServer = toJSON( tTmpData )
		local lastData = toJSON( tOldData )

		if tCashInfoUsers[dataToServer] then
			outputChatBox( "Такой игрок уже имеется" )
			return
		end

		if not tCashInfoUsers[lastData] then
			outputChatBox( "Таких данных уже нет!" )
			return
		end

		triggerServerEvent( "onModifyingDataToDB", resourceRoot, dataToServer, lastData )
	end, false )

	addEventHandler( "onDgsMouseClickUp", tUIElements.button_to_del, function()
		DGS:dgsSetVisible( tUIElements.window_for_conf, true )
	end, false )

	addEventHandler( "onDgsMouseClickUp", tUIElements.button_no_conf_delete, function()
		DGS:dgsSetVisible( tUIElements.window_for_conf, false )
	end, false )

	addEventHandler( "onDgsMouseClickUp", tUIElements.button_conf_delete, function()
		local list = getActualGridList()
		local selected_row = DGS:dgsGridListGetSelectedItem( list )
		if selected_row < 0 then return end

		local tOldData = {
			name = DGS:dgsGridListGetItemText( list, selected_row, 1 ),
			surname = DGS:dgsGridListGetItemText( list, selected_row, 2 ),
			adress = DGS:dgsGridListGetItemText( list, selected_row, 3 ),
		}

		local dataToServer = toJSON( tOldData )

		if not tCashInfoUsers[dataToServer] then
			outputChatBox( "Таких данных уже нет!" )
			return
		end

		triggerServerEvent( "onDeletingDataFromDB", resourceRoot, dataToServer )
		DGS:dgsSetVisible( tUIElements.window_for_conf, false )
	end, false )

	addEventHandler( "onDgsMouseClickUp", tUIElements.button_to_add, function()
		local tTmpData = {
			name = DGS:dgsGetText( tUIElements.edit_name ),
			surname = DGS:dgsGetText( tUIElements.edit_surname ),
			adress = DGS:dgsGetText( tUIElements.edit_adress )
		}
		
		for key, value in pairs( tTmpData ) do
			if key ~= "adress" then
				tTmpData[key] = value:gsub( " ", "" )
			end

			value = tTmpData[key]
			if not value or value:len() < MIN_LIMIT_TO_DATA_PAR then
				outputChatBox( "Неверный ввод параметра " .. key )
				return
			end
		end

		if tCashInfoUsers[toJSON( tTmpData )] then
			outputChatBox( "Такой игрок уже имеется" )
			return
		end

		triggerServerEvent( "onAddingNewDataToDB", resourceRoot, toJSON( tTmpData ) )
	end, false )

	addEventHandler( "onDgsMouseClickUp", tUIElements.button_to_search, function()
		local templateToSearch = DGS:dgsGetText( tUIElements.edit_search )
		for i = 1, count_downloaded_pages do
			local list = DGS:dgsGetChild( DGS:dgsTabPanelGetTabFromID( tUIElements.tab_for_players, i ) , 1)
			for j = 1, DGS:dgsGridListGetRowCount( list ) do
				local name, surname, adress = DGS:dgsGridListGetItemText( list, j, 1 ), 
					DGS:dgsGridListGetItemText( list, j, 2 ), DGS:dgsGridListGetItemText( list, j, 3 )
				if name:find( templateToSearch ) or surname:find( templateToSearch ) or adress:find( templateToSearch ) then
					DGS:dgsGridListSetItemColor( list, j, nil, 247, 2, 2 )
				else
					DGS:dgsGridListSetItemColor( list, j, nil, 247, 247, 247 )
				end
			end
		end
		outputChatBox( "Найденные строки выделены красным цветом!" )
	end, false )

	showCursor( true )

	addEventHandler( "onDgsTabPanelTabSelect", tUIElements.tab_for_players, function( newID )
		if newID == count_downloaded_pages + 1 then
			triggerServerEvent( "onQueryMorePages", resourceRoot, newID )
		end
	end, false )

	addEventHandler( "onDgsMouseClickUp", tUIElements.tab_for_players, function()
		DGS:dgsSetVisible( tUIElements.window_for_conf, false )
	end )
end 

addEvent( "onOpenedUI", true )
addEventHandler( "onOpenedUI", resourceRoot, function( tInfoUsers, is_necessary_to_add_new )
	initUI( tInfoUsers, is_necessary_to_add_new )
end )

addEvent( "onAddNewDataToLists", true )
addEventHandler( "onAddNewDataToLists", resourceRoot, function( tData, is_necessary_to_add_new )
	count_downloaded_pages = count_downloaded_pages + 1
	local list = getLastGridList()
	fillInNeededList( list, tData, is_necessary_to_add_new )
end )

addEvent( "onClosedUI", true )
addEventHandler( "onClosedUI", resourceRoot, function( tInfoUsers )
	if not isElement( tUIElements.main_window ) then return end

	tCashInfoUsers = {}
	destroyElement( tUIElements.main_window )
	tUIElements = {}
	showCursor( false )
end )

addEvent( "onAddingNewRowToList", true )
addEventHandler( "onAddingNewRowToList", resourceRoot, function( data, dataIndex )
	if not isElement( tUIElements.main_window ) then return end

	if dataIndex - SIZE_OF_PAGE * count_downloaded_pages == 1 then
		createNewList()
		return
	end

	local number_of_list = math.floor( dataIndex / SIZE_OF_PAGE )
	number_of_list = ( dataIndex % SIZE_OF_PAGE == 0 ) and number_of_list or ( number_of_list + 1 )
	if number_of_list > count_downloaded_pages then return end

	local list = getSpecificGridList( number_of_list )
	local row = DGS:dgsGridListAddRow( list )
	local tInfoCurrentUser = fromJSON( data )
	DGS:dgsGridListSetItemText( list, row, 1, tInfoCurrentUser.name )
	DGS:dgsGridListSetItemText( list, row, 2, tInfoCurrentUser.surname )
	DGS:dgsGridListSetItemText( list, row, 3, tInfoCurrentUser.adress )
	tCashInfoUsers[data] = number_of_list
end )

addEvent( "onModifyRowInList", true )
addEventHandler( "onModifyRowInList", resourceRoot, function( oldData, newData )
	if not isElement( tUIElements.main_window ) then return end

	local list, row = searchRowInGridList( oldData )
	if not list then return end

	local tInfoCurrentUser = fromJSON( newData )
	DGS:dgsGridListSetItemText( list, row, 1, tInfoCurrentUser.name )
	DGS:dgsGridListSetItemText( list, row, 2, tInfoCurrentUser.surname )
	DGS:dgsGridListSetItemText( list, row, 3, tInfoCurrentUser.adress )
	tCashInfoUsers[newData] = tCashInfoUsers[oldData]
	tCashInfoUsers[oldData] = nil
end )

addEvent( "onDeleteRowInList", true )
addEventHandler( "onDeleteRowInList", resourceRoot, function( data )
	if not isElement( tUIElements.main_window ) then return end

	local list, row = searchRowInGridList( data )
	if not list then return end

	DGS:dgsGridListRemoveRow( list, row )
	tCashInfoUsers[data] = nil
end )


