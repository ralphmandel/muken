item_legend_serluc_mod_passive = class({})

function item_legend_serluc_mod_passive:IsHidden()
    return true
end

function item_legend_serluc_mod_passive:IsPurgable()
    return false
end

---------------------------------------------------------------------------------------------------

function item_legend_serluc_mod_passive:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.passive_lifesteal = self.ability:GetSpecialValueFor("passive_lifesteal")
	local passive_str = self.ability:GetSpecialValueFor("passive_str")
	local passive_lck = self.ability:GetSpecialValueFor("passive_lck")
	local passive_mnd = self.ability:GetSpecialValueFor("passive_mnd")

	AddBonus(self.ability, "_1_STR", self.parent, passive_str, 0, nil)
	AddBonus(self.ability, "_2_LCK", self.parent, passive_lck, 0, nil)
	AddBonus(self.ability, "_2_MND", self.parent, passive_mnd, 0, nil)
end

function item_legend_serluc_mod_passive:OnRefresh( kv )
end

function item_legend_serluc_mod_passive:OnRemoved( kv )
	RemoveBonus(self.ability, "_1_STR", self.parent)
	RemoveBonus(self.ability, "_2_LCK", self.parent)
	RemoveBonus(self.ability, "_2_MND", self.parent)
end
---------------------------------------------------------------------------------------------------

-- function item_legend_serluc_mod_passive:CheckState()
-- 	local state = {
-- 		[MODIFIER_STATE_MAGIC_IMMUNE] = self.magic_immunity,
-- 	}

-- 	return state
-- end


function item_legend_serluc_mod_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_HERO_KILLED,
		MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function item_legend_serluc_mod_passive:OnHeroKilled(keys)
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if keys.attacker:HasModifier("item_legend_serluc_mod_berserk") == false then return end

	local xp_gain = 250
	self.ability:CheckXP()
	self.ability.xp = self.ability.xp - xp_gain
	if self.ability.xp < 0 then
		self:PlayLevelUpEfx()
		self.ability:UpgradeAbility(true)
	end
end

function item_legend_serluc_mod_passive:OnAttacked(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:IsBuilding() then return end

	local heal = keys.original_damage * self.passive_lifesteal * 0.01

	if self.parent:HasModifier("item_legend_serluc_mod_berserk") then
		local rank_lifesteal = self.ability:GetSpecialValueFor("rank_lifesteal")
		heal = keys.original_damage * rank_lifesteal * 0.01
	end

	self.parent:Heal(heal, self.ability)
	self:PlayEfxLifesteal(self.parent)
end

function item_legend_serluc_mod_passive:OnTakeDamage(keys)
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end
	if keys.damage_category ~= DOTA_DAMAGE_CATEGORY_SPELL then return end
	if keys.unit:IsBuilding() then return end

	local heal = keys.original_damage * self.passive_lifesteal * 0.01

	if self.parent:HasModifier("item_legend_serluc_mod_berserk") then
		local rank_lifesteal = self.ability:GetSpecialValueFor("rank_lifesteal")
		heal = keys.original_damage * rank_lifesteal * 0.01
	end

	self.parent:Heal(heal, self.ability)
	self:PlayEfxLifesteal(self.parent)
end

--------------------------------------------------------------------------------------------------

-- function item_legend_serluc_mod_passive:GetEffectName()
-- 	return "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_debuff.vpcf"
-- end

-- function item_legend_serluc_mod_passive:GetEffectAttachType()
-- 	return PATTACH_OVERHEAD_FOLLOW
-- end

-- function item_legend_serluc_mod_passive:GetStatusEffectName()
-- 	return "particles/econ/items/lifestealer/lifestealer_immortal_backbone/status_effect_life_stealer_immortal_rage.vpcf"
-- end

-- function item_legend_serluc_mod_passive:StatusEffectPriority()
-- 	return MODIFIER_PRIORITY_HIGH
-- end

function item_legend_serluc_mod_passive:PlayEfxLifesteal(target)
	local particle = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(effect, 1, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect)
end

function item_legend_serluc_mod_passive:PlayLevelUpEfx()
	local caster = self:GetCaster()
	local particle = "particles/econ/events/spring_2021/hero_levelup_spring_2021.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(effect, 0, caster:GetOrigin())
	self:AddParticle(effect, false, false, -1, false, false)

	--if IsServer() then caster:EmitSound("LevelUp.Legendary") end
end