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

    function Base:setVisible(visible)
        self.visible = visible

        if self.visible == true and self.parent then
            self.hovered = self.parent.hovered
            self.focused = self.parent.focused

            for _, child in ipairs(self.children) do
                child:setVisible(self.visible)
            end
        end
    end

    function Base:setWidth(width)
        self.width = width
        if self.onResize then self:onResize() end
    end

    function Base:setHeight(height)
        self.height = height
        if self.onResize then self:onResize() end
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

    function Base:getGrandParent() -- returns the parent of the parent of the parent of the...
        if self.parent then
            return self.parent:getGrandParent()
        else
            return self
        end
    end

    function Base:setSubTree(key, value)
        self[key] = value
        for _, child in ipairs(self.children) do
            child:setSubTree(key, value)
        end
    end

    function Base:keyPressed(self, key, isrepeat) end -- stub
    function Base:textInput(self, text) end -- stub

    function Base:onMouseDown(x, y, button)
        self:toTop()
        self.clicked = true
        self:getGrandParent():setSubTree("focused", self)
        gui.widgets.helpers.callThemeFunction(self, "onMouseDown", x, y, button)
    end

    function Base:onMouseUp(x, y, button)
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
        self:setSubTree("clicked", false) -- not very efficient
        passMouseEvent(self, "mouseReleased", x, y, function(self, x, y, button) self:onMouseUp(x, y, button) end, button)
    end

    function Base:mouseMove(x, y, dx, dy)
        passMouseEvent(self, "mouseMove", x, y, function(self, x, y, dx, dy) end, dx, dy)
    end

    -- some parts of the GUI had quite some amount of magic, but now it's this function that's by far the most magical.
    -- TODO: comment this more
    function Base:pickHovered(x, y, filtered)
        -- because the loops breaks for every child that claims the hover, all children have to be reset before.
        -- otherwise there will be multiple hovered objects in one tree.
        -- this way of doing it is not particularly efficient, because leafs will be resettet a number of times equal to their depth, but that's not a big issue
        self:setSubTree("hovered", nil)

        if self.visible and self.enabled then
            gui.widgets.helpers.withCanvas(self, function(child)
                local localMouse = gui.internal.toLocal(x, y)

                local childrenFilter = filtered
                if not childrenFilter then
                    -- childrenFilter is different from contains, because you still want the widget to be hovered in not-filtered areas not occupied by child
                    -- so toTop() works properly and hovered in generall is set correctly
                    childrenFilter = gui.widgets.helpers.callThemeFunction(self, "childrenFilter", unpack(localMouse))
                    if childrenFilter == nil then
                        childrenFilter = self.position and self.width and self.height and not gui.internal.inRect(localMouse, {0, 0, self.width, self.height})
                    end
                end

                self.hovered = gui.internal.foreach_array(self.children, function(child)
                    return child:pickHovered(x, y, childrenFilter) -- will break ~= nil
                end, true)

                if self.hovered == nil and (not filtered or self.breakout) then
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
        ["visible"] = Base.setVisible,
        ["width"] = Base.setWidth,
        ["height"] = Base.setHeight,
    }

    return Base
end

return module
