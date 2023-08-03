templar_1_modifier_aura_effect = class({})

function templar_1_modifier_aura_effect:IsHidden() return false end
function templar_1_modifier_aura_effect:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function templar_1_modifier_aura_effect:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  AddModifier(self.parent, self.caster, self.ability, "_modifier_heal_amp", {
    amount = self.ability:GetSpecialValueFor("heal_amp")
  }, false)

  if IsServer() then
    self:SetStackCount(0)
    self.ability:UpdateCount()
    self.parent:EmitSound("Hero_Pangolier.TailThump.Cast")
  end
end

function templar_1_modifier_aura_effect:OnRefresh(kv)
end

function templar_1_modifier_aura_effect:OnRemoved(kv)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_heal_amp", self.ability)
	RemoveBonus(self.ability, "DEF", self.parent)
  self.ability:UpdateCount()
end

-- API FUNCTIONS -----------------------------------------------------------


function templar_1_modifier_aura_effect:OnStackCountChanged(old)
  local def = self.ability:GetSpecialValueFor("def_base") + (self.ability:GetSpecialValueFor("def_bonus") * self:GetStackCount())

	RemoveBonus(self.ability, "DEF", self.parent)
  AddBonus(self.ability, "DEF", self.parent, def, 0, nil)

  if self:GetStackCount() > 0 then
    if IsServer() then self:PlayEfxStart() end
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function templar_1_modifier_aura_effect:PlayEfxStart()
	local special = 50
	local string = "particles/dasdingo/dasdingo_aura.vpcf"
  local size = 0
  local shield_count = self:GetStackCount() + 1

  if GetHeroName(self.parent:GetUnitName()) == "lawbreaker" then size = 185 end
  if GetHeroName(self.parent:GetUnitName()) == "bloodstained" then size = 210 end
  if GetHeroName(self.parent:GetUnitName()) == "bocuse" then size = 210 end
  if GetHeroName(self.parent:GetUnitName()) == "fleaman" then size = 155 end

  if GetHeroName(self.parent:GetUnitName()) == "dasdingo" then size = 175 end
  if GetHeroName(self.parent:GetUnitName()) == "druid" then size = 185 end
  if GetHeroName(self.parent:GetUnitName()) == "hunter" then size = 165 end

  if GetHeroName(self.parent:GetUnitName()) == "genuine" then size = 185 end
  if GetHeroName(self.parent:GetUnitName()) == "icebreaker" then size = 155 end

  if GetHeroName(self.parent:GetUnitName()) == "ancient" then size = 250 end
  if GetHeroName(self.parent:GetUnitName()) == "paladin" then size = 215 end
  if GetHeroName(self.parent:GetUnitName()) == "templar" then size = 235 end

  if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, true) end

  print("kubo", shield_count, math.floor(100 / shield_count), size)

	self.effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.effect_cast, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(self.effect_cast, 3, Vector(special, 0, 0))
  ParticleManager:SetParticleControl(self.effect_cast, 10, Vector(shield_count, math.floor(100 / shield_count), 0))
	ParticleManager:SetParticleControl(self.effect_cast, 11, Vector(0, 0, size))

	self:AddParticle(self.effect_cast, false, false, -1, false, false)
end