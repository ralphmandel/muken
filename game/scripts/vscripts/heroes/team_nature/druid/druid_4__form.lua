druid_4__form = class({})
LinkLuaModifier("druid_4_modifier_form", "heroes/team_nature/druid/druid_4_modifier_form", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_buff", "modifiers/_modifier_percent_movespeed_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_break", "modifiers/_modifier_break", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_fear", "modifiers/_modifier_fear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_fear_status_efx", "modifiers/_modifier_fear_status_efx", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function druid_4__form:Spawn()
    self:SetCurrentAbilityCharges(0)
  end

  function druid_4__form:OnOwnerSpawned()
    self:SetActivated(true)
    self:SetCurrentAbilityCharges(0)
  end

-- SPELL START

  function druid_4__form:OnSpellStart()
    local caster = self:GetCaster()

    local main = self:GetSpecialValueFor("main")
    local str = self:GetSpecialValueFor("str")
    local mnd = self:GetSpecialValueFor("mnd")
    local con = self:GetSpecialValueFor("con")
    local agi = self:GetSpecialValueFor("agi")

    local form = RandomInt(1, 3) -- black=STR, brown=CON, white=MND
    if form == 1 then str = str + main end
    if form == 2 then con = con + main end
    if form == 3 then mnd = mnd + main end
  
    AddBonus(self, "_1_STR", caster, str, 0, nil)
    AddBonus(self, "_2_MND", caster, mnd, 0, nil)
    AddBonus(self, "_1_CON", caster, con, 0, nil)
    AddBonus(self, "_1_AGI", caster, agi, 0, nil)

    caster:AddNewModifier(caster, self, "druid_4_modifier_form", {
      duration = CalcStatus(self:GetSpecialValueFor("duration"), caster, caster),
      form = form
    })
  end

-- EFFECTS