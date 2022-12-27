require("engine/test/bustedhelper")

local block = require("src/block")

describe('blue_block', function()
  local b

  before_each(function()
    b = block("blue")
  end)

  describe("type", function()
    it("should return 'blue'", function()
      assert.is_true(b.type == "blue")
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
    it("should return '▲ '", function()
      assert.are.equals("▲ ", stringify(b))
    end)
  end)
end)
