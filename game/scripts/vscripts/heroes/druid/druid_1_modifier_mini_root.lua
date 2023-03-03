druid_1_modifier_mini_root = class({})

function druid_1_modifier_mini_root:IsHidden() return true end
function druid_1_modifier_mini_root:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function druid_1_modifier_mini_root:IsAura() return true end
function druid_1_modifier_mini_root:GetModifierAura() return "druid_1_modifier_mini_root_aura_effect" end
function druid_1_modifier_mini_root:GetAuraRadius() return 30 end
function druid_1_modifier_mini_root:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function druid_1_modifier_mini_root:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function druid_1_modifier_mini_root:GetAuraEntityReject(hEntity) return false end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_1_modifier_mini_root:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	if IsServer() then self:PlayEfxStart() end
end

function druid_1_modifier_mini_root:OnRefresh(kv)
end

function druid_1_modifier_mini_root:OnRemoved()
	RemoveFOWViewer(self.caster:GetTeamNumber(), self.fow)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_1_modifier_mini_root:PlayEfxStart()
	local radius = self.ability:GetSpecialValueFor("path_radius")
	self.fow = AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), radius + 50, self:GetDuration(), false)

	local string = "particles/druid/druid_bush.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
  ParticleManager:SetParticleControl(effect_cast, 10, Vector(self:GetDuration(), 0, 0 ))
	self:AddParticle(effect_cast, false, false, -1, false, false)
    
	if IsServer() then self.parent:EmitSound("Druid.Foot_" .. RandomInt(1, 3)) end
end