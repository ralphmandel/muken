druid_1_modifier_root = class({})

function druid_1_modifier_root:IsHidden() return true end
function druid_1_modifier_root:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_1_modifier_root:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	if IsServer() then
    self:PlayEfxStart()
    self:OnIntervalThink()
  end
end

function druid_1_modifier_root:OnRefresh(kv)
end

function druid_1_modifier_root:OnRemoved()
	RemoveFOWViewer(self.caster:GetTeamNumber(), self.fow)
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_1_modifier_root:OnIntervalThink()
  local enemies = FindUnitsInRadius(
    self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, 50,
    self.ability:GetAbilityTargetTeam(), self.ability:GetAbilityTargetType(),
    self.ability:GetAbilityTargetFlags(), FIND_CLOSEST, false
  )

  for _,enemy in pairs(enemies) do
    local root_duration = self.ability:GetSpecialValueFor("root_duration")
    enemy:AddNewModifier(self.caster, self.ability, "_modifier_root", {
      duration = CalcStatus(root_duration, self.caster, enemy), effect = 5
    })

    local silence_duration = self.ability:GetSpecialValueFor("special_silence_duration")
    if silence_duration > 0 then
      local mod = enemy:FindAllModifiersByName("_modifier_silence")
      for _,modifier in pairs(mod) do
        if modifier:GetAbility() == self.ability then modifier:Destroy() end
      end

      enemy:AddNewModifier(self.caster, self.ability, "_modifier_silence", {
        duration = CalcStatus(silence_duration, self.caster, enemy)
      })
    end

    local damage = self.ability:GetSpecialValueFor("special_damage")
    if damage > 0 then
      ApplyDamage({
        attacker = self.caster, victim = enemy, damage = damage,
        damage_type = self.ability:GetAbilityDamageType(),
        ability = self.ability
      })
    end

    self:Destroy()
    return
  end

  if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_1_modifier_root:PlayEfxStart()
	local radius = self.ability:GetSpecialValueFor("path_radius")
	self.fow = AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), radius + 50, self:GetDuration(), false)

	local string = "particles/druid/druid_skill2_ground_root.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
  ParticleManager:SetParticleControl(effect_cast, 10, Vector(self:GetDuration(), 0, 0 ))
	self:AddParticle(effect_cast, false, false, -1, false, false)
    
	if IsServer() then self.parent:EmitSound("Druid.Move_" .. RandomInt(1, 3)) end
end