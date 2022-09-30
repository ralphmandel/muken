bloodstained_4_modifier_frenzy = class({})

function bloodstained_4_modifier_frenzy:IsHidden()
	return false
end

function bloodstained_4_modifier_frenzy:IsPurgable()
	return true
end

function bloodstained_4_modifier_frenzy:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_4_modifier_frenzy:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local agi = self.ability:GetSpecialValueFor("agi")
	local ms = self.ability:GetSpecialValueFor("ms")

	self.parent:SetForceAttackTarget(self.ability.target)
	self.ability:AddBonus("_1_AGI", self.parent, agi, 0, nil)
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {percent = ms})

	if IsServer() then self:PlayEfxStart() end
end

function bloodstained_4_modifier_frenzy:OnRefresh(kv)
end

function bloodstained_4_modifier_frenzy:OnRemoved()
	self.parent:SetForceAttackTarget(nil)
	self.ability:RemoveBonus("_1_AGI", self.parent)

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function bloodstained_4_modifier_frenzy:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true
	}

	return state
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bloodstained_4_modifier_frenzy:GetEffectName()
	return "particles/econ/items/void_spirit/void_spirit_immortal_2021/void_spirit_immortal_2021_astral_step_debuff.vpcf"
end

function bloodstained_4_modifier_frenzy:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function bloodstained_4_modifier_frenzy:PlayEfxStart()
	local particle_cast = "particles/econ/items/lifestealer/lifestealer_immortal_backbone_gold/lifestealer_immortal_backbone_gold_rage.vpcf"
	local efx = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(efx, 0, self.parent:GetOrigin())
	self:AddParticle(efx, false, false, -1, false, true)

	if IsServer() then self.parent:EmitSound("Hero_ShadowDemon.DemonicPurge.Damage") end
end