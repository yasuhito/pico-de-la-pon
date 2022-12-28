---@diagnostic disable: lowercase-global

local stack_class = require("stack")
local player_cursor_class = require("player_cursor")

local stack
local player_cursor

function _init()
  stack = stack_class()
  stack:put_random_blocks()
  player_cursor = player_cursor_class()
end

function _update60()
  player_cursor:update()
end

function _draw()
  cls()

  stack:draw()
  player_cursor:draw(3, 3)
end
