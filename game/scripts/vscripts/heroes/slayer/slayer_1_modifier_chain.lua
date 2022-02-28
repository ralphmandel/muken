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
	self.spin = self.ability:GetSpecialValueFor("spin")
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

	self.parent:AddNewModifier(self.caster, self.ability, "slayer_1_modifier_effect", {})
end

function slayer_1_modifier_chain:OnRefresh(kv)
	self.spin = self.ability:GetSpecialValueFor("spin")
end

function slayer_1_modifier_chain:OnRemoved(kv)
	if IsServer() then self.parent:StopSound("Hero_Shredder.Chakram.TI9") end
	self.parent:RemoveModifierByName("slayer_1_modifier_effect")
end

------------------------------------------------------------

function slayer_1_modifier_chain:CheckState()
	local state = {
	    [MODIFIER_STATE_SILENCED] = true,
	    [MODIFIER_STATE_DISARMED] = true
	}

	return state
end

-- function slayer_1_modifier_chain:DeclareFunctions()
-- 	local funcs = {
-- 		MODIFIER_EVENT_ON_ATTACK,
-- 	}

-- 	return funcs
-- end

-- function slayer_1_modifier_chain:OnAttack(keys)
-- end

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

	GridNav:DestroyTreesAroundPoint(self.parent:GetOrigin(), self.radius, true)

	self.spin = self.spin - 1
	if self.spin < 1 then self:Destroy() end
end

-----------------------------------------------------------

function slayer_1_modifier_chain:PlayEfxStart()
	self.parent:StartGestureWithPlaybackRate(ACT_DOTA_INTRO, 1.2)
	if IsServer() then
		self.parent:EmitSound("Hero_Juggernaut.BladeDance.Arcana")
		self.parent:EmitSound("Hero_Shredder.Chakram.TI9")
	end

	-- local string = "particles/econ/items/juggernaut/highplains_sword_longfang/juggernaut_blade_fury_longfang.vpcf"
	-- local efx = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	-- ParticleManager:SetParticleControl(efx, 0, self.parent:GetOrigin())
	-- ParticleManager:SetParticleControl(efx, 5, Vector(self.radius, 0, 0))
end

function slayer_1_modifier_chain:PlayEfxHit()
	if IsServer() then self.parent:EmitSound("Hero_Slayer.Chain_Hit") end
end