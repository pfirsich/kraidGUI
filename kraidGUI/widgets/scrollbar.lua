function getModule(gui)
    local Scrollbar = gui.internal.class(gui.widgets.Base)

    function Scrollbar:init(params)
        self.type = "Scrollbar"

        self.position = {0, 0}
        self.vertical = true -- should this be two different widgets?
        self.value = 0.0
        self.scrollDelta = 0.1
        self:setParam("length", 300)
        self:setParam("thickness", 20)

        gui.widgets.Base.init(self, params)
        gui.internal.callThemeFunction(self, "init")

        self:setParam("length", self.length)
        self:setParam("thickness", self.thickness)
    end

    function Scrollbar:scrollUp()
        self.value = math.min(1, self.value + self.scrollDelta)
    end

    function Scrollbar:scrollDown()
        self.value = math.max(0, self.value - self.scrollDelta)
    end

    function Scrollbar:onMouseDown(x, y, button)
        gui.widgets.Base.onMouseDown(self, x, y, button)
        if button == "wu" then self:scrollDown() end
        if button == "wd" then self:scrollUp() end
    end

    function Scrollbar:setLength(length)
        self.length = length
        self[self.vertical and "height" or "width"] = self.length
    end

    function Scrollbar:setThickness(thickness)
        self.thickness = thickness
        self[self.vertical and "width" or "height"] = self.thickness
    end

    Scrollbar.static.setters["length"] = Scrollbar.setLength
    Scrollbar.static.setters["thickness"] = Scrollbar.setThickness

    return Scrollbar
end

return getModule
