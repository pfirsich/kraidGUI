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
        self.text = text
        self.width = gui.backend.text.getWidth(self.text) -- not sure if this works with multiple lines
        self.height = gui.backend.text.getHeight() * (select(2, self.text:gsub('\n', '\n')) + 1)
    end

    Label.static.setters["text"] = Label.setText

    return Label
end

return getModule
