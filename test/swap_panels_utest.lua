require("engine/test/bustedhelper")

local stack_class = require("src/stack")
local panel = require("panel")

describe("stack", function()
  local stack

  before_each(function()
    stack = stack_class()
  end)

  describe("swap", function()
    it("パネルを入れ替える", function()
      local left_panel = panel("red")
      local right_panel = panel("blue")

      stack:put(left_panel, 1, 1)
      stack:put(right_panel, 2, 1)

      stack:swap(1, 1)

      -- stack:swap() でパネルの状態が swapping になる
      assert.is_true(left_panel:is_swapping())
      assert.is_true(right_panel:is_swapping())

      for i = 1, 3 do
        stack:update()

        -- 以降 panel.swap_frame_count フレームの間、
        -- パネルの状態は "swapping" になる
        assert.is_true(left_panel:is_swapping())
        assert.is_true(right_panel:is_swapping())
      end

      stack:update()

      -- パネルが入れ替わる
      assert.are_equal("blue", stack:panel_at(1, 1)._color)
      assert.are_equal("red", stack:panel_at(2, 1)._color)

      -- swap が終わるとパネルは idle 状態になる
      assert.is_true(left_panel:is_idle())
      assert.is_true(right_panel:is_idle())
    end)
  end)
end)
