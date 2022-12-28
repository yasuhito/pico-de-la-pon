---@diagnostic disable: lowercase-global

local stack_class = require("stack")
local block = require("block")

local stack

function _init()
  stack = stack_class()

  for x = 1, stack.width do
    for y = 1, stack.height do
      stack:put(block("red"), x, y)
    end
  end
end

function _update60()
end

function _draw()
  cls()

  stack:draw()
end
