require("class")

local panel_class = require("panel")
local stack = new_class()

function stack:_init(offset_x, offset_y)
  self.width = 6
  self.height = 12
  self.offset_x = offset_x or 0
  self.offset_y = offset_y or 0
  self.panels = {}
  for y = 1, self.height do
    self.panels[y] = {}
    for x = 1, self.width do
      self:put(panel_class("_"), x, y)
    end
  end
end

function stack:put(panel, x, y)
  panel.x = x
  panel.y = y
  self.panels[y][x] = panel

  -- printh("PUT " .. x .. ", " .. y .. " = " .. panel._color)

  panel:attach(self)
end

function stack:put_random_panels()
  local all_panel_colors = { "red", "yellow", "green", "purple", "blue", "dark_blue", "!" }

  for x = 1, self.width do
    for y = 1, self.height do
      local random_panel_color = rnd(all_panel_colors)

      self:put(panel_class(random_panel_color), x, y)
    end
  end
end

function stack:panel_at(x, y)
  return self.panels[y][x]
end

function stack:is_empty(x, y)
  return self.panels[y][x]._color == "_"
end

-- パネル (x, y) と (x + 1, y) を入れ替える
function stack:swap(x, y)
  self:panel_at(x, y):swap_with("right")
  self:panel_at(x + 1, y):swap_with("left")
end

function stack:update()
  -- すべてのパネルをアップデート
  for y = 1, self.height do
    for x = 1, self.width do
      self.panels[y][x]:update()
    end
  end

  -- マッチしたものを消す
  for y = 1, self.height do
    for x = 1, self.width do
      local panel = self.panels[y][x]

      if panel:is_empty() or not panel:is_idle() then
        goto continue
      end

      if x + 2 <= self.width then
        local panel_dx1 = self.panels[y][x + 1]
        local panel_dx2 = self.panels[y][x + 2]

        if not panel_dx1:is_idle() or not panel_dx2:is_idle() then
          goto continue
        end

        if panel._color == panel_dx1._color and
            panel._color == panel_dx2._color then
          panel:match()
          panel_dx1:match()
          panel_dx2:match()
        end
      end

      if y + 2 <= self.height then
        local panel_dy1 = self.panels[y + 1][x]
        local panel_dy2 = self.panels[y + 2][x]

        if not panel_dy1:is_idle() or not panel_dy2:is_idle() then
          goto continue
        end

        if panel._color == panel_dy1._color and
            panel._color == panel_dy2._color then
          panel:match()
          panel_dy1:match()
          panel_dy2:match()
        end
      end

      ::continue::
    end
  end

  -- 落下中のパネルを下に落とす
  -- それ以上落とせない場合、(とりあえず) idle 状態に遷移
  for y = 1, self.height do
    for x = 1, self.width do
      local panel = self.panels[y][x]

      if panel:is_falling() then
        if y > 1 and self:panel_at(x, y - 1):is_empty() then
          self:put(panel, x, y - 1)
          self:put(panel_class("_"), x, y)
        else
          -- 着地
          panel:change_state(":idle")
        end
      end
    end
  end

  -- 下が空のパネルはホバー状態にする
  for y = 2, self.height do
    for x = 1, self.width do
      local panel = self.panels[y][x]

      if panel:is_empty() or
         panel:is_swapping() or
         panel:is_hover() or
         panel:is_falling() then
        goto continue
      end

      local panel_below = self.panels[y - 1][x]

      if panel_below:is_empty() then
        panel:hover()
      end
      if panel_below:is_hover() then
        panel:hover()
        panel._timer = panel_below._timer
      end

      ::continue::
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

  -- printh(panel._color .. " " .. "x, y = " .. x .. ", " .. y)
  -- printh(panel._color .. " " .. old_state .. " -> " .. panel._state)

  -- swap が完了
  if old_state == ":swapping_with_right" and panel:is_idle() then
    local new_x = x + 1
    local right_panel = self.panels[y][new_x]

    self:put(panel, new_x, y)
    self:put(right_panel, x, y)

    right_panel:change_state(":idle")
  end

  -- hover が完了して下のパネルが空または falling の場合、
  -- パネルの状態を ":falling" にする
  if old_state == ":hover" and
      (self:panel_at(x, y - 1):is_empty() or self:panel_at(x, y - 1):is_falling()) then
    panel:fall()
  end

  -- flash が終わったパネルを消す
  if old_state == ":match" then
    self:put(panel_class("_"), x, y)
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
