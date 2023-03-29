bald_4_modifier_passive = class({})

function bald_4_modifier_passive:IsHidden() return false end
function bald_4_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_4_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	self.exceptions = {
		"_1_AGI_modifier_stack", "_1_CON_modifier_stack",
		"_1_INT_modifier_stack", "_1_STR_modifier_stack",
		"_2_DEF_modifier_stack", "_2_DEX_modifier_stack",
		"_2_LCK_modifier_stack", "_2_MND_modifier_stack",
		"_2_REC_modifier_stack", "_2_RES_modifier_stack",
		"_modifier_blind_stack", "_modifier_movespeed_debuff",
    "_modifier_percent_movespeed_debuff"
	}
end

function bald_4_modifier_passive:OnRefresh(kv)
end

function bald_4_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_4_modifier_passive:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_EVENT_ON_MODIFIER_ADDED
	}

	return funcs
end

function bald_4_modifier_passive:GetModifierHealAmplify_PercentageTarget()
	if self:GetParent():PassivesDisabled() then return 0 end
	return self:GetAbility():GetSpecialValueFor("heal_amp")
end

function bald_4_modifier_passive:OnModifierAdded(keys)
	if keys.unit ~= self.parent then return end
	if keys.added_buff:IsDebuff() == false then return end
	if self.parent:PassivesDisabled() then return end

	for _,mod_name in pairs(self.exceptions) do
		if mod_name == keys.added_buff:GetName() then
			return
		end
	end

	local heal = self.ability:GetSpecialValueFor("heal")
	local base_stats = self.caster:FindAbilityByName("base_stats")
	if base_stats then heal = heal * base_stats:GetHealPower() end

	self.parent:Heal(heal, self.ability)

  if RandomFloat(1, 100) <= self.ability:GetSpecialValueFor("purge_chance") then
    self.parent:Purge(false, true, false, true, false)
    self:PlayEfxPurge(self.parent)
  end

  local damage = ApplyDamage({
		damage = self.ability:GetSpecialValueFor("special_damage"),
		attacker = self.caster,
		victim = keys.added_buff:GetCaster(),
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability
	})

	if keys.added_buff:GetCaster() then
		if IsValidEntity(keys.added_buff:GetCaster()) then
			self:PlayEfxDamage(keys.added_buff:GetCaster(), damage)			
		end
	end
end

function bald_4_modifier_passive:OnIntervalThink()
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bald_4_modifier_passive:GetEffectName()
	return "particles/units/heroes/hero_skeletonking/wraith_king_ghosts_ambient.vpcf"
end

function bald_4_modifier_passive:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function bald_4_modifier_passive:PlayEfxPurge(target)
	local string = "particles/units/heroes/hero_oracle/oracle_false_promise_attacked.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle, 0, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle)
	if IsServer() then target:EmitSound("DOTA_Item.HotD.Activate") end
end

function bald_4_modifier_passive:PlayEfxDamage(target, damage)
	if damage == 0 then return end

	local particle = "particles/bald/bald_zap/bald_zap_attack_heavy_ti_5.vpcf"
	local zap_pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControlEnt(zap_pfx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(zap_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(zap_pfx)

	if IsServer() then
		self.parent:EmitSound("Hero_Pugna.NetherWard.Attack")
		target:EmitSound("Hero_Pugna.NetherWard.Target")
	end
end