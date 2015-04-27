do
    local kraidGUILove = {}

    function kraidGUILove.init(gui)
        gui.backend = {}

        function gui.backend.setColor(r, g, b, a) -- this should also be able to take a table
            love.graphics.setColor(r, g, b, a or 255)
        end

        local function drawShape(func, lineWidth, ...)
            love.graphics.push()
            love.graphics.translate(unpack(gui.internal.origin()))
            if lineWidth then
                if lineWidth > 0 then
                    love.graphics.setLineWidth(lineWidth)
                    func("line", ...)
                end
            else
                func("fill", ...)
            end
            love.graphics.pop()
        end

        function gui.backend.drawRectangle(x, y, w, h, lineWidth)
            drawShape(love.graphics.rectangle, lineWidth, x, y, w, h)
        end

        function gui.backend.drawCircle(x, y, radius, segments, lineWidth)
            drawShape(love.graphics.circle, lineWidth, x, y, radius, segments)
        end

        function gui.backend.drawPolygon(points, lineWidth)
            drawShape(love.graphics.polygon, lineWidth, points)
        end

        gui.backend.text = {}
        function gui.backend.text.getHeight()
            return love.graphics.getFont():getHeight()
        end

        function gui.backend.text.getWidth(text)
            return love.graphics.getFont():getWidth(text)
        end

        function gui.backend.text.draw(text, x, y)
            local origin = gui.internal.origin()
            love.graphics.print(text, x + origin[1], y + origin[2])
        end

        gui.backend.scissorRect = love.graphics.setScissor

        gui.backend.getTime = love.timer.getTime
        gui.backend.keyDown = love.keyboard.isDown
    end

    return kraidGUILove
end
