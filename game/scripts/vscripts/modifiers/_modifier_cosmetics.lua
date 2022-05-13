_modifier_cosmetics = class({})

--------------------------------------------------------------------------------
function _modifier_cosmetics:IsPurgable()
	return false
end

function _modifier_cosmetics:IsHidden()
	return true
end

function _modifier_cosmetics:IsDebuff()
	return false
end

function _modifier_cosmetics:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_cosmetics:OnCreated( kv )
	self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.model = kv.model

	Timers:CreateTimer((0.2), function()
		self.parent:FollowEntity(self.caster, true)
		self:PlayEfxAmbient()
	end)
end

function _modifier_cosmetics:OnRefresh( kv )
end

function _modifier_cosmetics:OnRemoved()
end

--------------------------------------------------------------------------------

function _modifier_cosmetics:CheckState()
	local state = {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}

	return state
end

function _modifier_cosmetics:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_EVENT_ON_STATE_CHANGED

	}

	return funcs
end

function _modifier_cosmetics:GetModifierModelChange()
	return self.model
end

function _modifier_cosmetics:OnStateChanged(keys)
	if keys.unit ~= self.caster then return end
	if self.caster:IsHexed() or self.caster:IsOutOfGame() then
		self.parent:AddNoDraw()
	else
		self.parent:RemoveNoDraw()
	end
end

--------------------------------------------------------------------------------

function _modifier_cosmetics:PlayEfxAmbient()
	if self.model == "models/items/elder_titan/harness_of_the_soulforged_weapon/harness_of_the_soulforged_weapon.vmdl" then
		local string = "particles/econ/items/elder_titan/elder_titan_fissured_soul/elder_titan_fissured_soul_weapon.vpcf"
		local effect_cast = ParticleManager:CreateParticle(string, PATTACH_POINT_FOLLOW, self.parent)
		ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
		ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_weapon", Vector(0,0,0), true)
		self:AddParticle(effect_cast, false, false, -1, false, false)
	end

	if self.model == "models/items/elder_titan/elder_titan_immortal_back/elder_titan_immortal_back.vmdl" then
		local string = "particles/econ/items/elder_titan/elder_titan_ti7/elder_titan_ti7_ambient.vpcf"
		local effect_cast = ParticleManager:CreateParticle(string, PATTACH_POINT_FOLLOW, self.parent)
		ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
		ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_back", Vector(0,0,0), true)
		ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())
		ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_back_top_left", Vector(0,0,0), true)
		ParticleManager:SetParticleControl(effect_cast, 2, self.parent:GetOrigin())
		ParticleManager:SetParticleControlEnt(effect_cast, 2, self.parent, PATTACH_POINT_FOLLOW, "attach_back_top_right", Vector(0,0,0), true)
		ParticleManager:SetParticleControl(effect_cast, 3, self.parent:GetOrigin())
		ParticleManager:SetParticleControlEnt(effect_cast, 3, self.parent, PATTACH_POINT_FOLLOW, "attach_back_bot_right", Vector(0,0,0), true)
		ParticleManager:SetParticleControl(effect_cast, 4, self.parent:GetOrigin())
		ParticleManager:SetParticleControlEnt(effect_cast, 4, self.parent, PATTACH_POINT_FOLLOW, "attach_back_bot_left", Vector(0,0,0), true)
		ParticleManager:SetParticleControl(effect_cast, 5, self.parent:GetOrigin())
		ParticleManager:SetParticleControlEnt(effect_cast, 5, self.parent, PATTACH_POINT_FOLLOW, "attach_back", Vector(0,0,0), true)
		ParticleManager:SetParticleControl(effect_cast, 6, self.parent:GetOrigin())
		ParticleManager:SetParticleControlEnt(effect_cast, 6, self.parent, PATTACH_POINT_FOLLOW, "attach_back", Vector(0,0,0), true)
		ParticleManager:SetParticleControl(effect_cast, 7, self.parent:GetOrigin())
		ParticleManager:SetParticleControlEnt(effect_cast, 7, self.parent, PATTACH_POINT_FOLLOW, "attach_back", Vector(0,0,0), true)
		self:AddParticle(effect_cast, false, false, -1, false, false)
	end

	if self.model == "models/items/shadow_demon/ti7_immortal_back/sd_ti7_immortal_back.vmdl" then
		local string = "particles/econ/items/shadow_demon/sd_ti7_shadow_poison/sd_ti7_immortal_ambient.vpcf"
		local effect_cast = ParticleManager:CreateParticle(string, PATTACH_POINT_FOLLOW, self.parent)
		ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
		ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_head", Vector(0,0,0), true)
		self:AddParticle(effect_cast, false, false, -1, false, false)
	end
	if self.model == "models/items/shadow_demon/sd_crown_of_the_nightworld_armor/sd_crown_of_the_nightworld_armor.vmdl" then
		local string = "particles/econ/items/shadow_demon/sd_crown_nightworld/sd_crown_nightworld_armor.vpcf"
		local effect_cast = ParticleManager:CreateParticle(string, PATTACH_POINT_FOLLOW, self.parent)
		ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
		ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
		self:AddParticle(effect_cast, false, false, -1, false, false)
	end
end
