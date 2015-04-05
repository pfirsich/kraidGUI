do
    local kraidGUILove = {}

    function kraidGUILove.init(gui)
        gui.graphics = {}

        function gui.graphics.setColor(r, g, b, a)
            love.graphics.setColor(r, g, b, a or 255)
        end

        function drawShape(func, lineWidth, ...)
            love.graphics.push()
            love.graphics.translate(unpack(gui.internal.origin()))
            if lineWidth then
                love.graphics.setLineWidth(lineWidth)
                func("line", ...)
            else
                func("fill", ...)
            end
            love.graphics.pop()
        end

        function gui.graphics.drawRectangle(x, y, w, h, lineWidth)
            drawShape(love.graphics.rectangle, lineWidth, x, y, w, h)
        end

        function gui.graphics.drawText(text, x, y)
            love.graphics.print(text, x, y)
        end

        function gui.graphics.drawCircle(x, y, radius, segments, lineWidth)
            drawShape(love.graphics.circle, lineWidth, x, y, radius, segments)
        end

        function gui.graphics.drawPolygon(points, lineWidth)
            drawShape(love.graphics.polygon, lineWidth, points)
        end

        gui.graphics.scissorRect = love.graphics.setScissor
    end

    function kraidGUILove.uiState()
        return {
    		mouse = {
    			leftDown = love.mouse.isDown("l"),
    			rightDown = love.mouse.isDown("r"),
    			mouseWheel = (love.mouse.isDown("wu") and 1 or 0) - (love.mouse.isDown("wd") and 1 or 0),
    			position = {love.mouse.getPosition()}
    		}
    	}
    end

    return kraidGUILove
end
