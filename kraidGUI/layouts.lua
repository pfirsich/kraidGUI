do
    function getModule(gui)
        -- TODO: Vertical resizing?
        local LineLayout = gui.internal.class()

        function LineLayout:init(parent, params)
            self.lines = {}
            self.parent = parent
            self.defaultParameters = {
                ["padding"] = 5,
                ["spacing"] = 5,
            }

            for k, v in pairs(params) do
                self.defaultParameters[k] = v
            end
        end

        function LineLayout:setParam(parameter, value)
            self.defaultParameters[parameter] = value
        end

        function LineLayout:newLine(params)
            self.lines[#self.lines+1] = {parameters = params or {}, widgets = {}}
        end

        function LineLayout:addWidget(widget, params)
            if #self.lines == 0 then error("LineLayout needs at least one line") end
            table.insert(self.lines[#self.lines].widgets, {object = widget, parameters = params or {}})
        end

        function LineLayout:arrange()
            local parameterStack = gui.internal.Stack()
            parameterStack:push(self.defaultParameters)

            -- helper function so parameter won't just be replaced, but are pushed incrementally
            parameterStack.pushParams = function(self, params)
                self:push(gui.internal.tableDeepCopy(self:top()))
                gui.internal.addTableKeys(self:top(), params)
            end

            parameterStack.getParam = function(self, name)
                local matchLength, ret = 0, nil
                for k, v in pairs(self:top()) do
                    local keyLen = k:len()
                    if keyLen > matchLength and name:sub(1, keyLen) == k then
                        ret = v
                        matchLength = keyLen
                    end
                end

                if ret == nil then error("Parameter " .. name .. " could not be evaluated.") end
                return ret
            end

            local cursorY = parameterStack:getParam("padding-top")
            for line = 1, #self.lines do
                parameterStack:pushParams(self.lines[line].parameters)

                local cursorX = parameterStack:getParam("padding-left")
                local totalWidth = self.parent.width
                local height = 0
                local width = parameterStack:getParam("padding-left") + parameterStack:getParam("padding-right")
                local sizeUp = {}
                local sizeUpCount = 0

                for index, widget in ipairs(self.lines[line].widgets) do
                    parameterStack:pushParams(widget.parameters)

                    height = math.max(height, widget.object.height)
                    sizeUp[index] = 0 -- because with numbers I don't need type conversion later
                    if widget.object.minWidth or widget.object.maxWidth then
                        width = width + (widget.object.minWidth or 0)
                        sizeUp[index] = 1
                        sizeUpCount = sizeUpCount + 1
                        widget.object.width = widget.object.minWidth or 0
                    else
                        width = width + widget.object.width
                    end
                    if index < #self.lines[line].widgets then width = width + parameterStack:getParam("spacing-horizontal") end

                    parameterStack:pop()
                end

                for index, widget in ipairs(self.lines[line].widgets) do
                    parameterStack:pushParams(widget.parameters)

                    -- math.floor because thin lines don't like being drawn between pixels! (button-outlines would flicker)
                    widget.object.position = {math.floor(cursorX), math.floor(cursorY + height/2 - widget.object.height/2)}
                    widget.object:setParam("width", math.floor(widget.object.width + sizeUp[index] * math.max(0, (totalWidth - width)) / math.max(1, sizeUpCount)))
                    cursorX = cursorX + widget.object.width + parameterStack:getParam("spacing-horizontal")

                    parameterStack:pop()
                end

                cursorY = cursorY + height + parameterStack:getParam("spacing-vertical")

                parameterStack:pop()
            end
        end

        gui.layouts = {}
        gui.layouts.LineLayout = LineLayout
    end

    return getModule
end
