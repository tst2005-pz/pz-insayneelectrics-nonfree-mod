-- Made by MisterInSayne
-- This coding is not to be used or adjusted without my express permission.

InPlaceObjectInWorldMenu = {};

InPlaceObjectInWorldMenu.doMenu = function(player, context, worldobjects, test)
	if test and ISWorldObjectContextMenu.Test then return true end

    --if getCore():getGameMode()=="LastStand" then
      --  return;
    --end
	
	local square = nil;
	
	for i,v in ipairs(worldobjects) do
		if v:getSquare() then
			square = v:getSquare();
			break;
		end
    end
	
	local inv = getSpecificPlayer(player):getInventory();
	if inv:FindAndReturn("InFridge") or inv:FindAndReturn("InMicrowave") or inv:FindAndReturn("InStove") or inv:FindAndReturn("InBBQ") then
		local placeOptions = context:addOption("Place", worldobjects, nil);
		local subMenu = ISContextMenu:getNew(context);
		
		local objTypes = {"InFridge", "InMicrowave", "InStove", "InBBQ"};
		for i,v in ipairs(objTypes) do
			local itemstack = inv:FindAll(v);
			if itemstack then
				for iS=0, itemstack:size()-1 do
					local item = itemstack:get(iS);
					context:addSubMenu(placeOptions, subMenu);
					subMenu:addOption(item:getName(), worldobjects, InPlaceObjectInWorldMenu.onPlaceObject, square, item, player);
				end
			end
		end
	end
	
end

InPlaceObjectInWorldMenu.onPlaceObject = function(worldobjects, square, item, player)
	
	local sprite = InPlaceObjectInWorldMenu.getObjectSprite(item);
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

InPlaceObjectInWorldMenu.getObjectSprite = function(item)
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

Events.OnFillWorldObjectContextMenu.Add(InPlaceObjectInWorldMenu.doMenu);



