function module(gui)
    gui.widgets.helpers = {}
    function gui.widgets.helpers.callThemeFunction(object, func, ...)
        if object.theme and object.theme[object.type] and object.theme[object.type][func] then
            return object.theme[object.type][func](object, ...)
        end
    end

    function gui.widgets.helpers.withCanvas(rectWidgetLike, func)
        if rectWidgetLike and rectWidgetLike.position and rectWidgetLike.width and rectWidgetLike.height then
            gui.internal.pushCanvas(rectWidgetLike.position[1], rectWidgetLike.position[2], rectWidgetLike.width, rectWidgetLike.height)
        end

        func()

        if rectWidgetLike and rectWidgetLike.position and rectWidgetLike.width and rectWidgetLike.height then
            gui.internal.popCanvas()
        end
    end

    gui.widgets.Base = require("kraidGUI.widgets.base")(gui)
    gui.widgets.Label = require("kraidGUI.widgets.label")(gui)
    gui.widgets.Button = require("kraidGUI.widgets.button")(gui)
    gui.widgets.Window = require("kraidGUI.widgets.window")(gui)
    gui.widgets.Checkbox = require("kraidGUI.widgets.checkbox")(gui)
end

return module
