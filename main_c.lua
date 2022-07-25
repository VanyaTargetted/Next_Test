local parMaxX, parMaxY = guiGetScreenSize()

local tBoundaryParametrs = {
	left = {},
	right = {}
}
tBoundaryParametrs.left.currentX = math.random( 0, parMaxX / 2 - 128 )
tBoundaryParametrs.left.currentY = math.random( 0, parMaxY - 128 )
tBoundaryParametrs.left.MaxX = parMaxX / 2 - 128
tBoundaryParametrs.left.MinX = 0
tBoundaryParametrs.left.r = math.random( 0, 255 )
tBoundaryParametrs.left.g = math.random( 0, 255 )
tBoundaryParametrs.left.b = math.random( 0, 255 )
tBoundaryParametrs.left.changeX = 5
tBoundaryParametrs.left.changeY = 5

tBoundaryParametrs.right.currentX = math.random( parMaxX / 2, parMaxX - 128 )
tBoundaryParametrs.right.currentY = math.random( 0, parMaxY - 128 )
tBoundaryParametrs.right.MaxX = parMaxX - 128
tBoundaryParametrs.right.MinX = parMaxX / 2
tBoundaryParametrs.right.r = math.random( 0, 255 )
tBoundaryParametrs.right.g = math.random( 0, 255 )
tBoundaryParametrs.right.b = math.random( 0, 255 )
tBoundaryParametrs.right.changeX = 5
tBoundaryParametrs.right.changeY = 5

local timerVar

addEventHandler( 'onClientRender', root, function()
	if not timerVar then
		return
	end

	--dxDrawImageSection(400, 200, 64, 64, 0, 0, 64, 64, 'mts.png') -- Draw a certain section
	dxDrawLine( parMaxX / 2, parMaxX, parMaxX / 2, 0, tocolor( 255, 255, 255, 255 ) )
	dxDrawImage( tBoundaryParametrs.right.currentX, tBoundaryParametrs.right.currentY, 128, 128, 'logo.png', 0, 0, 0, tocolor( tBoundaryParametrs.right.r, tBoundaryParametrs.right.g, tBoundaryParametrs.right.b, 255 ) )
	dxDrawImage( tBoundaryParametrs.left.currentX, tBoundaryParametrs.left.currentY, 128, 128, 'logo.png', 0, 0, 0, tocolor( tBoundaryParametrs.left.r, tBoundaryParametrs.left.g, tBoundaryParametrs.left.b, 255 ) )
end )

local function changeColor( parOrientation )
	tBoundaryParametrs[parOrientation].r = math.random( 0, 255 )
	tBoundaryParametrs[parOrientation].g = math.random( 0, 255 )
	tBoundaryParametrs[parOrientation].b = math.random( 0, 255 )
end

local function changeCoordinates( parOrientation )
	if tBoundaryParametrs[parOrientation].currentX >= tBoundaryParametrs[parOrientation].MaxX then
		tBoundaryParametrs[parOrientation].changeX = -5
		changeColor( parOrientation )
	end
	
	if tBoundaryParametrs[parOrientation].currentY >= parMaxY - 128 then
		tBoundaryParametrs[parOrientation].changeY = -5
		changeColor( parOrientation )
	end
	
	if tBoundaryParametrs[parOrientation].currentX <= tBoundaryParametrs[parOrientation].MinX then
		tBoundaryParametrs[parOrientation].changeX = 5
		changeColor( parOrientation )
	end
	
	if tBoundaryParametrs[parOrientation].currentY <= 0 then
		tBoundaryParametrs[parOrientation].changeY = 5
		changeColor( parOrientation )
	end

	tBoundaryParametrs[parOrientation].currentX = tBoundaryParametrs[parOrientation].currentX + tBoundaryParametrs[parOrientation].changeX
	tBoundaryParametrs[parOrientation].currentY = tBoundaryParametrs[parOrientation].currentY + tBoundaryParametrs[parOrientation].changeY
end

addCommandHandler( "changeMotion", function()
	if timerVar then
		killTimer( timerVar )
		timerVar = nil
		return
	end

	timerVar = setTimer( function()
		changeCoordinates( "left" )

		changeCoordinates( "right" )
	end, 5, 0 )
end )

addEvent( "testingJSON:OnDestroyDXMotion", true )
addEventHandler( "testingJSON:OnDestroyDXMotion", resourceRoot, function()
	if timerVar then
		killTimer( timerVar )
		timerVar = nil
	end
end )

