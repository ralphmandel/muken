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
        self.hp_regen_base = 0
        self.regen_state = 1
        
        self.ability:CalculateAttributes(0, 0)
    end
end

function _1_CON_modifier:OnRefresh(kv)
end

function _1_CON_modifier:DeclareFunctions()

    local funcs = {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_EVENT_ON_HEAL_RECEIVED,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return funcs
end

function _1_CON_modifier:GetModifierHealthBonus()
    return self:GetStackCount() * self.hp
end

function _1_CON_modifier:GetModifierConstantHealthRegen()
    return ((self:GetStackCount() * self.hp_regen) + self.hp_regen_base) * self.regen_state
end

function _1_CON_modifier:SetRegenState(bool)
    if bool == true then self.regen_state = 1 else self.regen_state = 0 end
end

function _1_CON_modifier:Base_CON(value)
    self.hp_regen_base = (self.ability:GetSpecialValueFor("hp_regen_bonus") * value) + self.ability:GetSpecialValueFor("hp_regen_base")
end

function _1_CON_modifier:OnHealReceived(keys)
    if keys.unit ~= self.parent then return end
    if keys.inflictor == nil then return end
    if keys.gain < 1 then return end

    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, keys.unit, keys.gain, keys.unit)
end

function _1_CON_modifier:OnTakeDamage(keys)
    if keys.unit ~= self.parent then return end
    if keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then return end

    local efx = nil
    --if keys.damage_type == DAMAGE_TYPE_PHYSICAL then efx = OVERHEAD_ALERT_DAMAGE end
    if keys.damage_type == DAMAGE_TYPE_MAGICAL then efx = OVERHEAD_ALERT_BONUS_SPELL_DAMAGE end
    if keys.damage_type == DAMAGE_TYPE_PURE then self:PopupCustom(math.floor(keys.damage), Vector(255, 225, 175)) end

    if keys.inflictor ~= nil then
        if keys.inflictor == "shadow_1__weapon"
        or keys.inflictor == "shadow_2__smoke" then
            efx = OVERHEAD_ALERT_BONUS_POISON_DAMAGE
        end
    end

    if efx == nil then return end
    SendOverheadEventMessage(nil, efx, self.parent, keys.damage, self.parent)
end

function _1_CON_modifier:PopupCustom(damage, color)
	local pidx = ParticleManager:CreateParticle("particles/msg_fx/msg_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent) -- target:GetOwner()
    local digits = 1
	if damage < 10 then digits = 2 end
    if damage > 9 and damage < 100 then digits = 3 end
    if damage > 99 and damage < 1000 then digits = 4 end
    if damage > 999 then digits = 5 end

    ParticleManager:SetParticleControl(pidx, 1, Vector(0, damage, 6))
    ParticleManager:SetParticleControl(pidx, 2, Vector(3, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
    --ParticleManager:SetParticleControl(pidx, 3, Vector(155, 225, 175)) -- GREEN
    --ParticleManager:SetParticleControl(pidx, 3, Vector(125, 190, 175)) -- GREEN 2
    --ParticleManager:SetParticleControl(pidx, 3, Vector(125, 200, 225)) -- CYAN
end