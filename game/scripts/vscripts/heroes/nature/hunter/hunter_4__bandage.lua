hunter_4__bandage = class({})
LinkLuaModifier("hunter_4_modifier_bandage", "heroes/nature/hunter/hunter_4_modifier_bandage", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function hunter_4__bandage:OnSpellStart()
    local caster = self:GetCaster()
    local tree = self:GetCursorTarget()

    tree:CutDownRegrowAfter(180, caster:GetTeamNumber())

    caster:Purge(false, true, false, false, false)
    caster:Heal(CalcHeal(caster, self:GetSpecialValueFor("heal")), self)
    if IsServer() then self:PlayEfxHeal(caster) end

    AddModifier(caster, self, "hunter_4_modifier_bandage", {duration = self:GetSpecialValueFor("duration")}, true)
	end

-- EFFECTS

  function hunter_4__bandage:PlayEfxHeal(target)
    local particle = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
    local effect_parent = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(effect_parent, 1, target:GetOrigin())
    ParticleManager:ReleaseParticleIndex(effect_parent)
  end