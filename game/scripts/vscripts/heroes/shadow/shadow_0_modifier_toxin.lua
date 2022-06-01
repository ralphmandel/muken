shadow_0_modifier_toxin = class ({})
local tempTable = require("libraries/tempTable")

function shadow_0_modifier_toxin:IsHidden()
    return false
end

function shadow_0_modifier_toxin:IsPurgable()
    return self.purge
end

function shadow_0_modifier_toxin:IsDebuff()
    return true
end

-----------------------------------------------------------

function shadow_0_modifier_toxin:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.purge = true

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect("shadow_0_modifier_toxin_status_efx", true) end

	local lifetime = self.ability:GetSpecialValueFor("lifetime")
	local intervals = self.ability:GetSpecialValueFor("intervals")
	self.toxin_damage = self.ability:GetSpecialValueFor("toxin_damage")
	self.total_toxin = 0
	self.last_damage = 0
	self.percent = 1 + (self.ability:GetSpecialValueFor("damage_percent") * 0.01)

	self.damageTable = {
		damage = nil,
		attacker = self.caster,
		victim = self.parent,
		damage_type = self.ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
		ability = self.ability
	}

	-- UP 0.11
	if self.ability:GetRank(11) then
		self.damageTable.damage = 75 * self.percent
		ApplyDamage(self.damageTable)
		self:PlayEfxDamage()
	end

	-- UP 0.31
	if self.ability:GetRank(31) then
		lifetime = lifetime + 10
	end

	if IsServer() then
		self:SetStackCount(0)
		self:AddMultStack(lifetime)
		self:PlayEfxHit()
		self:StartIntervalThink(intervals)
	end
end

function shadow_0_modifier_toxin:OnRefresh(kv)
	local lifetime = self.ability:GetSpecialValueFor("lifetime")
	local intervals = self.ability:GetSpecialValueFor("intervals")
	self.toxin_damage = self.ability:GetSpecialValueFor("toxin_damage")

	-- UP 0.31
	if self.ability:GetRank(31) then
		lifetime = lifetime + 10
	end

	if IsServer() then
		self:AddMultStack(lifetime)
		self:PlayEfxHit()
	end
end

function shadow_0_modifier_toxin:OnRemoved(kv)
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect("shadow_0_modifier_toxin_status_efx", false) end
	self:ApplyWeakness(false)
end

------------------------------------------------------------

function shadow_0_modifier_toxin:DeclareFunctions()
	local funcs = {
	}

	return funcs
end

-----------------------------------------------------------

function shadow_0_modifier_toxin:OnIntervalThink()
	if self:GetStackCount() > 0 then self:ApplyToxinDamage() end
end

function shadow_0_modifier_toxin:AddMultStack(lifetime)
	self:IncrementStackCount()

	local this = tempTable:AddATValue(self)
	self.parent:AddNewModifier(self.caster, self.ability, "shadow_0_modifier_toxin_stack", {
		duration = self.ability:CalcStatus(lifetime, self.caster, self.parent),
		modifier = this
	})
end

function shadow_0_modifier_toxin:ApplyToxinDamage()
	local damage = 0
	for x = 1, self:GetStackCount(), 1 do
		damage = damage + (self.toxin_damage * (0.8^x))
	end

	self.damageTable.damage = damage * self.percent
	self.last_damage = ApplyDamage(self.damageTable)
	self.total_toxin = self.total_toxin + self.last_damage

	self:PlayEfxDamage()
end

function shadow_0_modifier_toxin:ApplyWeakness(bApply)
	local stats = {
		"_1_STR", "_1_AGI", "_1_CON", "_1_INT", "_2_DEF", "_2_DEX", "_2_LCK", "_2_MND", "_2_REC", "_2_RES"
	}

	for _,string in pairs(stats) do
		self.ability:RemoveBonus(string, self.parent)
		if bApply then self.ability:AddBonus(string, self.parent, -self:GetStackCount(), 0, nil) end
	end

	-- UP 0.41
	if self.ability:GetRank(41) then
		local mod = self.parent:FindAllModifiersByName("_modifier_blind")
		for _,modifier in pairs(mod) do
			if modifier:GetAbility() == self.ability then modifier:Destroy() end
		end

		if bApply then
			self.parent:AddNewModifier(self.caster, self.ability, "_modifier_blind", {
				percent = self:GetStackCount() * 5, miss_chance = 0
			})
		end
	end
end

function shadow_0_modifier_toxin:OnStackCountChanged(iStackCount)
	if iStackCount == self:GetStackCount() then return end
	if self:GetStackCount() > 0 then self:ApplyWeakness(true) else self:Destroy() end
end

-----------------------------------------------------------

function shadow_0_modifier_toxin:GetStatusEffectName()
    return "particles/status_fx/status_effect_maledict.vpcf"
end

function shadow_0_modifier_toxin:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function shadow_0_modifier_toxin:PlayEfxHit()
	local particle = "particles/units/heroes/hero_witchdoctor/witchdoctor_shard_switcheroo_cast.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect)

	if IsServer() then self.parent:EmitSound("Shadowmancer.Poison.Start") end
end

function shadow_0_modifier_toxin:PlayEfxDamage()
    local particle_cast = "particles/econ/events/ti9/blink_dagger_ti9_start_lvl2_splash.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then EmitSoundOnLocationForAllies(self.parent:GetOrigin(), "Shadowmancer.Poison.Damage", self.parent) end
end