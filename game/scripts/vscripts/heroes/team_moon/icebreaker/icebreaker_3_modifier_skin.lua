icebreaker_3_modifier_skin = class({})

function icebreaker_3_modifier_skin:IsHidden() return false end
function icebreaker_3_modifier_skin:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_3_modifier_skin:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  AddModifier(self.parent, self.caster, self.ability, "_modifier_mana_regen", {
    amount = self.ability:GetSpecialValueFor("special_mp_regen")
  }, false)

  self.hp_regen = self.ability:GetSpecialValueFor("special_hp_regen")

	if IsServer() then
		self:SetStackCount(self.ability:GetSpecialValueFor("layers"))
		self:PlayEfxStart()
	end
end

function icebreaker_3_modifier_skin:OnRefresh(kv)
	if IsServer() then
		self:SetStackCount(self.ability:GetSpecialValueFor("layers"))
		self:PlayEfxStart()
	end
end

function icebreaker_3_modifier_skin:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_mana_regen", self.ability)
  if IsServer() then self.parent:EmitSound("Hero_Lich.IceAge.Tick") end
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_3_modifier_skin:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK
	}

	return funcs
end

function icebreaker_3_modifier_skin:GetModifierConstantHealthRegen(keys)
  return self.hp_regen
end

function icebreaker_3_modifier_skin:GetModifierPhysical_ConstantBlock(keys)
  if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end
	if keys.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then return end

  AddModifier(keys.attacker, self.caster, self.ability, "icebreaker__modifier_hypo", {
    stack = self.ability:GetSpecialValueFor("hypo_stack")
  }, false)

  AddModifier(keys.attacker, self.caster, self.ability, "icebreaker__modifier_instant", {
    duration = self.ability:GetSpecialValueFor("special_mini_freeze")
  }, true)
  
	if IsServer() then
    self:DecrementStackCount()
    self:PlayEfxBlock(keys.attacker)
  end

	if self:GetStackCount() < 1 then
		self:Destroy()
	end

  return keys.damage
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function icebreaker_3_modifier_skin:PlayEfxStart()
  local particle = "particles/units/heroes/hero_lich/lich_ice_age.vpcf"
	local efx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
  ParticleManager:SetParticleControlEnt(efx, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, nil, self.parent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(efx, 2, Vector(300, 300, 300))
	self:AddParticle(efx, false, false, -1, false, false)

  local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_frost_armor.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
	self:AddParticle(particle2, false, false, -1, false, false)

  if IsServer() then self.parent:EmitSound("Hero_Lich.IceAge") end
end

function icebreaker_3_modifier_skin:PlayEfxBlock(target)
  if IsServer() then target:EmitSound("Hero_Lich.IceAge.Damage") end
end