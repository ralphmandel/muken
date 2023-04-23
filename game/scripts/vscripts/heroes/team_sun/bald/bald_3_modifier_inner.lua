bald_3_modifier_inner = class({})

function bald_3_modifier_inner:IsHidden() return false end
function bald_3_modifier_inner:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_3_modifier_inner:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.origin = self.parent:GetOrigin()
  self.stomp = 0
  
  self.spell_immunity = self:GetAbility():GetSpecialValueFor("special_spell_immunity")
  self.giant = self:GetAbility():GetSpecialValueFor("special_giant")

  self.ability:SetActivated(false)
  self.ability:EndCooldown()

	if IsServer() then
		self:PlayEfxStart()
    if self.spell_immunity == 1 then self:PlayEfxBKB() end
    if self.giant == 1 then self:OnIntervalThink() end
	end
end

function bald_3_modifier_inner:OnRefresh(kv)
	if IsServer() then self:PlayEfxStart() end
end

function bald_3_modifier_inner:OnRemoved()
  self.ability:ResetModifierStack()
  self.ability:SetActivated(true)
  self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_3_modifier_inner:CheckState()
	local state = {}

  if self.giant == 1 then
  	table.insert(state, MODIFIER_STATE_ALLOW_PATHING_THROUGH_CLIFFS, true)
  	table.insert(state, MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES, true)
  	table.insert(state, MODIFIER_STATE_NO_UNIT_COLLISION, true)
  end

  if self.spell_immunity == 1 then
    table.insert(state, MODIFIER_STATE_MAGIC_IMMUNE, true)
  end

	return state
end

function bald_3_modifier_inner:OnIntervalThink()
  local trees = GridNav:GetAllTreesAroundPoint(self.parent:GetOrigin(), self.parent:GetModelScale() * 75, false)
  if trees == nil then return end
  for _,tree in pairs(trees) do tree:CutDown(self.parent:GetTeamNumber()) end

  local distance = (self.origin - self.parent:GetOrigin()):Length2D()
  if distance >= 50 then
    self.stomp = self.stomp + distance
    self.origin = self.parent:GetOrigin()
  end

  if self.stomp >= 150 then
    self.stomp = self.stomp - 150
    self:PerformStomp()
  end

  if IsServer() then self:StartIntervalThink(0.1) end
end

-- UTILS -----------------------------------------------------------

function bald_3_modifier_inner:PerformStomp()
  local stomp_radius = self.parent:GetModelScale() * self.ability:GetSpecialValueFor("special_stomp_radius")
  local stomp_damage = self.parent:GetModelScale() * self.ability:GetSpecialValueFor("special_stomp_damage")

  local enemies = FindUnitsInRadius(
    self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, stomp_radius,
    DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false
  )

  for _,enemy in pairs(enemies) do
    ApplyDamage({
      attacker = self.parent, victim = enemy,
      damage = stomp_damage,
      damage_type = DAMAGE_TYPE_PHYSICAL,
      ability = self.ability
    })
  end

  local trees = GridNav:GetAllTreesAroundPoint(self.parent:GetOrigin(), stomp_radius, false)
  if trees then
    for _,tree in pairs(trees) do
      tree:CutDown(self.parent:GetTeamNumber())
    end
  end

  if IsServer() then self:PlayEfxShake(stomp_radius) end
end

-- EFFECTS -----------------------------------------------------------

function bald_3_modifier_inner:PlayEfxStart()
	local string = "particles/bald/bald_inner/bald_inner_owner.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(particle, 10, Vector(self.parent:GetModelScale() * 100, 0, 0))
	ParticleManager:SetParticleControlEnt(particle, 2, self.parent, PATTACH_POINT_FOLLOW, "attach_weapon", Vector(0,0,0), true)
	self:AddParticle(particle, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_EarthSpirit.Magnetize.Cast") end
end

function bald_3_modifier_inner:PlayEfxBKB()
	local bkb_particle = ParticleManager:CreateParticle("particles/items_fx/black_king_bar_avatar.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(bkb_particle, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	self:AddParticle(bkb_particle, false, false, -1, true, false)
end

function bald_3_modifier_inner:PlayEfxShake(stomp_radius)
  local string = "particles/osiris/poison_alt/osiris_poison_splash_shake.vpcf"
  local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, self.parent)
  ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
  ParticleManager:SetParticleControl(particle, 1, Vector((self.parent:GetModelScale() - 1) * 800, 0, 0))
	ParticleManager:ReleaseParticleIndex(particle)

	local particle_stomp = "particles/units/heroes/hero_earthshaker/earthshaker_aftershock.vpcf"
	local effect_stomp = ParticleManager:CreateParticle(particle_stomp, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_stomp, 1, Vector(stomp_radius, stomp_radius, stomp_radius))
	ParticleManager:ReleaseParticleIndex(effect_stomp)

  if IsServer() then self.parent:EmitSound("Bald.Move") end
end