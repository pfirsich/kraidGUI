function module(gui)
    gui.widgets.Base = require("kraidGUI.widgets.base")(gui)
    gui.widgets.Window = require("kraidGUI.widgets.window")(gui)
    gui.widgets.Label = require("kraidGUI.widgets.label")(gui)
end

return module
