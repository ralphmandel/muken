druid_1_modifier_root = class({})

function druid_1_modifier_root:IsHidden() return true end
function druid_1_modifier_root:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function druid_1_modifier_root:IsAura() return self:GetAbility():GetSpecialValueFor("special_permanent_bush") == 1 end
function druid_1_modifier_root:GetModifierAura() return "druid_1_modifier_root_aura_effect" end
function druid_1_modifier_root:GetAuraRadius() return 50 end
function druid_1_modifier_root:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function druid_1_modifier_root:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function druid_1_modifier_root:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end
function druid_1_modifier_root:GetAuraEntityReject(hEntity) return false end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_1_modifier_root:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	if IsServer() then
    self:PlayEfxStart()
    if self:IsAura() == false then
      self:OnIntervalThink()
    end
  end
end

function druid_1_modifier_root:OnRefresh(kv)
end

function druid_1_modifier_root:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_1_modifier_root:OnIntervalThink()
  local enemies = FindUnitsInRadius(
    self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, 50,
    self.ability:GetAbilityTargetTeam(), self.ability:GetAbilityTargetType(),
    self.ability:GetAbilityTargetFlags(), FIND_CLOSEST, false
  )

  for _,enemy in pairs(enemies) do
    enemy:AddNewModifier(self.caster, self.ability, "druid_1_modifier_root_aura_effect", {
      duration = CalcStatus(self.ability:GetSpecialValueFor("root_duration"), self.caster, enemy)
    })

    if self.bush then ParticleManager:DestroyParticle(self.bush, true) end
    self:Destroy()
    return
  end

  if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_1_modifier_root:PlayEfxStart()
	local radius = self.ability:GetSpecialValueFor("path_radius")
	--self.fow = AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), radius + 50, self:GetDuration(), false)

	local string = "particles/druid/druid_skill2_ground_root.vpcf"
	self.bush = ParticleManager:CreateParticle(string, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(self.bush, 0, self.parent:GetOrigin())
  ParticleManager:SetParticleControl(self.bush, 10, Vector(self:GetDuration(), 0, 0 ))
	self:AddParticle(self.bush, false, false, -1, false, false)
    
	if IsServer() then self.parent:EmitSound("Druid.Move_" .. RandomInt(1, 3)) end
end