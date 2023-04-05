genuine_4_modifier_aura_effect = class({})

function genuine_4_modifier_aura_effect:IsHidden() return false end
function genuine_4_modifier_aura_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_4_modifier_aura_effect:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.exceptions = {
		"_1_AGI_modifier_stack", "_1_CON_modifier_stack",
		"_1_INT_modifier_stack", "_1_STR_modifier_stack",
		"_2_DEF_modifier_stack", "_2_DEX_modifier_stack",
		"_2_LCK_modifier_stack", "_2_MND_modifier_stack",
		"_2_REC_modifier_stack", "_2_RES_modifier_stack",
		"_modifier_blind", "_modifier_movespeed_debuff",
    "_modifier_percent_movespeed_debuff"
	}

	self:ApplyBuff()
	self:ApplyDebuff()
end

function genuine_4_modifier_aura_effect:OnRefresh(kv)
end

function genuine_4_modifier_aura_effect:OnRemoved(kv)
	RemoveBonus(self.ability, "_2_RES", self.parent)

	local mod = self.parent:FindAllModifiersByName("_modifier_debuff_increase")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_4_modifier_aura_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
		MODIFIER_EVENT_ON_MODIFIER_ADDED
	}
	
	return funcs
end

function genuine_4_modifier_aura_effect:GetBonusNightVision()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then return 0 end
	return self:GetAbility():GetSpecialValueFor("special_night_vision")
end

function genuine_4_modifier_aura_effect:OnModifierAdded(keys)
	if keys.unit ~= self.parent then return end
	if keys.added_buff:IsDebuff() == false then return end
	if keys.added_buff == self then return end
	if self.parent:GetTeamNumber() == self.caster:GetTeamNumber() then return end

	for _,mod_name in pairs(self.exceptions) do
		if mod_name == keys.added_buff:GetName() then return end
	end

	local damage = ApplyDamage({
		damage = self.ability:GetSpecialValueFor("special_damage"),
		attacker = self.caster,
		victim = self.parent,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability
	})

	if self.parent then
		if IsValidEntity(self.parent) then
			self:PlayEfxDamage(self.parent, damage)			
		end
	end
end

-- UTILS -----------------------------------------------------------

function genuine_4_modifier_aura_effect:ApplyBuff()
	if self.parent:GetTeamNumber() ~= self.caster:GetTeamNumber() then return end
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_debuff_increase", {
		percent = self.ability:GetSpecialValueFor("debuff_power")
	})
end

function genuine_4_modifier_aura_effect:ApplyDebuff()
	if self.parent:GetTeamNumber() == self.caster:GetTeamNumber() then return end
	AddBonus(self.ability, "_2_RES", self.parent, self.ability:GetSpecialValueFor("res"), 0, nil)
end

-- EFFECTS -----------------------------------------------------------

function genuine_4_modifier_aura_effect:PlayEfxDamage(target, damage)
	if damage == 0 then return end

	local particle = "particles/genuine/genuine_zap/genuine_zap_attack_heavy_ti_5.vpcf"
	local zap_pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControlEnt(zap_pfx, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(zap_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(zap_pfx)

	if IsServer() then
		self.caster:EmitSound("Hero_Pugna.NetherWard.Attack")
		target:EmitSound("Hero_Pugna.NetherWard.Target")
	end
end