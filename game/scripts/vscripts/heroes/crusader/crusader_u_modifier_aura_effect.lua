crusader_u_modifier_aura_effect = class({})

function crusader_u_modifier_aura_effect:IsHidden()
	return false
end

function crusader_u_modifier_aura_effect:IsPurgable()
	return false
end

-----------------------------------------------------------

function crusader_u_modifier_aura_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.regen = self.ability:GetSpecialValueFor("regen")
	self.amplify = self.ability:GetSpecialValueFor("amplify")
	self.radius = self.ability:GetSpecialValueFor("radius")
	self.min_health = 0

	-- UP 4.1
	if self.ability:GetRank(1) then
		self.radius = self.ability:GetSpecialValueFor("radius") + 100
	end

	-- UP 4.6
	if self.ability:GetRank(6) then
		self.regen = self.ability:GetSpecialValueFor("regen") + 2.5
	end

	if IsServer() then
		if self.caster ~= self.parent then
			self:PlayEfxUnits()
			if (self.parent:GetUnitName() == "crusader" or self.parent:IsHero())
			and self.parent:HasModifier("crusader_u_modifier_reborn") == false then
				self.min_health = 1
			end
		else
			self:PlayEfxAura()
			self:SetStackCount(0)
			self:StartIntervalThink(0.2)
		end
	end
end

function crusader_u_modifier_aura_effect:OnRefresh(kv)
	-- UP 4.1
	if self.ability:GetRank(1) then
		self.radius = self.ability:GetSpecialValueFor("radius") + 100
	end
	
	-- UP 4.6
	if self.ability:GetRank(6) then
		self.regen = self.ability:GetSpecialValueFor("regen") + 2.5
	end
end

function crusader_u_modifier_aura_effect:OnRemoved(kv)
	if self.caster ~= self.parent then
		if self.effect_caster then ParticleManager:DestroyParticle(self.effect_caster, false) end
	end
end

------------------------------------------------------------

function crusader_u_modifier_aura_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE
	}

	return funcs
end

function crusader_u_modifier_aura_effect:GetMinHealth()
    return self.min_health
end

function crusader_u_modifier_aura_effect:OnAttacked(keys)
    if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self.caster == self.parent then return end

	-- UP 4.5
	if self.ability:GetRank(5) then
		local lifesteal = keys.original_damage * 0.1
		self.parent:Heal(lifesteal, nil)
		self.caster:Heal(lifesteal * 0.5, nil)
		self:PlayEfxLifesteal()
	end

end

function crusader_u_modifier_aura_effect:OnTakeDamage(keys)
    if keys.unit ~= self.parent then return end
	if self.parent:IsIllusion() then return end
	if self.parent:IsHero() == false and self.parent:GetUnitName() ~= "crusader" then return end
	if self.parent:HasModifier("crusader_u_modifier_reborn") then return end

	if self.parent:GetHealth() == 1 then
		if self.parent:IsHero() == false then
			if self.parent:HasModifier("crusader_1_modifier_summon") then
				local grave_delay = self.ability:GetSpecialValueFor("grave_delay")

				-- UP 4.2
				if self.ability:GetRank(2) then
					grave_delay = 1.1
				end

				self.parent:AddNewModifier(self.caster, self.ability, "crusader_1_modifier_summon", {})
				self.parent:AddNewModifier(self.caster, self.ability, "crusader_u_modifier_ban", {duration = grave_delay})
			end
		else
			local reborn_duration = self.ability:GetSpecialValueFor("reborn_duration")

			-- UP 4.4
			if self.ability:GetRank(4) then
				reborn_duration = reborn_duration  + 3
			end

			self.parent:AddNewModifier(self.caster, self.ability, "crusader_u_modifier_reborn", {duration = reborn_duration})
		end

		self.min_health = 0
	end
end

function crusader_u_modifier_aura_effect:GetModifierConstantHealthRegen()
	if self.caster ~= self.parent then return 0 end
	return self:GetStackCount() * self.regen
end

function crusader_u_modifier_aura_effect:GetModifierHPRegenAmplify_Percentage(keys)
	if self.caster ~= self.parent then return 0 end
	return self:GetStackCount() * self.amplify
end

function crusader_u_modifier_aura_effect:OnIntervalThink()
	local count = 0
	local allies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.radius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0, 0, false
	)

	for _,ally in pairs(allies) do
		if (ally:IsHero() or ally:GetUnitName() == "crusader")
		and ally:HasModifier(self:GetName())
		and ally:IsIllusion() == false
		and ally ~= self.caster then
			count = count + 1
		end
	end

	self:SetStackCount(count)
end

-----------------------------------------------------------

function crusader_u_modifier_aura_effect:PlayEfxAura()
	if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, false) end
	self.effect_cast = ParticleManager:CreateParticle("particles/crusader/crusader_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast, 0, self.parent:GetOrigin())
    ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(self.radius, 0, 0 ))
	self:AddParticle(self.effect_cast, false, false, -1, false, false)
    
	if IsServer() then self.parent:EmitSound("Hero_DarkWillow.Brambles.Cast") end
end

function crusader_u_modifier_aura_effect:PlayEfxUnits()
	if self.parent:IsIllusion() then return end
	if self.parent:IsHero() == false and self.parent:GetUnitName() ~= "crusader" then return end
	if self.parent:HasModifier("crusader_u_modifier_reborn") then return end

	self.effect_caster = ParticleManager:CreateParticle("particles/crusader/crusader_aura_buff_caster.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
	ParticleManager:SetParticleControl(self.effect_caster, 0, self.caster:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_caster, 1, self.caster:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_caster, 2, self.caster:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_caster, 4, self.caster:GetOrigin())
	self:AddParticle(self.effect_caster, false, false, -1, false, false)

	self.effect_parent = ParticleManager:CreateParticle("particles/crusader/crusader_aura_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_parent, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_parent, 1, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_parent, 2, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_parent, 4, self.parent:GetOrigin())
	self:AddParticle(self.effect_parent, false, false, -1, false, false)
end

function crusader_u_modifier_aura_effect:PlayEfxLifesteal()
	local particle = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"

	local effect_caster = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.caster)
	ParticleManager:SetParticleControl(effect_caster, 1, self.caster:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_caster)

	local effect_parent = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_parent, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_parent)
end