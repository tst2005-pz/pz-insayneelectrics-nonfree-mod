-- Made by MisterInSayne

InPickUpMenu = {};

InPickUpMenu.doMenu = function(player, context, worldobjects, test)
	if test and ISWorldObjectContextMenu.Test then return true end
	
	----[[
	local squarechecked = {};
	
	for i,v in ipairs(worldobjects) do
		--[[
		if v:getContainer() then
			if v:getContainer():getType() == "fridge" then
				local addedOption = context:addOption("Pick Up Fridge", v, InPickUpMenu.onTakeObject, player);
				if getSpecificPlayer(player):getMaxWeight() < getSpecificPlayer(player):getInventoryWeight() then
					addedOption.onSelect = nil;
					addedOption.notAvailable = true;
				end
			end
			
		end
		]]
		if v:getSquare() and not squarechecked[v:getSquare()] then
			for iB=0,v:getSquare():getObjects():size()-1 do
				local checkObject = v:getSquare():getObjects():get(iB);
				local addedOption = nil;
				if checkObject:getContainer() then
					if checkObject:getContainer():getType() == "fridge" then
						addedOption = context:addOption("Pick Up Fridge", checkObject, InPickUpMenu.onTakeObject, player);
					end
					if checkObject:getContainer():getType() == "microwave" then
						addedOption = context:addOption("Pick Up Microwave", checkObject, InPickUpMenu.onTakeObject, player);
					end
					if checkObject:getContainer():getType() == "stove" then
						addedOption = context:addOption("Pick Up Stove", checkObject, InPickUpMenu.onTakeObject, player);
					end
					if checkObject:getContainer():getType() == "barbecue" then
						addedOption = context:addOption("Pick Up Grill", checkObject, InPickUpMenu.onTakeObject, player);
					end
				end
				if addedOption and getSpecificPlayer(player):getMaxWeight() < getSpecificPlayer(player):getInventoryWeight() then
					addedOption.onSelect = nil;
					addedOption.notAvailable = true;
				end
			end
			squarechecked[v:getSquare()] = true;
		end
	end
	--]]
end

InPickUpMenu.onTakeObject = function(object, player)
	local playerObj = getSpecificPlayer(player);
	if luautils.walkAdj(playerObj, object:getSquare()) then
		ISTimedActionQueue.add(InPickUpObjectAction:new(playerObj, object, 120));
	end
end

Events.OnFillWorldObjectContextMenu.Add(InPickUpMenu.doMenu);