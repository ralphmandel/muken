striker_1_modifier_passive = class({})

function striker_1_modifier_passive:IsHidden()
	return false
end

function striker_1_modifier_passive:IsPurgable()
	return false
end

function striker_1_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_1_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.hits = 0
end

function striker_1_modifier_passive:OnRefresh(kv)
end

function striker_1_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function striker_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK
	}

	return funcs
end

function striker_1_modifier_passive:OnAttack(keys)
	if keys.attacker ~= self.parent then return end
	
	self:CheckHits()
	self:TryCombo(keys.fail_type)
end

-- UTILS -----------------------------------------------------------

function striker_1_modifier_passive:CheckHits()
	if self.hits > 0 then self.hits = self.hits - 1 return end
	self.ability:RemoveBonus("_1_AGI", self.parent)
end

function striker_1_modifier_passive:TryCombo(fail)
	if self.parent:PassivesDisabled() then return end
	if fail > 0 then return end

	local chance = self.ability:GetSpecialValueFor("chance")
	local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats then chance = chance * base_stats:GetCriticalChance() end

	if RandomFloat(1, 100) <= chance then
		self:PerformCombo()
	end
end

function striker_1_modifier_passive:PerformCombo()
	local agi = self.ability:GetSpecialValueFor("agi")
	self.hits = self.ability:GetSpecialValueFor("hits")

	self.ability:RemoveBonus("_1_AGI", self.parent)
	self.ability:AddBonus("_1_AGI", self.parent, agi, 0, nil)
	self:PlayEfxComboStart()
end

-- EFFECTS -----------------------------------------------------------

function striker_1_modifier_passive:PlayEfxComboStart()
	local particle_cast = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_spawn_v2.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())

	if IsServer() then self.parent:EmitSound("Hero_Centaur.DoubleEdge") end
end