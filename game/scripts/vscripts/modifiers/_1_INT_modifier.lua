_1_INT_modifier = class ({})

function _1_INT_modifier:IsHidden()
    return false
end

function _1_INT_modifier:IsPermanent()
    return true
end

function _1_INT_modifier:IsPurgable()
    return false
end

-----------------------------------------

function _1_INT_modifier:OnCreated(kv)
    if IsServer() then
        self.caster = self:GetCaster()
        self.parent = self:GetParent()
        self.ability = self:GetAbility()

        self.spell_amp = self.ability:GetSpecialValueFor("spell_amp")
        self.buff_amp = self.ability:GetSpecialValueFor("buff_amp")
        self.ability:CalculateAttributes(0, 0)
    end
end

function _1_INT_modifier:OnRefresh(kv)
end

function _1_INT_modifier:DeclareFunctions()

    local funcs = {
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }
    return funcs
end

function _1_INT_modifier:GetModifierManaBonus()
    return self.mana
end

function _1_INT_modifier:GetModifierSpellAmplify_Percentage(keys)
    if keys.damage_type ~= DAMAGE_TYPE_MAGICAL then return end
    return self:GetStackCount() * self.spell_amp
end

function _1_INT_modifier:Base_INT(value)
    self.mana = self.ability:GetSpecialValueFor("mana") * value
end

function _1_INT_modifier:GetDebuffTime()
    return self:GetStackCount() * self.buff_amp * 0.01
end