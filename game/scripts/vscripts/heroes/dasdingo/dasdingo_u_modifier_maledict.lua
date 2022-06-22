dasdingo_u_modifier_maledict = class({})

function dasdingo_u_modifier_maledict:IsHidden()
	return false
end

function dasdingo_u_modifier_maledict:IsDebuff()
	return true
end

function dasdingo_u_modifier_maledict:IsPurgable()
	return true
end

-----------------------------------------------------------

function dasdingo_u_modifier_maledict:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local initial_damage = self.ability:GetSpecialValueFor("initial_damage")
	local tick_max = self.ability:GetSpecialValueFor("tick_max")
	self.tick_intervals = self.ability:GetSpecialValueFor("tick_intervals")
	self.amplification = self.ability:GetSpecialValueFor("amplification") * 0.01
	self.health = self.parent:GetHealth()

	self.damageTable = {
		victim = self.parent,
		attacker = self.caster,
		damage = initial_damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability
	}

	ApplyDamage(self.damageTable)

	-- UP 4.21
	if self.ability:GetRank(21) then
		self.amplification = (self.ability:GetSpecialValueFor("amplification") + 3) * 0.01
	end

	-- UP 4.31
	if self.ability:GetRank(31) then
		self.tick_intervals = self.tick_intervals - 0.5
		tick_max = tick_max + 2
	end
	
	if IsServer() then
		self:SetStackCount(tick_max)
		self:PlayEfxStart(true)
		self:StartIntervalThink(self.tick_intervals * 0.1)
	end
end

function dasdingo_u_modifier_maledict:OnRefresh(kv)
	local initial_damage = self.ability:GetSpecialValueFor("initial_damage")
	local tick_max = self.ability:GetSpecialValueFor("tick_max")
	self.tick_intervals = self.ability:GetSpecialValueFor("tick_intervals")
	self.amplification = self.ability:GetSpecialValueFor("amplification") * 0.01
	self.health = self.parent:GetHealth()

	self.damageTable = {
		victim = self.parent,
		attacker = self.caster,
		damage = initial_damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability
	}

	ApplyDamage(self.damageTable)

	-- UP 4.21
	if self.ability:GetRank(21) then
		self.amplification = (self.ability:GetSpecialValueFor("amplification") + 3) * 0.01
	end

	-- UP 4.31
	if self.ability:GetRank(31) then
		self.tick_intervals = self.tick_intervals - 0.5
		tick_max = tick_max + 2
	end
	
	if IsServer() then
		self:SetStackCount(tick_max)
		self:PlayEfxStart(true)
		self:StartIntervalThink(self.tick_intervals)
	end
end

function dasdingo_u_modifier_maledict:OnRemoved(kv)
	if IsServer() then self.parent:StopSound("Hero_WitchDoctor.Maledict_Loop") end
	local mod = self.parent:FindAllModifiersByName("dasdingo_u_modifier_overtime")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

------------------------------------------------------------

function dasdingo_u_modifier_maledict:OnIntervalThink()
	-- UP 4.41
	if self.ability:GetRank(41) then
		self.parent:Purge(true, false, false, false, false)
	end

	local damage = self.health - self.parent:GetHealth()

	if damage < 0 then
		self.health = self.parent:GetHealth()
	else
		self.damageTable.damage = damage * self.amplification
		ApplyDamage(self.damageTable)
	end

	self:PlayEfxStart(false, 0)

	self:DecrementStackCount()
	if self:GetStackCount() < 1 then
		self:Destroy()
		self:StartIntervalThink(-1)
	end
end

-----------------------------------------------------------

function dasdingo_u_modifier_maledict:PlayEfxStart(bStart)
	if bStart then
		if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, true) end

		local string = "particles/econ/items/witch_doctor/wd_ti8_immortal_head/wd_ti8_immortal_maledict.vpcf"
		self.effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
		ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(self.tick_intervals, 0, 0))
		self:AddParticle(self.effect_cast, false, false, -1, false, false)

		if IsServer() then
			self.parent:EmitSound("Hero_WitchDoctor.Maledict_Cast")
			if self.parent:GetPlayerOwnerID() and self.parent:IsAlive() then
				EmitSoundOnEntityForPlayer("Hero_WitchDoctor.Maledict_Loop", self.parent, self.parent:GetPlayerOwnerID())
			end
		end
	else
		if IsServer() then self.parent:EmitSound("Hero_WitchDoctor.Maledict_Tick") end
	end
end