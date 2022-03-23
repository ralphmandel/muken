_2_REC_modifier = class ({})

function _2_REC_modifier:IsHidden()
    return true
end

function _2_REC_modifier:IsPermanent()
    return true
end

function _2_REC_modifier:IsPurgable()
    return false
end

-----------------------------------------

function _2_REC_modifier:OnCreated(kv)
    if IsServer() then
        self.caster = self:GetCaster()
        self.parent = self:GetParent()
        self.ability = self:GetAbility()

        self.mp_regen = self.ability:GetSpecialValueFor("mp_regen")
        self.cooldown = self.ability:GetSpecialValueFor("cooldown")
        self.channel = self.ability:GetSpecialValueFor("channel")
        self.ability:CalculateAttributes(0, 0)
    end
end

function _2_REC_modifier:OnRefresh(kv)
end

function _2_REC_modifier:DeclareFunctions()

    local funcs = {
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
    }
    return funcs
end

function _2_REC_modifier:GetModifierConstantManaRegen()
    if self.parent:GetUnitName() == "npc_dota_hero_bloodseeker" then
        return 0
    end
    return self:GetStackCount() * self.mp_regen
end

function _2_REC_modifier:GetModifierPercentageCooldown()
    if self.parent:GetUnitName() == "npc_dota_hero_bloodseeker" then
        return self:GetStackCount() * 1
    end
    return self:GetStackCount() * self.cooldown
end

function _2_REC_modifier:GetChannelTimeReduction(time)
    return time - (time * self:GetStackCount() * self.channel * 0.01)
end