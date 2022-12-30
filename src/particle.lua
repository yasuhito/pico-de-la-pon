---@diagnostic disable: lowercase-global, global-in-nil-env, deprecated

function ceil_rnd(num)
  return flr(rnd(num)) + 1
end

local effect_set = new_class()

function effect_set:_init()
  self.all = {}
end

function effect_set:_add(f)
  local _ENV = setmetatable({}, { __index = _ENV })
  f(_ENV)
  add(self.all, _ENV)
end

function effect_set:update_all()
  foreach(self.all, function(each)
    self._update(each, self)
  end)
end

function effect_set:render_all()
  foreach(self.all, function(each)
    self._render(each, self)
  end)
end

local particle_class = derived_class(effect_set)

-- singleton
particle = particle_class()

function particle:create_chunk(x, y, frame_count_delay, data)
  for _, each in pairs(split(data, "|")) do
    self:_create(x, y, frame_count_delay, unpack(split(each)))
  end
end

function particle:_create(x, y, frame_count_delay, radius, end_radius, __color, __color_fade, dx, dy, ddx, ddy, max_tick)
  self:_add(function(_ENV)
    _x, _y, _frame_count_delay, _radius, _end_radius, _color, _color_fade, _tick, _max_tick, _ddx, _ddy =
    x, y, frame_count_delay, radius, end_radius, __color, __color_fade, 0, max_tick + rnd(10), ddx, ddy

    _dx = dx == "random" and rnd(1.2) * .8 or dx
    _dy = dy == "random" and rnd(1.2) * .8 or dy

    if dx == "random" or dy == "random" then
      -- move to the left
      if ceil_rnd(2) == 1 then
        _dx, _ddx = _dx * -1, _ddx * -1
      end

      -- move upwards
      if ceil_rnd(2) == 1 then
        _dy, _ddy = _dy * -1, _ddy * -1
      end
    end
  end)
end

function particle._update(_ENV, self)
  if _frame_count_delay > 0 then
    _frame_count_delay = _frame_count_delay - 1
    return
  end

  if _tick > _max_tick then
    del(self.all, _ENV)
  end
  if _tick > _max_tick * 0.5 then
    _color = _color_fade
    _radius = _end_radius
  end

  _x, _y, _dx, _dy, _tick = _x + _dx, _y + _dy, _dx + _ddx, _dy + _ddy, _tick + 1
end

function particle._render(_ENV)
  circfill(_x, _y, _radius, _color)
end
