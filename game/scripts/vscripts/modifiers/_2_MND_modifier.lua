_2_MND_modifier = class ({})

function _2_MND_modifier:IsHidden()
    return true
end

function _2_MND_modifier:IsPermanent()
    return true
end

function _2_MND_modifier:IsPurgable()
    return false
end

-----------------------------------------

function _2_MND_modifier:OnCreated(kv)
    if IsServer() then
        self.caster = self:GetCaster()
        self.parent = self:GetParent()
        self.ability = self:GetAbility()

        self.heal_power = self.ability:GetSpecialValueFor("heal_power")
        self.buff = self.ability:GetSpecialValueFor("buff")
        self.ability:CalculateAttributes(0, 0)
    end
end

function _2_MND_modifier:OnRefresh(kv)
end

function _2_MND_modifier:GetHealPower()
    return 1 + (self:GetStackCount() * self.heal_power * 0.01)
end

function _2_MND_modifier:GetBuffAmp()
    return self:GetStackCount() * self.buff * 0.01
end