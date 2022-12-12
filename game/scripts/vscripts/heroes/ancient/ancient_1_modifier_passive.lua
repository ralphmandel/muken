ancient_1_modifier_passive = class({})
HITS_TO_DOUBLE_ATTACK = 5

function ancient_1_modifier_passive:IsHidden()
	return self:GetAbility():GetCurrentAbilityCharges() % 2 ~= 0
end

function ancient_1_modifier_passive:IsPurgable()
	return false
end

function ancient_1_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_1_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.hidden = true

	self.damage = self.ability:GetSpecialValueFor("damage")
	self.damage_percent = self.ability:GetSpecialValueFor("damage_percent")
	self.stun_multiplier = self.ability:GetSpecialValueFor("stun_multiplier")

	self.base_stats = self.parent:FindAbilityByName("base_stats")
	if self.base_stats then self.base_stats:SetBaseAttackTime(0) end

	if IsServer() then self:SetStackCount(HITS_TO_DOUBLE_ATTACK) end
end

function ancient_1_modifier_passive:OnRefresh(kv)
	-- UP 1.41
	if self.ability:GetRank(41) then
		self.damage = self.ability:GetSpecialValueFor("damage") + 50
	end
end

function ancient_1_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PRE_ATTACK,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function ancient_1_modifier_passive:GetModifierPreAttack(keys)
	if self.parent:IsIllusion() then return end

	if IsServer() then
		if self:ShouldLaunch(keys.target) then
			if self.base_stats then self.base_stats:SetForceCritHit(0) end
			
			if self.punch then
				self.parent:MoveToTargetToAttack(keys.target)
			else
				self.parent:Stop()
				if self.cast then self.parent:MoveToTargetToAttack(keys.target) end
			end

			self.punch = true
		else
			self.punch = false
		end
	end
end

function ancient_1_modifier_passive:GetModifierAttackSpeedBonus_Constant()
	if self:GetStackCount() > 0 then return 0 end

	return 400
end

function ancient_1_modifier_passive:GetModifierProcAttack_BonusDamage_Physical()
	return self.damage
end

function ancient_1_modifier_passive:GetModifierBaseDamageOutgoing_Percentage()
	return self.damage_percent
end

function ancient_1_modifier_passive:OnAttack(keys)
	if keys.attacker ~= self.parent then return end

	-- UP 1.21
	if self.ability:GetRank(21) then
		self:CheckDoubleHit()
	else
		self:SetStackCount(HITS_TO_DOUBLE_ATTACK)
	end
end

function ancient_1_modifier_passive:OnOrder(keys)
	if keys.unit ~= self.parent then return end

	if keys.ability then
		if keys.ability == self.ability then
			self.cast = true
			return
		end
	end
	
	self.cast = false
end

function ancient_1_modifier_passive:OnTakeDamage(keys)
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end

	self:ApplyStuns(keys)

	-- UP 1.11
	if self.ability:GetRank(11) then
		self:ApplyReflect(keys, 0.5)
	end
end

function ancient_1_modifier_passive:OnStackCountChanged(old)
	if self.base_stats then self.base_stats:UpdateBaseAttackTime() end
end

-- UTILS -----------------------------------------------------------

function ancient_1_modifier_passive:ApplyStuns(keys)
	if keys.attacker ~= self.parent then return end
	if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end
	if self.parent:PassivesDisabled() then return end

	self:CheckCritStrike(keys.unit, keys.damage_category)
	local stun_duration = keys.damage * self.stun_multiplier * 0.01

	if self.punch then
		self.punch = false
		self.ability:UseResources(true, false, true)
		if self.base_stats then self.base_stats:SetForceCritHit(-1) end
		
		local ult = self.parent:FindAbilityByName("ancient_u__final")
		if ult then
			if ult:IsTrained() then
				ult:UpdateResistance()
			end
		end
		
		keys.unit:AddNewModifier(self.caster, self.ability, "ancient_1_modifier_punch", {
            duration = stun_duration * 1.5
        })
	end

	if self.ability.pinned then stun_duration = stun_duration * 4 end

	keys.unit:AddNewModifier(self.caster, self.ability, "_modifier_stun", {
		duration = CalcStatus(stun_duration, self.caster, keys.unit)
	})
end

function ancient_1_modifier_passive:ApplyReflect(keys, stun_multiplier)
	if keys.unit ~= self.parent then return end
	if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end
	if keys.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then return end
	if self.parent:PassivesDisabled() then return end

	local base_stats_target = keys.attacker:FindAbilityByName("base_stats")
	if base_stats_target == nil then return end
	if base_stats_target.has_crit ~= true then return end
	if RandomFloat(1, 100) > 50 then return end

	if keys.damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION then	
		local total_damage = ApplyDamage({
			attacker = self.caster, victim = keys.attacker,
			ability = self.ability, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
			damage = keys.damage + self.damage, damage_type = keys.damage_type,
		})

		local stun_duration = total_damage * stun_multiplier * 0.01
		self:PlayEfxCrit(keys.attacker, true)
		self:PlayEfxCrit(self.parent, true)

		keys.attacker:AddNewModifier(self.caster, self.ability, "_modifier_stun", {
			duration = CalcStatus(stun_duration, self.caster, keys.attacker)
		})
	end
end

function ancient_1_modifier_passive:CheckDoubleHit()
	if not IsServer() then return end

	if self.parent:PassivesDisabled() then
		if self:GetStackCount() > 0 then
			return
		else
			self:SetStackCount(HITS_TO_DOUBLE_ATTACK)
		end
	end

	if self:GetStackCount() == 0 then
		self:SetStackCount(HITS_TO_DOUBLE_ATTACK)
	else
		self:DecrementStackCount()
	end
end

function ancient_1_modifier_passive:CheckCritStrike(target, damage_category)
	if self.base_stats == nil then return end
	
	self:PlayEfxCrit(target, self.base_stats.has_crit)
	if damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
		self:PlayEfxCrit(self.parent, self.base_stats.has_crit)
	end
end

function ancient_1_modifier_passive:ShouldLaunch(target)
	self.autocast = false
	if self.ability:GetAutoCastState() then
		local flags = self.ability:GetAbilityTargetFlags()

		local nResult = UnitFilter(
			target,
			self.ability:GetAbilityTargetTeam(),
			self.ability:GetAbilityTargetType(),
			flags,
			self.caster:GetTeamNumber()
		)
		if nResult == UF_SUCCESS then
			self.autocast = true
		end
	end

	if (self.cast or self.autocast) and self.ability:IsFullyCastable()
	and self.parent:IsSilenced() == false then
		return true
	end

	return false
end

-- EFFECTS -----------------------------------------------------------

function ancient_1_modifier_passive:PlayEfxCrit(target, crit)
	if target:GetPlayerOwner() == nil or crit == false then return end
	local particle_screen = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_screen.vpcf"
	local effect_screen = ParticleManager:CreateParticleForPlayer(particle_screen, PATTACH_WORLDORIGIN, nil, target:GetPlayerOwner())

	local effect = ParticleManager:CreateParticle("particles/osiris/poison_alt/osiris_poison_splash_shake.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effect, 1, Vector(500, 0, 0))
end