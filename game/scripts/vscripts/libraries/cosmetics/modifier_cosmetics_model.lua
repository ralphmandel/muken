--[[
Copyright (c) Elfansoer

RESTRICTED MODIFICATION:
Any changes outside Editable Section is prohibited.
- There is no Editable Section in this file.
]]

--------------------------------------------------------------------------------
modifier_cosmetics_model = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_cosmetics_model:IsHidden()
	return true
end

function modifier_cosmetics_model:IsPurgable()
	return false
end

function modifier_cosmetics_model:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT 
end

function modifier_cosmetics_model:GetPriority()
	-- don't override gameplay transformations
	return MODIFIER_PRIORITY_LOW
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_cosmetics_model:OnCreated( kv )
	if not IsServer() then return end
	-- references
	-- self.itemID = kv.itemID
	self.parent = self:GetParent()
	self.model = kv.model

	-- for safety net as model changer crash easily
	if not kv.model then
		self.model = self.parent:GetModelName()
	end
end

function modifier_cosmetics_model:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_cosmetics_model:OnRemoved()
	if not IsServer() then return end
	-- notify that this change is internal
	self.parent.model_change_notify = true
end

function modifier_cosmetics_model:OnDestroy()
	if not IsServer() then return end
	-- internal model change ended
	self.parent.model_change_notify = false
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_cosmetics_model:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
	}

	return funcs
end
function modifier_cosmetics_model:GetModifierModelChange()
	return self.model
end