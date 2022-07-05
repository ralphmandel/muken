dasdingo_1_modifier_immortal = class({})

function dasdingo_1_modifier_immortal:IsHidden()
	return false
end

function dasdingo_1_modifier_immortal:IsPurgable()
	return false
end

function dasdingo_1_modifier_immortal:GetTexture()
	return "dasdingo_immortal"
end

-----------------------------------------------------------

function dasdingo_1_modifier_immortal:OnCreated(kv)
	self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self.parent:EmitSound("Hero_SkeletonKing.Reincarnate.Ghost") end

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(nil, "dasdingo_1_modifier_immortal_status_efx", true) end
end

function dasdingo_1_modifier_immortal:OnRefresh(kv)
end

function dasdingo_1_modifier_immortal:OnRemoved(kv)
	self.parent:RemoveModifierByName("dasdingo_1_modifier_heal_effect")
	if self.parent:IsAlive() then self.parent:Kill(self.inflictor, self.attacker) end

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(nil, "dasdingo_1_modifier_immortal_status_efx", false) end
end

-----------------------------------------------------------

function dasdingo_1_modifier_immortal:CheckState()
	local state = {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}

	return state
end

function dasdingo_1_modifier_immortal:DeclareFunctions()
    local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end

function dasdingo_1_modifier_immortal:OnTakeDamage(keys)
    if keys.unit ~= self.parent then return end
	self.inflictor = keys.inflictor
	self.attacker = keys.attacker
end

function dasdingo_1_modifier_immortal:SetKillData(keys)
	self.inflictor = keys.inflictor
	self.attacker = keys.attacker
end

-----------------------------------------------------------

function dasdingo_1_modifier_immortal:GetEffectName()
	return "particles/units/heroes/hero_skeletonking/wraith_king_ghosts_ambient.vpcf"
end

function dasdingo_1_modifier_immortal:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function dasdingo_1_modifier_immortal:GetStatusEffectName()
	return "particles/status_fx/status_effect_wraithking_ghosts.vpcf"
end

function dasdingo_1_modifier_immortal:StatusEffectPriority()
	return 99999999
end