druid_1_modifier_mini_root = class({})

function druid_1_modifier_mini_root:IsHidden() return true end
function druid_1_modifier_mini_root:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_1_modifier_mini_root:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	if IsServer() then
    self:PlayEfxStart()
    self:OnIntervalThink()
  end
end

function druid_1_modifier_mini_root:OnRefresh(kv)
end

function druid_1_modifier_mini_root:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_1_modifier_mini_root:OnIntervalThink()
  local enemies = FindUnitsInRadius(
    self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, 30,
    self.ability:GetAbilityTargetTeam(), self.ability:GetAbilityTargetType(),
    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false
  )

  for _,enemy in pairs(enemies) do
    if IsServer() then enemy:EmitSound("Druid.Foot_" .. RandomInt(1, 3)) end

    if enemy:IsMagicImmune() == false and
    RandomFloat(1, 100) <= self.ability:GetSpecialValueFor("special_root_chance") then
      local root_duration = self.ability:GetSpecialValueFor("special_root_duration")
      enemy:AddNewModifier(self.caster, self.ability, "_modifier_root", {
        duration = CalcStatus(root_duration, self.caster, enemy), effect = 5
      })
    end

    if self.bush then ParticleManager:DestroyParticle(self.bush, true) end
    self:Destroy()
    return
  end

  if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_1_modifier_mini_root:PlayEfxStart()
	local radius = self.ability:GetSpecialValueFor("path_radius") * 0.6

	local string = "particles/druid/druid_bush.vpcf"
	self.bush = ParticleManager:CreateParticle(string, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(self.bush, 0, self.parent:GetOrigin())
  ParticleManager:SetParticleControl(self.bush, 10, Vector(self:GetDuration(), 0, 0 ))
	self:AddParticle(self.bush, false, false, -1, false, false)
    
	if IsServer() then self.parent:EmitSound("Druid.Foot_" .. RandomInt(1, 3)) end
end