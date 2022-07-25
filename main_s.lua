tOpenedUI = {}
tInfoUsers = {}
tNumberToInfo = {}
tFreeNumbers = {}
tPoolForQueries = {}
local count_made_queries = 0

setTimer( function()
	local counter = 0
	local i = 1
	while counter < MAX_COUNT_QUERY_PER_SECOND and #tPoolForQueries ~= 0 do

		local func_to_call = tPoolForQueries[i][1]

		dbQuery( func_to_call, { unpack( tPoolForQueries[i], 4 ) }, DB_CONNECTION, tPoolForQueries[i][2] )
		if isElement( tPoolForQueries[i][3] ) then
			outputChatBox( "Запрос выполнен!", tPoolForQueries[i][3] )
		end
		counter = counter + 1
		table.remove( tPoolForQueries, i )
	end
	count_made_queries = counter
end, 20000, 0 )

local function addDB( qh, data )
	local not_error = dbPoll( qh, 0 )
	if not not_error then
		outputChatBox( "Произошла ошибка!", client )
		return
	end

	if tInfoUsers[data] then return end

	if #tFreeNumbers == 0 then
		table.insert( tNumberToInfo, data )
		tInfoUsers[data] = #tNumberToInfo
	else
		tNumberToInfo[tFreeNumbers[1]] = data
		tInfoUsers[data] = tFreeNumbers[1]
		table.remove( tFreeNumbers, 1 )
	end

	addNewDataToAll( data )
end

local function modifyInDB( qh, newData, oldData )
	local not_error = dbPoll( qh, 0 )
	if not not_error then
		outputChatBox( "Произошла ошибка!", client )
		return
	end

	local number_of_last_data = tInfoUsers[oldData]
	if not number_of_last_data then return end

	tNumberToInfo[number_of_last_data] = newData
	tInfoUsers[oldData] = nil
	tInfoUsers[newData] = number_of_last_data
	updateDataToAll( oldData, newData, number_of_last_data )
end

local function deleteFromDB( qh, data )
	local not_error = dbPoll( qh, 0 )

	if not not_error then
		outputChatBox( "Произошла ошибка!", client )
		return
	end

	local number_of_data_in_table = tInfoUsers[data]
	if not number_of_data_in_table then return end

	tInfoUsers[data] = nil
	tNumberToInfo[data] = 0
	updateTableFreeNumbers( number_of_data_in_table )
	deleteDataFromAll( data )
end

addEventHandler( "onResourceStart", resourceRoot, function()
	for _, player in pairs( getElementsByType( "player" ) ) do
		bindKey( player, "L", "down", buttonPress )
	end
	DB_CONNECTION = dbConnect( "mysql", STRING_FOR_CONNECTION, USER_NAME, PASSWORD_NAME  )
	if not isElement( DB_CONNECTION ) then
		iprint( "THERE WERE SOME PROBLEMS TO CONNECT TO DB WITH PARAMETERS: " .. STRING_FOR_CONNECTION )
		return
	end

	iprint( "CONNECTION WAS SET" )
	dbQuery( function( qh )
		local tResultData = dbPoll( qh, 0 )
		local counter = 1
		for _, tCurrentRes in pairs( tResultData ) do
			tInfoUsers[tCurrentRes.jsonPar] = counter
			table.insert( tNumberToInfo, tCurrentRes.jsonPar )
			counter = counter + 1
		end

	end, DB_CONNECTION, "SELECT * FROM everydata" )
end )

addEvent( "onAddingNewDataToDB", true )
addEventHandler( "onAddingNewDataToDB", resourceRoot, function( jsonData )
	if tInfoUsers[jsonData] then
		outputChatBox( "Такие данные уже есть!", client )
		return
	end

	if count_made_queries >= MAX_COUNT_QUERY_PER_SECOND then
		outputChatBox( "Ожидайте, запрос будет выполнен чуть позже" )
		table.insert( tPoolForQueries, { addDB, 
			dbPrepareString( DB_CONNECTION,  QUERY_FOR_ADDING_DATA, jsonData, jsonData ), 
				client, jsonData } )
		return
	end

	count_made_queries = count_made_queries + 1

	dbQuery( addDB, { jsonData }, DB_CONNECTION, 
		QUERY_FOR_ADDING_DATA, jsonData, jsonData )
end )

addEvent( "onModifyingDataToDB", true )
addEventHandler( "onModifyingDataToDB", resourceRoot, function( newData, lastData )
	if tInfoUsers[newData] then
		outputChatBox( "Такие данные уже есть!", client )
		return
	end

	if not tInfoUsers[lastData] then return end


	if count_made_queries >= MAX_COUNT_QUERY_PER_SECOND then
		outputChatBox( "Ожидайте, запрос будет выполнен чуть позже" )
		table.insert( tPoolForQueries, { modifyInDB, 
			dbPrepareString( DB_CONNECTION,  "UPDATE everydata SET jsonPar = ? WHERE jsonPar = ?", newData, lastData ),
				client, newData, lastData } )
		return
	end

	count_made_queries = count_made_queries + 1

	dbQuery( modifyInDB, { newData, lastData }, DB_CONNECTION, "UPDATE everydata SET jsonPar = ? WHERE jsonPar = ?", newData, lastData )
end )

addEvent( "onDeletingDataFromDB", true )
addEventHandler( "onDeletingDataFromDB", resourceRoot, function( data )
	if not tInfoUsers[data] then
		outputChatBox( "Таких данных нет!", client )
		return
	end

	if count_made_queries >= MAX_COUNT_QUERY_PER_SECOND then
		outputChatBox( "Ожидайте, запрос будет выполнен чуть позже" )
		table.insert( tPoolForQueries, { deleteFromDB, 
			dbPrepareString( DB_CONNECTION,  "DELETE FROM everydata WHERE jsonPar = ?", data ), client, data } )
		return
	end

	count_made_queries = count_made_queries + 1

	dbQuery( deleteFromDB, { data }, DB_CONNECTION, "DELETE FROM everydata WHERE jsonPar = ?", data )
end )
