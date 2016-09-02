-- Made by MisterInSayne
-- This coding is not to be used or adjusted without my express permission.

require "TimedActions/ISBaseTimedAction"

InPlaceObjectAction = ISBaseTimedAction:derive("InPlaceObjectAction");

function InPlaceObjectAction:isValid()
	return true;
end

function InPlaceObjectAction:start()
	-- sound stuff
end

function InPlaceObjectAction:update()
	-- sound stuff
end

function InPlaceObjectAction:stop()
	-- sound stuff
	ISBaseTimedAction.stop(self)
end

function InPlaceObjectAction:perform()
	-- sound stuff
	
	self.item.character = self.character;
	self.item:create(self.x, self.y, self.z, self.north, self.spriteName);
	
    self.square:RecalcAllWithNeighbours(true);
	
	ISBaseTimedAction.perform(self)
end

function InPlaceObjectAction:new(character, item, x, y, z, north, spriteName, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character;
	o.item = item;
	o.x = x;
	o.y = y;
	o.z = z;
	o.north = north;
	o.spriteName = spriteName;
	o.stopOnWalk = true;
	o.stopOnRun = true;
	o.maxTime = time;
	if character:HasTrait("Handy") then
		o.maxTime = time - 50;
	end
    o.square = getCell():getGridSquare(x,y,z);
    o.doSaw = true;
	return o
end