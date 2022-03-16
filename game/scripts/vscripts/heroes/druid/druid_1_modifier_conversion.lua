druid_1_modifier_conversion = class ({})

function druid_1_modifier_conversion:IsHidden()
    return false
end

function druid_1_modifier_conversion:IsPurgable()
    return false
end

-----------------------------------------------------------

function druid_1_modifier_conversion:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.parent:SetTeam(self.caster:GetTeamNumber())
	self.parent:SetOwner(self.caster)
	self.parent:SetControllableByPlayer(self.caster:GetPlayerOwnerID(), true)

	-- self.bonus_damage = self.ability:GetSpecialValueFor("bonus_damage")
	-- local caster_int = self.caster:FindModifierByName("_1_INT_modifier")

	-- if caster_int then
	-- 	self.bonus_damage = math.floor(self.bonus_damage * (1 + caster_int:GetSpellAmp()))
	-- end

    self.parent:Heal(9999, self.ability)
    self:PlayEfxStart()
end

function druid_1_modifier_conversion:OnRefresh(kv)
end

function druid_1_modifier_conversion:OnRemoved(kv)
	if IsValidEntity(self.parent) then
        if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, false) end
		if self.parent:IsAlive() then
			self.parent:ForceKill(false)
		end
	end
end

------------------------------------------------------------

function druid_1_modifier_conversion:CheckState()
	local state = {
		[MODIFIER_STATE_DOMINATED] = true
	}

	return state
end

function druid_1_modifier_conversion:DeclareFunctions()
	local funcs = {
		--MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_HEAL_RECEIVED
	}

	return funcs
end

-- function druid_1_modifier_conversion:GetModifierPreAttack_BonusDamage(keys)
-- 	return self.bonus_damage
-- end

function druid_1_modifier_conversion:OnHealReceived(keys)
    if keys.gain <= 0 then return end

    if keys.inflictor ~= nil and keys.unit == self.parent then
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, keys.unit, math.floor(keys.gain), keys.unit)
    end
end

--------------------------------------------------------------------------------

function druid_1_modifier_conversion:PlayEfxStart()
	self.effect_cast = ParticleManager:CreateParticle("particles/druid/druid_skill1_convert.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast, 0, self.parent:GetOrigin())
	self:AddParticle(self.effect_cast, false, false, -1, false, false)
end