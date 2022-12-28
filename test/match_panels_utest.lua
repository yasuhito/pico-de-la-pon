require("engine/test/bustedhelper")

local stack_class = require("src/stack")
local panel = require("panel")

describe("stack", function()
  local stack

  before_each(function()
    stack = stack_class()
  end)

  describe("update", function()
    it("横に 3 つ並んだ同じパネルを消す", function()
      stack:put(panel("red"), 1, 1)
      stack:put(panel("red"), 2, 1)
      stack:put(panel("red"), 3, 1)

      stack:update()

      assert.is_true(stack:is_empty(1, 1))
    end)
  end)
end)
