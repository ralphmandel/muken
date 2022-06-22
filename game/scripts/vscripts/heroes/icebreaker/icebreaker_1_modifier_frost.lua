icebreaker_1_modifier_frost = class({})

--------------------------------------------------------------------------------

function icebreaker_1_modifier_frost:IsHidden()
	return true
end

function icebreaker_1_modifier_frost:IsPurgable()
    return false
end

function icebreaker_1_modifier_frost:GetTexture()
	return "icebreaker_aspd"
end

--------------------------------------------------------------------------------

function icebreaker_1_modifier_frost:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.hits = 0
	
	self:PlayEffects()
	
	if self.parent:IsIllusion() then self:Destroy() end
end

function icebreaker_1_modifier_frost:OnRefresh( kv )
end

function icebreaker_1_modifier_frost:OnRemoved( kv )
	if self.effect_cast then
		ParticleManager:DestroyParticle(self.effect_cast, false)
	end
end

--------------------------------------------------------------------------------

function icebreaker_1_modifier_frost:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	
	return funcs
end

function icebreaker_1_modifier_frost:OnAttack(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	self:StartIntervalThink(5)

    -- UP 1.11
    if self.ability:GetRank(11) then
		if self.parent:PassivesDisabled() == false
		and self.ability:IsCooldownReady() then
			self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
			self.ability:RemoveBonus("_1_AGI", self.parent)
			self.ability:AddBonus("_1_AGI", self.parent, 999, 0, 2)
			self.hits = 1
		end

		if self.hits > 0 then
			self.hits = self.hits - 1
		else
			self.ability:RemoveBonus("_1_AGI", self.parent)
		end
	end
end

function icebreaker_1_modifier_frost:OnAttackLanded(keys)
	local ability_slow = self.caster:FindAbilityByName("icebreaker_0__slow")
	if ability_slow == nil then return end
	if ability_slow:IsTrained() == false then return end
	if keys.attacker ~= self.parent then return end

	-- UP 1.22
	if self.ability:GetRank(22) then
		local mod = keys.target:FindModifierByName("icebreaker_0_modifier_slow")
		if mod then
			local damageTable = {
				victim = keys.target,
				attacker = self.parent,
				damage = mod:GetStackCount(),
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self.ability
			}
			ApplyDamage(damageTable)
		end
	end

	-- UP 1.31
	if self.ability:GetRank(31) 
	or (keys.target:IsMagicImmune() == false and self.parent:PassivesDisabled() == false) then
		ability_slow:AddSlow(keys.target, self.ability)
	end

	local chance = 12
	local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats then chance = chance * base_stats:GetCriticalChance() end

	-- UP 1.41
	if self.ability:GetRank(41) 
	and RandomFloat(1, 100) <= chance
	and self.parent:PassivesDisabled() == false then
		ability_slow:CreateIceIllusions(keys.target, 7)
	end

	chance = 20
	local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats then chance = chance * base_stats:GetCriticalChance() end

	-- UP 1.42
	if self.ability:GetRank(42) 
	and RandomFloat(1, 100) <= chance
	and self.parent:PassivesDisabled() == false then
		local direction = keys.target:GetForwardVector() * (-1)
		local blink_point = keys.target:GetAbsOrigin() + direction * 130

		self:PlayEfxAutoBlink()
		self.parent:SetAbsOrigin(blink_point)
		self.parent:SetForwardVector(-direction)
		FindClearSpaceForUnit(self.parent, blink_point, true)
	end
end

-----------------------------------------------------------------------------

function icebreaker_1_modifier_frost:PlayEffects()
	local particle_cast = "particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_buff.vpcf"

	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControl( self.effect_cast, 0, self.parent:GetOrigin() )
	self:AddParticle(self.effect_cast, false, false, -1, false, false)
end

function icebreaker_1_modifier_frost:PlayEfxAutoBlink()
	local particle_cast = "particles/econ/events/winter_major_2017/blink_dagger_start_wm07.vpcf" 
	local effect_cast_a = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast_a, 0, self.parent:GetOrigin())
	--ParticleManager:SetParticleControlForward(effect_cast_a, 0, direction:Normalized())
	--ParticleManager:SetParticleControl(effect_cast_a, 1, origin + direction)
	ParticleManager:ReleaseParticleIndex(effect_cast_a)

	if IsServer() then self.parent:EmitSound("Hero_QueenOfPain.Blink_out") end
end