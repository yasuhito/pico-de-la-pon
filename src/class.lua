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
