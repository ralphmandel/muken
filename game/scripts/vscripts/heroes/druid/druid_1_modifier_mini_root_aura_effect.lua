druid_1_modifier_mini_root_aura_effect = class({})

function druid_1_modifier_mini_root_aura_effect:IsHidden() return true end
function druid_1_modifier_mini_root_aura_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_1_modifier_mini_root_aura_effect:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	if IsServer() then self:OnIntervalThink() end
end

function druid_1_modifier_mini_root_aura_effect:OnRefresh(kv)
end

function druid_1_modifier_mini_root_aura_effect:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_1_modifier_mini_root_aura_effect:OnIntervalThink()
  if RandomFloat(1, 100) <= self.ability:GetSpecialValueFor("special_root_chance") then
    self.parent:AddNewModifier(self.caster, self.ability, "_modifier_root", {
      duration = CalcStatus(self.ability:GetSpecialValueFor("special_root_duration"), self.caster, self.parent),
      effect = 5
    })
  end

  if IsServer() then self:StartIntervalThink(1) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_1_modifier_mini_root_aura_effect:PlayEfxStart()
	local radius = self.ability:GetSpecialValueFor("path_radius")
	self.fow = AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), radius + 50, self:GetDuration(), false)

	local string = "particles/druid/druid_skill2_ground_root.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
  ParticleManager:SetParticleControl(effect_cast, 10, Vector(self:GetDuration(), 0, 0 ))
	self:AddParticle(effect_cast, false, false, -1, false, false)
    
	if IsServer() then self.parent:EmitSound("Druid.Move_" .. RandomInt(1, 3)) end
end