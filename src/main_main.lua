---@diagnostic disable: lowercase-global

local stack_class = require("stack")
local player_class = require("player")
local player_cursor_class = require("player_cursor")

local stack
local player
local player_cursor

function _init()
  stack = stack_class()
  stack:put_random_blocks()
  player = player_class()
  player_cursor = player_cursor_class()
end

function _update60()
  player:update()

  if player.left then
    player_cursor:move_left()
  end
  if player.right then
    player_cursor:move_right(stack.width)
  end
  if player.up then
    player_cursor:move_up(stack.height)
  end
  if player.down then
     player_cursor:move_down()
  end

  player_cursor:update()
end

function _draw()
  cls()

  stack:draw()
  player_cursor:draw((player_cursor.x - 1) * 8 + 3, (stack.height - player_cursor.y) * 8 + 3)
end
