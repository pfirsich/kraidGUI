function module(gui)
    local LineInput = gui.internal.class(gui.widgets.Base)

    function LineInput:init(params)
        self.type = "LineInput"

        self.position = {0, 0}
        self.width = 100
        self.height = 30
        self.cursor = 0

        gui.widgets.Base.init(self, params)
        gui.widgets.helpers.callThemeFunction(self, "init")
    end

    function LineInput:moveCursor(delta) -- a helper function
        self.cursor = math.min(self.text:len(), math.max(0, self.cursor + delta))
    end

    function LineInput:textInput(text)
        print("'" .. text .. "'")
        self.text = self.text:sub(1, self.cursor) .. text .. self.text:sub(self.cursor + 1)
        self:moveCursor(text:len())
        if self.onChange then self:onChange() end
    end

    function LineInput:keyPressed(key, isrepeat)
        if key == "left" then
            self:moveCursor(-1)
        end

        if key == "right" then
            self:moveCursor(1)
        end

        if key == "backspace" then
            self.text = self.text:sub(1, self.cursor - 1) .. self.text:sub(self.cursor + 1)
            self:moveCursor(-1)
            if self.onChange then self:onChange() end
        end
    end

    function LineInput:setText(text)
        self.text = text
        self.cursor = self.text:len()
    end

    LineInput.static.setters["text"] = LineInput.setText

    return LineInput
end

return module
