function module(gui)
    local Numberwheel = gui.internal.class(gui.widgets.Base)

    function Numberwheel:init(params)
        self.type = "Numberwheel"

        self.position = {0, 0}
        self.width = 100
        self.height = 20
        self.value = 0
        self.speed = 100.0 -- may be a function
        self.format = "%.3f"

        gui.widgets.Base.init(self, params)
        gui.widgets.helpers.callThemeFunction(self, "init")
    end

    function Numberwheel:setValue(value)
        if self.maxValue then value = math.min(self.maxValue, value) end
        if self.minValue then value = math.max(self.minValue, value) end
        if self.onChange then value = self:onChange(value) or value end
        self.value = value
    end

    Numberwheel.static.setters["value"] = Numberwheel.setValue

    return Numberwheel
end

return module
