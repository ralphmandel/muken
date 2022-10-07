druid_u_modifier_conversion = class({})

function druid_u_modifier_conversion:IsHidden()
	return false
end

function druid_u_modifier_conversion:IsPurgable()
	return false
end

function druid_u_modifier_conversion:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_u_modifier_conversion:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.parent:SetTeam(self.caster:GetTeamNumber())
	self.parent:SetOwner(self.caster)
	self.parent:SetControllableByPlayer(self.caster:GetPlayerOwnerID(), true)

	self.ability:AddUnit(self.parent)
	self:PlayEfxStart()
end

function druid_u_modifier_conversion:OnRefresh(kv)
end

function druid_u_modifier_conversion:OnRemoved()
	if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, false) end

	if IsServer() then
		if self.parent:GetUnitName() == "npc_druid_treant_lv1"
		or self.parent:GetUnitName() == "npc_druid_treant_lv2"
		or self.parent:GetUnitName() == "npc_druid_treant_lv3" then
			self.parent:EmitSound("Hero_Furion.TreantDeath")
		else
			self.parent:EmitSound("Creature.Kill")
		end
	end
	
	self.ability:RemoveUnit(self.parent)

	if self.parent:IsAlive() then
		self.parent:Kill(nil, nil)
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_u_modifier_conversion:CheckState()
	local state = {
		[MODIFIER_STATE_DOMINATED] = true
	}

	return state
end

function druid_u_modifier_conversion:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PRE_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_MISS_PERCENTAGE,
        MODIFIER_EVENT_ON_HEAL_RECEIVED,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function druid_u_modifier_conversion:GetModifierPreAttack(keys)
	if keys.attacker ~= self.parent then return end

	if self.parent:GetUnitName() == "npc_druid_treant_lv1"
	or self.parent:GetUnitName() == "npc_druid_treant_lv2"
	or self.parent:GetUnitName() == "npc_druid_treant_lv3" then
		if IsServer() then self.parent:EmitSound("Furion_Treant.PreAttack") end
	end
end

function druid_u_modifier_conversion:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end

	if self.parent:GetUnitName() == "npc_druid_treant_lv1"
	or self.parent:GetUnitName() == "npc_druid_treant_lv2"
	or self.parent:GetUnitName() == "npc_druid_treant_lv3" then
		if IsServer() then self.parent:EmitSound("Furion_Treant.Attack") end
	end
end

function druid_u_modifier_conversion:GetModifierMiss_Percentage()
	if self.parent:GetUnitName() == "npc_druid_treant_lv1"
	or self.parent:GetUnitName() == "npc_druid_treant_lv2"
	or self.parent:GetUnitName() == "npc_druid_treant_lv3" then
		return 10
	end
	
	return 0
end

function druid_u_modifier_conversion:OnHealReceived(keys)
    if keys.unit ~= self.parent then return end
    if keys.inflictor == nil then return end
    if keys.gain < 1 then return end

    if self.parent:GetUnitName() == "npc_druid_treant_lv1"
	or self.parent:GetUnitName() == "npc_druid_treant_lv2"
	or self.parent:GetUnitName() == "npc_druid_treant_lv3" then
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, keys.unit, keys.gain, keys.unit)
	end
end

function druid_u_modifier_conversion:OnTakeDamage(keys)
    if keys.unit ~= self.parent then return end
    if keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then return end

    local efx = nil
    --if keys.damage_type == DAMAGE_TYPE_PHYSICAL then efx = OVERHEAD_ALERT_DAMAGE end
    if keys.damage_type == DAMAGE_TYPE_MAGICAL then efx = OVERHEAD_ALERT_BONUS_SPELL_DAMAGE end

    if keys.inflictor ~= nil then
        if keys.inflictor:GetClassname() == "ability_lua" then
            if keys.inflictor:GetAbilityName() == "shadow_0__toxin"
			or keys.inflictor:GetAbilityName() == "osiris_1__poison"
            or keys.inflictor:GetAbilityName() == "dasdingo_4__tribal" then
                efx = OVERHEAD_ALERT_BONUS_POISON_DAMAGE
            end

			if keys.inflictor:GetAbilityName() == "bloodstained_4__frenzy" then
				return
			end

			if keys.inflictor:GetAbilityName() == "bloodstained_u__seal" then
				return
			end
        end
    end

	if keys.damage_type == DAMAGE_TYPE_PURE then self:PopupCustom(math.floor(keys.damage), Vector(255, 225, 175)) end

    if efx == nil then return end

	if self.parent:GetUnitName() == "npc_druid_treant_lv1"
	or self.parent:GetUnitName() == "npc_druid_treant_lv2"
	or self.parent:GetUnitName() == "npc_druid_treant_lv3" then
		SendOverheadEventMessage(nil, efx, self.parent, keys.damage, self.parent)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_u_modifier_conversion:PlayEfxStart()
	self.effect_cast = ParticleManager:CreateParticle("particles/druid/druid_skill1_convert.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast, 0, self.parent:GetOrigin())
	self:AddParticle(self.effect_cast, false, false, -1, false, false)
end

function druid_u_modifier_conversion:PopupCustom(damage, color)
	local pidx = ParticleManager:CreateParticle("particles/msg_fx/msg_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.unit)
    local digits = 1
	if damage < 10 then digits = 2 end
    if damage > 9 and damage < 100 then digits = 3 end
    if damage > 99 and damage < 1000 then digits = 4 end
    if damage > 999 then digits = 5 end

    ParticleManager:SetParticleControl(pidx, 1, Vector(0, damage, 6))
    ParticleManager:SetParticleControl(pidx, 2, Vector(3, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
end