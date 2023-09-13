templar_3__circle = class({})
LinkLuaModifier("templar_3_modifier_circle", "heroes/sun/templar/templar_3_modifier_circle", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("templar_3_modifier_aura_effect", "heroes/sun/templar/templar_3_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("templar_3_modifier_combo", "heroes/sun/templar/templar_3_modifier_combo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

function templar_3__circle:GetAOERadius()
  return self:GetSpecialValueFor("radius")
end

-- SPELL START

	function templar_3__circle:OnSpellStart()
		local caster = self:GetCaster()
    local loc = self:GetCursorPosition()

    if IsServer() then self:PlayEfxStart(loc) end

    CreateModifierThinker(caster, self, "templar_3_modifier_circle", {
      duration = self:GetSpecialValueFor("duration"),
    }, loc, caster:GetTeamNumber(), false)
	end

-- EFFECTS

  function templar_3__circle:PlayEfxStart(point)
    local caster = self:GetCaster()
    local particle_cast = "particles/templar/circle/templar_circle_pit_pre.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(effect_cast, 0, point)
    ParticleManager:SetParticleControl(effect_cast, 1, Vector(self:GetAOERadius(), 1, 1))
    ParticleManager:ReleaseParticleIndex(effect_cast)

    if IsServer() then caster:EmitSound("Hero_Oracle.RainOfDestiny.Cast") end
  end