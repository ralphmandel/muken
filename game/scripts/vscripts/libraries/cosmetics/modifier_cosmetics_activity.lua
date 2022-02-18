--[[
Copyright (c) Elfansoer

RESTRICTED MODIFICATION:
Any changes outside Editable Section is prohibited.
- There is no Editable Section in this file.
]]

--------------------------------------------------------------------------------
modifier_cosmetics_activity = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_cosmetics_activity:IsHidden()
	return true
end

function modifier_cosmetics_activity:IsPurgable()
	return false
end

function modifier_cosmetics_activity:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_cosmetics_activity:OnCreated( kv )
	if not IsServer() then return end
	-- references
	self.itemID = kv.itemID
	self.parent = self:GetParent()
	self.activity = kv.activity
end

function modifier_cosmetics_activity:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_cosmetics_activity:OnRemoved()
end

function modifier_cosmetics_activity:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_cosmetics_activity:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}

	return funcs
end

function modifier_cosmetics_activity:GetActivityTranslationModifiers()
	return self.activity
end