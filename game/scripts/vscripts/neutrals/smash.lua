smash = class({})
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

function smash:OnAbilityPhaseStart()
  local caster = self:GetCaster()
  if IsServer() then caster:EmitSound("Generic.Jump") end

  return true
end

function smash:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  if IsServer() then caster:StopSound("Generic.Jump") end
end

function smash:OnSpellStart()
  local caster = self:GetCaster()

	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(), caster:GetOrigin(), nil, self:GetSpecialValueFor("stun_radius"),
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false
	)

	for _,enemy in pairs(enemies) do		
		enemy:AddNewModifier(caster, self, "_modifier_stun", {
			duration = CalcStatus(self:GetSpecialValueFor("stun_duration"), caster, enemy)
		})

    ApplyDamage({
      attacker = caster, victim = enemy, ability = self,
      damage = self:GetSpecialValueFor("stun_damage"),
      damage_type = self:GetAbilityDamageType(),
    })
	end

  self:PlayEfxStart()
end

function smash:PlayEfxStart()
  local caster = self:GetCaster()
  local string = "particles/neutral_fx/ogre_bruiser_smash.vpcf"
  local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, caster)
  ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
  ParticleManager:ReleaseParticleIndex(particle)

  if IsServer() then caster:EmitSound("n_creep_OgreBruiser.Smash.Stun") end
end