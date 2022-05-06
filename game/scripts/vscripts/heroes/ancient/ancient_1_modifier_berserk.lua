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
	self.no_disarm = false
	self.popup_mana = 0
	self.heal = 0

	self.agi_mod = self.parent:FindModifierByName("_1_AGI_modifier")
	self.hits = 0
	self:SetMultipleHits(0)

	if IsServer() then
		self:SetStackCount(0)
		self:StartIntervalThink(FrameTime())
	end
end

function ancient_1_modifier_berserk:OnRefresh(kv)
	-- UP 1.11
	if self.ability:GetRank(11) then
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

function ancient_1_modifier_berserk:SetMultipleHits(hits)
	if hits > 0 then
		if hits > self.hits then self.hits = hits end
	else
		self.hits = self.hits - 1
	end

	local atkSpeed = self.ability:GetSpecialValueFor("aspd")
	local baseAS = 0

	if self.hits > 0 then
		atkSpeed = 5
		baseAS = -1
	end

	if self.agi_mod then self.agi_mod:SetBaseAttackTime(baseAS) end
	self.aspd = atkSpeed

	if self.hits < 0 then self.hits = 0 end
end

function ancient_1_modifier_berserk:OnAttackFail(keys)
	if keys.attacker ~= self.parent then return end

	-- UP 1.41
	if self.ability:GetRank(41) then
		if self.parent:PassivesDisabled() == false then
			if self:GetStackCount() == 0 then
				self:SetStackCount(4)
			else
				self:DecrementStackCount()
			end
			if self:GetStackCount() == 0 then
				self:SetMultipleHits(1)
				return
			end
		end
	end

	self:SetMultipleHits(0)
end

function ancient_1_modifier_berserk:GetModifierPreAttack_CriticalStrike()
	-- UP 1.31
	if self.ability:GetRank(31) 
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

	-- UP 1.31
	if self.ability:GetRank(31) 
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
		if self.parent:PassivesDisabled() == false then
			if self:GetStackCount() == 0 then
				self:SetStackCount(4)
			else
				self:DecrementStackCount()
			end
			if self:GetStackCount() == 0 then
				self:SetMultipleHits(1)
				return
			end
		end
	end

	self:SetMultipleHits(0)
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
				self.heal = self.heal + (self.ability.original_damage * 0.15)
			end
	
			if IsServer() then keys.unit:EmitSound("DOTA_Item.SkullBasher") end
			mana_gain = self.ability:GetSpecialValueFor("mana_gain_crit")
		end
	end

	if keys.unit:IsIllusion() == false and keys.unit:IsHero() then
		mana_gain = mana_gain + self.ability:GetSpecialValueFor("mana_gain_hero")
	end

	-- local final = self.parent:FindAbilityByName("ancient_u__final")
	-- if final then
	-- 	if final:IsTrained() then
	-- 		if final:GetRank(31)
	-- 		and keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
	-- 			local burned_mana = keys.unit:GetMaxMana() * 0.05
	-- 			if burned_mana > keys.unit:GetMana() then burned_mana = keys.unit:GetMana() end
	-- 			if burned_mana > 0 then
	-- 				keys.unit:ReduceMana(burned_mana)
	-- 				SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, keys.unit, burned_mana, self.caster)
	-- 				mana_gain = mana_gain + burned_mana
	-- 			end
	-- 		end
	-- 	end
	-- end

	self.parent:GiveMana(mana_gain)
	self.popup_mana = self.popup_mana + mana_gain
end

function ancient_1_modifier_berserk:OnIntervalThink()
	if self.popup_mana > 0 then
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, self.parent, self.popup_mana, self.caster)
		self.popup_mana = 0
	end

	if self.heal > 0 then
		self.parent:Heal(self.heal, self.ability)
		self.heal = 0
	end
end

function ancient_1_modifier_berserk:GetModifierConstantManaRegen()
	if self.parent:HasModifier("ancient_3_modifier_aura") then return 0 end
    return -self.ability.natural_loss
end