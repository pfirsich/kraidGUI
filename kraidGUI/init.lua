do
    ---------------------------- HELPERS
    ------------------------------------

    function addTableKeys(to, from)
        for k, v in pairs(from) do
            to[k] = v
        end
    end

    function foreach(table, func)
        for k, v in pairs(table) do
            func(k, v)
        end
    end

    function foreach_array(table, func, reverse)
        local from, to, step = 1, #table, 1
        if reverse == true then from, to, step = #table, 1, -1 end
        print("--- ", from, to, step)
        for i = from, to, step do
            print(i)
            func(table[i])
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
    gui.internal.canvasStack = {{0,0,100000,100000}}
    gui.internal.foreach = foreach
    gui.internal.foreach_array = foreach_array

    -- relative to last scissor origin
    function gui.internal.pushCanvas(x, y, w, h)
        local stk = gui.internal.canvasStack
        local origin = gui.internal.origin()
        stk[#stk+1] = {x + origin[1], y + origin[2], w, h}
        gui.graphics.scissorRect(unpack(stk[#stk]))
    end

    function gui.internal.popCanvas()
        local stk = gui.internal.canvasStack
        if #stk <= 1 then
            error("origin popped more than pushed")
        else
            stk[#stk] = nil
            gui.graphics.scissorRect(unpack(stk[#stk]))
        end
    end

    function gui.internal.origin()
        local top = gui.internal.canvasStack[#gui.internal.canvasStack]
        return {top[1], top[2]}
    end

    function gui.internal.toLocal(point)
        local origin = gui.internal.origin()
        return {point[1] - origin[1], point[2] - origin[2]}
    end

    function gui.internal.inRect(point, rect) -- rect = {x, y, w, h}
        return point[1] >= rect[1] and point[1] <= rect[1] + rect[3] and point[2] >= rect[2] and point[2] <= rect[2] + rect[4]
    end

    function gui.internal.class(base)
        local cls = {}
        cls.__index = cls

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
        enabled = true, -- this is just a mode of display/interactivity (disabled as in 'greyed-out' - will not be updated)
        visible = true
    }

    function gui.widgets.setDefault(name, value)
        gui.widgets._defaultParameters[name] = value
    end

    gui.widgets.setDefault("theme", gui.getTheme("kraidGUI.themes.default"))
    gui.widgets.setDefault("padding", 5)

    -- Widgets (themes!) should generally call these:
	-- onMouseEnter, onMouseExit, onMouseUp, onClicked (onMouseDown)
    -- and subsequently set hovered, clicked
    require("kraidGUI.widgets")(gui)

    return gui
end
