druid_2_modifier_aura = class({})

function druid_2_modifier_aura:IsHidden()
	return false
end

function druid_2_modifier_aura:IsPurgable()
	return false
end

function druid_2_modifier_aura:IsAura()
	return true
end

function druid_2_modifier_aura:GetModifierAura()
	return "druid_2_modifier_aura_effect"
end

function druid_2_modifier_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function druid_2_modifier_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function druid_2_modifier_aura:GetAuraRadius()
	return self:GetAbility():GetAOERadius()
end

-----------------------------------------------------------

function druid_2_modifier_aura:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then
		self:PlayEfxStart()
	end
end

function druid_2_modifier_aura:OnRefresh(kv)
end

function druid_2_modifier_aura:OnRemoved(kv)
	RemoveFOWViewer(self.caster:GetTeamNumber(), self.fow)
end

-----------------------------------------------------------

function druid_2_modifier_aura:PlayEfxStart()
	self.fow = AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), self.ability:GetAOERadius() + 50, self:GetDuration(), false)

	local string = "particles/druid/druid_skill2_ground_root.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
    ParticleManager:SetParticleControl(effect_cast, 1, Vector(self.radius, 0, 0 ))
	self:AddParticle(effect_cast, false, false, -1, false, false)
    
	if IsServer() then self.parent:EmitSound("Druid.Bramble_" .. RandomInt(1, 3)) end
end