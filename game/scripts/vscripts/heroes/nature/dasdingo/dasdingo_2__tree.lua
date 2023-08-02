dasdingo_2__tree = class({})
LinkLuaModifier("dasdingo_2_modifier_aura", "heroes/nature/dasdingo/dasdingo_2_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_2_modifier_aura_effect", "heroes/nature/dasdingo/dasdingo_2_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function dasdingo_2__tree:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

-- SPELL START

  function dasdingo_2__tree:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    local loc = self:GetCursorPosition()
    local trees = GridNav:GetAllTreesAroundPoint(loc, 25, false)
    self.tree = nil

    if trees then
      for _, tree in pairs(trees) do
        self.tree = tree
        return true
      end
    end

    return false
  end

  function dasdingo_2__tree:OnSpellStart()
    if self.tree == nil then return end
    if IsValidEntity(self.tree) == false then return end

    local caster = self:GetCaster()

    local test = CreateModifierThinker(
      caster, self, "dasdingo_2_modifier_aura", {
        duration = self:GetSpecialValueFor("duration"),
        tree_index = self.tree:entindex()
      }, self.tree:GetAbsOrigin(), caster:GetTeamNumber(), false
    )
  end

-- EFFECTS