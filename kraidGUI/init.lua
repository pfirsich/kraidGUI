do
    ---------------------------- HELPERS
    ------------------------------------

    function addTableKeys(to, from)
        for k, v in pairs(from) do
            to[k] = v
        end
    end

    function tableDeepCopy(tbl)
        local ret = {}
        for k, v in pairs(tbl) do
            if type(tbl[k]) == "table" then
                ret[k] = tableDeepCopy(tbl[k])
            else
                ret[k] = tbl[k]
            end
        end
        return ret
    end

    function foreach(table, func)
        for k, v in pairs(table) do
            func(k, v)
        end
    end

    function foreach_array(table, func, reverse)
        local from, to, step = 1, #table, 1
        if reverse == true then from, to, step = #table, 1, -1 end

        for i = from, to, step do
            if func(table[i]) then return true end
        end
    end

    -------------------------------- GUI
    ------------------------------------

    local gui = {}

    function gui.getTheme(name)
        return require(name)(gui)
    end

    --------------------------- INTERNAL
    ------------------------------------

    gui.internal = {}
    gui.internal.canvasStack = {{origin = {0,0}, scissor = {0,0,100000,100000}}}
    gui.internal.foreach = foreach
    gui.internal.foreach_array = foreach_array
    gui.internal.tableDeepCopy = tableDeepCopy

    -- relative to last scissor origin
    function gui.internal.pushCanvas(x, y, w, h)
        local stk = gui.internal.canvasStack
        local origin = gui.internal.origin()

        local sx, sy = math.max(stk[#stk].scissor[1], x + origin[1]), math.max(stk[#stk].scissor[2], y + origin[2])
        local sw, sh = math.min(math.max(0, stk[#stk].scissor[3] - x), w), math.min(math.max(0, stk[#stk].scissor[4] - y), h)
        stk[#stk+1] = {origin = {x + origin[1], y + origin[2]}, scissor = {sx, sy, sw, sh}}

        gui.graphics.scissorRect(unpack(stk[#stk].scissor))
    end

    function gui.internal.popCanvas()
        local stk = gui.internal.canvasStack
        if #stk <= 1 then
            error("origin popped more than pushed")
        else
            stk[#stk] = nil
            gui.graphics.scissorRect(unpack(stk[#stk].scissor))
        end
    end

    function gui.internal.topCanvas()
        return gui.internal.canvasStack[#gui.internal.canvasStack]
    end

    function gui.internal.origin()
        return gui.internal.canvasStack[#gui.internal.canvasStack].origin
    end

    function gui.internal.toLocal(x, y)
        local origin = gui.internal.origin()
        return {x - origin[1], y - origin[2]}
    end

    function gui.internal.inRect(point, rect) -- rect = {x, y, w, h}
        return point[1] >= rect[1] and point[1] <= rect[1] + rect[3] and point[2] >= rect[2] and point[2] <= rect[2] + rect[4]
    end

    function gui.internal.class(base)
        local cls = {}
        cls.__index = cls
        cls.static = base and tableDeepCopy(base.static) or {}

        return setmetatable(cls, {
            __index = base,

            __call = function(c, ...)
                local self = setmetatable({}, c)
                if self.init then self:init(...) end
                return self
            end
        })
    end

    ---------------------------- WIDGETS
    ------------------------------------

    gui.widgets = {}
    gui.widgets._defaultParameters = {
        enabled = true, -- this is just a mode of display/interactivity (disabled as in 'greyed-out' - will not be updated) - not implemented in "default"-theme.
        visible = true,
        virtual = false -- will only be updated, but not drawn
    }

    function gui.widgets.setDefault(name, value)
        gui.widgets._defaultParameters[name] = value
    end

    gui.widgets.setDefault("theme", gui.getTheme("kraidGUI.themes.default"))

    require("kraidGUI.widgets")(gui)

    return gui
end
