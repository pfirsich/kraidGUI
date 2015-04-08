function module(gui)
    local Line = gui.internal.class(gui.widgets.Base)

    function Line:init(params)
        self.type = "Line"

        self.position = {0, 0}
        self.width = 100
        self.height = 2
        self.minWidth = 0

        gui.widgets.Base.init(self, params)
        gui.widgets.helpers.callThemeFunction(self, "init")
    end

    return Line
end

return module
