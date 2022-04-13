crusader_1_modifier_summon = class ({})

function crusader_1_modifier_summon:IsHidden()
    return false
end

function crusader_1_modifier_summon:IsPurgable()
    return false
end

-----------------------------------------------------------

function crusader_1_modifier_summon:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	
	self.resist = 0
	self.pierce_proc = false

	-- UP 1.1
	if self.ability:GetRank(1) then
		self:PlayEfxResist()
		self.resist = 50
	end

	local levels = 0
	local int = self.caster:FindModifierByName("_1_INT_modifier")
	if int then self.parent:CreatureLevelUp(int:GetStackCount()) end

	self:StartIntervalThink(0.5)
end

function crusader_1_modifier_summon:OnRefresh(kv)
end

function crusader_1_modifier_summon:OnRemoved(kv)
	if IsValidEntity(self.parent) then
		if self.parent:IsAlive() then
			self.parent:RemoveModifierByName("crusader_u_modifier_aura_effect")
			self.parent:Kill(self.ability, nil)
		end
	end
end

------------------------------------------------------------

function crusader_1_modifier_summon:CheckState()
	local state = {}
	
	if self.pierce_proc then
		state = {
			[MODIFIER_STATE_CANNOT_MISS] = true
		}
	end

	return state
end

function crusader_1_modifier_summon:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_EVENT_ON_HEAL_RECEIVED,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_PRE_ATTACK,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}

	return funcs
end

function crusader_1_modifier_summon:GetModifierHealAmplify_PercentageTarget(keys)
	return -50
end

function crusader_1_modifier_summon:ceived(keys)
    if keys.unit ~= self.parent then return end
    if keys.inflictor == nil then return end
    if keys.gain < 1 then return end

    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, keys.unit, keys.gain, keys.unit)
end

function crusader_1_modifier_summon:OnTakeDamage(keys)
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

function crusader_1_modifier_summon:PopupCustom(damage, color)
	local pidx = ParticleManager:CreateParticle("particles/msg_fx/msg_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent) -- target:GetOwner()
    local digits = 1
	if damage < 10 then digits = 1 end
    if damage > 9 and damage < 100 then digits = 2 end
    if damage > 99 and damage < 1000 then digits = 3 end
    if damage > 999 then digits = 4 end

    ParticleManager:SetParticleControl(pidx, 1, Vector(0, damage, 6))
    ParticleManager:SetParticleControl(pidx, 2, Vector(3, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
end

function crusader_1_modifier_summon:GetModifierPreAttack(keys)
	if RandomInt(1, 100) <= 25 then
		self.pierce_proc = true
	else
		self.pierce_proc = false
	end
end

function crusader_1_modifier_summon:GetModifierPreAttack_CriticalStrike(keys)
	if IsServer() and (not self.parent:PassivesDisabled()) then
		if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then
			return
		end

		-- UP 1.4
		if self.ability:GetRank(4)
		and self.pierce_proc == true then
			self.pierce_proc = false
			self.record = keys.record
			return 200
		end
	end
end

function crusader_1_modifier_summon:GetModifierProcAttack_Feedback(keys)
	if IsServer() then
		if self.record and self.record == keys.record then
			self.record = nil
			self.parent:EmitSound("Item_Desolator.Target")
		end
	end
end

function crusader_1_modifier_summon:GetModifierMagicalResistanceBonus(keys)
    return self.resist
end

function crusader_1_modifier_summon:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if IsServer() then self.parent:EmitSound("Hero_Meepo.Attack") end

	-- UP 1.3
	if self.ability:GetRank(3)
	and self.parent:PassivesDisabled() == false
	and keys.target:IsMagicImmune() == false
	and RandomInt(1, 100) <= 35 then
		local mod = keys.target:FindAllModifiersByName("_modifier_movespeed_debuff")
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self.ability then modifier:Destroy() end
        end

		keys.target:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
			duration = self.ability:CalcStatus(4, self.caster, keys.target),
			percent = 50
		})
	end
end

function crusader_1_modifier_summon:GetAttackSound(keys)
    return ""
end

function crusader_1_modifier_summon:OnIntervalThink(keys)
    if self.parent:GetAggroTarget() ~= nil then return end
	local dist = CalcDistanceBetweenEntityOBB(self.parent, self.caster)

	if dist > 200 then
		self.parent:MoveToPositionAggressive(self.caster:GetOrigin())
	else
		if self.parent:IsMoving() then self.parent:Stop() end
	end
end

-----------------------------------------------------------

function crusader_1_modifier_summon:PlayEfxResist()
	self.effect = ParticleManager:CreateParticle("particles/crusader/crusader_resist.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect, 0, self.parent:GetOrigin())
	--ParticleManager:SetParticleControl(self.effect, 2, self.parent:GetOrigin())
	self:AddParticle(self.effect, false, false, -1, false, false)
end