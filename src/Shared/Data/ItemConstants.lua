
local ids = {
	TEST_CATEGORY = {
		TEST_ITEM = "TEST_ITEM"
	}
}

-- We don't need this for now, but might at some point in the future:

-- local idToCategoryMap = {}

-- for categoryKey, category in pairs(ids) do
-- 	for itemKey, itemId in pairs(category) do
-- 		idToCategoryMap[itemKey] = category
-- 	end
-- end

-- function itemCategoryFromId(itemId)
-- 	return idToCategoryMap[itemId]
-- end

-- --[[ Exmaple code for checking an item's category:

-- local ItemConstants = import "Shared/Data/ItemConstants"

-- function thatNeedsAnItemsCategory(itemId)
-- 	local itemCategory = ItemConstants.itemCategoryFromId(itemId)
-- 	if itemCategory == ItemConstants.TEST then
-- 		-- do shit
-- 	end
-- end

-- ]]

return ids