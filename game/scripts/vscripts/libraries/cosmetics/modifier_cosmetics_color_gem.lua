--[[
Copyright (c) Elfansoer

RESTRICTED MODIFICATION:
Any changes outside Editable Section is prohibited.
- There is no Editable Section in this file.
]]

--------------------------------------------------------------------------------
modifier_cosmetics_color_gem = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_cosmetics_color_gem:IsHidden()
	return false
end

function modifier_cosmetics_color_gem:IsDebuff()
	return false
end

function modifier_cosmetics_color_gem:IsStunDebuff()
	return false
end

function modifier_cosmetics_color_gem:IsPurgable()
	return true
end

function modifier_cosmetics_color_gem:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_cosmetics_color_gem:OnCreated( kv )
	if not IsServer() then return end
	local r = kv.r or 0
	local g = kv.g or 0
	local b = kv.b or 0

	self.registered_effects = {}

	local color = Vector( r, g, b )

	self:SetColor( color )
end

function modifier_cosmetics_color_gem:OnRefresh( kv )
	if not IsServer() then return end
	local r = kv.r or 0
	local g = kv.g or 0
	local b = kv.b or 0

	local color = Vector( r, g, b )

	self:SetColor( color )
end

function modifier_cosmetics_color_gem:OnRemoved()
end

function modifier_cosmetics_color_gem:OnDestroy()
end

--------------------------------------------------------------------------------
function modifier_cosmetics_color_gem:SetColor( color )
	self.color = color
	GameRules:SendCustomMessage( "color (" .. color.x .. "," .. color.y .. "," .. color.z .. ")", 0, 0 )

	for modifier,_ in pairs(self.registered_effects) do
		for effect_cast,_ in pairs(modifier.effects) do
			-- set particle control
			ParticleManager:SetParticleControl( effect_cast, 15, Vector( color.x, color.y, color.z ) )
			ParticleManager:SetParticleControl( effect_cast, 16, Vector( 1,0,0 ) )
		end
	end
end

function modifier_cosmetics_color_gem:GetColorAsVector()
	return self.color
end

function modifier_cosmetics_color_gem:GetColorAsRGB()
	return self.color.x, self.color.y, self.color.b
end

function modifier_cosmetics_color_gem:GetColorAsTable()
	local ret = {}
	ret.r = self.color.x
	ret.g = self.color.y
	ret.b = self.color.z

	return ret
end

--------------------------------------------------------------------------------
function modifier_cosmetics_color_gem:RegisterEffects( modifier, isOriginal )
	if not isOriginal then return end
	self.registered_effects[ modifier ] = true

	for effect_cast,_ in pairs(modifier.effects) do
		-- set particle control
		ParticleManager:SetParticleControl( effect_cast, 15, Vector( self.color.x, self.color.y, self.color.z ) )
		ParticleManager:SetParticleControl( effect_cast, 16, Vector( 1,0,0 ) )
	end
end

function modifier_cosmetics_color_gem:UnregisterEffects( modifier )
	self.registered_effects[ modifier ] = nil
end