function module(gui)
    gui.widgets.Base = require("kraidGUI.widgets.base")(gui)
    gui.widgets.Label = require("kraidGUI.widgets.label")(gui)
    gui.widgets.Button = require("kraidGUI.widgets.button")(gui)
    gui.widgets.Window = require("kraidGUI.widgets.window")(gui)
end

return module
