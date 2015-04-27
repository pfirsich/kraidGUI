--- Test
-- @module test

function getModule(gui)
    local Checkbox = gui.internal.class(gui.widgets.Base)

    function Checkbox:init(params)
        self.type = "Checkbox"

        self.position = {0, 0}
        self.width = 20
        self.height = 20
        self.checked = false

        gui.widgets.Base.init(self, params)
        gui.internal.callThemeFunction(self, "init")
    end

    function Checkbox:onMouseDown(x, y, button)
        gui.widgets.Base.onMouseDown(self, x, y, button)
        self:setChecked(not self.checked)
    end

    function Checkbox:setChecked(checked)
        self.checked = checked
        if self.onChecked then self:onChecked(checked) end
    end

    Checkbox.static.setters["checked"] = Checkbox.setChecked

    return Checkbox
end

return getModule
