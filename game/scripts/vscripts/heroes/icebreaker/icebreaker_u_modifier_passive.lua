icebreaker_u_modifier_passive = class({})
function icebreaker_u_modifier_passive:IsHidden() return true end
function icebreaker_u_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_u_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function icebreaker_u_modifier_passive:OnRefresh(kv)
end

function icebreaker_u_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_u_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_TURNING,
		MODIFIER_EVENT_ON_ABILITY_START,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function icebreaker_u_modifier_passive:GetModifierDisableTurning()
	return self.ability.turn
end

function icebreaker_u_modifier_passive:OnAbilityStart(keys)
	if keys.unit ~= self.parent then return end
	if keys.ability ~= self.ability then return end
	
	self.ability.turn = 1
end

function icebreaker_u_modifier_passive:OnTakeDamage(keys)
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if keys.inflictor == nil then return end
	if keys.inflictor ~= self.ability then return end

	local spellsteal = self.ability:GetSpecialValueFor("special_spellsteal") * 0.01
	local spellsteal_kill = self.ability:GetSpecialValueFor("special_spellsteal_kill") * 0.01
	local damage = keys.original_damage

	local heal = damage * spellsteal_kill
	if keys.unit:IsAlive() then heal = damage * spellsteal end

	if heal > 0 then
		self.parent:Heal(heal, self.ability)
		self:PlayEfxSpellLifesteal(self.parent)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function icebreaker_u_modifier_passive:PlayEfxSpellLifesteal(target)
	local particle = "particles/items3_fx/octarine_core_lifesteal.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect)
end