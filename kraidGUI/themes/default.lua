function module(gui)
	local theme = {name = "default", author = "Joel Schumacher"}

	theme.colors = { -- inspired by https://love2d.org/forums/viewtopic.php?f=5&t=75614 (Gray)
		background = {70, 70, 70},
		border = {45, 45, 45},
		text = {255, 255, 255},
		object = {100, 100, 100},
		objectHighlight = {180, 180, 180},
		marked = {205, 0, 0},
		markedHighlight = {205, 120, 120}
	}

	--------------------------------------------------------------------
	--------------------------------------------------------------------
	theme.Base = {}

	function theme.Base.draw(self)
		gui.internal.foreach_array(self.children, function(child)
			child:draw()
		end)
	end

	--------------------------------------------------------------------
	--------------------------------------------------------------------
	theme.Window = {}
	theme.Window.titleBarBorder = 0
	theme.Window.titleOffsetX = 5
	theme.Window.titleBarHeight = 25
	theme.Window.borderWidth = 2

	theme.Window.closeButtonWidth = 20
	theme.Window.closeButtonHeight = 8
	theme.Window.closeButtonMargin = theme.Window.closeButtonWidth + 5
	theme.Window.closeButtonPosY = -1

	-- relative
	theme.Window.childCanvas = {0, theme.Window.titleBarHeight, 0, -theme.Window.titleBarHeight}

	function theme.Window.init(self)
		self.closeButton:setParam("position", {self.width - self.theme.Window.closeButtonMargin, self.theme.Window.closeButtonPosY})
		self.closeButton:setParam("width", self.theme.Window.closeButtonWidth)
		self.closeButton:setParam("height", self.theme.Window.closeButtonHeight)

		local buttonTheme = {Button = {}}
		buttonTheme.Button.borderWidth = 0
		buttonTheme.colors = {
			objectHighlight = self.theme.colors.objectHighlight,
			object = self.theme.colors.markedHighlight,
			border = self.theme.colors.marked,
			text = self.theme.colors.text
		}
		buttonTheme.Button.draw = self.theme.Button.draw
		self.closeButton:setParam("theme", buttonTheme)
	end

	function theme.Window.mouseMove(self, x, y, dx, dy)
		if self.dragged then
			self.position = {self.position[1] + dx, self.position[2] + dy}
			if self.onMove then self:onMove(unpack(self.position)) end
			return true
		end
	end

	function theme.Window.mouseReleased(self, x, y, button)
		if button == "l" then self.dragged = false end
	end

	function theme.Window.mousePressed(self, x, y, button)
		if button == "l" then
			local localMouse = gui.internal.toLocal(x, y)

			if gui.internal.inRect(localMouse, {0, 0, self.width, self.theme.Window.titleBarHeight}) then
				self.dragged = true
				return true
			end
		end
	end

	function theme.Window.draw(self)
		gui.graphics.setColor(self.theme.colors.background)
		gui.graphics.drawRectangle(0, 0, self.width, self.height)

		gui.internal.foreach_array(self.children, function(child)
			child:draw()
		end)

		gui.graphics.setColor(self.theme.colors.border)
		gui.graphics.drawRectangle(	self.theme.Window.titleBarBorder, self.theme.Window.titleBarBorder,
									self.width - self.theme.Window.titleBarBorder * 2,
									self.theme.Window.titleBarHeight - self.theme.Window.titleBarBorder * 2)

		gui.graphics.setColor(self.theme.colors.text)
		gui.graphics.text.draw(self.text, self.theme.Window.titleOffsetX, self.theme.Window.titleBarHeight/2 - gui.graphics.text.getHeight()/2)

		gui.graphics.setColor(self.theme.colors.border)
		gui.graphics.drawRectangle(0, 0, self.width, self.height, self.theme.Window.borderWidth)

		if self.closeButton.visible then
			gui.widgets.helpers.withCanvas(self.closeButton, function()
				gui.widgets.helpers.callThemeFunction(self.closeButton, "draw")
			end)
		end
	end


	--------------------------------------------------------------------
	--------------------------------------------------------------------
	theme.Label = {}
	function theme.Label.draw(self)
		gui.graphics.setColor(self.theme.colors.text)
		gui.graphics.text.draw(self.text, 0, 0)
	end

	--------------------------------------------------------------------
	--------------------------------------------------------------------
	theme.Button = {}

	theme.Button.borderWidth = 2

	function theme.Button.draw(self)
		local bg = self.clicked and self.theme.colors.objectHighlight or (self.hovered and self.theme.colors.object or self.theme.colors.border)
		local border = self.clicked and self.theme.colors.border or self.theme.colors.objectHighlight

		gui.graphics.setColor(bg)
		gui.graphics.drawRectangle(0, 0, self.width, self.height)
		gui.graphics.setColor(border)
		gui.graphics.drawRectangle(0, 0, self.width, self.height, self.theme.Button.borderWidth)

		gui.graphics.setColor(self.theme.colors.text)
		gui.graphics.text.draw(self.text, self.width/2 - gui.graphics.text.getWidth(self.text)/2, self.height/2 - gui.graphics.text.getHeight()/2)
	end

	--------------------------------------------------------------------
	--------------------------------------------------------------------

	theme.Checkbox = {}

	theme.Checkbox.checkSizeFactor = 0.6
	theme.Checkbox.borderWidth = 2
	theme.Checkbox.hoverLineWidth = 2

	function theme.Checkbox.draw(self)
		gui.graphics.setColor(self.theme.colors.object)
		gui.graphics.drawRectangle(0, 0, self.width, self.height)
		gui.graphics.setColor(self.theme.colors.border)
		gui.graphics.drawRectangle(0, 0, self.width, self.height, self.theme.Checkbox.borderWidth)

		local w, h = self.width * self.theme.Checkbox.checkSizeFactor, self.height * self.theme.Checkbox.checkSizeFactor
		local x, y = self.width/2 - w/2, self.height/2 - h/2

		if self.hovered then gui.graphics.drawRectangle(x, y, w, h, self.theme.Checkbox.hoverLineWidth) end

		gui.graphics.setColor(self.theme.colors.marked)
		if self.checked then gui.graphics.drawRectangle(x, y, w, h) end
	end

	return theme
end

return module
