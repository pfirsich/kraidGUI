function module(gui)
    local Numberwheel = gui.internal.class(gui.widgets.Base)

    function Numberwheel:init(params)
        self.type = "Numberwheel"

        self.position = {0, 0}
        self.width = 100
        self.height = 30
        self.value = 0
        self.speed = 100.0 -- may be a function
        self.format = "%.3f"

        -- again this object is constructed first, because it can't be with a parent given, because Base.init has to be called first. Also Base.init will
        -- call setValue and therefore set the text in this widget.
        local onChangeLine = function(inputLine, before)
            if tonumber(inputLine.text) == nil then return true end -- if the current text can not be tonumber-ed, reject changes
            self:setValue(tonumber(inputLine.text))
        end

        self.numberInputLine = gui.widgets.LineInput{parent = nil, onChange = onChangeLine}

        gui.widgets.Base.init(self, params)
        gui.widgets.helpers.callThemeFunction(self, "init")

        self.numberInputLine:setParam("parent", self)
        self.numberInputLine:setParam("text", tostring(self.value))
    end

    function Numberwheel:setValue(value)
        if self.maxValue then value = math.min(self.maxValue, value) end
        if self.minValue then value = math.max(self.minValue, value) end
        if self.onChange then value = self:onChange(value) or value end
        self.value = value
        self.numberInputLine.text = string.format(self.format, self.value) -- so onChange is not called
    end

    Numberwheel.static.setters["value"] = Numberwheel.setValue

    return Numberwheel
end

return module
