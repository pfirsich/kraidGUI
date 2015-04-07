function module(gui)
    local Category = gui.internal.class(gui.widgets.Base)

    function Category:init(params)
        self.type = "Category"

        self.position = {0, 0}
        self.text = "Category"
        self.collapsedHeight = 30
        self.inflatedHeight = 150
        self.width = 150
        params.collapsed = params.collapsed ~= nil and false

        gui.widgets.Base.init(self, params)
        gui.widgets.helpers.callThemeFunction(self, "init")
    end

    function Category:setCollapsed(collapsed)
        print("set", collapsed)
        self.collapsed = collapsed
        self.height = self.collapsed and self.collapsedHeight or self.inflatedHeight
        if self.onCollapse then self:onCollapse() end
    end

    Category.static.setters["collapsed"] = Category.setCollapsed

    return Category
end

return module
