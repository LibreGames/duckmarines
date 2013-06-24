Entity = { MOVE_SPEED = 100 }
Entity.__index = Entity

function Entity.create(x, y, dir)
	local self = setmetatable({}, Entity)

	self.x, self.y = x, y
	self.dir = dir
	self.moved = 0

	return self
end

function Entity:update(dt, map)
	-- Update animation
	self:getAnim():update(dt)

	-- Move
	local toMove = self.MOVE_SPEED*dt
	if self.dir == 0 then -- up
		self.y = self.y - toMove
	elseif self.dir == 1 then -- right
		self.x = self.x + toMove
	elseif self.dir == 2 then -- down
		self.y = self.y + toMove
	elseif self.dir == 3 then -- left
		self.x = self.x - toMove
	end

	-- Check if whole step has been moved
	self.moved = self.moved + toMove
	if self.moved > 48 then
		-- Collide with walls
		local cx = math.floor(self.x / 48)
		local cy = math.floor(self.y / 48)
		self.x = cx*48 + 24
		self.y = cy*48 + 24

		-- Check collision with walls
		self:collideWalls(map)

		-- Check current tile
		self:onCell(map:getTile(cx, cy))
	end
end

function Entity:collideWalls(map)
	local cx = math.floor(self.x / 48)
	local cy = math.floor(self.y / 48)
	if self.dir == 0 and map:northWall(cx, cy) then
		if not map:eastWall(cx, cy) then
			self.dir = 1
			self.moved = 0
		else
			self.dir = 3
		end
	elseif self.dir == 1 and map:eastWall(cx, cy) then
		if not map:southWall(cx, cy) then
			self.dir = 2
			self.moved = 0
		else
			self.dir = 0
		end
	elseif self.dir == 2 and map:southWall(cx, cy) then
		if not map:westWall(cx, cy) then
			self.dir = 3
			self.moved = 0
		else
			self.dir = 1
		end
	elseif self.dir == 3 and map:westWall(cx, cy) then
		if not map:northWall(cx, cy) then
			self.dir = 0
			self.moved = 0
		else
			self.dir = 2
		end
	else
		self.moved = 0
	end
end

function Entity:draw()
	love.graphics.draw(ResMgr.getImage("entity_shadow.png"), self.x, self.y, 0, 1, 1, 15, -5)
	self:getAnim():draw(self.x, self.y)
end