shadow_1_modifier_passive = class({})

function shadow_1_modifier_passive:IsHidden()
	return true
end

function shadow_1_modifier_passive:IsPurgable()
	return false
end

-----------------------------------------------------------

function shadow_1_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if self.parent:IsIllusion() then
		self.caster = self.parent:GetPlayerOwner():GetAssignedHero()
		self.ability = self.caster:FindAbilityByName("shadow_1__strike")
	end
end

function shadow_1_modifier_passive:OnRefresh(kv)
end

function shadow_1_modifier_passive:OnRemoved()
end

-----------------------------------------------------------

function shadow_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_FAIL
	}

	return funcs
end

function shadow_1_modifier_passive:OnAttackLanded(keys)
	local toxin_ability = self.caster:FindAbilityByName("shadow_0__toxin")
	if toxin_ability == nil then return end
	if self.ability == nil then return end
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self.parent:PassivesDisabled() then return end
	local chance = self.ability:GetSpecialValueFor("chance")
	local chance_copy = self.ability:GetSpecialValueFor("chance_copy")
	if self.parent:IsIllusion() then chance = chance_copy end
	local toxin_target = keys.target:FindModifierByName("shadow_0_modifier_toxin")

	-- UP 1.21
	if self.ability:GetRank(21)
	and self.ability:IsCooldownReady()
	and toxin_target then
		self.ability:AddBonus("_1_AGI", self.parent, 25, 0, 5)
		self.ability:StartCooldown(20)
	end

	-- UP 1.31
	if self.ability:GetRank(31)
	and toxin_target then
		local heal = toxin_target.last_damage
		self.parent:Heal(heal, self.ability)
		self:PlayEfxHeal()
	end

	-- UP 1.32
	if self.ability:GetRank(32) then
		chance = chance + 5
	else
		if keys.target:IsMagicImmune() then
			return
		end
	end
	
	if RandomInt(1, 100) <= chance then
		keys.target:AddNewModifier(self.caster, toxin_ability, "shadow_0_modifier_toxin", {})

		-- UP 1.11
		if self.ability:GetRank(11) then
			keys.target:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
				duration = 0.5, percent = 100
			})
		end
	end
end

function shadow_1_modifier_passive:OnAttackFail(keys)
	local toxin_ability = self.caster:FindAbilityByName("shadow_0__toxin")
	if toxin_ability == nil then return end
	if self.ability == nil then return end
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self.parent:PassivesDisabled() then return end
	local chance = self.ability:GetSpecialValueFor("chance")
	local chance_copy = self.ability:GetSpecialValueFor("chance_copy")
	if self.parent:IsIllusion() then chance = chance_copy end

	-- UP 1.32
	if self.ability:GetRank(32)
	and RandomInt(1, 100) <= chance + 5 then
		keys.target:AddNewModifier(self.caster, toxin_ability, "shadow_0_modifier_toxin", {})

		-- UP 1.11
		if self.ability:GetRank(11) then
			keys.target:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
				duration = 0.5, percent = 100
			})
		end
	end
end

-----------------------------------------------------------

function shadow_1_modifier_passive:PlayEfxHeal()
	local particle = "particles/items3_fx/octarine_core_lifesteal.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect)
end