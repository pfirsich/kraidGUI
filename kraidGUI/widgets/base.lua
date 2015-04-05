function module(gui)
    local Base = gui.internal.class()

    function Base:init(params)
        self.type = self.type or "Base"
        self.children = {}

        local set = {}
        addTableKeys(set, gui.widgets._defaultParameters)
        if params then addTableKeys(set, params) end

        foreach(set, function(param, value)
            self:setParam(param, value)
        end)
    end

    function Base:update(uiState, child)
        if self.visible and self.enabled then
            if child ~= true then
                if self.lastUIState then
                    local last = self.lastUIState
                    uiState.mouse.pressed  = uiState.mouse.leftDown and not last.mouse.leftDown
                    uiState.mouse.released = not uiState.mouse.leftDown and last.mouse.leftDown
                    uiState.mouse.move = {uiState.mouse.position[1] - last.mouse.position[1], uiState.mouse.position[2] - last.mouse.position[2]}
                else
                    self.lastUIState = {mouse = {}}
                    uiState.mouse.move = {0, 0}
                end
                addTableKeys(self.lastUIState.mouse, uiState.mouse)
                self.lastUIState.mouse.position = {uiState.mouse.position[1], uiState.mouse.position[2]}
            end

            if self.position and self.width and self.height then
                gui.internal.pushCanvas(self.position[1], self.position[2], self.width, self.height)
            end

            if self.theme[self.type] and self.theme[self.type].update then
                self.theme[self.type].update(self, uiState)
            end

            gui.internal.foreach_array(self.children, function(child)
                child:update(uiState, true)
            end, true)

            if self.position and self.width and self.height then
                gui.internal.popCanvas()
            end
        end
    end

    function Base:draw()
        if self.visible then
            if self.position and self.width and self.height then
                gui.internal.pushCanvas(self.position[1], self.position[2], self.width, self.height)
            end

            if self.theme[self.type] and self.theme[self.type].draw then
                self.theme[self.type].draw(self)
            end

            if self.position and self.width and self.height then
                gui.internal.popCanvas()
            end
        end
    end

    function Base:setParam(name, value)
        if self.setters[name] then
            self.setters[name](self, value)
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

    Base.setters = { -- static
        ["parent"] = Base.setParent
    }

    return Base
end

return module
