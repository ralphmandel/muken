ancient_3__roar = class({})
LinkLuaModifier("ancient_3_modifier_pre", "heroes/sun/ancient/ancient_3_modifier_pre", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function ancient_3__roar:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    AddModifier(caster, self, "ancient_3_modifier_pre", {}, false)
    return true
  end

  function ancient_3__roar:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()
    caster:RemoveModifierByName("ancient_3_modifier_pre")
  end

	function ancient_3__roar:OnSpellStart()
		local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local loc_start = caster:GetOrigin()
    local direction = (loc_start - target:GetOrigin()):Normalized()
    local loc_end = loc_start - direction * self:GetCastRange(loc_start, nil)
    local flags = DOTA_DAMAGE_FLAG_NONE

    caster:RemoveModifierByName("ancient_3_modifier_pre")

    if caster:HasModifier("ancient_1_modifier_passive")
    and caster:PassivesDisabled() == false then
      flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK
    end

    if IsServer() then self:PlayEfxStart(loc_start, loc_end) end

    local enemies = FindUnitsInLine(
      caster:GetTeamNumber(), loc_start, loc_end, nil, self:GetSpecialValueFor("width"),
      self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags()
    )

    for _, enemy in pairs(enemies) do
      if IsServer() then enemy:EmitSound("Hero_PrimalBeast.Uproar.Projectile.Split") end

      ApplyDamage({
        victim = enemy, attacker = caster,
        damage = self:GetSpecialValueFor("damage"),
        damage_type = self:GetAbilityDamageType(),
        ability = self, damage_flags = flags
      })
    end
	end

-- EFFECTS

function ancient_3__roar:PlayEfxStart(loc_start, loc_end)
  local caster = self:GetCaster()

  local particle_cast = "particles/units/heroes/hero_beastmaster/beastmaster_primal_roar.vpcf"
  local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
  ParticleManager:SetParticleControlEnt(effect_cast, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
  ParticleManager:SetParticleControl(effect_cast, 1, loc_end)
  ParticleManager:ReleaseParticleIndex(effect_cast)

  local particle_shake = "particles/osiris/poison_alt/osiris_poison_splash_shake.vpcf"
	local effect = ParticleManager:CreateParticle(particle_shake, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(effect, 0, caster:GetOrigin())
	ParticleManager:SetParticleControl(effect, 1, Vector(1500, 0, 0))

  if IsServer() then caster:EmitSound("Hero_PrimalBeast.Uproar.Scepter") end
end