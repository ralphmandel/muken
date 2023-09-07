icebreaker_3_modifier_skin = class({})

function icebreaker_3_modifier_skin:IsHidden() return false end
function icebreaker_3_modifier_skin:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_3_modifier_skin:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	if IsServer() then self:PlayEfxStart() end
end

function icebreaker_3_modifier_skin:OnRefresh(kv)
	if IsServer() then self:PlayEfxStart() end
end

function icebreaker_3_modifier_skin:OnRemoved()
  if IsServer() then self.parent:EmitSound("Hero_Lich.IceAge.Tick") end
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_3_modifier_skin:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
	}

	return funcs
end

function icebreaker_3_modifier_skin:GetModifierPhysical_ConstantBlock(keys)
	if keys.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then return 0 end
	if RandomFloat(0, 100) >= self.ability:GetSpecialValueFor("chance") then return 0 end

  AddModifier(keys.attacker, self.ability, "icebreaker__modifier_hypo", {
    stack = self.ability:GetSpecialValueFor("stack")
  }, false)
  
	if IsServer() then self:PlayEfxBlock(keys.attacker) end

  return 0
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