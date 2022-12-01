bald_5_modifier_aura = class({})

function bald_5_modifier_aura:IsHidden() return true end
function bald_5_modifier_aura:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function bald_5_modifier_aura:IsAura() return true end
function bald_5_modifier_aura:GetModifierAura() return "bald_5_modifier_aura_effect" end
function bald_5_modifier_aura:GetAuraRadius() return self:GetAbility():GetAOERadius() end
function bald_5_modifier_aura:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function bald_5_modifier_aura:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function bald_5_modifier_aura:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end
function bald_5_modifier_aura:GetAuraEntityReject(hEntity) if hEntity == self:GetCaster() then return true end end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_5_modifier_aura:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:PlayEfxStart() end
end

function bald_5_modifier_aura:OnRefresh(kv)
end

function bald_5_modifier_aura:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bald_5_modifier_aura:PlayEfxStart()
	local particle_cast = "particles/bald/bald_ion/bald_ion.vpcf"
	local sound_cast = "Hero_Dark_Seer.Ion_Shield_Start"
	local sound_loop = "Hero_Dark_Seer.Ion_Shield_lp"
	local hull1 = self.parent:GetModelScale() * 70
	local hull2 = self.parent:GetModelScale() * 70

	if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, false) end
	self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(hull1, hull2, 0))
	self:AddParticle(self.effect_cast, false, false, -1, false, false)
end