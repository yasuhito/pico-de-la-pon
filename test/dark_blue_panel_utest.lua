require("engine/test/bustedhelper")

local panel = require("panel")

describe('dark_blue_panel', function()
  local p

  before_each(function()
    p = panel("dark_blue")
  end)

  describe("type", function()
    it("should return 'dark_blue'", function()
      assert.is_true(p.type == "dark_blue")
    end)
  end)

  describe("state", function()
    describe("is_idle", function()
      it("should return true", function()
        assert.is_true(p:is_idle())
      end)
    end)

    describe("is_swapping", function()
      it("should return false", function()
        assert.is_false(p:is_swapping())
      end)
    end)

    describe("is_falling", function()
      it("should return false", function()
        assert.is_false(p:is_falling())
      end)
    end)

    describe("is_match", function()
      it("should return false", function()
        assert.is_false(p:is_match())
      end)
    end)
  end)

  describe("is_empty", function()
    it("should return false", function()
      assert.is_false(p:is_empty())
    end)
  end)

  describe("is_reducible", function()
    it("should return true", function()
      assert.is_true(p:is_reducible())
    end)
  end)

  describe("fall", function()
    it("should raise", function()
      assert.error(function() p:fall() end)
    end)
  end)

  describe("stringify", function()
    it("should return '▼ '", function()
      assert.are.equals("▼ ", stringify(p))
    end)
  end)
end)
