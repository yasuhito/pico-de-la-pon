require("engine/test/bustedhelper")

local stack_class = require("src/stack")
local panel = require("panel")

describe("stack", function()
  local stack

  before_each(function()
    stack = stack_class()
  end)

  describe("update", function()
    it("横に 3 つ並んだ同じパネルをマッチさせる", function()
      stack:put(panel("red"), 1, 1)
      stack:put(panel("red"), 2, 1)
      stack:put(panel("red"), 3, 1)

      stack:update()

      assert.is_true(stack:panel_at(1, 1):is_match())
      assert.is_true(stack:panel_at(2, 1):is_match())
      assert.is_true(stack:panel_at(3, 1):is_match())
    end)

    it("縦に 3 つ並んだ同じパネルをマッチさせる", function()
      stack:put(panel("red"), 1, 1)
      stack:put(panel("red"), 1, 2)
      stack:put(panel("red"), 1, 3)

      stack:update()

      assert.is_true(stack:panel_at(1, 1):is_match())
      assert.is_true(stack:panel_at(1, 2):is_match())
      assert.is_true(stack:panel_at(1, 3):is_match())
    end)
  end)
end)
