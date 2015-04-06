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


    local function callThemeFunction(object, func, ...)
        if object.theme and object.theme[object.type] and object.theme[object.type][func] then
            return object.theme[object.type][func](object, ...)
        end
    end

    local function withCanvas(self, func)
        if self.position and self.width and self.height then
            gui.internal.pushCanvas(self.position[1], self.position[2], self.width, self.height)
        end

        func()

        if self.position and self.width and self.height then
            gui.internal.popCanvas()
        end
    end

    function Base:update()
        if self.visible and self.enabled then
            withCanvas(self, function()
                callThemeFunction(self, "update")

                gui.internal.foreach_array(self.children, function(child)
                    child:update()
                end, true)
            end)
        end
    end

    function Base:draw()
        if self.visible then
            withCanvas(self, function()
                callThemeFunction(self, "draw")
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
        withCanvas(self, function()
            local claimed = callThemeFunction(self, name, unpack(args))

            if not claimed then
                claimed = gui.internal.foreach_array(self.children, function(child)
                    return child[name](child, unpack(args)) -- will break if true
                end, true)
            end
        end)

        return claimed
    end

    function Base:mousePressed(x, y, button)
        if self.hovered then
            self:toTop()
            self.clicked = true
            if self.onClicked then self:onClicked() end

            mouseEvent(self, "mousePressed", x, y, button)
            return true
        end
    end

    function Base:mouseReleased(x, y, button)
        if self.hovered then
            self.clicked = false
            if self.onMouseUp then self:onMouseUp() end

            mouseEvent(self, "mouseReleased", x, y, button)
            return true
        end
    end

    function Base:mouseMove(x, y, dx, dy)
        local localMouse = gui.internal.toLocal(x, y)
        local hovered = (self.contains and self.contains(unpack(localMouse))) or
                        (self.position and self.width and self.height and gui.internal.inRect(localMouse, {self.position[1], self.position[2], self.width, self.height}))

        if not self.hovered and hovered and self.onMouseEnter then
            self:onMouseEnter() -- TODO: parameters!
        end

        if self.hovered and not hovered then
            if self.onMouseExit then self:onMouseExit() end -- TODO: parameters!
        end

        self.hovered = hovered

        return mouseEvent(self, "mouseMove", x, y, dx, dy)
    end

    Base.static.setters = { -- static
        ["parent"] = Base.setParent
    }

    return Base
end

return module
