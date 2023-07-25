paladin_u_modifier_passive = class({})

function paladin_u_modifier_passive:IsHidden() return true end
function paladin_u_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function paladin_u_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.cast = false

  AddBonus(self.ability, "CON", self.parent, 0, self.ability:GetSpecialValueFor("con"), nil)
end

function paladin_u_modifier_passive:OnRefresh(kv)
end

function paladin_u_modifier_passive:OnRemoved()
  RemoveBonus(self.ability, "CON", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function paladin_u_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
	}

	return funcs
end

function paladin_u_modifier_passive:OnOrder(keys)
	if keys.unit ~= self.parent then return end

	if keys.ability then
		if keys.ability == self:GetAbility() and keys.order_type == 6 then
			self.cast = true
			return
		end
	end
	
	self.cast = false
end

function paladin_u_modifier_passive:GetModifierProcAttack_Feedback(keys)
  if self:ShouldLaunch(keys.target) == false then return end

  self.ability:UseResources(true, false, false, true)
  self.ability:SetCurrentAbilityCharges(self.ability:GetCurrentAbilityCharges() - 1)

  if IsServer() then
    self:PlayEfxHit(keys.target)
    self:PlayEfxScreenShake(keys.target)
  end  

  ApplyDamage({
    victim = keys.target, attacker = self.caster,
    damage = self.ability:GetSpecialValueFor("damage"),
    damage_type = self.ability:GetAbilityDamageType(),
    ability = self.ability
  })
end

-- UTILS -----------------------------------------------------------

function paladin_u_modifier_passive:ShouldLaunch(target)
	if self.ability:GetAutoCastState() then
    local nResult = UnitFilter(
      target, self.ability:GetAbilityTargetTeam(),
      self.ability:GetAbilityTargetType(),
      self.ability:GetAbilityTargetFlags(),
      self.caster:GetTeamNumber()
    )

    if nResult == UF_SUCCESS then
      self.cast = true
    end
  end

	if self.cast == true and self.parent:IsSilenced() == false and self.ability:IsFullyCastable() then return true end

	return false
end

-- EFFECTS -----------------------------------------------------------

function paladin_u_modifier_passive:PlayEfxHit(target)
  local string = "particles/units/heroes/hero_omniknight/omniknight_shard_hammer_of_purity_target.vpcf"
  local effect = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, target)
  ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
  ParticleManager:ReleaseParticleIndex(effect)

  local particle_cast = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_spawn_v2.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
  ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())

  if IsServer() then
    target:EmitSound("Hero_Omniknight.HammerOfPurity.Target")
    self.parent:EmitSound("Hero_Centaur.DoubleEdge")
  end
end

function paladin_u_modifier_passive:PlayEfxScreenShake(target)
  local string = "particles/bioshadow/bioshadow_poison_hit_shake.vpcf"
  local effect = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, target)
  ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
  ParticleManager:SetParticleControl(effect, 1, Vector(75, 0, 0))
  ParticleManager:ReleaseParticleIndex(effect)

  local effect = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, self.parent)
  ParticleManager:SetParticleControl(effect, 0, self.parent:GetOrigin())
  ParticleManager:SetParticleControl(effect, 1, Vector(75, 0, 0))
  ParticleManager:ReleaseParticleIndex(effect)
end