_2_RES_modifier = class ({})

function _2_RES_modifier:IsHidden()
    return true
end

function _2_RES_modifier:IsPermanent()
    return true
end

function _2_RES_modifier:IsPurgable()
    return false
end

-----------------------------------------

function _2_RES_modifier:OnCreated(kv)
    if IsServer() then
        self.caster = self:GetCaster()
        self.parent = self:GetParent()
        self.ability = self:GetAbility()

        self.magic_resist = self.ability:GetSpecialValueFor("magic_resist")
        self.resistance = self.ability:GetSpecialValueFor("resistance")
        self.ability:CalculateAttributes(0, 0)
    end
end

function _2_RES_modifier:OnRefresh(kv)
end

function _2_RES_modifier:DeclareFunctions()
    if IsServer() then
        local funcs = {
            MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        }
        return funcs
    end
end

function _2_RES_modifier:GetModifierMagicalResistanceBonus()
    if IsServer() then
        local value = self:GetStackCount() * self.magic_resist
        local calc = (value * 6) / (1 +  (value * 0.06))
        return calc
    end
end

function _2_RES_modifier:GetStatus()
    return self:GetStackCount() * self.resistance * 0.01
end