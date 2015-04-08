function module(gui)
    local Base = gui.internal.class()

    function Base:init(params)
        self.type = self.type or "Base"
        self.children = {}

        local set = {}
        gui.internal.addTableKeys(set, gui.widgets._defaultParameters)
        if params then gui.internal.addTableKeys(set, params) end

        gui.internal.foreach(set, function(param, value)
            self:setParam(param, value)
        end)
    end

    function Base:update()
        if self.visible and self.enabled then
            gui.widgets.helpers.withCanvas(self, function()
                gui.widgets.helpers.callThemeFunction(self, "update")

                if not self.hovered and gui.widgets.hovered == self then
                    if self.onMouseEnter then self:onMouseEnter() end
                end

                if self.hovered and not gui.widgets.hovered == self then
                    if self.onMouseExit then self:onMouseExit() end
                    self.clicked = false
                end

                self.hovered = gui.widgets.hovered == self

                gui.internal.foreach_array(self.children, function(child)
                    child:update()
                end, true)
            end)
        end
    end

    function Base:draw()
        if self.visible and not self.virtual then
            gui.widgets.helpers.withCanvas(self, function()
                gui.widgets.helpers.callThemeFunction(self, "draw")
            end)
        end
    end

    function Base:setParam(name, value)
        if self.static.setters[name] then
            self.static.setters[name](self, value)
        else
            self[name] = value
        end
    end

    function Base:setParent(parent)
        if self.parent then
            for i = #self.parent.children, 1, -1 do
                if self.parent.children[i] == self then
                    table.remove(self.parent.children, i)
                end
            end
        end

        self.parent = parent
        self.parent.children[#self.parent.children+1] = self
    end

    function Base:toTop() -- make last in list (rendered last)
        if self.parent then
            self.parent:toTop()

            local index = nil
            for i = 1, #self.parent.children do
                if self.parent.children[i] == self then
                    index = i
                    break
                end
            end

            table.remove(self.parent.children, index)
            self.parent.children[#self.parent.children+1] = self
        end
    end

    function Base:keyPressed(self, key) end -- stub
    function Base:textInput(self, text) end -- stub

    local function mouseEvent(self, name, checkEvent, ...)
        if self.visible and self.enabled then
            local args = {...}
            return gui.widgets.helpers.withCanvas(self, function()
                local claimed = gui.internal.foreach_array(self.children, function(child)
                    return child[name](child, unpack(args)) -- will break if true
                end, true)

                if claimed then
                    return true
                else
                    return checkEvent(self, name)
                end
            end)
        end
        return false
    end

    function Base:mousePressed(x, y, button)
        return mouseEvent(self, "mousePressed", function(self, name)
            if self.hovered then
                self:toTop()
                gui.widgets.focused = self
                self.clicked = true
                if self.onClicked then self:onClicked() end
                gui.widgets.helpers.callThemeFunction(self, "mousePressed", x, y, button)
                return true
            end
            return false
        end, x, y, button)
    end

    function Base:mouseReleased(x, y, button)
        return mouseEvent(self, "mouseReleased", function(self, name)
            if self.hovered then
                self.clicked = false
                if self.onMouseUp then self:onMouseUp() end
                gui.widgets.helpers.callThemeFunction(self, "mouseReleased", x, y, button)
                return true
            end
            return false
        end, x, y, button)
    end

    function Base:mouseMove(x, y, dx, dy)
        return mouseEvent(self, "mouseMove", function(self, name)
            local localMouse = gui.internal.toLocal(x, y)
            local hovered = gui.widgets.helpers.callThemeFunction(self, "contains", unpack(localMouse))
            if hovered == nil then
                hovered = self.position and self.width and self.height and gui.internal.inRect(localMouse, {0, 0, self.width, self.height})
            end

            if hovered then
                gui.widgets.hovered = self
                gui.widgets.helpers.callThemeFunction(self, "mouseMove", x, y, dx, dy)
                return true -- so the first object that's hovered will claim the mouseMove event
            else
                return false
            end
        end, x, y, dx, dy)
    end

    Base.static.setters = { -- static
        ["parent"] = Base.setParent
    }

    return Base
end

return module
