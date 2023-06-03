genuine_3_modifier_passive = class({})

function genuine_3_modifier_passive:IsHidden() return false end
function genuine_3_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_3_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
  self.overnight = false

  if IsServer() then
    self.ability.kills = self.ability:GetSpecialValueFor("int")
    self:SetStackCount(self.ability.kills)
    self:OnIntervalThink()
  end
end

function genuine_3_modifier_passive:OnRefresh(kv)  
  if IsServer() then
		self:SetStackCount(self.ability.kills)
	end
end

function genuine_3_modifier_passive:OnRemoved(kv)
  if self.overnight == true then end
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_3_modifier_passive:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_DISABLE_TURNING,
		MODIFIER_EVENT_ON_ABILITY_START,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_HERO_KILLED
	}

	return funcs
end

function genuine_3_modifier_passive:OnHeroKilled(keys)
	if keys.attacker == nil or keys.target == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self.parent:IsIllusion() then return end
  if self.overnight == false then return end

	if IsServer() then
		self.ability.kills = self.ability.kills + 1
		self:SetStackCount(self.ability.kills)
    if BaseStats(self.parent) then BaseStats(self.parent):AddBaseStat("INT", 1) end
		self:PlayEfxKill()
	end
end


function genuine_3_modifier_passive:OnIntervalThink()
  if GameRules:IsDaytime() == false or GameRules:IsTemporaryNight() then
    if self.overnight == false then
      if self.ability:GetSpecialValueFor("special_ms_night") == 1 then self.ability:AddNightSpeed() end
      if BaseStats(self.parent) then BaseStats(self.parent):AddBaseStat("INT", self.ability.kills) end
      SetGenuineBarrier(self.parent, true)
      self.overnight = true
    end
  else
    if self.overnight == true then
      RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_buff", self.ability)
      if BaseStats(self.parent) then BaseStats(self.parent):AddBaseStat("INT", -self.ability.kills) end
      SetGenuineBarrier(self.parent, false)
      self.overnight = false
    end
  end

  if IsServer() then self:StartIntervalThink(0.1) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function genuine_3_modifier_passive:PlayEfxBuff()
	self:StopEfxBuff()

	local particle = "particles/genuine/morning_star/genuine_morning_star.vpcf"
	self.effect_caster = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_caster, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_caster, 1, self.parent:GetOrigin())
	self:AddParticle(self.effect_caster, false, false, -1, false, false)
end

function genuine_3_modifier_passive:StopEfxBuff()
	if self.effect_caster then ParticleManager:DestroyParticle(self.effect_caster, false) end
end

function genuine_3_modifier_passive:PlayEfxKill()
	local particle_cast = "particles/econ/items/techies/techies_arcana/techies_suicide_kills_arcana.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())

	local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(nFXIndex, 1, Vector(1, 0, 0))
	ParticleManager:ReleaseParticleIndex(nFXIndex)
end