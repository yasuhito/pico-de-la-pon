local stack_class = require("stack")
local block = require("block")

local stack

function _init()
  stack = stack_class()
  stack:put(block("red"), 1, 1)
end

function _update60()
end

function _draw()
  cls()

  stack:draw()
end
