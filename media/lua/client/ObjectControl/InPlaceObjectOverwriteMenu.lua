-- Made by MisterInSayne
-- This coding is not to be used or adjusted without my express permission.

InPlaceObjectOverwrite = {};

InPlaceObjectOverwrite.doMenu = function(player, context, items)
	
	local itemstack = {};
	
	for i,v in ipairs(items) do
		local tempitem = v;
        if not instanceof(v, "InventoryItem") then
            tempitem = v.items[1];
        end
		itemstack[i] = tempitem;
		
		if tempitem:getType() == "InFridge" or tempitem:getType() == "InMicrowave" or tempitem:getType() == "InStove" or tempitem:getType() == "InBBQ" then
			local optioncount = context.numOptions;
			for i=0,optioncount-2 do
				context:removeLastOption();
			end
			
			context:addOption("Place "..tempitem:getName(), tempitem, InPlaceObjectOverwrite.onPlaceObject, player);
			if getDebug() then
				context:addOption("Delete "..tempitem:getName(), tempitem, InPlaceObjectOverwrite.onDeleteObject, player);
			end
		end
	end
	
end

InPlaceObjectOverwrite.onPlaceObject = function(item, player)
	local square = getSpecificPlayer(player):getSquare();
	local sprite = InPlaceObjectOverwrite.getObjectSprite(item);
	local placeObject = InFridgeObject:new(sprite.sprite, sprite.northSprite, getSpecificPlayer(player), item);
	
    placeObject:setEastSprite(sprite.eastSprite);
    placeObject:setSouthSprite(sprite.southSprite);
    placeObject.player = player
	if item:getModData()["objType"] then
		if item:getModData()["objType"] == "microwave" then
			placeObject.needsCounter = true;
			placeObject.canBeAlwaysPlaced = true;
		end
	end
	
    getCell():setDrag(placeObject, player);
end

InPlaceObjectOverwrite.onDeleteObject = function(item, player)
	local playerObj = getSpecificPlayer(player);
	playerObj:getInventory():Remove(item);
	playerObj:getInventory():setDrawDirty(true);
	getPlayerData(player).playerInventory:refreshBackpacks();
end

InPlaceObjectOverwrite.getObjectSprite = function(item)
	local sprite = {};
	
	if item:getModData()["singleSprite"] then
		sprite.sprite = item:getModData()["singleSprite"];
		sprite.northSprite = item:getModData()["singleSprite"];
		sprite.southSprite = item:getModData()["singleSprite"];
		sprite.eastSprite = item:getModData()["singleSprite"];
	else
		local spriteBase = "";
		local spriteNumber = "0";
		if item:getModData()["SpriteBase"] then
			spriteBase = item:getModData()["SpriteBase"];
			spriteNumber = item:getModData()["SpriteNumber"];
		else
			if item:getType() == "InFridge" then
				spriteBase = "appliances_refrigeration_01_";
			elseif item:getType() == "InMicrowave" or item:getType() == "InStove" or item:getType() == "InBBQ" then
				spriteBase = "appliances_cooking_01_";
			end
		end
		
		sprite.sprite = spriteBase .. tostring(tonumber(spriteNumber)+3); -- 3
		sprite.northSprite = spriteBase .. tostring(tonumber(spriteNumber)+2); -- 2
		sprite.southSprite = spriteBase .. spriteNumber; -- 0
		sprite.eastSprite = spriteBase .. tostring(tonumber(spriteNumber)+1); -- 1
	end
	return sprite;
end

Events.OnFillInventoryObjectContextMenu.Add(InPlaceObjectOverwrite.doMenu);



