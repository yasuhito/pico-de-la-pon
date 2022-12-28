require("src/class")

local stack = new_class()

function stack:_init()
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

return stack
