require("class")

local stack = new_class()

function stack:_init()
  self.width = 6
  self.height = 13
  self.blocks = {}
  for y = 1, self.height do
    self.blocks[y] = {}
  end
end

function stack:put(block, x, y)
  self.blocks[y][x] = block
end

function stack:block_at(x, y)
  return self.blocks[y][x]
end

function stack:is_empty(x, y)
  return self.blocks[y][x] == nil
end

function stack:draw()
  for y = 1, self.height do
    for x = 1, self.width do
      local block = self.blocks[y][x]
      if block then
        block:render(x * 8, (self.height - y) * 8)
      end
    end
  end
end

return stack
