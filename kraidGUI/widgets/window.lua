function module(gui)
    local Window = gui.internal.class(gui.widgets.Base)

    function Window:init(params)
        self.type = "Window"

        self.position = {0, 0}
        self.width = 100
        self.height = 100
        self.text = "Window"
        self.closeable = true
        self.resizeable = false

        -- first create the button without a parent because it's parent (this window) is not properly constructed yet (Base.init has not been called)
        -- Base.init and this code can not change places, since Base.init will call the closeable-setter which demands the existence of self.closeButton
        local closeButtonCallback = function (button)
            if not self.onClose or self:onClose() then self.visible = false end
        end
        self.closeButton = gui.widgets.Button{parent = nil, text = "", onMouseUp = closeButtonCallback, virtual = true}

        gui.widgets.Base.init(self, params)
        gui.widgets.helpers.callThemeFunction(self, "init")

        -- set parent now that everything is set up (closeable is changed by Base.init)
        self.closeButton:setParam("parent", self)
        self.closeButton:setParam("visible", self.closeable)
    end

    Window.static.setters["closeable"] = function(self, closeable) self.closeable = closeable; self.closeButton.visible = closeable end

    return Window
end

return module
