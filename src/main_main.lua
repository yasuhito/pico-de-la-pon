---@diagnostic disable: lowercase-global

local stack_class = require("stack")
local player_class = require("player")
local player_cursor_class = require("player_cursor")

local stack
local player
local player_cursor

function _init()
  stack = stack_class(0, 20)
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
  if player.x then
     stack:swap(player_cursor.x, player_cursor.y)
  end

  stack:update()
  player_cursor:update()
end

function _draw()
  cls()

  stack:draw()
  player_cursor:draw((player_cursor.x - 1) * 8 + 3, stack.offset_y + (stack.height - player_cursor.y) * 8 + 3)
end
