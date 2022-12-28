require("engine/test/bustedhelper")

local panel = require("panel")

describe('yellow_panel', function()
  local b

  before_each(function()
    b = panel("yellow")
  end)

  describe("type", function()
    it("should return 'yellow'", function()
      assert.is_true(b.type == "yellow")
    end)
  end)

  describe("state", function()
    describe("is_idle", function()
      it("should return true", function()
        assert.is_true(b:is_idle())
      end)
    end)

    describe("is_swapping", function()
      it("should return false", function()
        assert.is_false(b:is_swapping())
      end)
    end)

    describe("is_falling", function()
      it("should return false", function()
        assert.is_false(b:is_falling())
      end)
    end)

    describe("is_match", function()
      it("should return false", function()
        assert.is_false(b:is_match())
      end)
    end)
  end)

  describe("is_empty", function()
    it("should return false", function()
      assert.is_false(b:is_empty())
    end)
  end)

  describe("is_reducible", function()
    it("should return true", function()
      assert.is_true(b:is_reducible())
    end)
  end)

  describe("fall", function()
    it("should raise", function()
      assert.error(function() b:fall() end)
    end)
  end)

  describe("stringify", function()
    it("should return '★ '", function()
      assert.are.equals("★ ", stringify(b))
    end)
  end)
end)
