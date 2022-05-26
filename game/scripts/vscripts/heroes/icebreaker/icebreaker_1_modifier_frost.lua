icebreaker_1_modifier_frost = class({})

--------------------------------------------------------------------------------

function icebreaker_1_modifier_frost:IsHidden()
	return false
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
	
	if IsServer() then
		self:SetStackCount(self.ability.kills)
	end
end

function icebreaker_1_modifier_frost:OnRefresh( kv )
	if IsServer() then
		self:SetStackCount(self.ability.kills)
	end
end

function icebreaker_1_modifier_frost:OnRemoved( kv )
	if self.effect_cast then
		ParticleManager:DestroyParticle(self.effect_cast, false)
	end
end

--------------------------------------------------------------------------------

function icebreaker_1_modifier_frost:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_HERO_KILLED,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	
	return funcs
end

function icebreaker_1_modifier_frost:OnHeroKilled(keys)
	if keys.attacker == nil or keys.target == nil or keys.inflictor == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end

	if IsServer() then
		if keys.inflictor:GetAbilityName() == "icebreaker_3__blink" then
			self.ability:AddKillPoint(1)
			self:SetStackCount(self.ability.kills)
		end
	end
end

function icebreaker_1_modifier_frost:GetModifierDamageOutgoing_Percentage(keys)
	if keys.attacker ~= self.parent then return end

	-- UP 1.32
	if self.ability:GetRank(32) then
		return -50
	end
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

	-- UP 1.32
	local slow_mod = keys.target:FindModifierByName("icebreaker_0_modifier_slow")
	if self.ability:GetRank(32) and slow_mod then
		local damageTable = {
			victim = keys.target,
			attacker = self.parent,
			damage = slow_mod:GetStackCount() * 2,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.ability
		}
		local total = ApplyDamage(damageTable)
		if total > 0 then
			if IsServer() then keys.target:EmitSound("Hero_DrowRanger.Reload") end
		end
	end
end

function icebreaker_1_modifier_frost:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end

	local ability_slow = self.caster:FindAbilityByName("icebreaker_0__slow")
	if ability_slow == nil then return end
	if ability_slow:IsTrained() == false then return end

	-- UP 1.31
	if self.ability:GetRank(31) 
	or (keys.target:IsMagicImmune() == false and self.parent:PassivesDisabled() == false) then
		ability_slow:AddSlow(keys.target, self.ability)
	end

	-- UP 1.41
	if --self.ability:GetRank(41) 
	--and
	RandomInt(1, 100) <= 15
	and self.parent:PassivesDisabled() == false then
		local illu = CreateIllusions(
			self.caster, self.caster,
			{
				outgoing_damage = -100,
				incoming_damage = 0,
				bounty_base = 0,
				bounty_growth = 0,
				duration = self.ability:CalcStatus(7, self.caster, nil),
			},
			1, 64, false, true
		)
		illu = illu[1]

		local area = 150
		local quarter = RandomInt(1, 4)
		local variable = RandomInt(0, area)
		local random_x
		local random_y

		if quarter == 1 then
			random_x = -area
			random_y = variable
		elseif quarter == 2 then
			random_x = variable
			random_y = area
		elseif quarter == 3 then
			random_x = area
			random_y = -variable
		elseif quarter == 4 then
			random_x = -variable
			random_y = -area
		end

		local x = self:Calculate( random_x, random_y)
		local y = self:Calculate( random_y, random_x)

		local point = keys.target:GetOrigin()
		point.x = point.x + x
		point.y = point.y + y

		FindClearSpaceForUnit( illu, point, true )

		illu:AddNewModifier(self.caster, ability_slow, "_modifier_phase", {})
		illu:AddNewModifier(self.caster, ability_slow, "icebreaker_0_modifier_illusion", {})
	end
end

function icebreaker_1_modifier_frost:Calculate( a, b)
    if a < 0 then
        if b > 0 then
            b = -b
        end
    elseif b < 0 then
        b = -b
    end
    local result = a - math.floor(b/4)

    return result
end

-----------------------------------------------------------------------------

function icebreaker_1_modifier_frost:PlayEffects()
	local particle_cast = "particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_buff.vpcf"

	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControl( self.effect_cast, 0, self.parent:GetOrigin() )
	self:AddParticle(self.effect_cast, false, false, -1, false, false)
end