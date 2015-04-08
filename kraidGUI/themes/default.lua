
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

	local hovered = function(self) return self.hovered == self end

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
	theme.Window.resizeHandleSize = 15

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
			if self.onMove then self:onMove() end
		end

		if self.resized then
			self.width = self.width + dx
			self.height = self.height + dy
			if self.onResize then self:onResize() end
			self.closeButton:setParam("position", {self.width - self.theme.Window.closeButtonMargin, self.theme.Window.closeButtonPosY})
		end
	end

	function theme.Window.mouseReleased(self, x, y, button)
		if button == "l" then
			self.resized = false
			self.dragged = false
		end
	end

	function theme.Window.onMouseDown(self, x, y, button)
		if button == "l" then
			if y < self.theme.Window.titleBarHeight then
				self.dragged = true
			end

			local fromCorner = {self.width - x, self.height - y}
			if fromCorner[1] > 0 and fromCorner[2] > 0 and fromCorner[1] + fromCorner[2] < self.theme.Window.resizeHandleSize then
				self.resized = true
			end
		end
	end

	function theme.Window.draw(self)
		gui.graphics.setColor(self.theme.colors.background)
		gui.graphics.drawRectangle(0, 0, self.width, self.height)

		gui.internal.foreach_array(self.children, function(child)
			if not child.breakout then child:draw() end
		end)

		gui.graphics.setColor(self.theme.colors.border)
		gui.graphics.drawRectangle(	self.theme.Window.titleBarBorder, self.theme.Window.titleBarBorder,
									self.width - self.theme.Window.titleBarBorder * 2,
									self.theme.Window.titleBarHeight - self.theme.Window.titleBarBorder * 2)

		gui.graphics.setColor(self.theme.colors.text)
		gui.graphics.text.draw(self.text, self.theme.Window.titleOffsetX, self.theme.Window.titleBarHeight/2 - gui.graphics.text.getHeight()/2)

		gui.graphics.setColor(self.theme.colors.border)
		gui.graphics.drawRectangle(0, 0, self.width, self.height, self.theme.Window.borderWidth)
		gui.graphics.drawPolygon({	self.width - self.theme.Window.resizeHandleSize, self.height,
									self.width, self.height,
									self.width, self.height - theme.Window.resizeHandleSize})

		if self.closeButton.visible then
			gui.widgets.helpers.withCanvas(self.closeButton, function()
				gui.widgets.helpers.callThemeFunction(self.closeButton, "draw")
			end)
		end

		gui.internal.foreach_array(self.children, function(child)
			if child.breakout then child:draw() end
		end)
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
		local bg = self.clicked and self.theme.colors.objectHighlight or (hovered(self) and self.theme.colors.object or self.theme.colors.border)
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

		gui.graphics.setColor(self.theme.colors.marked)
		if self.checked then gui.graphics.drawRectangle(x, y, w, h) end

		gui.graphics.setColor(self.theme.colors.border)
		if hovered(self) then gui.graphics.drawRectangle(x, y, w, h, self.theme.Checkbox.hoverLineWidth) end
	end

	--------------------------------------------------------------------
	--------------------------------------------------------------------

	theme.Radiobutton = {}

	theme.Radiobutton.checkSizeFactor = 0.6
	theme.Radiobutton.borderWidth = 2
	theme.Radiobutton.hoverLineWidth = 2

    function theme.Radiobutton.contains(self, x, y)
        local center = {self.width/2, self.height/2}
        local radius = math.min(self.width, self.height)/2

        local rel = {center[1] - x, center[2] - y}
        return rel[1]*rel[1] + rel[2]*rel[2] < radius*radius
    end

	function theme.Radiobutton.draw(self)
		local centerX, centerY = self.width/2, self.height/2
		local radius = math.min(self.width, self.height)/2 - 1

		gui.graphics.setColor(self.theme.colors.object)
		gui.graphics.drawCircle(centerX, centerY, radius, 16)
		gui.graphics.setColor(self.theme.colors.border)
		gui.graphics.drawCircle(centerX, centerY, radius, 16, self.theme.Radiobutton.borderWidth)

		gui.graphics.setColor(self.theme.colors.marked)
		if self.checked then gui.graphics.drawCircle(centerX, centerY, radius * self.theme.Radiobutton.checkSizeFactor, 16) end

		gui.graphics.setColor(self.theme.colors.border)
		if hovered(self) then gui.graphics.drawCircle(centerX, centerY, radius * self.theme.Radiobutton.checkSizeFactor, 16, self.theme.Radiobutton.hoverLineWidth) end
	end

	--------------------------------------------------------------------
	--------------------------------------------------------------------

	theme.Category = {}

	theme.Category.borderThickness = 5
	theme.Category.textMarginLeft = 5

	function theme.Category.onMouseDown(self, x, y, button)
		if button == "l" then
			if y < self.collapsedHeight then
				self:setCollapsed(not self.collapsed)
			end
		end
	end

	function theme.Category.draw(self)
		gui.graphics.setColor(self.collapsed and self.theme.colors.object or self.theme.colors.objectHighlight)
		gui.graphics.drawRectangle(0, 0, self.width, self.height)
		gui.graphics.setColor(self.theme.colors.text)
		gui.graphics.text.draw(self.text, theme.Category.textMarginLeft, self.collapsedHeight/2 - gui.graphics.text.getHeight()/2)

		if not self.collapsed then
			gui.graphics.setColor(self.theme.colors.background)
			gui.graphics.drawRectangle(	self.theme.Category.borderThickness, self.collapsedHeight + self.theme.Category.borderThickness,
										self.width - self.theme.Category.borderThickness*2, self.height - self.collapsedHeight - self.theme.Category.borderThickness*2)

			gui.internal.foreach_array(self.children, function(child)
				child:draw()
			end)
		end
	end

	--------------------------------------------------------------------
	--------------------------------------------------------------------

	theme.Numberwheel = {}

	theme.Numberwheel.borderThickness = 2
	theme.Numberwheel.wheelBorderThickness = 2
	theme.Numberwheel.smallRadius = 5
	theme.Numberwheel.blownUpRadius = 100
	theme.Numberwheel.wheelMarginLeft = theme.Numberwheel.smallRadius + 5
	theme.Numberwheel.textMarginLeft = theme.Numberwheel.smallRadius * 2 + theme.Numberwheel.wheelMarginLeft + 5
	theme.Numberwheel.guidelineCount = 6
	theme.Numberwheel.guidelineThickness = 1
	theme.Numberwheel.wheelAlpha = 150

	function theme.Numberwheel.init(self)
		self.breakout = true
	end

	function theme.Numberwheel.contains(self, x, y)
		local rel = {theme.Numberwheel.wheelMarginLeft - x, self.height/2 - y}
		local radius = self.blownUp and theme.Numberwheel.blownUpRadius or theme.Numberwheel.smallRadius
		return rel[1]*rel[1] + rel[2]*rel[2] < radius*radius
	end

	function theme.Numberwheel.mouseMove(self, x, y, dx, dy)
		local function angleDiff(a, b)
			local diff = a - b
			while diff >  180.0 do diff = 360 - diff end
			while diff < -180.0 do diff = 350 + diff end
			return diff
		end

		if self.blownUp then
			local rel = {theme.Numberwheel.wheelMarginLeft - x, self.height/2 - y}
			print(rel[1], rel[2])
			local angle = math.atan2(rel[2], rel[1])
			-- finite difference approximation and linearization (only lowest order)
			local dphi = 0
			local epsilon = 1e-10
			dphi = dphi + (math.atan2(rel[2] + epsilon, rel[1]) - angle)/epsilon * dy
			dphi = dphi + (math.atan2(rel[2], rel[1] + epsilon) - angle)/epsilon * dx

			-- NOTE: Check here if radius < 1.0 so outside the wheel nothing happens? It's actually quite useful, albeit unintuitive.
			local radius = math.sqrt(rel[1]*rel[1] + rel[2]*rel[2]) / theme.Numberwheel.blownUpRadius
			-- negative sign because I think clockwise increase seems more intuitive
			self:setParam("value", self.value - dphi * (type(self.speed) == "function" and self.speed(radius) or self.speed) * radius)
		end
	end

	function theme.Numberwheel.onMouseDown(self, x, y, button)
		if button == "l" then self.blownUp = true end
	end

	function theme.Numberwheel.mouseReleased(self, x, y, button)
		if button == "l" then self.blownUp = false end
	end

	function theme.Numberwheel.draw(self)
		gui.graphics.setColor(self.theme.colors.border)
		gui.graphics.drawRectangle(0, 0, self.width, self.height, self.theme.Numberwheel.borderThickness)

		local radius = self.blownUp and theme.Numberwheel.blownUpRadius or theme.Numberwheel.smallRadius
		local color = {unpack(hovered(self) and self.theme.colors.objectHighlight or self.theme.colors.object)} -- copy
		color[4] = self.blownUp and theme.Numberwheel.wheelAlpha or 255
		gui.graphics.setColor(color)
		gui.graphics.drawCircle(theme.Numberwheel.wheelMarginLeft, self.height/2, radius, 32)

		gui.graphics.setColor(self.theme.colors.border)
		gui.graphics.drawCircle(theme.Numberwheel.wheelMarginLeft, self.height/2, radius, 32, theme.Numberwheel.wheelBorderThickness)

		if self.blownUp then
			for i = 1, self.theme.Numberwheel.guidelineCount do
				local speed = function(x) return type(self.speed) == "function" and self.speed(x) or self.speed * x end
				local radius = speed(1.0 / self.theme.Numberwheel.guidelineCount * (i - 1)) / speed(1.0)
				gui.graphics.drawCircle(theme.Numberwheel.wheelMarginLeft, self.height/2, radius * theme.Numberwheel.blownUpRadius, 32, theme.Numberwheel.guidelineThickness)
			end
		end

		gui.graphics.setColor(self.blownUp and self.theme.colors.marked or self.theme.colors.text)
		gui.graphics.text.draw(string.format(self.format, self.value), theme.Numberwheel.textMarginLeft, self.height/2 - gui.graphics.text.getHeight()/2)
	end

	--------------------------------------------------------------------
	--------------------------------------------------------------------

	theme.Line = {}

	function theme.Line.draw(self)
		gui.graphics.setColor(self.theme.colors.border)
		gui.graphics.drawRectangle(0, 0, self.width, self.height)
	end

	return theme
end

return module
