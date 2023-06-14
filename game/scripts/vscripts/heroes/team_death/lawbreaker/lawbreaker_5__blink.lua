lawbreaker_5__blink = class({})
LinkLuaModifier("lawbreaker_5_modifier_charges", "heroes/team_death/lawbreaker/lawbreaker_5_modifier_charges", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("lawbreaker_5_modifier_blink", "heroes/team_death/lawbreaker/lawbreaker_5_modifier_blink", LUA_MODIFIER_MOTION_NONE)

-- INIT

  -- function lawbreaker_5__blink:GetIntrinsicModifierName()
  --   return "lawbreaker_5_modifier_charges"
  -- end

  function lawbreaker_5__blink:OnUpgrade()
    local caster = self:GetCaster()

    -- if self:IsCooldownReady() == false then
    --   if IsServer() then caster:FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), caster):ResetCharges() end
    -- end
  end

-- SPELL START

	function lawbreaker_5__blink:OnSpellStart()
		local caster = self:GetCaster()
    local origin = caster:GetOrigin()
    local direction = (origin - self:GetCursorPosition()):Normalized()
    local blink_point = origin - (direction * self:GetSpecialValueFor("range"))

    --if IsServer() then caster:FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), caster):DecrementStackCount() end

		ProjectileManager:ProjectileDodge(caster)
    FindClearSpaceForUnit(caster, blink_point, true)
    caster:MoveToPosition(self:GetCursorPosition())

    if IsServer() then self:PlayEfxBlink(origin, caster:GetOrigin()) end
	end

-- EFFECTS

  function lawbreaker_5__blink:PlayEfxBlink(start_point, end_point)
    local caster = self:GetCaster()
    local particle_start = "particles/lawbreaker/blink/lawbreaker_blink_start.vpcf"
    local particle_end = "particles/lawbreaker/blink/lawbreaker_blink_end.vpcf"

    local blink_start_fx = ParticleManager:CreateParticle(particle_start, PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(blink_start_fx, 0, start_point)
    ParticleManager:ReleaseParticleIndex(blink_start_fx)

    local blink_end_fx = ParticleManager:CreateParticle(particle_end, PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(blink_end_fx, 0, end_point)
    ParticleManager:ReleaseParticleIndex(blink_end_fx)

    if IsServer() then caster:EmitSound("DOTA_Item.Arcane_Blink.Activate") end
  end