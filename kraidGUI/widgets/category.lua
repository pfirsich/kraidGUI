--- Test
-- @module test

function getModule(gui)
    local Category = gui.internal.class(gui.widgets.Base)

    function Category:init(params)
        self.type = "Category"

        self.position = {0, 0}
        self.text = "Category"
        self.collapsedHeight = 30
        self.inflatedHeight = 150
        self.width = 150
        self.height = self.inflatedHeight
        self.collapsed = false

        gui.widgets.Base.init(self, params)
        gui.internal.callThemeFunction(self, "init")
    end

    function Category:setCollapsed(collapsed)
        self.collapsed = collapsed
        self.height = self.collapsed and self.collapsedHeight or self.inflatedHeight
        if self.onCollapse then self:onCollapse() end
    end

    function Category:updateHeight()
        self.height = self.collapsed and self.collapsedHeight or self.inflatedHeight
    end

    function Category:setInflatedHeight(inflatedHeight)
        self.inflatedHeight = inflatedHeight
        self:updateHeight()
    end

    function Category:setCollapsedHeight(collapsedHeight)
        self.collapsedHeight = collapsedHeight
        self:updateHeight()
    end

    Category.static.setters["inflatedHeight"] = Category.setInflatedHeight
    Category.static.setters["collapsedHeight"] = Category.setCollapsedHeight
    Category.static.setters["collapsed"] = Category.setCollapsed

    return Category
end

return getModule
