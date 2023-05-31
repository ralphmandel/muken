genuine_1__shooting = class({})
LinkLuaModifier("genuine_1_modifier_orb", "heroes/team_moon/genuine/genuine_1_modifier_orb", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function genuine_1__shooting:Spawn()
    if self:IsTrained() == false then self:UpgradeAbility(true) end
  end

  function genuine_1__shooting:GetIntrinsicModifierName()
		return "genuine_1_modifier_orb"
	end

	function genuine_1__shooting:GetProjectileName()
		return "particles/genuine/shooting_star/genuine_shooting.vpcf"
	end

-- SPELL START

  function genuine_1__shooting:OnOrbFire(keys)
    local caster = self:GetCaster()
    if IsServer() then caster:EmitSound("Hero_DrowRanger.FrostArrows") end
  end

  function genuine_1__shooting:OnOrbImpact(keys)
    local caster = self:GetCaster()
    if IsServer() then keys.target:EmitSound("Hero_DrowRanger.Marksmanship.Target") end

    if keys.target:HasModifier("genuine_u_modifier_star") then
      local mana_steal = keys.target:GetMaxMana() * self:GetSpecialValueFor("mana_steal") * 0.01
      StealMana(keys.target, caster, self, mana_steal)
    end

    ApplyDamage({
      victim = keys.target, attacker = caster,
      damage = self:GetSpecialValueFor("damage"),
      damage_type = self:GetAbilityDamageType(),
      ability = self
    })
  end

  function genuine_1__shooting:OnOrbFail(keys)
  end

-- EFFECTS