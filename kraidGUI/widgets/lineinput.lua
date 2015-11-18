utf8 = require('utf8')
local strlen = function(text) return utf8.len(text) end
local strsub = function(text, from, to) return text:sub(utf8.offset(text, from), to and utf8.offset(text, to+1)-1 or text:len()) end

function getModule(gui)
    local LineInput = gui.internal.class(gui.widgets.Base)

    function LineInput:init(params)
        self.type = "LineInput"

        self.position = {0, 0}
        self.width = 100
        self.height = 25
        self.cursor = {0,0}
        self.text = ""

        gui.widgets.Base.init(self, params)
        gui.internal.callThemeFunction(self, "init")
    end

    function LineInput:select(from, to)
        self.cursor = {from, to}
    end

    function LineInput:selected()
        return strsub(self.text, self.cursor[1] + 1, self.cursor[2])
    end

    function LineInput:cut()
        if self.cursor[1] ~= self.cursor[2] then
            local sel = self:selected()
            self.text = strsub(self.text, 1, self.cursor[1]) .. strsub(self.text, self.cursor[2] + 1)
            self:moveCursor(-1)
            return sel
        end
    end

    function LineInput:paste(str)
        self.text = strsub(self.text, 1, self.cursor[1]) .. str .. strsub(self.text, self.cursor[2] + 1)
        self.cursor[2] = self.cursor[1]
        self:moveCursor(str:len())
    end

    function LineInput:moveCursor(delta) -- a helper function
        local cursor = nil
        if self.cursor[1] ~= self.cursor[2] then
            cursor = delta > 0 and self.cursor[2] or self.cursor[1]
        else
            cursor = math.min(strlen(self.text), math.max(0, self.cursor[1] + delta))
        end
        self.cursor[1], self.cursor[2] = cursor, cursor
    end

    function LineInput:changeText(func)
        local before = self.text
        local beforeCursor = {self.cursor[1], self.cursor[2]}
        func()
        if self.onChange and self:onChange(before) then
            self.text = before
            self.cursor = beforeCursor
        end
    end

    function LineInput:textInput(text)
        --print("'" .. text .. "'")
        self:changeText(function() self:paste(text) end)
    end

    function LineInput:keyPressed(key, isrepeat)
        --print(key)

        if key == "left" then self:moveCursor(-1) end
        if key == "right" then self:moveCursor(1) end

        if key == "backspace" then
            self:changeText(function()
                if self.cursor[1] == self.cursor[2] then
                    self.cursor[1] = math.max(self.cursor[1] - 1, 0)
                end
                self:cut()
            end)
        end
    end

    function LineInput:setText(text)
        self.text = text
        self.cursor = {strlen(self.text), strlen(self.text)}
    end

    LineInput.static.setters["text"] = LineInput.setText

    return LineInput
end

return getModule
