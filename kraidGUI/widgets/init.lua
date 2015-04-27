--- Widgets
--- =====================
--- A widget is essentially a small container for relevant data and an abstraction that should be bound to the actual visual represantation as loosely as possible.
--- Mostly it just encapsulates the minimum necessary data and corresponding methods.
---
--- For an example of this, see a rather slim widget like :ref:`Button`. Also note that all widgets should derive from :ref:`Base`, preferably using the class-generator function

function getModule(gui)
    gui.widgets = {}
    --- ### default parameters
    gui.widgets._defaultParameters = {
        visible = true,
        enabled = true, --- * enabled: this is just a mode of display/interactivity (disabled as in 'greyed-out' - will not be updated) - not implemented in "default"-theme.
        virtual = false, -- will only be updated, but not drawn
        breakout = false, -- these widgets will be drawn without being confined by it's parents boundaries. also they are drawn over all other child widgets of their parent!
    }

    function gui.widgets.setDefaultParameter(name, value)
        gui.widgets._defaultParameters[name] = value
    end

    function gui.widgets.passEvent(event, source, target)
        source:setParam(event, function(source, ...) return target[event](target, ...) end)
    end

    -- these functions are added to internal here, because they need widgets to work 
    function gui.internal.callThemeFunction(object, func, ...)
        if object.theme and object.theme[object.type] and object.theme[object.type][func] then
            return object.theme[object.type][func](object, ...)
        end
        return nil
    end

    function gui.internal.withCanvas(rectWidgetLike, func, breakout)
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
    gui.widgets.LineInput = require("kraidGUI.widgets.lineinput")(gui)
    gui.widgets.Numberwheel = require("kraidGUI.widgets.numberwheel")(gui)
    gui.widgets.Line = require("kraidGUI.widgets.line")(gui)
    gui.widgets.Scrollbar = require("kraidGUI.widgets.scrollbar")(gui)
    gui.widgets.TreeView = require("kraidGUI.widgets.treeview")(gui)
end

return getModule
