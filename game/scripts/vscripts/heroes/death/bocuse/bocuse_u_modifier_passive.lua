bocuse_u_modifier_passive = class({})

function bocuse_u_modifier_passive:IsHidden() return false end
function bocuse_u_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_u_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	Timers:CreateTimer(0.2, function()
		if IsServer() then self:SetStackCount(self.ability.kills) end
	end)
end

function bocuse_u_modifier_passive:OnRefresh(kv)
end

function bocuse_u_modifier_passive:OnRemoved(kv)
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_u_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_HERO_KILLED,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	
	return funcs
end

function bocuse_u_modifier_passive:OnHeroKilled(keys)
	if keys.attacker == nil or keys.target == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self.parent:IsIllusion() then return end
	if self.parent:HasModifier("bocuse_u_modifier_mise") == false then return end

  self.ability.kills = self.ability.kills + 1

  local init_model_scale = self.ability:GetSpecialValueFor("init_model_scale")
  local model_scale = init_model_scale * (1 + (self.ability:GetSpecialValueFor("atk_range") * self.ability.kills * 0.003125))
  self.parent:SetModelScale(model_scale)
  self.parent:SetHealthBarOffsetOverride(200 * self.parent:GetModelScale())

	if IsServer() then
		self:SetStackCount(self.ability.kills)
		self:PlayEfxKill()
	end
end

function bocuse_u_modifier_passive:OnAttackLanded(keys)
  if not (keys.attacker == self.parent) then return end
  if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
  if self.parent:PassivesDisabled() then return end
	if self.parent:HasModifier("bocuse_1_modifier_julienne") then return end
	if self.parent:HasModifier("bocuse_u_modifier_mise") then return end
end

-- EFFECTS -----------------------------------------------------------

function bocuse_u_modifier_passive:PlayEfxKill()
	local particle_cast = "particles/econ/items/techies/techies_arcana/techies_suicide_kills_arcana.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())

	local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(nFXIndex, 1, Vector(1, 0, 0))
	ParticleManager:ReleaseParticleIndex(nFXIndex)
end