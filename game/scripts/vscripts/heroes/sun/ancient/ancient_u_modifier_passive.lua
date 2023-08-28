ancient_u_modifier_passive = class({})

function ancient_u_modifier_passive:IsHidden() return false end
function ancient_u_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_u_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	if IsServer() then
		self:OnIntervalThink()
		self:PlayEfxBuff()
	end
end

function ancient_u_modifier_passive:OnRefresh(kv)
end

function ancient_u_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_u_modifier_passive:DeclareFunctions()
	local funcs = {
    MODIFIER_EVENT_ON_ATTACKED
	}

	return funcs
end

function ancient_u_modifier_passive:OnAttacked(keys)
	if keys.attacker ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end

  local gain = self.ability:GetSpecialValueFor("energy_gain")

  -- if BaseStats(keys.attacker).has_crit == true then
  -- end

  IncreaseMana(self.parent, gain)
  self.ability:UpdateParticles()
end

function ancient_u_modifier_passive:OnIntervalThink()
  local interval = 1
  ReduceMana(self.parent, self.ability, self.ability:GetSpecialValueFor("energy_loss") * interval, false)
	self.ability:UpdateParticles()

	if IsServer() then self:StartIntervalThink(interval) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function ancient_u_modifier_passive:PlayEfxBuff()
	if self.ambient_aura then ParticleManager:DestroyParticle(self.ambient_aura, false) end
	self.ambient_aura = ParticleManager:CreateParticle("particles/ancient/ancient_aura_alt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.ambient_aura, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.ambient_aura, 1, Vector(0, 0, 0))
	self:AddParticle(self.ambient_aura, false, false, -1, false, false)
end

function ancient_u_modifier_passive:UpdateAmbients()
	if Cosmetics(self.parent) == nil then return end
	local ambient_back = Cosmetics(self.parent):GetAmbient("particles/ancient/ancient_back.vpcf")
	local ambient_weapon = Cosmetics(self.parent):GetAmbient("particles/ancient/ancient_weapon.vpcf")

	local value = self.parent:GetMana() * 0.7
	if self.ability.casting == true then value = 0 end

	if self.ambient_aura then ParticleManager:SetParticleControl(self.ambient_aura, 1, Vector(value, 0, 0)) end
	if ambient_back then ParticleManager:SetParticleControl(ambient_back, 20, Vector(value, 0, 0)) end
	if ambient_weapon then
		ParticleManager:SetParticleControl(ambient_weapon, 20, Vector(value, 30, 12))
		ParticleManager:SetParticleControl(ambient_weapon, 21, Vector(value * 0.01, 0, 0))
	end
end