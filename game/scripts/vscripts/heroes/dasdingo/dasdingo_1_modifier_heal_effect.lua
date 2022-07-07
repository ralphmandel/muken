dasdingo_1_modifier_heal_effect = class({})

function dasdingo_1_modifier_heal_effect:IsHidden()
	return false
end

function dasdingo_1_modifier_heal_effect:IsPurgable()
	return false
end

function dasdingo_1_modifier_heal_effect:IsDebuff()
	if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
		return true
	end

	return false
end

-----------------------------------------------------------

function dasdingo_1_modifier_heal_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	
	self.heal = self.ability:GetSpecialValueFor("heal")
	self.intervals = self.ability:GetSpecialValueFor("intervals") / 0.25
	self.count = 0
	self.min_health = 0
	self.death = false
	self.purge = 0

	-- UP 1.41
	if self.ability:GetRank(41) then
		self.intervals = self.intervals - 1
	end

	if self.caster:GetTeamNumber() ~= self.parent:GetTeamNumber() then return end

	-- UP 1.12
	if self.ability:GetRank(12) then
		self.min_health = 1
	end

	self:StartIntervalThink(0.25)
end

function dasdingo_1_modifier_heal_effect:OnRefresh(kv)
end

function dasdingo_1_modifier_heal_effect:OnRemoved(kv)
	if self.particle_regen then ParticleManager:DestroyParticle(self.particle_regen, false) end

	self.parent:RemoveModifierByName("dasdingo_1_modifier_immortal")

	local mod = self.parent:FindAllModifiersByName("_modifier_invisible")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-----------------------------------------------------------

function dasdingo_1_modifier_heal_effect:DeclareFunctions()

    local funcs = {
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return funcs
end

function dasdingo_1_modifier_heal_effect:GetMinHealth()
    return self.min_health
end

function dasdingo_1_modifier_heal_effect:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end

	if self.min_health == 1
	and keys.unit:GetHealth() == 1
	and keys.unit:HasModifier("dasdingo_1_modifier_immortal") == false then		
		local mod = keys.unit:AddNewModifier(self.caster, self.ability, "dasdingo_1_modifier_immortal", {
			duration = self.ability:CalcStatus(5, self.caster, keys.unit)
		})

		local info = {}
		info.inflictor = keys.inflictor
		info.attacker = keys.attacker
		mod:SetKillData(info)
	end

	local chance = 12.5
	if keys.attacker:IsBaseNPC() then
		if keys.attacker:IsHero()
		and keys.attacker:IsIllusion() == false then
			chance = 25
		end
	end

	local base_stats = self.caster:FindAbilityByName("base_stats")
	if base_stats then chance = chance * base_stats:GetCriticalChance() end

	if RandomFloat(1, 100) <= chance
	and keys.unit:IsMagicImmune() == false
	and keys.unit:GetTeamNumber() ~= self.caster:GetTeamNumber()
	and keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
		keys.unit:AddNewModifier(self.caster, self.ability, "_modifier_root", {
			duration = self.ability:CalcStatus(1.5, self.caster, keys.unit),
			effect = 4
		})
	end
end

function dasdingo_1_modifier_heal_effect:OnIntervalThink()
	-- UP 1.11
	if self.ability:GetRank(11)
	and self.parent:IsHero() then
		local invi_bool = false
		local mod = self.parent:FindAllModifiersByName("_modifier_invisible")
		for _,modifier in pairs(mod) do
			if modifier:GetAbility() == self.ability then invi_bool = true end
		end

		if invi_bool == false then
			self.parent:AddNewModifier(self.caster, self.ability, "_modifier_invisible", {delay = 3})
		end
	end

	self.count = self.count + 1
	if self.count < self.intervals then return end
	self.count = 0

	local heal = 0
    local base_stats = self.caster:FindAbilityByName("base_stats")
	if base_stats then heal = self.heal * base_stats:GetHealPower() end
    if heal > 0 then
        self.parent:Heal(heal, self.ability)
        self:PlayEfxHeal()
    end

	-- UP 1.41
	if self.ability:GetRank(41) then
		self.purge = self.purge + 1
		if self.purge > 3 then
			self.parent:Purge(false, true, false, false, false)
			self.purge = 0
		end
	end
end

-----------------------------------------------------------

function dasdingo_1_modifier_heal_effect:PlayEfxHeal()
	local particle = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect_parent = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_parent, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_parent)

	if IsServer() then self.parent:EmitSound("Hero_Dasdingo.Heal") end
end

function dasdingo_1_modifier_heal_effect:PlayEfxRegen()
	if self.particle_regen then ParticleManager:DestroyParticle(self.particle_regen, false) end

	local particle = "particles/units/heroes/hero_oracle/oracle_purifyingflames.vpcf"
	self.particle_regen = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
end