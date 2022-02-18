_2_LCK_modifier = class ({})

function _2_LCK_modifier:IsHidden()
    return true
end

function _2_LCK_modifier:IsPermanent()
    return true
end

function _2_LCK_modifier:IsPurgable()
    return false
end

-----------------------------------------

function _2_LCK_modifier:OnCreated(kv)
    if IsServer() then
        self.caster = self:GetCaster()
        self.parent = self:GetParent()
        self.ability = self:GetAbility()

        self.crit_chance = self.ability:GetSpecialValueFor("crit_chance")
        self.ability:CalculateAttributes(0, 0)
    end
end

function _2_LCK_modifier:OnRefresh(kv)
end

-----------------------------------------

function _2_LCK_modifier:GetCriticalChance()
    local value = self:GetStackCount() * self.crit_chance
    local calc = (value * 6) / (1 +  (value * 0.06))
    return calc
end