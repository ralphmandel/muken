hunter_2__aim = class({})
LinkLuaModifier("hunter_2_modifier_aim", "heroes/nature/hunter/hunter_2_modifier_aim", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("hunter_2_modifier_timer", "heroes/nature/hunter/hunter_2_modifier_timer", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

function hunter_2__aim:OnSpellStart()
  local caster = self:GetCaster()

  AddModifier(caster, self, "hunter_2_modifier_aim", {}, false)

  if IsServer() then
    caster:EmitSound("DOTA_Item.MaskOfMadness.Activate")
    caster:EmitSound("Hero_Sniper.TakeAim.Cast")
  end
end

-- EFFECTS