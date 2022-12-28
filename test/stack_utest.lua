---@diagnostic disable: undefined-global

require("engine/test/bustedhelper")

local stack_class = require("src/stack")
local block = require("src/block")

describe("stack", function()
  describe("put", function()
    it("1, 1 に red ブロックを置く", function()
      local stack = stack_class()

      stack:put(block("red"), 1, 1)

      assert.is_false(stack:is_empty(1, 1))
      assert.are_equal("red", stack:block_at(1, 1).color)
    end)
  end)
end)
