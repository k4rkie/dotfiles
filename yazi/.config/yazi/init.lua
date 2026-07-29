require("full-border"):setup {
  type = ui.Border.PLAIN,
}
require("no-status"):setup()

-- Hide the header bar (path line at the top) and give its row to the content
-- Header.redraw = function() return {} end
--
-- local old_root_layout = Root.layout
-- Root.layout = function(self, ...)
--   old_root_layout(self, ...)
--   local c = self._chunks[3]
--   self._chunks[3] = ui.Rect { x = c.x, y = c.y - 1, w = c.w, h = c.h + 1 }
-- end
