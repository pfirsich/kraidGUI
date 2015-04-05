


function module(gui)
	local theme = {}

	theme.colors = { -- inspired by https://love2d.org/forums/viewtopic.php?f=5&t=75614 (Gray)
		background = {70, 70, 70},
		border = {45, 45, 45},
		text = {255, 255, 255},
		object = {100, 100, 100},
		objectHighlight = {140, 100, 100},
		marked = {205, 0, 0},
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
	theme.Window.titleBarBorder = 2
	theme.Window.titleBarHeight = 25

	function theme.Window.update(self, uiState)
		local lastHovered = self.hovered
		local lastClicked = self.clicked

		local localMouse = gui.internal.toLocal(uiState.mouse.position)

		self.hovered = gui.internal.inRect(localMouse, {0, 0, self.width, self.height})
		self.clicked = self.hovered and uiState.mouse.leftDown

		if self.hovered then
			if not self.lastHovered and self.onMouseEnter then
				self:onMouseEnter()
			end

			if uiState.mouse.pressed then
				self:toTop()
				if self.onClicked then self:onClicked() end

				if gui.internal.inRect(localMouse, {0, 0, self.width, theme.Window.titleBarHeight}) then
					self.dragged = true
				end
			end
		else
			if self.lastHovered and self.onMouseExit then
				self:onMouseExit()
			end
		end

		if self.lastClicked and not self.clicked and self.onMouseUp then
			self:onMouseUp()
		end

		if self.dragged then
			if uiState.mouse.leftDown then
				self.position = {self.position[1] + uiState.mouse.move[1], self.position[2] + uiState.mouse.move[2]}
			else
				self.dragged = false
			end
		end
	end

	function theme.Window.draw(self)
		gui.graphics.setColor(theme.colors.background)
		gui.graphics.drawRectangle(0, 0, self.width, self.height)

		gui.internal.foreach_array(self.children, function(child)
			child:draw()
		end)

		gui.graphics.setColor(theme.colors.border)
		gui.graphics.drawRectangle(		theme.Window.titleBarBorder, theme.Window.titleBarBorder,
										self.width - theme.Window.titleBarBorder * 2,
										theme.Window.titleBarHeight - theme.Window.titleBarBorder * 2)

		gui.graphics.drawRectangle(0, 0, self.width, self.height, 1)
	end

	return theme
end

return module
