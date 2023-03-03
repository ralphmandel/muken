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
    local debuff_duration = CalcStatus(self.ability:GetSpecialValueFor("root_duration"), self.caster, enemy)
    local damage = self.ability:GetSpecialValueFor("special_damage")

    enemy:AddNewModifier(self.caster, self.ability, "_modifier_root", {
      duration = debuff_duration, effect = 5
    })

    if damage > 0 then
      enemy:AddNewModifier(self.caster, self.ability, "_modifier_silence", {duration = debuff_duration})
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