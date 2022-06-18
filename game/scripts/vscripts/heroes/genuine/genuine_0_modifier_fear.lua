genuine_0_modifier_fear = class ({})

function genuine_0_modifier_fear:IsHidden()
    return false
end

function genuine_0_modifier_fear:IsPurgable()
    return true
end

function genuine_0_modifier_fear:IsDebuff()
    return true
end

-----------------------------------------------------------

function genuine_0_modifier_fear:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    if IsServer() then
        self:ApplyFear()
        self:PlayEfxStart()
    end

    local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect("genuine_0_modifier_fear_status_efx", true) end
end

function genuine_0_modifier_fear:OnRefresh(kv)
    self:ApplyFear()
end

function genuine_0_modifier_fear:OnRemoved(kv)
    local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect("genuine_0_modifier_fear_status_efx", false) end

    if IsServer() then self.parent:StopSound("Genuine.Fear.Loop") end

    self.parent:Stop()
end

function genuine_0_modifier_fear:OnDestroy()
    if IsServer() then self.parent:StopSound("Genuine.Fear.Loop") end
end

-----------------------------------------------------------

function genuine_0_modifier_fear:CheckState()
	local state = {[MODIFIER_STATE_COMMAND_RESTRICTED] = true}

	return state
end

function genuine_0_modifier_fear:ApplyFear()
    local direction = (self.caster:GetAbsOrigin() - self.parent:GetAbsOrigin()):Normalized() * -1000
    local pos = self.parent:GetOrigin() + direction
    self.parent:MoveToPosition(pos)

    if IsServer() then self.parent:EmitSound("Hero_DarkWillow.Fear.Target") end
end

-----------------------------------------------------------

function genuine_0_modifier_fear:GetStatusEffectName()
 	return "particles/status_fx/status_effect_lone_druid_savage_roar.vpcf"
end

function genuine_0_modifier_fear:StatusEffectPriority()
 	return MODIFIER_PRIORITY_HIGH
end

function genuine_0_modifier_fear:PlayEfxStart()
	local particle_cast1 = "particles/econ/items/dark_willow/dark_willow_immortal_2021/dw_2021_willow_wisp_spell_debuff.vpcf"
	local particle_cast2 = "particles/genuine/genuine_fear.vpcf"
	local effect_cast1 = ParticleManager:CreateParticle(particle_cast1, PATTACH_OVERHEAD_FOLLOW, self.parent)
	local effect_cast2 = ParticleManager:CreateParticle(particle_cast2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	
	self:AddParticle(effect_cast1, false, false, -1, false, false)
	self:AddParticle(effect_cast2, false, false, -1, false, false)

    if IsServer() then self.parent:EmitSound("Genuine.Fear.Loop") end
end