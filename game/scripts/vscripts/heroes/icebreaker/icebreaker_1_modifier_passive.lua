icebreaker_1_modifier_passive = class ({})

function icebreaker_1_modifier_passive:IsHidden()
    return false
end

function icebreaker_1_modifier_passive:IsPurgable()
    return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_1_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.double_attack = 0

	if self.parent:IsIllusion() then
		self:SetUpIllusion()
	end

	if IsServer() then
		self:SetStackCount(self.ability.kills)
		self:PlayEfxAmbient()
	end
end

function icebreaker_1_modifier_passive:OnRefresh(kv)
	if IsServer() then
		self:SetStackCount(self.ability.kills)
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_HERO_KILLED,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_FAIL
	}
	
	return funcs
end

function icebreaker_1_modifier_passive:OnHeroKilled(keys)
	if keys.attacker == nil or keys.target == nil or keys.inflictor == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if self.parent:IsIllusion() then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end

	if IsServer() then
		if keys.inflictor:GetAbilityName() == "icebreaker_u__blink" then
			self.ability:AddKillPoint(1)
			self:SetStackCount(self.ability.kills)
		end
	end
end

function icebreaker_1_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end

	self:ApplyHypothermia(keys.target, self.parent:IsIllusion())

	-- UP 1.11
	if self.ability:GetRank(11) then
		self:ApplyInstantFrozen(keys.target, self.parent:IsIllusion())
	end

	-- UP 1.21
	if self.ability:GetRank(21) then
		self:ApplyBonusMagicalDamage(keys.target, self.parent:IsIllusion())
	end

	-- UP 1.41
	if self.ability:GetRank(41) then
		self:ApplyAutoBlink(keys.target, self.parent:IsIllusion())
	end
end

function icebreaker_1_modifier_passive:OnAttackFail(keys)
	if keys.attacker ~= self.parent then return end

    if self.double_attack > 0 then
		self.double_attack = self.double_attack - 1
		self.ability:RemoveBonus("_1_AGI", self.parent)
	end
end

-- UTILS -----------------------------------------------------------

function icebreaker_1_modifier_passive:ApplyHypothermia(target, bIllusion)
	local hypo_chance = 75
	if bIllusion then hypo_chance = 100 end
	if target:IsMagicImmune() then hypo_chance = 25 end
	if self.parent:PassivesDisabled() then hypo_chance = 0 end
	if RandomFloat(1, 100) <= hypo_chance then self.ability:AddSlow(target, self.ability, 1, true) end
end

function icebreaker_1_modifier_passive:ApplyBonusMagicalDamage(target, bIllusion)
	if self.parent:PassivesDisabled() then return end
	if bIllusion then return end

	local damageTable = {
		victim = target,
		attacker = self.caster,
		damage = 12,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability
	}

	ApplyDamage(damageTable)
end

function icebreaker_1_modifier_passive:ApplyInstantFrozen(target, bIllusion)
	if self.parent:PassivesDisabled() then return end
	if target:HasModifier("icebreaker_1_modifier_frozen") then return end
	if target:IsAlive() == false then return end
	if target:IsMagicImmune() then return end
	if bIllusion then return end  
	
	if RandomFloat(1, 100) <= 10 then
		target:AddNewModifier(self.caster, self.ability, "icebreaker_1_modifier_instant", {
			duration = 0.1
		})
	end
end

function icebreaker_1_modifier_passive:ApplyAutoBlink(target, bIllusion)
	if self.double_attack > 0 then
		self.double_attack = self.double_attack - 1
		self.ability:RemoveBonus("_1_AGI", self.parent)
	end

	if self.parent:PassivesDisabled() then return end
	if bIllusion then return end

	if RandomFloat(1, 100) <= 15 then
		local direction = target:GetForwardVector() * (-1)
		local blink_point = target:GetAbsOrigin() + direction * 130

		self:PlayEfxAutoBlink()
		self.parent:SetAbsOrigin(blink_point)
		self.parent:SetForwardVector(-direction)
		FindClearSpaceForUnit(self.parent, blink_point, true)

		self.ability:RemoveBonus("_1_AGI", self.parent)
		self.ability:AddBonus("_1_AGI", self.parent, 999, 0, 2)
		self.double_attack = 1
	end
end

function icebreaker_1_modifier_passive:SetUpIllusion()
	local new_caster = nil
	local new_ability = nil

	local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats then new_caster = base_stats:FindOriginalHero() end
	if new_caster == nil then self:Destroy() return end
	if new_caster:GetTeamNumber() ~= self.parent:GetTeamNumber() then return end

	local new_ability = new_caster:FindAbilityByName(self.ability:GetAbilityName())
	if new_ability == nil then self:Destroy() return end

	self.caster = new_caster
	self.ability = new_ability
end

-- EFFECTS -----------------------------------------------------------

function icebreaker_1_modifier_passive:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_radiant.vpcf"
end

function icebreaker_1_modifier_passive:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function icebreaker_1_modifier_passive:PlayEfxAmbient()
    if self.effect_cast_1 then ParticleManager:DestroyParticle(self.effect_cast_1, true) end
	local particle_cast_1 = "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ambient.vpcf"
	self.effect_cast_1 = ParticleManager:CreateParticle(particle_cast_1, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.effect_cast_1, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
	self:AddParticle(self.effect_cast_1, false, false, -1, false, false)

	if self.effect_cast_2 then ParticleManager:DestroyParticle(self.effect_cast_2, true) end
	local particle_cast_2 = "particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_buff.vpcf"
	self.effect_cast_2 = ParticleManager:CreateParticle(particle_cast_2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast_2, 0, self.parent:GetOrigin() )
	self:AddParticle(self.effect_cast_2, false, false, -1, false, false)
end

function icebreaker_1_modifier_passive:PlayEfxAutoBlink()
	local particle_cast = "particles/econ/events/winter_major_2017/blink_dagger_start_wm07.vpcf" 
	local effect_cast_a = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast_a, 0, self.parent:GetOrigin())
	--ParticleManager:SetParticleControlForward(effect_cast_a, 0, direction:Normalized())
	--ParticleManager:SetParticleControl(effect_cast_a, 1, origin + direction)
	ParticleManager:ReleaseParticleIndex(effect_cast_a)

	if IsServer() then self.parent:EmitSound("Hero_QueenOfPain.Blink_out") end
end