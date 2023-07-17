hunter_1__shot = class({})

-- INIT

-- SPELL START

  function hunter_1__shot:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if IsServer() then caster:EmitSound("Ability.MKG_AssassinateLoad") end

    return true
  end

	function hunter_1__shot:OnSpellStart()
		local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local bDodgeable = true
    local kill_chance = (100 - target:GetHealthPercent()) * self:GetSpecialValueFor("kill_chance")
    local kill = false

    if RandomFloat(0, 100) < kill_chance then
      bDodgeable = false
      kill = true
    end

    ProjectileManager:CreateTrackingProjectile({
      Target = target,
      Source = caster,
      Ability = self,	
      
      EffectName = "particles/econ/items/sniper/sniper_charlie/sniper_assassinate_charlie.vpcf",
      iMoveSpeed = 4000,
      bDodgeable = true,
      ExtraData = { kill = kill }
    })

    if IsServer() then
      caster:EmitSound("Ability.Assassinate")
      target:EmitSound("Hero_Sniper.AssassinateProjectile")
    end
	end

  function hunter_1__shot:OnProjectileHit_ExtraData(target, vLocation, extradata)
    if (not target) or target:IsInvulnerable() or target:IsOutOfGame() or target:TriggerSpellAbsorb( self ) then return end
		local caster = self:GetCaster()

    if IsServer() then target:EmitSound("Hero_Sniper.AssassinateDamage") end

    if extradata.kill == 1 then
      target:Kill(self, caster)
      return
    end

    ApplyDamage({
      victim = target, attacker = caster,
      damage = self:GetSpecialValueFor("damage"),
      damage_type = self:GetAbilityDamageType(),
      ability = self
    })
  
    target:Interrupt()
  end

-- EFFECTS