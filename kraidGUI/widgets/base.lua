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

    function Base:setTheme(theme)
        self.theme = theme
        if theme[self.type] == nil then error("Widget '" .. self.type .. "' is not implemented in theme '" .. theme.name .. "'.") end
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

    function Base:onMouseDown(x, y, button)
        self:toTop()
        self.clicked = true
        gui.widgets.helpers.callThemeFunction(self, "onMouseDown", x, y, button)
    end

    function Base:onMouseUp(x, y, button)
        self.clicked = false
        gui.widgets.helpers.callThemeFunction(self, "onMouseUp", x, y, button)
    end

    local function passMouseEvent(self, name, x, y, hoveredFunc, ...)
        if self.visible and self.enabled then
            local args = {...}
            return gui.widgets.helpers.withCanvas(self, function()
                local localMouse = gui.internal.toLocal(x, y)
                gui.widgets.helpers.callThemeFunction(self, name, localMouse[1], localMouse[2], unpack(args))

                if self.visible and self.enabled and self.hovered == self then
                    hoveredFunc(self, localMouse[1], localMouse[2], unpack(args))
                end

                gui.internal.foreach_array(self.children, function(child)
                    child[name](child, x, y, unpack(args))
                end, true)
            end)
        end
        return false
    end

    function Base:mousePressed(x, y, button)
        passMouseEvent(self, "mousePressed", x, y, function(self, x, y, button) self:onMouseDown(x, y, button) end, button)
    end

    function Base:mouseReleased(x, y, button)
        passMouseEvent(self, "mouseReleased", x, y, function(self, x, y, button) self:onMouseUp(x, y, button) end, button)
    end

    function Base:mouseMove(x, y, dx, dy)
        passMouseEvent(self, "mouseMove", x, y, function(self, x, y, dx, dy) end, dx, dy)
    end

    function Base:pickHovered(x, y)
        self.hovered = nil

        if self.visible and self.enabled then
            gui.widgets.helpers.withCanvas(self, function(child)
                self.hovered = gui.internal.foreach_array(self.children, function(child)
                    local hovered = child:pickHovered(x, y)
                    if hovered ~= nil then
                        return child -- will break if ~= nil
                    end
                end, true)

                if self.hovered == nil then
                    local localMouse = gui.internal.toLocal(x, y)
                    local hovered = gui.widgets.helpers.callThemeFunction(self, "contains", unpack(localMouse))
                    if hovered == nil then
                        hovered = self.position and self.width and self.height and gui.internal.inRect(localMouse, {0, 0, self.width, self.height})
                    end

                    if hovered then self.hovered = self end
                end
            end)
        end

        return self.hovered
    end

    Base.static.setters = { -- static
        ["parent"] = Base.setParent,
        ["theme"] = Base.setTheme,
    }

    return Base
end

return module
