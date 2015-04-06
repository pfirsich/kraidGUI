function module(gui)
    local Checkbox = gui.internal.class(gui.widgets.Base)

    function Checkbox:init(params)
        self.type = "Checkbox"

        self.position = {0, 0}
        self.width = 20
        self.height = 20
        self.checked = true

        gui.widgets.Base.init(self, params)
        gui.widgets.helpers.callThemeFunction(self, "init")
    end

    function Checkbox:onClicked()
        self:setChecked(not self.checked)
    end

    function Checkbox:setChecked(checked)
        self.checked = checked
        if self.onCheck then self:onCheck(checked) end
    end

    Checkbox.static.setters["checked"] = Checkbox.setChecked

    return Checkbox
end

return module
