function module(gui)
    local Label = gui.internal.class(gui.widgets.Base)

    function Label:init(params)
        self.type = "Label"

        self.position = {0, 0}
        params.text = "Label"

        gui.widgets.Base.init(self, params)
    end

    function Label:setText(text)
        self.width = gui.graphics.text.getWidth(text)
        self.height = gui.graphics.text.getHeight()
        self.text = text
    end

    Label.static.setters["text"] = Label.setText

    return Label
end

return module
