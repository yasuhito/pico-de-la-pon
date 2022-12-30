---@diagnostic disable: global-in-nil-env, lowercase-global, unbalanced-assignments, undefined-field, undefined-global, deprecated

--- @class panel
--- @field type "i" | "h" | "x" | "y" | "z" | "s" | "t" | "control" | "cnot_x" | "swap" | "g" | "?" panel type
--- @field span 1 | 2 | 3 | 4 | 5 | 6 span of the panel
--- @field height integer height of the panel
--- @field render function
--- @field replace_with function
--- @field new_panel panel
--- @field change_state function
local panel = new_class()
panel.size = 8
panel.frame_count_swap = 3
panel.frame_count_hover = 12
panel.frame_count_flash = 44
panel.frame_count_face = 24
panel.frame_count_pop_per_panel = 9
panel.sprites = {
  -- default|face|landed|match|bouncing
  red = "0|4|1,1,1,1,3,3,2,2,2,1,1,1|24,24,24,25,25,25,24,24,24,26,26,26,0,0,0,27|0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,2,2,2,2",
  yellow = "16|20|33,33,33,33,35,35,34,34,34,33,33,33|56,56,56,57,57,57,56,56,56,58,58,58,32,32,32,59|32,32,32,32,32,32,32,32,33,33,33,33,34,34,34,34,35,35,35,35,34,34,34,34",
  green = "32|36|33,33,33,33,35,35,34,34,34,33,33,33|56,56,56,57,57,57,56,56,56,58,58,58,32,32,32,59|32,32,32,32,32,32,32,32,33,33,33,33,34,34,34,34,35,35,35,35,34,34,34,34",
  purple = "48|52|49,49,49,49,51,51,50,50,50,49,49,49|12,12,12,13,13,13,12,12,12,14,14,14,48,48,48,15|48,48,48,48,48,48,48,48,49,49,49,49,50,50,50,50,51,51,51,51,50,50,50,50",
  blue = "5|9|5,5,5,5,7,7,6,6,6,5,5,5|28,28,28,29,29,29,28,28,28,30,30,30,4,4,4,31|4,4,4,4,4,4,4,4,5,5,5,5,6,6,6,6,7,7,7,7,6,6,6,6",
  dark_blue = "21|25|21,21,21,21,23,23,22,22,22,21,21,21|44,44,44,45,45,45,44,44,44,46,46,46,20,20,20,47|20,20,20,20,20,20,20,20,21,21,21,21,22,22,22,22,23,23,23,23,22,22,22,22",
  ["!"] = "37|41|37,37,37,37,39,39,38,38,38,37,37,37|60,60,60,61,61,61,60,60,60,62,62,62,36,36,36,63|36,36,36,36,36,36,36,36,37,37,37,37,38,38,38,38,39,39,39,39,38,38,38,38",
}

for key, each in pairs(panel.sprites) do
  local default, face, landed, match, bouncing = unpack(split(each, "|"))
  ---@diagnostic disable-next-line: assign-type-mismatch
  panel.sprites[key] = {
    default = default,
    face = face,
    landed = split(landed),
    match = split(match),
    bouncing = split(bouncing)
  }
end

--- @param _type "i" | "h" | "x" | "y" | "z" | "s" | "t" | "control" | "cnot_x" | "swap" | "g" | "?" panel type
--- @param _span? 1 | 2 | 3 | 4 | 5 | 6 span of the panel
--- @param _height? integer height of the panel
function panel._init(_ENV, _type, _span, _height)
  _color = _type
  type, sprite_set, span, height, _state, _fall_screen_dy = _type, sprites[_type], _span or 1, _height or 1, ":idle", 0
end

-------------------------------------------------------------------------------
-- パネルの種類と状態
-------------------------------------------------------------------------------

function panel:is_idle()
  return self._state == ":idle"
end

function panel:is_hover()
  return self._state == ":hover"
end

function panel.is_fallable(_ENV)
  return not (type == "i" or type == "?" or is_swapping(_ENV) or is_freeze(_ENV))
end

function panel:is_falling()
  return self._state == ":falling"
end

function panel.is_matchable(_ENV)
  return type ~= "_" and is_idle(_ENV)
end

-- マッチ状態である場合 true を返す
function panel:is_match()
  return self._state == ":match"
end

-- おじゃまユニタリがパネルに変化した後の硬直中
function panel:is_freeze()
  return self._state == ":freeze"
end

function panel:is_swapping()
  return self:_is_swapping_with_right() or self:_is_swapping_with_left()
end

--- @private
function panel:_is_swapping_with_left()
  return self._state == ":swapping_with_left"
end

--- @private
function panel:_is_swapping_with_right()
  return self._state == ":swapping_with_right"
end

function panel:is_empty()
  return self._color == "_" and not self:is_swapping()
end

function panel.is_single_panel(_ENV)
  return type == 'h' or type == 'x' or type == 'y' or type == 'z' or type == 's' or type == 't'
end

-------------------------------------------------------------------------------
-- パネル操作
-------------------------------------------------------------------------------

--- @param direction "left" | "right"
function panel:swap_with(direction)
  self._timer = self.frame_count_swap
  self.chain_id = nil
  self:change_state(":swapping_with_" .. direction)
end

function panel:hover()
  self._timer = self.frame_count_hover
  self:change_state(":hover")
end

function panel:fall()
  --#if assert
  assert(self:is_fallable(), "panel " .. self.type .. "(" .. self.x .. ", " .. self.y .. ")")
  --#endif

  if self:is_falling() then
    return
  end

  self:change_state(":falling")
end

function panel:match(match_time, pop_time, callback)
  self._timer = self.frame_count_flash + self.frame_count_face + match_time
  self._pop_time = pop_time
  self._match_callback = callback
  self:change_state(":match")
end

--- @param other panel
--- @param match_index integer
--- @param _chain_id string
--- @param garbage_span? integer
--- @param garbage_height? integer
function panel.replace_with(_ENV, other, match_index, _chain_id, garbage_span, garbage_height)
  new_panel, _match_index, _tick_match, chain_id, other.chain_id, _garbage_span, _garbage_height =
  other, match_index or 0, 1, _chain_id, _chain_id, garbage_span, garbage_height

  change_state(_ENV, ":match")
end

-------------------------------------------------------------------------------
-- update and render
-------------------------------------------------------------------------------

function panel.update(_ENV)
  if is_idle(_ENV) then
    if _tick_landed then
      _tick_landed = _tick_landed + 1

      if _tick_landed == 13 then
        _tick_landed = nil
      end
    end
  elseif is_swapping(_ENV) then
    if _timer > 0 then
      _timer = _timer - 1
    else
      chain_id = nil
      change_state(_ENV, ":idle")
    end
  elseif is_hover(_ENV) then
    if _timer > 0 then
      _timer = _timer - 1
    else
      chain_id = nil
      change_state(_ENV, ":idle")
    end
  elseif is_falling(_ENV) then
    -- NOP
  elseif is_match(_ENV) then
    if _timer > 0 then
      _timer = _timer - 1

      if _timer == _pop_time then
        _match_callback()
      end
    else
      change_state(_ENV, ":idle")
    end
  end
end

--- @param screen_x integer x position of the screen
--- @param screen_y integer y position of the screen
function panel:render(screen_x, screen_y)
  local shake_dx, shake_dy, swap_screen_dx, sprite = 0, 0, 0

  do
    local _ENV = self

    if _color == "_" then
      return
    end

    if is_swapping(_ENV) then
      swap_screen_dx = (frame_count_swap - _timer) * (size / frame_count_swap)
      if _is_swapping_with_left(_ENV) then
        swap_screen_dx = -swap_screen_dx
      end
    end

    -- if is_idle(_ENV) and _tick_landed then
    --   sprite = sprite_set.landed[_tick_landed]
    -- elseif (is_idle(_ENV) or is_freeze(_ENV)) and pinch then
    --   sprite = sprite_set.bouncing[tick_pinch % #sprite_set.bouncing + 1]
    -- elseif is_match(_ENV) then
    --   local sequence = sprite_set.match
    --   sprite = _tick_match <= panel_match_delay_per_panel and sequence[_tick_match] or sequence[#sequence]
    -- elseif _state == "over" then
    --   sprite = sprite_set.match[#sprite_set.match]
    -- else
    --   sprite = sprite_set.default
    -- end

    if is_match(_ENV) then
      if _timer <= _pop_time then
        return
      elseif _timer <= panel.frame_count_face then
        sprite = sprite_set.face
      else
        sprite = sprite_set.default
      end
    else
      sprite = sprite_set.default
    end
  end

  if self:is_match() and self._timer > panel.frame_count_face then
    if self._color == "red" then
      pal(8, 7)
    elseif self._color == "yellow" then
      pal(4, 7)
    elseif self._color == "green" then
      pal(3, 7)
    elseif self._color == "purple" then
      pal(2, 7)
    elseif self._color == "blue" then
      pal(12, 7)
    elseif self._color == "dark_blue" then
      pal(1, 7)
    elseif self._color == "!" then
      pal(13, 7)
      pal(7, 13)
    end
  end

  spr(sprite, screen_x + swap_screen_dx + shake_dx, screen_y + shake_dy)

  pal(1, 1)
  pal(2, 2)
  pal(3, 3)
  pal(4, 4)
  pal(7, 7)
  pal(8, 8)
  pal(12, 12)
  pal(13, 13)
end

-------------------------------------------------------------------------------
-- observer pattern
-------------------------------------------------------------------------------

--- @param observer table
function panel:attach(observer)
  self.observer = observer
end

--- @param new_state string
function panel.change_state(_ENV, new_state)
  local old_state = _state
  _state = new_state

  observer:observable_update(_ENV, old_state)
end

-------------------------------------------------------------------------------
-- debug
-------------------------------------------------------------------------------

--#if debug
local type_string = {
  red = '♥',
  yellow = '★',
  green = '●',
  purple = '◆',
  blue = '▲',
  dark_blue = '▼',
}

local state_string = {
  [":idle"] = " ",
  [":swapping_with_left"] = "<",
  [":swapping_with_right"] = ">",
  [":falling"] = "|",
  [":match"] = "*",
  freeze = "f",
}

function panel:_tostring()
  return (type_string[self.type] or self.type) .. state_string[self._state]
end

--#endif

return panel
