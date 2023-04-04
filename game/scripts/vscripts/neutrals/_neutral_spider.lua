_neutral_spider = class({})
LinkLuaModifier( "_modifier_neutral_spider", "neutrals/_modifier_neutral_spider", LUA_MODIFIER_MOTION_NONE )

function _neutral_spider:GetIntrinsicModifierName()
	return "_modifier_neutral_spider"
end