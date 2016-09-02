-- Made by MisterInSayne
-- This coding is not to be used or adjusted without my express permission.

require "TimedActions/ISBaseTimedAction"

InPickUpObjectAction = ISBaseTimedAction:derive("InPickUpObjectAction");

function InPickUpObjectAction:isValid()
	--if self.object:getObjectIndex() ~= -1 then return false end
	return (self.object:getContainer():getType() == "fridge" or
		   self.object:getContainer():getType() == "microwave" or
		   self.object:getContainer():getType() == "stove" or
		   self.object:getContainer():getType() == "barbecue") and
		   (self.character:getMaxWeight() > self.character:getInventoryWeight());
end

function InPickUpObjectAction:start()
end

function InPickUpObjectAction:update()
	self.character:faceThisObject(self.object)
end

function InPickUpObjectAction:stop()
	ISBaseTimedAction.stop(self)
end

function InPickUpObjectAction:perform()
	forceDropHeavyItems(self.character)
	-- Lets do some magic <3
	local item = nil;
	if self.object:getContainer():getType() == "fridge" then
		item = self.character:getInventory():AddItem("inSayne.InFridge");
	elseif self.object:getContainer():getType() == "microwave" then
		item = self.character:getInventory():AddItem("inSayne.InMicrowave");
	elseif self.object:getContainer():getType() == "stove" then
		item = self.character:getInventory():AddItem("inSayne.InStove");
	elseif self.object:getContainer():getType() == "barbecue" then
		item = self.character:getInventory():AddItem("inSayne.InBBQ");
	end
    self.character:setPrimaryHandItem(item);
    self.character:setSecondaryHandItem(item);
	
	
	-- Transfer the items
	--item:getInventory():setItems(self.object:getContainer():getItems());
	local itemstacksize = self.object:getContainer():getItems():size();
	for i=0,itemstacksize-1 do
		item:getInventory():DoAddItem(self.object:getContainer():getItems():get(0));
	end
	
	
	-- Save the type and the sprite it uses
	item:getModData()["objType"] = self.object:getContainer():getType();
	local spritename = self.object:getSprite():getName();
	local spritenumber = string.sub(spritename, -2);
	if string.sub(string.reverse(spritenumber), -1) == "_" then
		spritenumber = string.sub(spritenumber, -1);
	end
	local realspritenumber = tonumber(spritenumber);
	
	realspritenumber = math.floor(realspritenumber/4)*4;
	
	item:getModData()["SpriteBase"] = string.sub(spritename, 1, 0-(string.len(spritenumber)+1));
	item:getModData()["SpriteNumber"] = tostring(realspritenumber); -- sprite name 0-3, 4-7, etc
	--item:setTexture(self.object:getSprite():LoadFrameExplicit(string.sub(spritename, 1, 0-string.len(spritenumber)) .. tostring(realspritenumber)));
	item:setTexture(getTexture(string.sub(spritename, 1, 0-(string.len(spritenumber)+1)) .. tostring(realspritenumber)));
	
	-- BBQ stuff~
	if self.object:getContainer():getType() == "barbecue" then
		if self.object:isPropaneBBQ() then
			item:getModData()["usesTank"] = true;
			if self.object:hasPropaneTank() then
				item:getModData()["hasTank"] = true;
				item:getModData()["fuelAmmount"] = self.object:getFuelAmount();
			end
			item:getModData()["SpriteNumber"] = 36;
		else
			item:getModData()["usesTank"] = false;
			item:getModData()["singleSprite"] = self.object:getSprite():getName();
		end
	end
	
	if item:getModData()["singleSprite"] then
		item:setTexture(getTexture(item:getModData()["singleSprite"]));
	else
		item:setTexture(getTexture(string.sub(spritename, 1, 0-(string.len(spritenumber)+1)) .. tostring(realspritenumber)));
	end
	
	-- Refresh the backpacks
	self.character:getInventory():setDrawDirty(true);
	getPlayerData(self.character:getPlayerNum()).playerInventory:refreshBackpacks();
	
	
	-- And finally destroy the object
	if isClient() then
		sledgeDestroy(self.object);
	else
		self.object:getSquare():transmitRemoveItemFromSquare(self.object)
		self.object:getSquare():RemoveTileObject(self.object)
	end
	
	
	ISBaseTimedAction.perform(self)
end

function InPickUpObjectAction:new(character, object, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.stopOnWalk = true
	o.stopOnRun = true
	o.maxTime = time
	o.character = character;
	o.object = object
	return o
end