genuine_u_modifier_passive = class({})

function genuine_u_modifier_passive:IsHidden() return false end
function genuine_u_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_u_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  if IsServer() then
    self.ability.kills = 0
    self:SetStackCount(self.ability.kills)
  end
end

function genuine_u_modifier_passive:OnRefresh(kv)  
  if IsServer() then
		self:SetStackCount(self.ability.kills)
	end
end

function genuine_u_modifier_passive:OnRemoved(kv)
  RemoveBonus(self.ability, "_1_AGI", self.parent)
  RemoveBonus(self.ability, "_1_INT", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_u_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_HERO_KILLED
	}

	return funcs
end

function genuine_u_modifier_passive:OnHeroKilled(keys)
	if keys.attacker == nil or keys.target == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self.parent:IsIllusion() then return end
  if self.parent:HasModifier("genuine_u_modifier_morning") == false then return end

	if IsServer() then
		self.ability.kills = self.ability.kills + 1
		self:SetStackCount(self.ability.kills)
		self:PlayEfxKill()
	end
end

function genuine_u_modifier_passive:OnStackCountChanged(old)
  RemoveBonus(self.ability, "_1_AGI", self.parent)
  RemoveBonus(self.ability, "_1_INT", self.parent)
  AddBonus(self.ability, "_1_AGI", self.parent, self:GetStackCount(), 0, nil)
  AddBonus(self.ability, "_1_INT", self.parent, self:GetStackCount(), 0, nil)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function genuine_u_modifier_passive:PlayEfxBuff()
	self:StopEfxBuff()

	local particle = "particles/genuine/morning_star/genuine_morning_star.vpcf"
	self.effect_caster = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_caster, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_caster, 1, self.parent:GetOrigin())
	self:AddParticle(self.effect_caster, false, false, -1, false, false)
end

function genuine_u_modifier_passive:StopEfxBuff()
	if self.effect_caster then ParticleManager:DestroyParticle(self.effect_caster, false) end
end

function genuine_u_modifier_passive:PlayEfxKill()
	local particle_cast = "particles/econ/items/techies/techies_arcana/techies_suicide_kills_arcana.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())

	local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(nFXIndex, 1, Vector(1, 0, 0))
	ParticleManager:ReleaseParticleIndex(nFXIndex)
end