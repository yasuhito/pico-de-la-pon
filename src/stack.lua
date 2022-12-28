require("class")

local block = require("block")
local stack = new_class()

function stack:_init()
  self.width = 6
  self.height = 12
  self.offset_x = 0
  self.offset_y = 0
  self.blocks = {}
  for y = 1, self.height do
    self.blocks[y] = {}
  end
end

function stack:put(block, x, y)
  self.blocks[y][x] = block
end

function stack:put_random_blocks()
  local all_block_colors = { "red", "yellow", "green", "purple", "blue", "dark_blue", "!" }

  for x = 1, self.width do
    for y = 1, self.height do
      local random_block_color = rnd(all_block_colors)

      self:put(block(random_block_color), x, y)
    end
  end
end

function stack:block_at(x, y)
  return self.blocks[y][x]
end

function stack:is_empty(x, y)
  return self.blocks[y][x] == nil
end

function stack:draw()
  draw_rounded_box(self.offset_x, self.offset_y, self.offset_x + self.width * 8 + 4, self.offset_y + self.height * 8 + 3, 12, 12) -- 枠 (空色)
  draw_rounded_box(self.offset_x + 1, self.offset_y + 1, self.offset_x + self.width * 8 + 3, self.offset_y + self.height * 8 + 2, 1, 0) -- 枠 (暗い青)

  for y = 1, self.height do
    for x = 1, self.width do
      local block = self.blocks[y][x]
      if block then
        -- 枠線の太さ (1px) + マージン (1px) で x に +3 する
        block:render(self.offset_x + 3 + (x - 1) * 8, self.offset_y + 3 + (self.height - y) * 8)
      end
    end
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
