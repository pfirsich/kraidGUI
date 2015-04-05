function module(gui)
    local Window = gui.internal.class(gui.widgets.Base)


    function Window:init(...)
        self.type = "Window"

        self.position = {0, 0}
        self.width = 100
        self.heigh = 100
        self.text = "Window"
        self.closeable = true
        self.resizeable = false

        gui.widgets.Base.init(self, ...)
    end

    -- function setterForVal
    -- Window.setters["myval"] = settterForVal

    return Window
end

return module
