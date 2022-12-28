require("engine/test/bustedhelper")

local stack_class = require("src/stack")
local panel = require("panel")

describe("stack", function()
  local stack

  before_each(function()
    stack = stack_class()
  end)

  describe("update", function()
    it("下が空のパネルを落とす", function()
      stack:put(panel("red"), 1, 2)

      stack:update()

      assert.is_true(stack:is_empty(1, 2))
      assert.is_false(stack:is_empty(1, 1))
    end)
  end)
end)
