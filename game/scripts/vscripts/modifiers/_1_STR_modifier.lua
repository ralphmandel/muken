_1_STR_modifier = class ({})

function _1_STR_modifier:IsHidden()
    return false
end

function _1_STR_modifier:IsPermanent()
    return true
end

function _1_STR_modifier:IsPurgable()
    return false
end

-----------------------------------------

function _1_STR_modifier:OnCreated(kv)
    if IsServer() then
        self.caster = self:GetCaster()
        self.parent = self:GetParent()
        self.ability = self:GetAbility()

        self.critical_damage_bonus = 0
        self.critical_damage = 0
        self.spell_crit_damage = 0
        self.force_spell_crit = false
        self.spell_critical = false
        self.pierce_proc = false
        self.crit_on = true
        self.range = 0

        self.block_chance = self.ability:GetSpecialValueFor("block_chance")
        self.damage = self.ability:GetSpecialValueFor("damage")
        self.ability:CalculateAttributes(0, 0)
    end
end

function _1_STR_modifier:OnRefresh(kv)
end

-------------------------------------------

function _1_STR_modifier:CheckState()
	local state = {}
	
	if self.critical_damage > 0 and self.pierce_proc and self.crit_on == true then
		state = {[MODIFIER_STATE_CANNOT_MISS] = true}
	end

	return state
end

function _1_STR_modifier:DeclareFunctions()

    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_CONSTANT_BLOCK,
        MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
        MODIFIER_EVENT_ON_TAKEDAMAGE, -- PHYSICAL SPELL CRIT POPUP
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, --BONUS PHYSICAL SPELL DAMAGE
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_PROPERTY_PRE_ATTACK
    }
    return funcs
end

function _1_STR_modifier:GetModifierPhysical_ConstantBlock(keys)
    if RandomInt(1, 100) <= self.block_chance
    and self.parent:GetAttackCapability() == 1 then
        return math.floor(keys.damage * self.block_damage * 0.01)
    end
end

function _1_STR_modifier:GetModifierMagical_ConstantBlock(keys)
    if keys.damage_flags == DOTA_DAMAGE_FLAG_BYPASSES_BLOCK then return 0 end
    if RandomInt(1, 100) <= self.block_chance
    and self.parent:GetAttackCapability() == 1 then
        return math.floor(keys.damage * self.block_damage * 0.01)
    end
end

function _1_STR_modifier:OnTakeDamage(keys)
    if keys.attacker ~= self.parent then return end
    if keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then return end
    if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end
    if self.spell_critical == false then return end

    self:PopupSpellCrit(keys.damage, keys.unit)
end

function _1_STR_modifier:GetModifierSpellAmplify_Percentage(keys)
    if keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then return end
    if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end

    self.spell_critical = false

    if keys.damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION then
        local calc = (self:GetStackCount() * self.damage * 2.5)
        local crit = self.critical_damage - 100

        if self.spell_crit_damage > 0 then
            crit = self.spell_crit_damage - 100
            self.spell_crit_damage = 0
        end

        local critical_chance = 0
        local luck = self.parent:FindModifierByName("_2_LCK_modifier")
        if luck then critical_chance = luck:GetCriticalChance() end

        if (RandomInt(1, 10000) <= critical_chance * 100)
        or self.force_spell_crit == true then
            calc = calc + crit + (calc * crit * 0.01)
            self.spell_critical = true
            self.force_spell_crit = false
        end

        return calc
    end
end

function _1_STR_modifier:EnableForceSpellCrit(value)
    if value > 0 then self.spell_crit_damage = value end
    self.force_spell_crit = true
end

function _1_STR_modifier:GetModifierBaseAttack_BonusDamage()
    return self:GetStackCount() * self.damage
end

function _1_STR_modifier:GetModifierAttackRangeBonus()
    if self.parent:GetAttackCapability() == 2 then
        return self.range
    end
end

function _1_STR_modifier:GetModifierProcAttack_Feedback( params )
    --Critical Attack
    if self.record then
        self.record = nil
        if self.critical_damage > 0 and self.crit_on == true then
            if IsServer() then self.parent:EmitSound("Item_Desolator.Target") end
        end
    end
end

function _1_STR_modifier:GetModifierPreAttack_CriticalStrike(keys)
    if self.pierce_proc == true then
        self.pierce_proc = false

        if not self.parent:IsIllusion() and not keys.target:IsBuilding()
        and self.crit_on == true then
            self.record = keys.record
            self.has_crit = true
            return self.critical_damage
        else
            self.has_crit = false
        end
    else
        self.has_crit = false
    end
end

function _1_STR_modifier:GetModifierPreAttack(keys)
    if keys.attacker == self.parent then
        if self:RollChance() then
            self.pierce_proc = true
        else
            self.pierce_proc = false
        end
    end
end

function _1_STR_modifier:Base_STR(value)
    self.critical_damage = self.ability:GetSpecialValueFor("critical_damage")
    self.block_damage = self.ability:GetSpecialValueFor("base_block") + (self.ability:GetSpecialValueFor("block") * value)
    self.range = self.ability:GetSpecialValueFor("range") * value
end

function _1_STR_modifier:GetBaseRange()
    return 350 + self.range
end

function _1_STR_modifier:GetCriticalDamage()
    return self.critical_damage * 0.01
end

function _1_STR_modifier:AddCriticalDamage(value)
    self.critical_damage_bonus = self.critical_damage_bonus + value
    self.critical_damage = self.ability:GetSpecialValueFor("critical_damage") + self.critical_damage_bonus
end

function _1_STR_modifier:EnableCritical(value)
    self.crit_on = value
end

function _1_STR_modifier:HasCritical()
    return self.has_crit
end

function _1_STR_modifier:RollChance()
    local critical_chance = 0
    local luck = self.parent:FindModifierByName("_2_LCK_modifier")
    if luck then critical_chance = luck:GetCriticalChance() end

    if RandomInt(1, 10000) <= critical_chance * 100 then
        return true
    end
    
    return false
end

function _1_STR_modifier:OnIntervalThink()
    if self:RollChance() then
        self.pierce_proc = true
    else
        self.pierce_proc = false
    end
    self:StartIntervalThink(-1)
end

--------------------------------------------------------------------------------

function _1_STR_modifier:PopupSpellCrit(damage, target)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, math.floor(damage), target)

    if IsServer() then target:EmitSound("Item_Desolator.Target") end
end