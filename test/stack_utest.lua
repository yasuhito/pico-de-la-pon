---@diagnostic disable: undefined-global

require("engine/test/bustedhelper")

local stack_class = require("src/stack")
local panel = require("panel")

describe("stack", function()
  describe("put", function()
    it("1, 1 に red パネルを置く", function()
      local stack = stack_class()

      stack:put(panel("red"), 1, 1)

      assert.is_false(stack:is_empty(1, 1))
      assert.are_equal("red", stack:panel_at(1, 1).panel_type)
    end)
  end)
end)
