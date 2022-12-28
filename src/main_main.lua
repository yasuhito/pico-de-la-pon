---@diagnostic disable: lowercase-global

local stack_class = require("stack")
local stack

function _init()
  stack = stack_class()
  stack:put_random_blocks()
end

function _update60()
end

function _draw()
  cls()

  stack:draw()
end
