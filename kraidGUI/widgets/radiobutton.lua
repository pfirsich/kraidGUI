function module(gui)
    local Radiobutton = gui.internal.class(gui.widgets.Base)

    function Radiobutton:init(params)
        self.type = "Radiobutton"

        self.position = {0, 0}
        self.width = 20
        self.height = 20
        self.checked = false

        gui.widgets.Base.init(self, params)
        gui.widgets.helpers.callThemeFunction(self, "init")
    end

    function Radiobutton:onClicked()
        self:setChecked(not self.checked)
    end

    function Radiobutton:setChecked(checked) -- a radio button can only be checked, not unchecked (because then no button might be checked)
        if checked then
            self.checked = checked
            if self.parent then -- because parent might not be initialized when
                for _, child in ipairs(self.parent.children) do
        			if child ~= self and child.type == "Radiobutton" then
        				child.checked = false
        			end
        		end
            end
            if self.onCheck then self:onCheck(checked) end
        end

    end

    Radiobutton.static.setters["checked"] = Radiobutton.setChecked

    return Radiobutton
end

return module
