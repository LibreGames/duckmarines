SaveLevelState = {}
SaveLevelState.__index = SaveLevelState
setmetatable(SaveLevelState, State)

function SaveLevelState.create(parent)
	local self = setmetatable(State.create(), SaveLevelState)

	self.inputs = parent.inputs
	self.cursor = parent.cursor
	self.parent = parent

	self.list = SelectionList.create(178, 133, 200, 6, 21, self)
	self.input = TextInput.create(178, 307, 200, 24)
	self.menu = Menu.create(390, 212, 134, 32, 11, self)
	self.menu:addButton("SAVE", "save")
	self.menu:addButton("DELETE", "delete")
	self.menu:addButton("CANCEL", "cancel")

	self:addComponent(self.list)
	self:addComponent(self.input)
	self:addComponent(self.menu)

	self:updateFileList()

	return self
end

function SaveLevelState:update(dt)
	for i,v in ipairs(self.inputs) do
		if v:wasClicked() then
			for j,c in ipairs(self:getComponents()) do
				c:click(self.cursor.x, self.cursor.y)
			end
		end
		self.cursor:move(v:getMovement(dt, false))
	end
end

function SaveLevelState:draw()
	love.graphics.setColor(23, 23, 23, 255)
	love.graphics.rectangle("fill", 142, 96, 415, 271)
	love.graphics.setColor(241, 148, 0, 255)
	love.graphics.rectangle("line", 142.5, 96.5, 415, 271)

	love.graphics.setColor(255, 255, 255, 255)
	self.list:draw()
	self.input:draw()
	self.menu:draw()
	self.cursor:draw()
end

function SaveLevelState:updateFileList()
	local items = {}
	local files = love.filesystem.enumerate("usermaps")
	for i,v in ipairs(files) do
		table.insert(items, v:upper())
	end
	self.list:setItems(items)
end

function SaveLevelState:selectionChanged(text, source)
	self.input:setText(text)
end

function SaveLevelState:buttonPressed(id, source)
	if id == "save" then
		local strdata = self.parent.map:pack()
		love.filesystem.write(self:getFilename(), strdata)
		love.timer.sleep(0.25)
		popState()
	elseif id == "delete" then
		if love.filesystem.exists(self:getFilename()) then
			love.filesystem.remove(self:getFilename())
			self:updateFileList()
		end
	elseif id == "cancel" then
		love.timer.sleep(0.25)
		popState()
	end
end

function SaveLevelState:getFilename()
	return "usermaps/" .. self.input:getText():lower()
end

function SaveLevelState:isTransparent() return true end