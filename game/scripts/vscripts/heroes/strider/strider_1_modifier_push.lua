strider_1_modifier_push = class ({})

function strider_1_modifier_push:IsHidden()
    return true
end

function strider_1_modifier_push:IsPurgable()
    return false
end

-----------------------------------------------------------

function strider_1_modifier_push:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    self.debuff_duration = self.ability:GetSpecialValueFor("debuff_duration")
end

function strider_1_modifier_push:OnRefresh(kv)
end

function strider_1_modifier_push:OnRemoved(kv)
end

------------------------------------------------------------

function strider_1_modifier_push:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	
	return funcs
end

function strider_1_modifier_push:OnAttackLanded(keys)
    if keys.attacker ~= self.parent then return end
    if keys.target:GetTeamNumber() == self.caster:GetTeamNumber() then return end
    if self.ability:GetAutoCastState() == false then return end
    if keys.target:IsMagicImmune() then return end
    if self.ability:IsCooldownReady() == false then return end
    if self.parent:IsSilenced() then return end
    if self.parent:GetMana() < self.ability:GetManaCost(self.ability:GetLevel()) then return end
    if keys.target:HasModifier("strider_1_modifier_spirit") then return end

    local cooldown = self.ability:GetEffectiveCooldown(self.ability:GetLevel())
    self.ability:StartCooldown(cooldown)
    self.parent:SpendMana(self.ability:GetManaCost(self.ability:GetLevel()), self.ability)

    if keys.target:TriggerSpellAbsorb(self.ability) then return end

    if keys.target:IsIllusion() then
        keys.target:ForceKill(false)
        return
    end

    if keys.target:IsHero() then
        self.ability:DoPush(keys.target)
    else
        keys.target:AddNewModifier(self.caster, self.ability, "_modifier_disarm", {
            duration = self.ability:CalcStatus(self.debuff_duration, self.caster, keys.target)
        })
    end
end