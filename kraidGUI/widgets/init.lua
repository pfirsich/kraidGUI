function module(gui)
    gui.widgets.helpers = {}
    function gui.widgets.helpers.callThemeFunction(object, func, ...)
        if object.theme and object.theme[object.type] and object.theme[object.type][func] then
            return object.theme[object.type][func](object, ...)
        end
        return nil
    end

    function gui.widgets.helpers.withCanvas(rectWidgetLike, func, breakout)
        if rectWidgetLike and rectWidgetLike.position and rectWidgetLike.width and rectWidgetLike.height then
            local x, y, w, h = rectWidgetLike.position[1], rectWidgetLike.position[2], rectWidgetLike.width, rectWidgetLike.height
            gui.internal.pushCanvas(x, y, w, h, rectWidgetLike.breakout)
        end

        local ret = func()

        if rectWidgetLike and rectWidgetLike.position and rectWidgetLike.width and rectWidgetLike.height then
            gui.internal.popCanvas()
        end

        return ret
    end

    gui.widgets.Base = require("kraidGUI.widgets.base")(gui)
    gui.widgets.Label = require("kraidGUI.widgets.label")(gui)
    gui.widgets.Button = require("kraidGUI.widgets.button")(gui)
    gui.widgets.Window = require("kraidGUI.widgets.window")(gui)
    gui.widgets.Checkbox = require("kraidGUI.widgets.checkbox")(gui)
    gui.widgets.Category = require("kraidGUI.widgets.category")(gui)
    gui.widgets.Radiobutton = require("kraidGUI.widgets.radiobutton")(gui)
    gui.widgets.Numberwheel = require("kraidGUI.widgets.numberwheel")(gui)
end

return module
