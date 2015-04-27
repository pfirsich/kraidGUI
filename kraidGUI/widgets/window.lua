--- Test
-- @module test

function getModule(gui)
    local Window = gui.internal.class(gui.widgets.Base)

    function Window:init(params)
        self.type = "Window"

        self.position = {0, 0}
        self.width = 100
        self.height = 100
        self.text = "Window"
        self.closeable = true
        self.resizeable = false

        gui.widgets.Base.init(self, params)
        gui.internal.callThemeFunction(self, "init")
    end

    Window.static.setters["closeable"] = Window.setCloseable

    return Window
end

return getModule
