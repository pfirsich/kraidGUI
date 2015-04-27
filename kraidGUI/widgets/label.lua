--- Test
-- @module test

function getModule(gui)
    local Label = gui.internal.class(gui.widgets.Base)

    function Label:init(params)
        self.type = "Label"

        self.position = {0, 0}
        self:setText("Label")

        gui.widgets.Base.init(self, params)
        gui.internal.callThemeFunction(self, "init")
    end

    function Label:setText(text)
        -- NOTE: This should probably go into the theme
        self.width = gui.backend.text.getWidth(text)
        self.height = gui.backend.text.getHeight()
        self.text = text
    end

    Label.static.setters["text"] = Label.setText

    return Label
end

return getModule
