_2_DEX_modifier = class ({})

function _2_DEX_modifier:IsHidden()
    return true
end

function _2_DEX_modifier:IsPermanent()
    return true
end

function _2_DEX_modifier:IsPurgable()
    return false
end

-----------------------------------------

function _2_DEX_modifier:OnCreated(kv)
    if IsServer() then
        self.caster = self:GetCaster()
        self.parent = self:GetParent()
        self.ability = self:GetAbility()

        self.evade = self.ability:GetSpecialValueFor("evade")        
        self.ability:CalculateAttributes(0, 0)
    end
end

function _2_DEX_modifier:OnRefresh(kv)
end

-----------------------------------------

function _2_DEX_modifier:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_EVASION_CONSTANT
    }
    return funcs
end

function _2_DEX_modifier:GetModifierEvasion_Constant(keys)
    local value = self:GetStackCount() * self.evade
    local calc = (value * 6) / (1 +  (value * 0.06))
    return calc
end