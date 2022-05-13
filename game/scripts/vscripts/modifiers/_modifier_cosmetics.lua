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

	self.invi = false
	self.model = kv.model
	self.parent:SetOriginalModel(self.model)

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
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVISIBLE] = self.invi
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
	
	if self.caster:IsInvisible() then self.invi = true else self.invi = false end

	if self.caster:IsHexed()
	or self.caster:IsOutOfGame() then
		self.parent:AddNoDraw()
	else
		self.parent:RemoveNoDraw()
	end
end

--------------------------------------------------------------------------------

function _modifier_cosmetics:PlayEfxAmbient()
	if self.model == "models/items/elder_titan/harness_of_the_soulforged_weapon/harness_of_the_soulforged_weapon.vmdl" then
		local string = "particles/ancient/ancient_weapon.vpcf"
		self.ancient_mace = ParticleManager:CreateParticle(string, PATTACH_POINT_FOLLOW, self.parent)
		ParticleManager:SetParticleControl(self.ancient_mace, 0, self.parent:GetOrigin())
		ParticleManager:SetParticleControlEnt(self.ancient_mace, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_weapon", Vector(0,0,0), true)
		self:AddParticle(self.ancient_mace, false, false, -1, false, false)
	end

	if self.model == "models/items/elder_titan/elder_titan_immortal_back/elder_titan_immortal_back.vmdl" then
		local string = "particles/econ/items/elder_titan/elder_titan_ti7/elder_titan_ti7_ambient.vpcf"
		local effect_cast = ParticleManager:CreateParticle(string, PATTACH_POINT_FOLLOW, self.parent)
		ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
		ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_back", Vector(0,0,0), true)
		self:AddParticle(effect_cast, false, false, -1, false, false)
	end

	--BLOOSTAINED
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

	--SUCCUBUS
	if self.model == "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana_dagger.vmdl" then
		local string = "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_blade_ambient.vpcf"
		local effect_cast = ParticleManager:CreateParticle(string, PATTACH_POINT_FOLLOW, self.parent)
		ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
		ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
		self:AddParticle(effect_cast, false, false, -1, false, false)
	end
	if self.model == "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana_head.vmdl" then
		local string = "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_head_ambient.vpcf"
		local effect_cast = ParticleManager:CreateParticle(string, PATTACH_POINT_FOLLOW, self.parent)
		ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
		ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
		self:AddParticle(effect_cast, false, false, -1, false, false)
	end
	if self.model == "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana_modest_wings.vmdl" then
		local string = "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_wings_ambient.vpcf"
		local effect_cast = ParticleManager:CreateParticle(string, PATTACH_POINT_FOLLOW, self.parent)
		ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
		ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
		self:AddParticle(effect_cast, false, false, -1, false, false)
	end
end
