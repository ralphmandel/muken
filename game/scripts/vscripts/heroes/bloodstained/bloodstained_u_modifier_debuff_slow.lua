bloodstained_u_modifier_debuff_slow = class({})

--------------------------------------------------------------------------------
function bloodstained_u_modifier_debuff_slow:IsPurgable()
	return false
end

function bloodstained_u_modifier_debuff_slow:IsHidden()
	return false
end

function bloodstained_u_modifier_debuff_slow:IsDebuff()
	return true
end

function bloodstained_u_modifier_debuff_slow:GetTexture()
	return "bloodstained_slow"
end

--------------------------------------------------------------------------------

function bloodstained_u_modifier_debuff_slow:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.moving = false

	local outgoing = 0
	local source = kv.source
    local slow = self.ability:GetSpecialValueFor("slow")
    local blood_extraction = self.ability:GetSpecialValueFor("blood_extraction") * 0.01

    -- UP 4.4
	if self.ability:GetRank(4)
	and source == self.ability:GetAbilityName() then
		self.parent:AddNewModifier(self.caster, self.ability, "bloodstained_0_modifier_bleeding", {})
		slow = slow + 10
	end

    -- UP 4.7
	if self.ability:GetRank(7)
	and source == self.ability:GetAbilityName() then
		blood_extraction = (self.ability:GetSpecialValueFor("blood_extraction") + 5) * 0.01
		outgoing = 20
	end

    self.total_blood = self.parent:GetMaxHealth() * blood_extraction
    if self.parent:GetHealth() < self.total_blood then self.total_blood = self.parent:GetHealth() end
    self.parent:ModifyHealth(self.parent:GetHealth() - self.total_blood, self.ability, false, 0)

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {percent = slow})

    local illu = CreateIllusions(
            self.caster, self.parent, {
            outgoing_damage = outgoing,
            incoming_damage = 0,
            bounty_base = 0,
            bounty_growth = 0,
            duration = self:GetDuration() + 1,
        }, 1, 64, false, true
    )

    self.copy = illu[1]
    self.copy:SetForceAttackTarget(self.parent)
    self.copy:MoveToTargetToAttack(self.parent)
    self.copy:AddNewModifier(self.caster, self.ability, "bloodstained_u_modifier_copy", {})
	self.copy:ModifyHealth(self.total_blood, self.ability, false, 0)

	self:PlayEfxStart()
	self:StartIntervalThink(FrameTime())
end

function bloodstained_u_modifier_debuff_slow:OnRefresh( kv )
end

function bloodstained_u_modifier_debuff_slow:OnRemoved()
	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

    local bleeding = self.parent:FindAllModifiersByName("bloodstained_0_modifier_bleeding")
	for _,modifier in pairs(bleeding) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	if IsValidEntity(self.copy) then
		if self.copy:IsAlive() then
			self.caster:AddNewModifier(self.caster, self.ability, "bloodstained_u_modifier_hp_bonus", {
				bonus = self.total_blood
			})
			self.copy:ForceKill(false)
			return
		end
	end

	self.parent:ModifyHealth(self.parent:GetHealth() + self.total_blood, self.ability, false, 0)
end

--------------------------------------------------------------------------------
function bloodstained_u_modifier_debuff_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_AVOID_DAMAGE
	}

	return funcs
end

function bloodstained_u_modifier_debuff_slow:GetModifierAvoidDamage(keys)
	if IsValidEntity(self.copy) == false then self:Destroy() return 0 end
	if keys.attacker == self.copy then
		local damage = math.floor(keys.original_damage)
		if self.parent:GetHealth() < damage then damage = self.parent:GetHealth() end

		self.total_blood = self.total_blood + damage
		self.copy:SetMaxHealth(self.total_blood)
		local void = self.parent:FindAbilityByName("_void")
		if void ~= nil then void:SetLevel(void:GetLevel()) end

		self.copy:ModifyHealth(self.copy:GetHealth() + (damage * 0.5), self.ability, false, 0)
		self.parent:ModifyHealth(self.parent:GetHealth() - damage, self.ability, false, 0)
		return 1
	end

	return 0
end

function bloodstained_u_modifier_debuff_slow:OnIntervalThink()
	if IsValidEntity(self.copy) == false then self:Destroy() return end
	self.copy:SetMaxHealth(self.total_blood)

	--Check visibility
	if self.caster:CanEntityBeSeenByMyTeam(self.parent) then
		if self.moving == true then self.copy:Stop() end
		self.moving = false
		self.copy:SetForceAttackTarget(self.parent)
	else
		self.copy:MoveToNPC(self.parent)
		self.moving = true
	end
end

--------------------------------------------------------------------------------

function bloodstained_u_modifier_debuff_slow:PlayEfxStart()
	self.burn_particle = ParticleManager:CreateParticle( "particles/bloodstained/bloodstained_u_track1.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt( self.burn_particle, 3, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true )


	-- buff particle
	self:AddParticle(
		self.burn_particle,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	if IsServer() then self.parent:EmitSound("Hero_LifeStealer.OpenWounds") end
end