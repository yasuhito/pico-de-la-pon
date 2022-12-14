---@diagnostic disable: lowercase-global

require("class")
require("particle")

local stack_class = require("stack")
local player_class = require("player")
local player_cursor_class = require("player_cursor")

local player = player_class()
local player_cursor = player_cursor_class()
local stack = stack_class(player_cursor, 0, 20)

function _init()
  pal(({ [0] = 0, 128 + 12, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 }), 1)
  stack:put_random_panels()
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
  particle:update_all()
end

function _draw()
  cls()

  stack:draw()
  player_cursor:draw(stack:screen_x(player_cursor.x), stack:screen_y(player_cursor.y))
  particle:render_all()
end
