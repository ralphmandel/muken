_1_AGI_modifier = class ({})

function _1_AGI_modifier:IsHidden()
    return false
end

function _1_AGI_modifier:IsPermanent()
    return true
end

function _1_AGI_modifier:IsPurgable()
    return false
end

-----------------------------------------

function _1_AGI_modifier:OnCreated(kv)
    if IsServer() then
        self.caster = self:GetCaster()
        self.parent = self:GetParent()
        self.ability = self:GetAbility()

        self.min_ms = 100
        self.movespeed = 0
        self.as = self.ability:GetSpecialValueFor("as")
        self.base_attack_time = self.ability:GetSpecialValueFor("base_attack_time")
        self.ability:CalculateAttributes(0, 0)
    end
end

function _1_AGI_modifier:OnRefresh(kv)
end

function _1_AGI_modifier:DeclareFunctions()

    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE,
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
        MODIFIER_EVENT_ON_RESPAWN
    }
    return funcs
end

function _1_AGI_modifier:GetModifierMoveSpeedBonus_Percentage_Unique(keys)
    return (100 * self.min_ms) / self.movespeed
end

function _1_AGI_modifier:GetModifierMoveSpeedOverride(keys)
    return self.movespeed
end

function _1_AGI_modifier:GetModifierIgnoreMovespeedLimit()
	return 1
end

function _1_AGI_modifier:GetModifierMoveSpeed_Limit()
    return (self.movespeed * 2) + 100
end

function _1_AGI_modifier:GetModifierAttackSpeedBonus_Constant()
    if self.parent:HasModifier("ancient_1_modifier_berserk") then
        return 0
    end

    return self:GetStackCount() * self.as
end

function _1_AGI_modifier:GetModifierBaseAttackTimeConstant()
    return self.base_attack_time
end

function _1_AGI_modifier:Base_AGI(value)
    self.movespeed = (self.ability:GetSpecialValueFor("base_ms") + (self.ability:GetSpecialValueFor("ms") * value ))
end

function _1_AGI_modifier:SetBaseAttackTime(bonus)
    local bat = self.ability:GetSpecialValueFor("base_attack_time")
    if self.parent:HasModifier("ancient_1_modifier_berserk") then bat = 2.25 end
    self.base_attack_time = bat + bonus
end

function _1_AGI_modifier:OnRespawn(keys)
    if keys.unit == self.parent then
        self:SetBaseAttackTime(0)
    end
end