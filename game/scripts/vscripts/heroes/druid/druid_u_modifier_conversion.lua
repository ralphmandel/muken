druid_u_modifier_conversion = class({})

function druid_u_modifier_conversion:IsHidden()
	return false
end

function druid_u_modifier_conversion:IsPurgable()
	return false
end

function druid_u_modifier_conversion:IsDebuff()
	return true
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
	if IsServer() then self.parent:EmitSound("Creature.Kill") end
	
	self.ability:RemoveUnit(self.parent)
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
		MODIFIER_PROPERTY_MISS_PERCENTAGE,
        MODIFIER_EVENT_ON_HEAL_RECEIVED,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function druid_u_modifier_conversion:GetModifierMiss_Percentage()
	if self.parent:GetUnitName() ~= "npc_druid_treant_lv2"
	and self.parent:GetUnitName() ~= "npc_druid_treant_lv4"
	and self.parent:GetUnitName() ~= "npc_druid_treant_lv6" then
		return 0
	end
	
	return 15
end

function druid_u_modifier_conversion:OnHealReceived(keys)
	if self.parent:GetUnitName() ~= "npc_druid_treant_lv2"
	and self.parent:GetUnitName() ~= "npc_druid_treant_lv4"
	and self.parent:GetUnitName() ~= "npc_druid_treant_lv6" then
		return
	end

    if keys.unit ~= self.parent then return end
    if keys.inflictor == nil then return end
    if keys.gain < 1 then return end

    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, keys.unit, keys.gain, keys.unit)
end

function druid_u_modifier_conversion:OnTakeDamage(keys)
	if self.parent:GetUnitName() ~= "npc_druid_treant_lv2"
	and self.parent:GetUnitName() ~= "npc_druid_treant_lv4"
	and self.parent:GetUnitName() ~= "npc_druid_treant_lv6" then
		return
	end

    if keys.unit ~= self.parent then return end
    if keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then return end

    local efx = nil
    --if keys.damage_type == DAMAGE_TYPE_PHYSICAL then efx = OVERHEAD_ALERT_DAMAGE end
    if keys.damage_type == DAMAGE_TYPE_MAGICAL then efx = OVERHEAD_ALERT_BONUS_SPELL_DAMAGE end
    if keys.damage_type == DAMAGE_TYPE_PURE then self:PopupCustom(math.floor(keys.damage), Vector(255, 225, 175)) end

    if keys.inflictor ~= nil then
        if keys.inflictor:GetClassname() == "ability_lua" then
            if keys.inflictor:GetAbilityName() == "shadow_0__toxin" 
            or keys.inflictor:GetAbilityName() == "dasdingo_4__tribal" then
                efx = OVERHEAD_ALERT_BONUS_POISON_DAMAGE
            end
        end
    end

    if efx == nil then return end
    SendOverheadEventMessage(nil, efx, self.self.parent, keys.damage, self.self.parent)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_u_modifier_conversion:PlayEfxStart()
	self.effect_cast = ParticleManager:CreateParticle("particles/druid/druid_skill1_convert.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast, 0, self.parent:GetOrigin())
	self:AddParticle(self.effect_cast, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Druid.Finish") end
end