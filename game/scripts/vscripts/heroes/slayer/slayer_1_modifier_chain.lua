slayer_1_modifier_chain = class ({})

function slayer_1_modifier_chain:IsHidden()
    return true
end

function slayer_1_modifier_chain:IsPurgable()
    return false
end

-----------------------------------------------------------

function slayer_1_modifier_chain:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.delay = true
	self.radius = self.ability:GetSpecialValueFor("radius")
	local dps = self.ability:GetSpecialValueFor("dps")
	local intervals = self.ability:GetSpecialValueFor("intervals")

	self.damageTable = {
		victim = nil,
		attacker = self.caster,
		damage = dps * intervals,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		ability = self.ability
	}

	self:PlayEfxStart()
	self:StartIntervalThink(intervals)
end

function slayer_1_modifier_chain:OnRefresh(kv)
end

function slayer_1_modifier_chain:OnRemoved(kv)
end

------------------------------------------------------------

function slayer_1_modifier_chain:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,
	}

	return funcs
end

function slayer_1_modifier_chain:OnAttack(keys)
end

function slayer_1_modifier_chain:OnIntervalThink()
	if self.delay == true then
		self.delay = false
		if IsServer() then self.parent:EmitSound("Hero_Slayer.Laught") end
	end

	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false
	)
	
	for _,enemy in pairs(enemies) do
		self.damageTable.victim = enemy
		ApplyDamage(self.damageTable)

		self:PlayEfxHit()
	end
end

-----------------------------------------------------------

function slayer_1_modifier_chain:PlayEfxStart()
	self.parent:StartGestureWithPlaybackRate(ACT_DOTA_INTRO, 1.2)
end

function slayer_1_modifier_chain:PlayEfxHit()
	if IsServer() then self.parent:EmitSound("Hero_Slayer.Chain_Hit") end
end