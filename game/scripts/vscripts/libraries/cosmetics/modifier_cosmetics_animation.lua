--[[
Copyright (c) Elfansoer

RESTRICTED MODIFICATION:
Any changes outside Editable Section is prohibited.
- There is no Editable Section in this file.
]]

--------------------------------------------------------------------------------
modifier_cosmetics_animation = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_cosmetics_animation:IsHidden()
	return true
end

function modifier_cosmetics_animation:IsPurgable()
	return false
end

function modifier_cosmetics_animation:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_cosmetics_animation:OnCreated( kv )
	self.parent = self:GetParent()
	self.owner = self:GetCaster()

	if not IsServer() then return end

	self.parent:StartGesture( ACT_DOTA_IDLE )
end

function modifier_cosmetics_animation:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_cosmetics_animation:OnRemoved()
end

function modifier_cosmetics_animation:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_cosmetics_animation:DeclareFunctions()
	local funcs = {

		MODIFIER_EVENT_ON_RESPAWN,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_ATTACK_START,
	}

	return funcs
end

function modifier_cosmetics_animation:OnRespawn( params )
	if params.unit~=self.owner then return end

	self.parent:StartGesture( ACT_DOTA_IDLE )
end


function modifier_cosmetics_animation:OnDeath( params )
	if params.unit~=self.owner then return end

	self.parent:StartGesture( ACT_DOTA_DIE )
end

function modifier_cosmetics_animation:OnAttackStart( params )
	if params.attacker~=self.owner then return end

	self.parent:StartGesture( ACT_DOTA_ATTACK )
end