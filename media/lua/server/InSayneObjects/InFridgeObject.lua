-- Made by MisterInSayne
-- This coding is not to be used or adjusted without my express permission.

InFridgeObject = InSayneObject:derive("InFridgeObject");

function InFridgeObject:create(x, y, z, north, sprite)
	local cell = getWorld():getCell();
	self.sq = cell:getGridSquare(x, y, z);
	
	local objectType = "crate";
	if self.sourceItem:getModData()["objType"] then
		objectType = self.sourceItem:getModData()["objType"];
	end
	if objectType == "microwave" or objectType == "stove" then
		self.inObject = IsoStove.new(cell, self.sq, getSprite(sprite));
		--self.inObject:setSprite
	elseif objectType == "barbecue" then
		self.inObject = IsoBarbecue.new(cell, self.sq, getSprite(sprite));
		if self.sourceItem:getModData()["usesTank"] then
			if self.sourceItem:getModData()["hasTank"] then
				self.inObject:setFuelAmount(self.sourceItem:getModData()["fuelAmmount"]);
			else
				self.inObject:removePropaneTank();
			end
		else
			--self.inObject.noTankSprite = nil;
		end
	else
		self.inObject = IsoObject.new(cell, self.sq, sprite);
	end
	--buildUtil.setInfo(self.inObject, self);
	
	if self.sourceItem and self.sourceItem:getInventory() then
		
		local linkContainer = ItemContainer.new(objectType, self.sq, self.inObject, 0, 0);
		
		linkContainer:setHasBeenLooted(true);
		linkContainer:setExplored(true);
		
		local itemstacksize = self.sourceItem:getInventory():getItems():size();
		for i=0,itemstacksize-1 do
			linkContainer:DoAddItem(self.sourceItem:getInventory():getItems():get(0));
		end
		self.inObject:setContainer(linkContainer);
	end
	
	if self.character:getPrimaryHandItem() == self.sourceItem then
		if (self.sourceItem:isTwoHandWeapon() or self.sourceItem:isRequiresEquippedBothHands()) and self.sourceItem == self.character:getSecondaryHandItem() then
            self.character:setSecondaryHandItem(nil);
        end
		self.character:setPrimaryHandItem(nil);
	end
	if self.character:getSecondaryHandItem() == self.sourceItem then
		if (self.sourceItem:isTwoHandWeapon() or self.sourceItem:isRequiresEquippedBothHands()) and self.sourceItem == self.character:getPrimaryHandItem() then
            self.character:setPrimaryHandItem(nil);
        end
		self.character:setSecondaryHandItem(nil);
	end
	
	self.character:getInventory():Remove(self.sourceItem);
	
	self.character:getInventory():setDrawDirty(true);
	getPlayerData(self.character:getPlayerNum()).playerInventory:refreshBackpacks();
	
    self.sq:AddTileObject(self.inObject);
	--self.inObject:addToWorld();
	--self.sq:getProperties():Set("container",objectType);
	--self.sq:setCollisionMode();
	self.sq:RecalcAllWithNeighbours(true);
	
	self.inObject:transmitCompleteItemToServer()
	--self:reinit();
end

function InFridgeObject:new(sprite, northSprite, player, item)
	local o = {};
	setmetatable(o, self);
	self.__index = self;
	o:init();
	o:setSprite(sprite);
	o:setNorthSprite(northSprite);
	o.sourceItem = item;
	o.isContainer = true;
	o.blockAllTheSquare = true;
	--o.canBarricade = false;
	--o.dismantable = true;
    o.character = player;
    o.name = "InSayne Object";
	return o;
end

function InFridgeObject:isValid(square)
	--return square:isFree(true);
	return InSayneObject.isValid(self, square);
	--return true;
end

function InFridgeObject:render(x, y, z, square)
	InSayneObject.render(self, x, y, z, square)
end