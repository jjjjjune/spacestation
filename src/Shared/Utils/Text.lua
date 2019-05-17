-- local LuaUseUtf8TextTruncation = settings():GetFFlag("LuaUseUtf8TextTruncation")
-- local TextMeasureTemporaryPatch = settings():GetFFlag("TextMeasureTemporaryPatch")

local TextService = game:GetService("TextService")

local text = {}

-- FYI: Any number greater than 2^30 will make TextService:GetTextSize give invalid results
local MAX_BOUND = 10000

-- TODO(CLIPLAYEREX-1633): We can remove this padding patch after fixing TextService:GetTextSize sizing bug
text._TEMP_PATCHED_PADDING = Vector2.new(0, 0)

-- if TextMeasureTemporaryPatch then
-- 	text._TEMP_PATCHED_PADDING = Vector2.new(2, 2)
-- end

-- Wrapper function for GetTextSize
function text.getTextBounds(text, font, fontSize, bounds)
	return TextService:GetTextSize(text, fontSize, font, bounds) + text._TEMP_PATCHED_PADDING
end

function text.getTextWidth(text, font, fontSize)
	return text.getTextBounds(text, font, fontSize, Vector2.new(MAX_BOUND, MAX_BOUND)).X
end

function text.getTextHeight(text, font, fontSize, widthCap)
	return text.getTextBounds(text, font, fontSize, Vector2.new(widthCap, MAX_BOUND)).Y
end

-- TODO(CLIPLAYEREX-391): Kill these truncate functions once we have official support for text truncation
function text.truncate(text, font, fontSize, widthInPixels, overflowMarker)
	overflowMarker = overflowMarker or ""

	if text.getTextWidth(text, font, fontSize) > widthInPixels then
		-- if LuaUseUtf8TextTruncation then
		if false then
			-- A binary search may be more efficient
			local lastText = ""
			for _, stopIndex in utf8.graphemes(text) do
				local newText = string.sub(text, 1, stopIndex) .. overflowMarker
				if text.getTextWidth(newText, font, fontSize) > widthInPixels then
					return lastText
				end
				lastText = newText
			end
		else
			for len = #text, 1, -1 do
				local newText = string.sub(text, 1, len) .. overflowMarker
				if text.getTextWidth(newText, font, fontSize) <= widthInPixels then
					return newText
				end
			end
		end
	else -- No truncation needed
		return text
	end

	return ""
end

function text.truncateTextLabel(textLabel, overflowMarker)
	textLabel.Text = text.truncate(textLabel.Text, textLabel.Font,
			textLabel.TextSize, textLabel.AbsoluteSize.X, overflowMarker)
end

-- Remove whitespace from the beginning and end of the string
function text.trim(str)
	if type(str) ~= "string" then
		error(string.format("Text.Trim called on non-string type %s.", type(str)), 2)
	end
	return (str:gsub("^%s*(.-)%s*$", "%1"))
end

-- Remove whitespace from the end of the string
function text.rightTrim(str)
	if type(str) ~= "string" then
		error(string.format("Text.RightTrim called on non-string type %s.", type(str)), 2)
	end
	return (str:gsub("%s+$", ""))
end

-- Remove whitespace from the beginning of the string
function text.leftTrim(str)
	if type(str) ~= "string" then
		error(string.format("Text.LeftTrim called on non-string type %s.", type(str)), 2)
	end
	return (str:gsub("^%s+", ""))
end

-- Replace multiple whitespace with one; remove leading and trailing whitespace
function text.spaceNormalize(str)
	if type(str) ~= "string" then
		error(string.format("Text.SpaceNormalize called on non-string type %s.", type(str)), 2)
	end
	return (str:gsub("%s+", " "):gsub("^%s+" , ""):gsub("%s+$" , ""))
end

-- Splits a string by the provided pattern into a table. The pattern is interpreted as plain text.
function text.split(str, pattern)
	if type(str) ~= "string" then
		error(string.format("text.split called on non-string type %s.", type(str)), 2)
	elseif type(pattern) ~= "string" then
		error(string.format("text.split called with a pattern that is non-string type %s.", type(pattern)), 2)
	elseif pattern == "" then
		error("text.split called with an empty pattern.", 2)
	end

	local result = {}
	local currentPosition = 1

	while true do
		local patternStart, patternEnd = string.find(str, pattern, currentPosition, true)
		if not patternStart or not patternEnd then break end
		table.insert(result, string.sub(str, currentPosition, patternStart - 1))
		currentPosition = patternEnd + 1
	end

	table.insert(result, string.sub(str, currentPosition, string.len(str)))

	return result
end

return text