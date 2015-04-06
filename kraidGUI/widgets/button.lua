function module(gui)
    local Button = gui.internal.class(gui.widgets.Base)

    function Button:init(params)
        self.type = "Button"

        self.position = {0, 0}
        self.width = 100
        self.height = 20

        gui.widgets.Base.init(self, params)
        gui.widgets.helpers.callThemeFunction(self, "init")
    end

    return Button
end

return module
