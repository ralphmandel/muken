_2_DEF_modifier = class ({})

function _2_DEF_modifier:IsHidden()
    return true
end

function _2_DEF_modifier:IsPermanent()
    return true
end

function _2_DEF_modifier:IsPurgable()
    return false
end

-----------------------------------------

function _2_DEF_modifier:OnCreated(kv)
    if IsServer() then
        self.caster = self:GetCaster()
        self.parent = self:GetParent()
        self.ability = self:GetAbility()

        self.armor = self.ability:GetSpecialValueFor("armor")
        self.ability:CalculateAttributes(0, 0)
    end
end

function _2_DEF_modifier:OnRefresh(kv)
end

function _2_DEF_modifier:OnRemoved()
end

function _2_DEF_modifier:DeclareFunctions()
    if IsServer() then
        local funcs = {
            MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
        }
        return funcs
    end
end

function _2_DEF_modifier:GetModifierPhysicalArmorBonus()
    if IsServer() then
        return self:GetStackCount() * self.armor
    end
end