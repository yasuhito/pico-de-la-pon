---@diagnostic disable: lowercase-global

local function new(cls, ...)
  local self = setmetatable({}, cls)
  self:_init(...)
  return self
end

function new_class()
  local class = {}
  class.__index = class

  setmetatable(class, {
    __index = _ENV,
    __call = new
  })

  return class
end

function derived_class(base_class)
  local class = {}
  class.__index = class

  setmetatable(class, {
    __index = base_class,
    __call = new
  })

  return class
end
