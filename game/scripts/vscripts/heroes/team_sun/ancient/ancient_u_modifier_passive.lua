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

  if BaseStats(keys.attacker).has_crit then
    gain = self.ability:GetSpecialValueFor("energy_gain_crit")
  end

  self.parent:GiveMana(gain)
  self.ability:UpdateCON()
  SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, self.parent, gain, self.caster)

  if IsServer() then self:StartIntervalThink(self.ability:GetSpecialValueFor("delay")) end
end

function ancient_u_modifier_passive:OnIntervalThink()
	self.parent:Script_ReduceMana(self.ability:GetSpecialValueFor("energy_loss") * 0.1, self.ability)
	self.ability:UpdateCON()

	if IsServer() then self:StartIntervalThink(0.1) end
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
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics == nil then return end
	local ambient_back = cosmetics:GetAmbient("particles/ancient/ancient_back.vpcf")
	local ambient_weapon = cosmetics:GetAmbient("particles/ancient/ancient_weapon.vpcf")

	local value = self.parent:GetMana() * 2.5
	if self.ability.casting == true then value = 0 end

	if self.ambient_aura then ParticleManager:SetParticleControl(self.ambient_aura, 1, Vector(value, 0, 0)) end
	if ambient_back then ParticleManager:SetParticleControl(ambient_back, 20, Vector(value, 0, 0)) end
	if ambient_weapon then
		ParticleManager:SetParticleControl(ambient_weapon, 20, Vector(value, 30, 12))
		ParticleManager:SetParticleControl(ambient_weapon, 21, Vector(value * 0.01, 0, 0))
	end
end