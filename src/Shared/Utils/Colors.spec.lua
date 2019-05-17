local colors = require(script.Parent.Colors)

local PERCENT = 10
local TEST_COLOR = Color3.fromRGB(200, 200, 200)

-- Compares two colors to see if one is brighter than the other
local function isBrighter(c1, c2)
	local h1, s1, v1 = Color3.toHSV(c1)
	local h2, s2, v2 = Color3.toHSV(c2)
	return (h1 > h2) or (s1 > s2) or (v1 > v2)
end

return function()
    describe("brighten()", function()
        it("should return a Color3", function()
            local color = colors.brighten(TEST_COLOR, PERCENT)
            expect(typeof(color)).to.equal("Color3")
        end)

        it("should make the color brighter", function()
            local color = colors.brighten(TEST_COLOR, PERCENT)
            expect(isBrighter(color, TEST_COLOR)).to.equal(true)
        end)
    end)

    describe("darken()", function()
        it("should return a Color3", function()
            local color = colors.darken(TEST_COLOR, PERCENT)
            expect(typeof(color)).to.equal("Color3")
        end)

        it("should make the color darker", function()
            local color = colors.darken(TEST_COLOR, PERCENT)
            expect(isBrighter(color, TEST_COLOR)).to.equal(false)
        end)
    end)
end
