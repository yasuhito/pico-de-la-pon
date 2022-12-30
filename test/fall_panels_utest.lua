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

      -- 下が空白のパネルは状態が hover に遷移する
      stack:update()

      assert.is_true(stack:panel_at(1, 2):is_hover())

      -- hover 状態は 12 フレームほど続く
      for i = 1, 12 do
        stack:update()
      end

      assert.is_true(stack:panel_at(1, 2):is_hover())

      -- 次の 1 フレームで状態が falling になり、1 マス落下する
      stack:update()

      assert.is_true(stack:panel_at(1, 1):is_falling())

      -- これ以上落下できなくなると、状態が idle に遷移する
      stack:update()

      assert.is_true(stack:panel_at(1, 1):is_idle())
    end)

    it("2 つのパネルをまとめて落とす", function()
      stack:put(panel("red"), 1, 2)
      stack:put(panel("red"), 1, 3)

      -- 下が空白のパネルは状態が hover に遷移する
      stack:update()

      assert.is_true(stack:panel_at(1, 2):is_hover())
      assert.is_true(stack:panel_at(1, 3):is_hover())

      -- hover 状態は 12 フレームほど続く
      for i = 1, 12 do
        stack:update()
      end

      assert.is_true(stack:panel_at(1, 2):is_hover())
      assert.is_true(stack:panel_at(1, 3):is_hover())

      -- 次の 1 フレームで状態が falling になり、1 マス落下する
      stack:update()

      assert.is_true(stack:panel_at(1, 1):is_falling())
      assert.is_true(stack:panel_at(1, 2):is_falling())

      -- これ以上落下できなくなると、状態が idle に遷移する
      stack:update()

      assert.is_true(stack:panel_at(1, 1):is_idle())
      assert.is_true(stack:panel_at(1, 2):is_idle())
    end)

    it("重なった 2 つのパネルの上を左にずらして落とす", function()
      stack:put(panel("red"), 2, 1)
      stack:put(panel("red"), 2, 2)

      stack:swap(1, 2)

      stack:update()
      stack:update()
      stack:update()
      stack:update()

      -- swap 完了

      for i = 1, 12 do
        stack:update()
      end

      -- hover 完了

      stack:update()

      assert.are_equal("red", stack:panel_at(1, 1).panel_type)
    end)
  end)
end)
