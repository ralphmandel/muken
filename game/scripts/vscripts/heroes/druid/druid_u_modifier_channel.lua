druid_u_modifier_channel = class({})

function druid_u_modifier_channel:IsHidden() return true end
function druid_u_modifier_channel:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_u_modifier_channel:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  CreateModifierThinker(
		self.caster, self.ability, "druid_u_modifier_aura", {},
    self.ability.point, self.parent:GetTeamNumber(), false
	)

  if IsServer() then self:StartIntervalThink(0.1) end
end

function druid_u_modifier_channel:OnRefresh(kv)
end

function druid_u_modifier_channel:OnRemoved()
	if self.efx_channel then ParticleManager:DestroyParticle(self.efx_channel, false) end
	if self.efx_channel2 then ParticleManager:DestroyParticle(self.efx_channel2, false) end

  local thinkers = Entities:FindAllByClassname("npc_dota_thinker")
	for _,thinker in pairs(thinkers) do
		if thinker:GetOwner() == self.caster and thinker:HasModifier("druid_u_modifier_aura") then
			thinker:RemoveModifierByName("druid_u_modifier_aura")
		end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_u_modifier_channel:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}

	return funcs
end

function druid_u_modifier_channel:GetModifierConstantManaRegen()
	return -self:GetAbility():GetManaCost(self:GetAbility():GetLevel())
end

function druid_u_modifier_channel:OnIntervalThink()
	if self.parent:GetMana() < self.ability:GetManaCost(self.ability:GetLevel()) then self.parent:InterruptChannel() end
	if IsServer() then self:StartIntervalThink(0.1) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------