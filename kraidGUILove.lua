do
    local kraidGUILove = {}

    function kraidGUILove.init(gui)
        gui.graphics = {}

        function gui.graphics.setColor(r, g, b, a) -- this should also be able to take a table
            love.graphics.setColor(r, g, b, a or 255)
        end

        function drawShape(func, lineWidth, ...)
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

        function gui.graphics.drawRectangle(x, y, w, h, lineWidth)
            drawShape(love.graphics.rectangle, lineWidth, x, y, w, h)
        end

        function gui.graphics.drawCircle(x, y, radius, segments, lineWidth)
            drawShape(love.graphics.circle, lineWidth, x, y, radius, segments)
        end

        function gui.graphics.drawPolygon(points, lineWidth)
            drawShape(love.graphics.polygon, lineWidth, points)
        end

        gui.graphics.text = {}
        function gui.graphics.text.getHeight()
            return love.graphics.getFont():getHeight()
        end

        function gui.graphics.text.getWidth(text)
            return love.graphics.getFont():getWidth(text)
        end

        function gui.graphics.text.draw(text, x, y)
            local origin = gui.internal.origin()
            love.graphics.print(text, x + origin[1], y + origin[2])
        end

        gui.graphics.scissorRect = love.graphics.setScissor
    end

    return kraidGUILove
end
