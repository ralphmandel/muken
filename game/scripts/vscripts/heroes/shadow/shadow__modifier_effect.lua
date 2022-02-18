shadow__modifier_effect = class ({})

function shadow__modifier_effect:IsHidden()
    return true
end

function shadow__modifier_effect:IsPurgable()
    return false
end

-----------------------------------------------------------

function shadow__modifier_effect:OnCreated(kv)
	self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:PlayEfxStart() end
end

function shadow__modifier_effect:OnRefresh(kv)
end

-----------------------------------------------------------

function shadow__modifier_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}

	return funcs
end

function shadow__modifier_effect:OnAttackLanded(keys)
	if keys.attacker ~= self:GetParent() then return end
	if IsServer() then self:GetParent():EmitSound("Hero_PhantomAssassin.Attack") end
end

function shadow__modifier_effect:GetAttackSound(keys)
    return ""
end

------------------------------------------------------------

function shadow__modifier_effect:GetStatusEffectName()
    return "particles/status_fx/status_effect_phantom_assassin_fall20_active_blur.vpcf"
end

function shadow__modifier_effect:StatusEffectPriority()
	return 99999999
end

function shadow__modifier_effect:PlayEfxStart()
	self.effect = ParticleManager:CreateParticle("particles/units/heroes/hero_spectre/spectre_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect, 0, self.parent:GetOrigin())
end

function shadow__modifier_effect:StopEfxStart(target, radius)
	if self.effect then ParticleManager:DestroyParticle(self.effect, false) end
end