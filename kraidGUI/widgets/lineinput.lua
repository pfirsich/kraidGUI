function module(gui)
    local LineInput = gui.internal.class(gui.widgets.Base)

    function LineInput:init(params)
        self.type = "LineInput"

        self.position = {0, 0}
        self.width = 100
        self.height = 30
        self.cursor = {0,0}

        gui.widgets.Base.init(self, params)
        gui.widgets.helpers.callThemeFunction(self, "init")
    end

    function LineInput:select(from, to)
        self.cursor = {from, to}
    end

    function LineInput:selected()
        return self.text:sub(self.cursor[1] + 1, self.cursor[2])
    end

    function LineInput:cut()
        if self.cursor[1] ~= self.cursor[2] then
            local sel = self:selected()
            self.text = self.text:sub(1, self.cursor[1]) .. self.text:sub(self.cursor[2] + 1)
            self:moveCursor(-1)
            return sel
        end
    end

    function LineInput:paste(str)
        self.text = self.text:sub(1, self.cursor[1]) .. str .. self.text:sub(self.cursor[2] + 1)
        self.cursor[2] = self.cursor[1]
        self:moveCursor(str:len())
    end

    function LineInput:moveCursor(delta) -- a helper function
        local cursor = nil
        if self.cursor[1] ~= self.cursor[2] then
            cursor = delta > 0 and self.cursor[2] or self.cursor[1]
        else
            cursor = math.min(self.text:len(), math.max(0, self.cursor[1] + delta))
        end
        self.cursor[1], self.cursor[2] = cursor, cursor
    end

    function LineInput:textInput(text)
        print("'" .. text .. "'")
        self:paste(text)
        if self.onChange then self:onChange() end
    end

    function LineInput:keyPressed(key, isrepeat)
        print(key)

        if key == "left" then self:moveCursor(-1) end
        if key == "right" then self:moveCursor(1) end

        if key == "backspace" then
            if self.cursor[1] == self.cursor[2] then
                self.cursor[1] = math.max(self.cursor[1] - 1, 0)
            end
            self:cut()

            if self.onChange then self:onChange() end
        end
    end

    function LineInput:setText(text)
        self.text = text
        self.cursor = {self.text:len(), self.text:len()}
    end

    LineInput.static.setters["text"] = LineInput.setText

    return LineInput
end

return module
