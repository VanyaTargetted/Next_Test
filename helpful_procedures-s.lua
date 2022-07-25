function buttonPress( player )
	if tOpenedUI[player] then
		triggerClientEvent( player, "onClosedUI", resourceRoot )
		tOpenedUI[player] = nil
	else
		triggerClientEvent( player, "onOpenedUI", resourceRoot, { unpack( tNumberToInfo, 1, SIZE_OF_PAGE ) }, 
			#tNumberToInfo > SIZE_OF_PAGE )
		tOpenedUI[player] = 1
	end
end

function addNewDataToAll( data )
	local tWhomSend = {}
	local number_of_data = tInfoUsers[data]

	for player, current_page in pairs( tOpenedUI ) do
		if number_of_data <= current_page * SIZE_OF_PAGE + 1 then
			table.insert( tWhomSend, player )
		end
	end

	triggerClientEvent( tWhomSend, "onAddingNewRowToList", resourceRoot, data, number_of_data )
end

function updateDataToAll( old, new, indexInTable )
	local tWhomSend = {}
	for player, current_page in pairs( tOpenedUI ) do
		if indexInTable <= current_page * SIZE_OF_PAGE then
			table.insert( tWhomSend, player )
		end
	end

	triggerClientEvent( tWhomSend, "onModifyRowInList", resourceRoot, old, new )
end

function deleteDataFromAll( data )
	local tWhomSend = {}

	for player, current_page in pairs( tOpenedUI ) do
		table.insert( tWhomSend, player )
	end

	triggerClientEvent( tWhomSend, "onDeleteRowInList", resourceRoot, data )
end

function updateTableFreeNumbers( newNumber )
	for i = 1, #tFreeNumbers do
		if tFreeNumbers[i] >= newNumber then
			table.insert( tFreeNumbers, i, newNumber )
			return
		end
	end
	table.insert( tFreeNumbers, newNumber )
end

addEvent( "onSettingTableIndexUI", true )
addEventHandler( "onSettingTableIndexUI", resourceRoot, function()
	tOpenedUI[client] = nil
end )

addEventHandler( "onPlayerJoin", root, function()
	tOpenedUI[source] = true
end )

addEvent( "onQueryMorePages", true )
addEventHandler( "onQueryMorePages", resourceRoot, function( page_to_download )
	if not tOpenedUI[client] or tOpenedUI[client] ~= page_to_download - 1 then return end

	triggerClientEvent( client, "onAddNewDataToLists", resourceRoot, 
		{ unpack( tNumberToInfo, (page_to_download - 1) * SIZE_OF_PAGE + 1, page_to_download * SIZE_OF_PAGE ) }, 
			#tNumberToInfo > page_to_download * SIZE_OF_PAGE )
	tOpenedUI[client] = page_to_download
end )