require("class")
require("helpers")
require("particle")

local panel_class = require("panel")

--- @class stack
local stack = new_class()

stack.frame_count_rise = 50
-- stack.frame_count_rise = 942

--- @param offset_x integer
--- @param offset_y integer
function stack:_init(cursor, offset_x, offset_y)
  self.cursor = cursor
  self.width = 6
  self.height = 12

  -- This variable indicates how far below the top of the play
  -- area the top row of panels actually is.
  -- This variable being decremented causes the stack to rise.
  -- During the automatic rising routine, if this variable is 0,
  -- it's reset to 15, all the panels are moved up one row,
  -- and a new row is generated at the bottom.
  -- Only when the displacement is 0 are all 12 rows "in play."
  self.displacement = 16

  self.offset_x = offset_x or 0
  self.offset_y = offset_y or 0
  self.panels = {}
  for y = 0, self.height do
    self.panels[y] = {}
    for x = 1, self.width do
      self:put(panel_class("_"), x, y)
    end
  end

  self.rise_timer = stack.frame_count_rise
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
    for y = 0, self.height do
      local random_panel_color = rnd(all_panel_colors)
      self:put(panel_class(random_panel_color), x, y)
    end
  end
end

function stack:panel_at(x, y)
  return self.panels[y][x]
end

function stack:is_empty(x, y)
  return self.panels[y][x].panel_type == "_"
end

-- パネル (x, y) と (x + 1, y) を入れ替える
function stack:swap(x, y)
  local left_panel, right_panel = self:panel_at(x, y), self:panel_at(x + 1, y)

  if not left_panel:is_idle() or not right_panel:is_idle() then
    return
  end

  left_panel:swap_with("right")
  right_panel:swap_with("left")
end

function stack:update()
  self.rise_timer = self.rise_timer - 1
  if self.rise_timer <= 0 then
    self.displacement = self.displacement - 1
    if self.displacement == 0 then
      self:new_row()
    end
    self.rise_timer = self.rise_timer + stack.frame_count_rise
  end

  -- すべてのパネルをアップデート
  for y = 0, self.height do
    for x = 1, self.width do
      self.panels[y][x]:update()
    end
  end

  -- 水平・垂直方向にマッチを探す
  for y = #self.panels, 1, -1 do
    for x = self.width, 1, -1 do
      local panel_xy = self:panel_at(x, y)

      if panel_xy:is_matchable() then
        -- x, y のパネルを起点として、3 以上同じ色のパネルが続けばマッチする
        -- dx, dy はそれぞれ x, y との差分を表し、dx = 0, dy = 0 のとき起点のパネルを指す
        local dx = 0
        local dy = 0

        -- 水平方向のマッチを探す
        -- dx = -1, -2, ... のように左向きにマッチを調べる
        while 0 < x + dx - 1 and
            self:panel_at(x + dx - 1, y):is_matchable() and
            self:panel_at(x + dx - 1, y).panel_type == panel_xy.panel_type do
          dx = dx - 1
        end

        -- 水平に 3 つ以上並んでいる
        if dx < -1 then
          for _dx = 0, dx, -1 do
            self:panel_at(x + _dx, y):match(
              panel_class.frame_count_pop_per_panel * -dx,
              panel_class.frame_count_pop_per_panel * (_dx - dx),
              self:match_callback(x, y, _dx, nil)
            )
          end
        end

        -- 垂直方向のマッチを探す
        -- dy = -1, -2, ... のように下向きにマッチを調べる
        while 0 < y + dy - 1 and
            self:panel_at(x, y + dy - 1):is_matchable() and
            self:panel_at(x, y + dy - 1).panel_type == panel_xy.panel_type do
          dy = dy - 1
        end

        -- 垂直に 3 つ以上並んでいる
        if dy < -1 then
          for _dy = 0, dy, -1 do
            self:panel_at(x, y + _dy):match(
              panel_class.frame_count_pop_per_panel * -dy,
              panel_class.frame_count_pop_per_panel * (_dy - dy),
              self:match_callback(x, y, nil, _dy)
            )
          end
        end
      end
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
          panel.timer = 12
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
        panel.timer = panel_below.timer
      end

      ::continue::
    end
  end
end

function stack:new_row()
  -- move cursor up
  self.cursor:move_up(self.height)

  -- move panels up
  for row = #self.panels + 1, 1, -1 do
    self.panels[row] = self.panels[row - 1]
    for x = 1, self.width do
      self.panels[row][x].y = row
    end
  end
  self.panels[0] = {}

  local all_panel_colors = { "red", "yellow", "green", "purple", "blue", "dark_blue", "!" }

  for x = 1, self.width do
    local random_panel_color = rnd(all_panel_colors)
    self:put(panel_class(random_panel_color), x, 0)
  end

  self.displacement = 16
end

function stack:match_callback(x, y, dx, dy)
  return function()
    particle:create_chunk(
      self:screen_x(x + (dx or 0)) + 3,
      self:screen_y(y + (dy or 0)) + 3,
      "2,1,7,7,-1,-1,0.05,0.05,16|2,1,7,7,1,-1,-0.05,0.05,16|2,1,7,7,-1,1,0.05,-0.05,16|2,1,7,7,1,1,-0.05,-0.05,16"
    )
  end
end

function stack:draw()
  -- すべてのパネルを描画
  for y = 0, self.height do
    for x = 1, self.width do
      self.panels[y][x]:render(self:screen_x(x), self:screen_y(y))
    end
  end

  -- 最下段のパネルにマスクをかける
  for x = 1, self.width do
    spr(10, self:screen_x(x), self:screen_y(0))
  end

  -- 上部のマスク
  rectfill(
    self.offset_x,
    0,
    self.offset_x + self.width * 8 + 4,
    self.offset_y - 1,
    0
  )

  -- 外側の枠を描画
  draw_rounded_box(
    self.offset_x,
    self.offset_y,
    self.offset_x + self.width * 8 + 4,
    self.offset_y + self.height * 8 + 4,
    12
  )
  rect(
    self.offset_x + 1,
    self.offset_y + 1,
    self.offset_x + self.width * 8 + 3,
    self.offset_y + self.height * 8 + 3,
    12
  )

  -- 内側の枠を描画
  draw_rounded_box(
    self.offset_x + 1,
    self.offset_y + 1,
    self.offset_x + self.width * 8 + 3,
    self.offset_y + self.height * 8 + 3,
    1
  )

  -- 上部のマスク
  rectfill(
    self.offset_x,
    self.offset_y + self.height * 8 + 5,
    self.offset_x + self.width * 8 + 4,
    127,
    0
  )
end

-- パネルの x 座標をスクリーン上の x 座標に変換
function stack:screen_x(panel_x)
  return self.offset_x + 3 + (panel_x - 1) * 8
end

-- パネルの y 座標をスクリーン上の y 座標に変換
function stack:screen_y(panel_y)
  return self.offset_y + 3 + (self.height - panel_y - 1) * 8 + self.displacement / 2
end

-- ボード内にあるいずれかのパネルが更新された場合に呼ばれる。
-- _changed フラグを立て各種キャッシュも更新・クリアする。
function stack:observable_update(panel, old_state)
  local x, y = panel.x, panel.y

  -- printh(panel.panel_type .. " " .. "x, y = " .. x .. ", " .. y)
  -- printh(panel.panel_type .. " " .. old_state .. " -> " .. panel._state)

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
  if old_state == ":matched" then
    self:put(panel_class("_"), x, y)
  end
end

return stack
