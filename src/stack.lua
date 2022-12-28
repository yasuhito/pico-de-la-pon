require("class")

local panel = require("panel")
local stack = new_class()

function stack:_init(offset_x, offset_y)
  self.width = 6
  self.height = 12
  self.offset_x = offset_x or 0
  self.offset_y = offset_y or 0
  self.panels = {}
  for y = 1, self.height do
    self.panels[y] = {}
  end
end

function stack:put(panel, x, y)
  panel.x = x
  panel.y = y
  self.panels[y][x] = panel

  panel:attach(self)
end

function stack:put_random_panels()
  local all_panel_colors = { "red", "yellow", "green", "purple", "blue", "dark_blue", "!" }

  for x = 1, self.width do
    for y = 1, self.height do
      local random_panel_color = rnd(all_panel_colors)

      self:put(panel(random_panel_color), x, y)
    end
  end
end

function stack:panel_at(x, y)
  return self.panels[y][x]
end

function stack:is_empty(x, y)
  return self.panels[y][x] and self.panels[y][x]._color == "_"
end

-- パネル (x, y) と (x + 1, y) を入れ替える
function stack:swap(x, y)
  self:panel_at(x, y):swap_with("right")
  self:panel_at(x + 1, y):swap_with("left")
end

function stack:update()
  for y = 1, self.height do
    for x = 1, self.width do
      local panel = self.panels[y][x]
      if panel then
        panel:update()
      end
    end
  end

  for y = 1, self.height do
    for x = 1, self.width do
      if not self:is_empty(x, y) then
        local panel_dx0 = self.panels[y][x]
        local panel_dx1 = self.panels[y][x + 1]
        local panel_dx2 = self.panels[y][x + 2]

        if panel_dx1 and panel_dx2 then
          if panel_dx0._color == panel_dx1._color and
              panel_dx0._color == panel_dx2._color then
            self:put(panel("_"), x, y)
            self:put(panel("_"), x + 1, y)
            self:put(panel("_"), x + 2, y)
          end
        end
      end
    end
  end
end

function stack:draw()
  draw_rounded_box(self.offset_x, self.offset_y, self.offset_x + self.width * 8 + 4, self.offset_y + self.height * 8 + 3
    , 12, 12) -- 枠 (空色)
  draw_rounded_box(self.offset_x + 1, self.offset_y + 1, self.offset_x + self.width * 8 + 3,
    self.offset_y + self.height * 8 + 2, 1, 0) -- 枠 (暗い青)

  for y = 1, self.height do
    for x = 1, self.width do
      local panel = self.panels[y][x]
      if panel then
        -- 枠線の太さ (1px) + マージン (1px) で x に +3 する
        panel:render(self.offset_x + 3 + (x - 1) * 8, self.offset_y + 3 + (self.height - y) * 8)
      end
    end
  end
end

-- ボード内にあるいずれかのパネルが更新された場合に呼ばれる。
-- _changed フラグを立て各種キャッシュも更新・クリアする。
function stack:observable_update(panel, old_state)
  local x, y = panel.x, panel.y

  if old_state == "swapping_with_right" and panel:is_idle() then
    local new_x = x + 1
    local right_panel = self.panels[y][new_x]

    self:put(panel, new_x, y)
    self:put(right_panel, x, y)

    right_panel:change_state("idle")
  end
end

function draw_rounded_box(x0, y0, x1, y1, border_color, fill_color)
  line(x0 + 1, y0, x1 - 1, y0, border_color)
  line(x1, y0 + 1, x1, y1 - 1, border_color)
  line(x1 - 1, y1, x0 + 1, y1, border_color)
  line(x0, y1 - 1, x0, y0 + 1, border_color)

  if fill_color then
    rectfill(x0 + 1, y0 + 1, x1 - 1, y1 - 1, fill_color)
  end
end

return stack
