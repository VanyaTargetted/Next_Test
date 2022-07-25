local function checkingDXMotionOnExit()
	triggerClientEvent( source, "testingJSON:OnDestroyDXMotion", resourceRoot )
end
addEventHandler( "onPlayerLogout", root, checkingDXMotionOnExit )
addEventHandler( "onPlayerQuit", root, checkingDXMotionOnExit )
