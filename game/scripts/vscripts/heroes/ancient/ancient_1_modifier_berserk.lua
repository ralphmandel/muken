ancient_1_modifier_berserk = class ({})

function ancient_1_modifier_berserk:IsHidden()
    return false
end

function ancient_1_modifier_berserk:IsPurgable()
    return false
end

function ancient_1_modifier_berserk:GetPriority()
    return MODIFIER_PRIORITY_HIGH
end

-----------------------------------------------------------

function ancient_1_modifier_berserk:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.stun_percent = self.ability:GetSpecialValueFor("stun_percent") * 0.01
	self.aspd = self.ability:GetSpecialValueFor("aspd")
	self.no_disarm = false

	self.agi_mod = self.parent:FindModifierByName("_1_AGI_modifier")
	if self.agi_mod then self.agi_mod:SetBaseAttackTime(0) end

	if IsServer() then
		self:SetStackCount(0)
	end
end

function ancient_1_modifier_berserk:OnRefresh(kv)
	-- UP 1.31
	if self.ability:GetRank(31) then
		self.no_disarm = true
	end
end

function ancient_1_modifier_berserk:OnRemoved(kv)
end

------------------------------------------------------------

function ancient_1_modifier_berserk:CheckState()
	local state = {}

	if self.no_disarm == true then
		state = {
			[MODIFIER_STATE_DISARMED] = false,
		}
	end

	return state
end

function ancient_1_modifier_berserk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_ATTACKSPEED_BASE_OVERRIDE,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}

	return funcs
end

function ancient_1_modifier_berserk:OnOrder(keys)
	if keys.unit ~= self.parent then return end
	if keys.order_type == 1 then self.ability.attack_target = keys.target return end
	if keys.target ~= nil then self.ability.attack_target = keys.target end
end

function ancient_1_modifier_berserk:GetModifierAttackSpeedBaseOverride()
	return self.aspd
end

function ancient_1_modifier_berserk:OnAttackFail(keys)
	if keys.attacker ~= self.parent then return end

	-- UP 1.41
	if self.ability:GetRank(41) then
		if self:GetStackCount() > 0 then
			if self:GetStackCount() == 1 then
				if self.parent:PassivesDisabled() == false then
					if self.agi_mod then self.agi_mod:SetBaseAttackTime(-2) end
					self.aspd = 5
				else
					return
				end
			end
			self:DecrementStackCount()
		else
			self:SetStackCount(4)
			if self.agi_mod then self.agi_mod:SetBaseAttackTime(0) end
			self.aspd = self.ability:GetSpecialValueFor("aspd")
		end
	end
end

function ancient_1_modifier_berserk:GetModifierPreAttack_CriticalStrike()
	-- UP 1.11
	if self.ability:GetRank(11) 
	and self.ability:IsCooldownReady() 
	and self.parent:PassivesDisabled() == false then
		local str_mod = self.parent:FindModifierByName("_1_STR_modifier")
		if str_mod then str_mod:EnableForceCrit(0) end
	end
end

function ancient_1_modifier_berserk:GetModifierProcAttack_Feedback(keys)
	local str_mod = self.parent:FindModifierByName("_1_STR_modifier")

	-- UP 2.31
	local leap = self.parent:FindAbilityByName("ancient_2__leap")
	if leap then
		if leap:IsTrained() then
			if leap:GetRank(31) then
				local cd = leap:GetCooldownTimeRemaining() - 1.5
				leap:EndCooldown()
				if cd > 0 then leap:StartCooldown(cd) end
			end			
		end
	end

	-- UP 1.11
	if self.ability:GetRank(11) 
	and self.ability:IsCooldownReady() 
	and self.parent:PassivesDisabled() == false then
		if str_mod then
			if str_mod:HasCritical() then
				self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
				keys.target:AddNewModifier(self.caster, self.ability, "_modifier_disarm", {
					duration = self.ability:CalcStatus(5, self.caster, keys.target)
				})
			end
		end
	end

	-- UP 1.41
	if self.ability:GetRank(41) then
		if self:GetStackCount() > 0 then
			if self:GetStackCount() == 1 then
				if self.parent:PassivesDisabled() == false then
					if self.agi_mod then self.agi_mod:SetBaseAttackTime(-2) end
					self.aspd = 5
				else
					return
				end
			end
			self:DecrementStackCount()
		else
			self:SetStackCount(4)
			if self.agi_mod then self.agi_mod:SetBaseAttackTime(0) end
			self.aspd = self.ability:GetSpecialValueFor("aspd")
		end
	end
end

function ancient_1_modifier_berserk:GetModifierTotalDamageOutgoing_Percentage(keys)
	if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end
	if keys.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then return end
	if self.parent:PassivesDisabled() then return end

	self.ability.original_damage = keys.original_damage
end

function ancient_1_modifier_berserk:OnTakeDamage(keys)
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end
	local mana_gain = self.ability:GetSpecialValueFor("mana_gain")

	local str_mod = self.parent:FindModifierByName("_1_STR_modifier")
	if str_mod then
		if str_mod:HasCritical()
		and self.parent:PassivesDisabled() == false then
			local stun_duration = self.ability:CalcStatus(self.ability.original_damage * self.stun_percent, nil, keys.unit)
			keys.unit:AddNewModifier(self.caster, self.ability, "_modifier_stun", {duration = stun_duration})

			-- UP 1.32
			if self.ability:GetRank(32) then
				self.parent:Heal(self.ability.original_damage * 0.15, self.ability)
			end
	
			if IsServer() then keys.unit:EmitSound("DOTA_Item.SkullBasher") end
			mana_gain = self.ability:GetSpecialValueFor("mana_gain_crit")
		end
	end

	if keys.unit:IsIllusion() == false and keys.unit:IsHero() then
		mana_gain = mana_gain + self.ability:GetSpecialValueFor("mana_gain_hero")
	end

	self.parent:GiveMana(mana_gain)
end

function ancient_1_modifier_berserk:GetModifierConstantManaRegen()
	if self.parent:HasModifier("ancient_3_modifier_aura") then return 0 end
    return -5
end