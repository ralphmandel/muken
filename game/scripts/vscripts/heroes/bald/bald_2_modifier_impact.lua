bald_2_modifier_impact = class({})

function bald_2_modifier_impact:IsHidden() return true end
function bald_2_modifier_impact:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_2_modifier_impact:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then
		self.parent:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 2)
		self:StartIntervalThink(0.15)
	end
end

function bald_2_modifier_impact:OnRefresh(kv)
end

function bald_2_modifier_impact:OnRemoved()
	self.ability:SetActivated(true)
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_2_modifier_impact:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true
	}

	return state
end

function bald_2_modifier_impact:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_TURNING
	}

	return funcs
end

function bald_2_modifier_impact:GetModifierDisableTurning()
	return 1
end

function bald_2_modifier_impact:OnIntervalThink()
	self:ApplyImpact()

	if IsServer() then self:StartIntervalThink(-1) end
end

-- UTILS -----------------------------------------------------------

function bald_2_modifier_impact:ApplyImpact()
	local target = self.ability.target
	if target == nil then return end
	if IsValidEntity(target) == false then return end
	if target:IsInvisible() then return end

	ApplyDamage({
		damage = self.ability.damage,
		attacker = self.caster,
		victim = target,
		damage_type = self.ability:GetAbilityDamageType(),
		ability = self.ability,
		damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK
	})

	if IsServer() then target:EmitSound("Hero_Bristleback.Attack") end

	if target:IsMagicImmune() == false then
		self:PlayEfxImpact(target)
		target:AddNewModifier(self.caster, self.ability, "_modifier_stun", {
			duration = self.ability:CalcStatus(self.ability.stun, self.caster, target)
		})
	
		target:AddNewModifier(self.caster, nil, "modifier_knockback", {
			duration = 0.25,
			knockback_duration = 0.25,
			knockback_distance = self.ability.stun * 50,
			center_x = self.parent:GetAbsOrigin().x + 1,
			center_y = self.parent:GetAbsOrigin().y + 1,
			center_z = self.parent:GetAbsOrigin().z,
			knockback_height = self.ability.stun * 20,
		})
	end
end

-- EFFECTS -----------------------------------------------------------

function bald_2_modifier_impact:PlayEfxImpact(target)
	local sound_cast = "Hero_Spirit_Breaker.GreaterBash.Creep"
	if target:IsHero() then sound_cast = "Hero_Spirit_Breaker.GreaterBash" end 

	local particle_cast = "particles/econ/items/spirit_breaker/spirit_breaker_weapon_ti8/spirit_breaker_bash_ti8.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(effect_cast, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then target:EmitSound(sound_cast) end
end