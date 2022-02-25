_1_CON_modifier = class ({})

function _1_CON_modifier:IsHidden()
    return false
end

function _1_CON_modifier:IsPermanent()
    return true
end

function _1_CON_modifier:IsPurgable()
    return false
end

-----------------------------------------

function _1_CON_modifier:OnCreated(kv)
    if IsServer() then
        self.caster = self:GetCaster()
        self.parent = self:GetParent()
        self.ability = self:GetAbility()

        self.hp = self.ability:GetSpecialValueFor("hp")
        self.hp_regen = self.ability:GetSpecialValueFor("hp_regen")
        self.heal_amp = 0
        
        self.ability:CalculateAttributes(0, 0)
    end
end

function _1_CON_modifier:OnRefresh(kv)
end

function _1_CON_modifier:DeclareFunctions()

    local funcs = {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        --MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
        MODIFIER_EVENT_ON_HEAL_RECEIVED
    }
    return funcs
end

function _1_CON_modifier:GetModifierHealthBonus()
    return self:GetStackCount() * self.hp
end

function _1_CON_modifier:GetModifierConstantHealthRegen()
    return (self:GetStackCount() * self.hp_regen) + self.heal_amp
end

-- function _1_CON_modifier:GetModifierHealAmplify_PercentageTarget()
--     return self.heal_amp
-- end

function _1_CON_modifier:OnHealReceived(params)
    if params.gain <= 0 then return end

    if params.inflictor ~= nil and params.unit == self:GetParent() then
        self:Popup(params.unit, math.floor(params.gain))
    end
end

function _1_CON_modifier:Base_CON(value)
    self.heal_amp = self.ability:GetSpecialValueFor("heal_amp") * value
end

-----------------------------------------------------------------

function _1_CON_modifier:Popup(target, amount)
    self:PopupNumbers(target, "heal", Vector(0, 255, 0), 2.0, amount, 10, 0)
end

function _1_CON_modifier:PopupNumbers(target, pfx, color, lifetime, number, presymbol, postsymbol)
    local pfxPath = string.format("particles/msg_fx/msg_%s.vpcf", pfx)
    local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, target) -- target:GetOwner()
    
     
    local digits = 0
    if number ~= nil then
        digits = #tostring(number)
    end
    if presymbol ~= nil then
        digits = digits + 1
    end
    if postsymbol ~= nil then
        digits = digits + 1
    end

    if number < 10 then digits = 2 end
    if number > 9 and number < 100 then digits = 3 end
    if number > 99 then digits = 4 end

    ParticleManager:SetParticleControl(pidx, 1, Vector(tonumber(presymbol), tonumber(number), tonumber(postsymbol)))
    ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
end