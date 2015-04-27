--- Test
-- @module test

function getModule(gui)
    local TreeView = gui.internal.class(gui.widgets.Base)

    function TreeView:init(params)
        self.type = "TreeView"

        self.position = {0, 0}
        self.width = 100
        self.height = 20
        self.multiSelect = true -- if this is false self.selected will still be a table

        -- tree elements are tables, you must not use (as in: do something else with it) these keys: text, children, collapsed, id, depth
        -- also you must not write the latter two as they are computed by setTree
        self.tree = {}
        self.linearizedTree = {}
        self.selected = {}

        gui.widgets.Base.init(self, params)
        gui.internal.callThemeFunction(self, "init")
    end

    -- linearized in a depth-first manner. the output therefore resembles the rendered, fully uncollapsed tree read from top to bottom
    function TreeView:linearizeTree(list, node, depth)
        node = node or self.tree
        depth = depth or -1

        if node ~= self.tree then
            list[#list+1] = node
            node.depth = depth
            node.id = #list
        end

        if node.children then
            for i = 1, #node.children do
                self:linearizeTree(list, node.children[i], depth + 1)
            end
        end
    end

    function TreeView:updateTree()
        self.linearizedTree = {}
        self:linearizeTree(self.linearizedTree)
    end

    function TreeView:setTree(tree)
        self.tree = tree
        self.selected = {}
        self:updateTree()
    end

    TreeView.static.setters["tree"] = TreeView.setTree

    return TreeView
end

return getModule
