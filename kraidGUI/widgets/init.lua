function module(gui)
    gui.widgets.Base = require("kraidGUI.widgets.base")(gui)
    gui.widgets.Window = require("kraidGUI.widgets.window")(gui)
end

return module
