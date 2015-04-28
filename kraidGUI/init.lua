do
    local gui = {}

    function gui.getTheme(name) return require(name)(gui) end



    -- Objects in internal are supposed to only be used by GUI code (e.g. this library of anyone extending/modyfing it)
    gui.internal = {}

    function gui.internal.addTableKeys(to, from)
        for k, v in pairs(from) do
            to[k] = v
        end
    end

    function gui.internal.tableDeepCopy(tbl)
        local ret = {}
        for k, v in pairs(tbl) do
            if type(tbl[k]) == "table" then
                ret[k] = gui.internal.tableDeepCopy(tbl[k])
            else
                ret[k] = tbl[k]
            end
        end
        return ret
    end

    function gui.internal.class(base)
        local cls = {}
        cls.__index = cls
        cls.static = base and gui.internal.tableDeepCopy(base.static) or {}

        return setmetatable(cls, {
            __index = base,

            __call = function(c, ...)
                local self = setmetatable({}, c)
                if self.init then self:init(...) end
                return self
            end
        })
    end

    gui.internal.Stack = gui.internal.class()
    function gui.internal.Stack:init() self.stack = {} end
    function gui.internal.Stack:push(v) self.stack[#self.stack+1] = v end
    function gui.internal.Stack:top() return self.stack[#self.stack] end
    function gui.internal.Stack:size() return #self.stack end
    function gui.internal.Stack:pop()
        local temp = self.stack[#self.stack]
        self.stack[#self.stack] = nil
        return temp
    end

    gui.internal.canvasStack = gui.internal.Stack()
    -- This is not pretty. There could be a possibility of making a special case that unsets the scissor, but it would make quite a few places
    -- a lot less prettier. Even though this is not strictly future proof, it's good enough. inf aka math.huge does not work!
    gui.internal.canvasStack:push({origin = {0,0}, scissor = {0,0,100000,100000}})

    -- relative to last scissor origin
    function gui.internal.pushCanvas(x, y, w, h, breakout)
        local origin = gui.internal.origin()
        local top = gui.internal.canvasStack:top()

        local sx, sy = math.max(top.scissor[1], x + origin[1]), math.max(top.scissor[2], y + origin[2])
        local sw, sh = math.min(math.max(0, top.scissor[3] - x), w), math.min(math.max(0, top.scissor[4] - y), h)
        gui.internal.canvasStack:push{origin = {x + origin[1], y + origin[2]}, scissor = breakout and gui.internal.canvasStack.stack[1].scissor or {sx, sy, sw, sh}}

        gui.backend.scissorRect(unpack(gui.internal.canvasStack:top().scissor))
    end

    function gui.internal.popCanvas()
        if gui.internal.canvasStack:size() <= 1 then
            error("origin popped more than pushed")
        else
            gui.internal.canvasStack:pop()
            gui.backend.scissorRect(unpack(gui.internal.canvasStack:top().scissor))
        end
    end

    function gui.internal.origin()
        return gui.internal.canvasStack:top().origin
    end

    function gui.internal.toLocal(x, y)
        local origin = gui.internal.origin()
        return {x - origin[1], y - origin[2]}
    end

    function gui.internal.inRect(point, rect) -- rect = {x, y, w, h}
        return point[1] >= rect[1] and point[1] <= rect[1] + rect[3] and point[2] >= rect[2] and point[2] <= rect[2] + rect[4]
    end



    require("kraidGUI.widgets")(gui)
    gui.widgets.setDefaultParameter("theme", gui.getTheme("kraidGUI.themes.default"))

    require("kraidGUI.layouts")(gui)

    return gui
end
