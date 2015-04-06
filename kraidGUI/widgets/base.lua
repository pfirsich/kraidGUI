function module(gui)
    local Base = gui.internal.class()

    function Base:init(params)
        self.type = self.type or "Base"
        self.children = {}

        local set = {}
        addTableKeys(set, gui.widgets._defaultParameters)
        if params then addTableKeys(set, params) end

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

    function Base:toTop() -- make last in list (rendered last)
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

    local function mouseEvent(self, name, ...)
        local args = {...}
        gui.widgets.helpers.withCanvas(self, function()
            local claimed = gui.widgets.helpers.callThemeFunction(self, name, unpack(args))

            if not claimed then
                claimed = gui.internal.foreach_array(self.children, function(child)
                    return child[name](child, unpack(args)) -- will break if true
                end, true)
            end
        end)

        return claimed
    end

    function Base:mousePressed(x, y, button)
        if self.visible and self.enabled then
            if self.hovered then
                self:toTop()
                self.clicked = true
                if self.onClicked then self:onClicked() end
            end

            -- these are taken apart and the check is added, so Base-Widgets without position/dimensions will still pass the events to their children
            if self.hovered or not (self.position and self.width and self.height) then
                mouseEvent(self, "mousePressed", x, y, button)
            end

            return self.hovered
        end
    end

    function Base:mouseReleased(x, y, button)
        if self.visible and self.enabled then
            if self.hovered then
                self.clicked = false
                if self.onMouseUp then self:onMouseUp() end
            end

            if self.hovered or not (self.position and self.width and self.height) then
                mouseEvent(self, "mouseReleased", x, y, button)
            end

            return self.hovered
        end
    end

    function Base:mouseMove(x, y, dx, dy)
        if self.visible and self.enabled then
            local localMouse = gui.internal.toLocal(x, y)
            local hovered = (self.contains and self.contains(unpack(localMouse))) or
                            (self.position and self.width and self.height and gui.internal.inRect(localMouse, {self.position[1], self.position[2], self.width, self.height}))

            if not self.hovered and hovered and self.onMouseEnter then
                self:onMouseEnter() -- TODO: parameters!
            end

            if self.hovered and not hovered then
                if self.onMouseExit then self:onMouseExit() end -- TODO: parameters!
                self.clicked = false
            end

            self.hovered = hovered

            mouseEvent(self, "mouseMove", x, y, dx, dy)

            return self.hovered -- so the first object that is hovered (the upmost one) will stop all other objects from being hovered
        end
    end

    Base.static.setters = { -- static
        ["parent"] = Base.setParent
    }

    return Base
end

return module
