-- Made by MisterInSayne
-- Visual and Input interface derived from Robert Johnson's ISBuildingObject
-- This coding is not to be used or adjusted without my express permission.


require "ISBaseObject"

InSayneObject = ISBaseObject:derive("InSayneObject");

function InSayneObject:initialise()
	
end

function InSayneObject:setCanPassThrough(passThrough)
	self.canPassThrough(passThrough);
end

function InSayneObject:setNorthSprite(sprite)
	self.northSprite = sprite;
end

function InSayneObject:setEastSprite(sprite)
	self.eastSprite = sprite;
end

function InSayneObject:setSouthSprite(sprite)
	self.southSprite = sprite;
end

function InSayneObject:setSprite(sprite)
	self.sprite = sprite;
	self.choosenSprite = sprite;
end

function InSayneObject:setDragNilAfterPlace(nilAfter)
	self.dragNilAfterPlace = nilAfter;
end

--[[
-- Not sure if we want to give it a onDestroy function yet, but we'll see.
function InSayneObject.onDestroy(thump, player)
	if thump:getContainer() and thump:getContainer():getItems() then
		local items = thump:getContainer():getItems()
		for i=0,items:size()-1 do
			thump:getSquare():AddWorldInventoryItem(items:get(i), 0.0, 0.0, 0.0)
		end
	end
	for index, value in pairs(thump:getModData()) do
		if luautils.stringStarts(index, "need:") then
			local itemToConsume = luautils.split(index, ":")[2];
			for i=1,tonumber(value) do
				if ZombRand(2) == 0 then
					-- item destroyed
				elseif player then
                    player:getInventory():AddItem(itemToConsume);
                else
                    thump:getSquare():AddWorldInventoryItem(itemToConsume, 0.0, 0.0, 0.0);
                end
			end
		end
	end
	
	local stairObjects = buildUtil.getStairObjects(thump)
	if #stairObjects > 0 then
		for i=1,#stairObjects do
			stairObjects[i]:getSquare():transmitRemoveItemFromSquare(stairObjects[i])
			stairObjects[i]:getSquare():RemoveTileObject(stairObjects[i])
		end
    else
		thump:getSquare():transmitRemoveItemFromSquare(thump)
		thump:getSquare():RemoveTileObject(thump)
	end
end
]]

local function isMouseOverUI()
	local uis = UIManager.getUI()
	for i=1,uis:size() do
		local ui = uis:get(i-1)
		if ui:isMouseOver() then
			return true
		end
	end
	return false
end


function InSayneObject:tryBuild(x, y, z)
	local square = getCell():getGridSquare(x, y, z)
	local playerObj = getSpecificPlayer(self.player)
	local doIt = false
	if not ISBuildMenu.cheat then
		if self.skipWalk or luautils.walkAdj(playerObj, square) then
			doIt = true
		end
	else
		doIt = true
	end
	if doIt then
		--if self.dragNilAfterPlace then
			getCell():setDrag(nil, self.player)
		--end
		
		-- InSayne's Adjustment: We're using strength instead
		local maxTime = (200 - (playerObj:getPerkLevel(Perks.Strength) * 5))
		if self.maxTime then
			maxTime = self.maxTime
		end
		if ISBuildMenu.cheat then
			maxTime = 1
		end
		if self.skipBuildAction then
			self:create(x, y, z, self.north, self:getSprite())
		else
			-- InSayne's Adjustment: This is where we build the object in the real world :D
			ISTimedActionQueue.add(ISBuildAction:new(playerObj, self, x, y, z, self.north, self:getSprite(), maxTime))
		end
	end
end

function InSayneObject:haveMaterial(square)
	if ISBuildMenu.cheat then
		return true;
	end
	local dragItem = self
	
	if dragItem.character:getInventory():getItems():contains(dragItem.sourceItem) then
		return true;
	end
	--[[
	if dragItem.character:getPrimaryHandItem() then
		local carriedItem = dragItem.character:getPrimaryHandItem();
		
		if carriedItem:getType() == "InFridge" or carriedItem:getType() == "InMicrowave" or carriedItem:getType() == "InStove" then
			return true;
		end
	end
	]]
	return false;
end

function InSayneObject:reinit()
--~ 	ISBuildingObject.nSprite = 1;
	self.isLeftDown = false;
	self.clickedUI = false;
	self.canBeBuild = false;
	self.build = false;
	self.square = nil;
--~ 	ISBuildingObject.north = false;
end

function InSayneObject:reset()
--	getCell():setDrag(nil);
	self.northSprite = nil;
	self.sprite = nil;
	self.southSprite = nil;
	self.eastSprite = nil;
	self.nSprite = 1;
	self.isLeftDown = false;
	self.clickedUI = false;
	self.canBeBuild = false;
	self.build = false;
	self.square = nil;
	self.north = false;
	self.south = false;
	self.east = false;
	self.west = false;
	self.choosenSprite = nil;
	self.dragNilAfterPlace = false;
	self.xJoypad = -1;
	self.yJoypad = -1;
	self.zJoypad = -1;
end

function InSayneObject:init()
	self:reset();
	self.canBeAlwaysPlaced = false;
	self.isContainer = false;
	self.canPassThrough = false;
	self.canBarricade = false;
	self.needsCounter = false;
	self.thumpDmg = 8;
	self.isDoor = false;
	self.isDoorFrame = false;
	self.crossSpeed = 1.0;
	self.blockAllTheSquare = false;
	self.dismantable = false;
	self.canBePlastered = false;
	self.hoppable = false;
    self.isThumpable = true;
	self.sourceItem = nil;
	self.modData = {};
end

function InSayneObject:getSprite()
	self.north = false;
	self.south = false;
	self.east = false;
	self.west = false;
	self.choosenSprite = self.sprite;
	if self.nSprite == 1 then
		self.west = true;
		self.choosenSprite = self.sprite;
	elseif self.nSprite == 2 then
		self.north = true;
		self.choosenSprite = self.northSprite;
	elseif self.nSprite == 3 then
		if self.eastSprite then
			self.choosenSprite = self.eastSprite;
			self.east = true;
		else
			self.west = true;
			self.choosenSprite = self.sprite;
		end
	elseif self.nSprite == 4 then
		if self.southSprite then
			self.south = true;
			self.choosenSprite = self.southSprite;
		else
			self.north = true;
			self.choosenSprite = self.northSprite;
		end
	end
	return self.choosenSprite;
end

function InSayneObject:rotateKey(key)
	if key == getCore():getKey("Rotate building") then
		self.nSprite = self.nSprite + 1;
		if self.nSprite > 4 then
			self.nSprite = 1;
		end
	end
end

local function rotateKey(key)
	if getCell() and getCell():getDrag(0) then
		getCell():getDrag(0):rotateKey(key)
	end
end

function InSayneObject:rotateMouse(x, y)
	if self.square then
		-- we start to get the direction the mouse is compared to the selected square for the item
		local difx = x - self.square:getX();
		local dify = y - self.square:getY();
		-- west
		if difx < 0 and math.abs(difx) > math.abs(dify) then
			self.nSprite = 1;
		end
		-- east
		if difx > 0 and math.abs(difx) > math.abs(dify) then
			self.nSprite = 3;
		end
		-- north
		if dify < 0 and math.abs(difx) < math.abs(dify) then
			self.nSprite = 2;
		end
		-- south
		if dify > 0 and math.abs(difx) < math.abs(dify) then
			self.nSprite = 4;
		end
	end
end

function InSayneObject:isValid(square)
	if not square then return false end
	if not self:haveMaterial(square) then return false end
	if self.sourceItem then
		if self.sourceItem:getModData()["objType"] then
			if self.sourceItem:getModData()["objType"] == "barbecue" then
				if not square:isOutside() then
					return false;
				end
			end
		end
	end
	if self.canBeAlwaysPlaced then
		-- even if we can place this item everywhere, we can't place 2 same objects on the same tile
		for i=0,square:getObjects():size()-1 do
			local obj = square:getObjects():get(i);
			if self:getSprite() == obj:getTextureName() then
				return false
			end
		end
		if self.needsCounter then
			local hasCounter = false;
			local hasStuffOnTop = false;
			for i=0,square:getObjects():size()-1 do
				local obj = square:getObjects():get(i);
				if obj:getContainer() then
					if obj:getContainer():getType() == "counter" then
						hasCounter = true;
					end
				else
					if instanceof(obj, "IsoStove") or instanceof(obj, "IsoLightSwitch") or obj:hasWater() then
						hasStuffOnTop = true;
					end
				end
			end
			return hasCounter and not hasStuffOnTop;
		end
		return true
	end
	
	if square:isSolid() or square:isSolidTrans() then return false end
	if square:HasStairs() then return false end
	if square:HasTree() then return false end
	if not square:getMovingObjects():isEmpty() then return false end
	if not square:TreatAsSolidFloor() then return false end
	for i=1,square:getObjects():size() do
		local obj = square:getObjects():get(i-1)
		if self:getSprite() == obj:getTextureName() then return false end
		if not (instanceof(obj, "IsoDoor") or instanceof(obj, "IsoWindow") or instanceof(obj, "IsoCurtain") or instanceof(obj, "IsoBarricade") or obj:getType() == IsoObjectType.wall or obj:getType() == IsoObjectType.doorFrN or obj:getType() == IsoObjectType.doorFrW or (instanceof(obj, "IsoThumpable") and (obj:isFloor() or obj:isDoor() or obj:isDoorFrame())) or obj:getProperties():getPropertyNames():toString() == "[]" or string.sub(obj:getSprite():getName(), 1, 5) == "blend") then return false end
		--if not (obj:getType():toString() == "wall" or obj:getProperties():getPropertyNames():toString() == "[]") then return false end
	end
	return square:isFreeOrMidair(true, true)
	--return buildUtil.canBePlace(self, square) and square:isFreeOrMidair(true, true)
end

function InSayneObject:render(x, y, z, square)
	-- optionally draw a floor tile to aid placement (stacked wooden crates for example)
	if self.renderFloorHelper then
		local sprite = IsoSprite.new()
		sprite:LoadFramesNoDirPageSimple('carpentry_02_56')
		sprite:RenderGhostTile(x, y, z)
	end

	local spriteName = self:getSprite()
	local sprite = IsoSprite.new()
	sprite:LoadFramesNoDirPageSimple(spriteName)

	-- if the square is free and our item can be build
	if self:isValid(square) then
		sprite:RenderGhostTile(x, y, z);
	else
		sprite:RenderGhostTileRed(x, y, z);
	end
end

function InSayneObject:onJoypadPressButton(joypadIndex, joypadData, button)
    local playerObj = getSpecificPlayer(joypadData.player)
    if button == Joypad.AButton then
        if self.canBeBuild then
            self:tryBuild(self.xJoypad, self.yJoypad, self.zJoypad)
        end
    end

    if button == Joypad.BButton then
        getCell():setDrag(nil, joypadData.player);
    end

    if button == Joypad.RBumper then
        self.nSprite = self.nSprite + 1;
        if self.nSprite > 4 then
            self.nSprite = 1;
        end
    end

    if button == Joypad.LBumper then
        self.nSprite = self.nSprite - 1;
        if self.nSprite < 1 then
            self.nSprite = 4;
        end
    end
end

function InSayneObject:onJoypadDirDown(joypadData)
    self.yJoypad = self.yJoypad + 1;
end

function InSayneObject:onJoypadDirUp(joypadData)
    self.yJoypad = self.yJoypad - 1;
end

function InSayneObject:onJoypadDirRight(joypadData)
    self.xJoypad = self.xJoypad + 1;
end

function InSayneObject:onJoypadDirLeft(joypadData)
    self.xJoypad = self.xJoypad - 1;
end

function InSayneObject:getAPrompt()
    if self.canBeBuild then
        return "Place";
    end
end

function InSayneObject:getLBPrompt()
    return getText("IGUI_Controller_RotateLeft")
end

function InSayneObject:getRBPrompt()
    return getText("IGUI_Controller_RotateRight")
end

--[[
function DoInSaynTileBuilding(draggingItem, isRender, x, y, z, square)
	local spriteName = nil;
	if not draggingItem.player then print('ERROR: player not set in DoInSaynTileBuilding'); draggingItem.player = 0 end;
	if square == nil and getWorld():isValidSquare(x, y, z) then
		square = getCell():createNewGridSquare(x, y, z, true);
	end
	
	-- get the sprite we have to display
	if draggingItem.player == 0 then
		local mouseOverUI = isMouseOverUI();
		if Mouse:isLeftDown() then
			if not draggingItem.isLeftDown then
				draggingItem.clickedUI = mouseOverUI;
				draggingItem.isLeftDown = true;
			end
			if draggingItem.clickedUI then return end
			draggingItem:rotateMouse(x, y);
		else
			if draggingItem.isLeftDown then
				draggingItem.isLeftDown = false;
				draggingItem.build = draggingItem.canBeBuild and not mouseOverUI and not draggingItem.clickedUI;
				draggingItem.clickedUI = false;
			end
			if mouseOverUI then return end
		end
	end
	spriteName = draggingItem:getSprite();
	-- if we have the left mouse button down, we fix the item to the square we clicked
	-- so while we have the left button down, we can drag the mouse to change the direction of the item (like in the Sims..)
	if (draggingItem.isLeftDown or draggingItem.build) and draggingItem.square then
		square = draggingItem.square;
		x = square:getX();
		y = square:getY();
	else -- else, the square is the one our mouse is on
		draggingItem.square = square;
	end
	-- There may be no square if we are at the edge of the map.
	if not square then
		draggingItem.canBeBuild = false
		return
	end
	-- render our item on the ground, if it can be placed we render it with a bit of red over it
	if isRender then
		-- we first call the isValid function of our item
		draggingItem.canBeBuild = draggingItem:isValid(square, draggingItem.north)
		-- we call the render function of our item, because for stairs (for example), we drag only 1 item : the 1st part of the stairs
		-- so in the :render function is ISWoodenStair, we gonna display the 2 other part of the stairs, depending on his direction
		draggingItem:render(x, y, z, square)
	end
	-- finally build our item !
	if draggingItem.canBeBuild and draggingItem.build then
		draggingItem:tryBuild(x, y, z)
	end
	if draggingItem.build and not draggingItem.dragNilAfterPlace then
		draggingItem:reinit();
	end
end


function DoInSayneObjectInWorldBuildingJoypad(draggingItem, isRender, x, y, z)
    if draggingItem.xJoypad == -1 then
        draggingItem.xJoypad = x;
        draggingItem.yJoypad = y;
        draggingItem.zJoypad = z;
--        local buts = getButtonPrompts(playerIndex);
--        if buts ~= nil then
--            buts:getBestLBButtonAction(nil);
--            buts:getBestRBButtonAction(nil);
--        end
    end
    local square = getCell():getGridSquare(draggingItem.xJoypad, draggingItem.yJoypad, draggingItem.zJoypad);
    DoTileBuilding(draggingItem, isRender, draggingItem.xJoypad, draggingItem.yJoypad, draggingItem.zJoypad, square);
end


Events.OnDoTileBuilding2.Add(DoTileBuilding);

Events.OnDoTileBuilding3.Add(DoInSayneObjectInWorldBuildingJoypad);
]]

--Events.OnKeyPressed.Add(rotateKey);