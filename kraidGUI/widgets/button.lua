function getModule(gui)
    local Button = gui.internal.class(gui.widgets.Base)

    function Button:init(params)
        self.type = "Button"

        self.position = {0, 0}
        self.width = 100
        self.height = 20

        gui.widgets.Base.init(self, params)
        gui.internal.callThemeFunction(self, "init")
    end

    function Button:onMouseUp(x, y, button)
        if self.clicked and button == "l" then
            if self.onClicked then self:onClicked() end
        end
        gui.widgets.Base.onMouseUp(self, x, y, button)
    end

    return Button
end

return getModule
