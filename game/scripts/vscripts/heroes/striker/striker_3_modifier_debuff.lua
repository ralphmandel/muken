striker_3_modifier_debuff = class({})

function striker_3_modifier_debuff:IsHidden()
	return false
end

function striker_3_modifier_debuff:IsPurgable()
	return true
end

function striker_3_modifier_debuff:IsDebuff()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_3_modifier_debuff:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.root_count = 0
	self.root = false

	self.ticks = self.ability:GetSpecialValueFor("max_ticks")
	self.amount = self.ability:GetSpecialValueFor("init_amount")
	self.amount_reduction = self.ability:GetSpecialValueFor("amount_reduction")
	self.tick_interval = self.ability:GetSpecialValueFor("tick_interval")

	-- UP 3.11
	if self.ability:GetRank(11) then
		self.root_count = 2
		self.root = true
		self:PlayEfxRoot()
	end

	-- UP 3.21
	if self.ability:GetRank(21) then
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_silence", {})
	end

	if IsServer() then
		self:ApplyTick()
		self:PlayEfxStart()
	end
end

function striker_3_modifier_debuff:OnRefresh(kv)
	-- UP 3.11
	if self.ability:GetRank(11) then
		self.root_count = 2
		self.root = true
		self:PlayEfxRoot()
	end

	-- UP 3.21
	if self.ability:GetRank(21) then
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_silence", {})
	end

	if IsServer() then
		self:ModifyStack(0, true)
		self:PlayEfxStart()
	end
end

function striker_3_modifier_debuff:OnRemoved()
	if self.particle then ParticleManager:DestroyParticle(self.particle, false) end
	if self.particle_root then ParticleManager:DestroyParticle(self.particle_root, false) end

	local mod = self.parent:FindAllModifiersByName("_modifier_silence")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function striker_3_modifier_debuff:CheckState()
	local state = {}

	if self.root == true then
		table.insert(state, MODIFIER_STATE_ROOTED, true)
	end

	return state
end

function striker_3_modifier_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function striker_3_modifier_debuff:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end
	if keys.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then return end
	if keys.damage > 0 then self:ModifyStack(-1, false) end
end

function striker_3_modifier_debuff:OnIntervalThink()
	if IsServer() then
		self:CheckRoot()
		self:ApplyTick()
	end
end

function striker_3_modifier_debuff:OnStackCountChanged(old)
	if self:GetStackCount() < 1 then self:Destroy() end
end

-- UTILS -----------------------------------------------------------

function striker_3_modifier_debuff:ApplyTick()
	-- UP 3.31
	if self.ability:GetRank(31) then
		self:ApplyPurge()
	end

	local damageTable = {
		victim = self.parent,
		attacker = self.caster,
		damage = self.amount,
		damage_type = self.ability:GetAbilityDamageType(),
		ability = self.ability
	}
	ApplyDamage(damageTable)

	self:ModifyStack(-1, true)

	if self.particle then ParticleManager:SetParticleControl(self.particle, 1, self.parent:GetAbsOrigin()) end
	if IsServer() then self:StartIntervalThink(self.tick_interval) end
end

function striker_3_modifier_debuff:ModifyStack(value, bModifyAmount)
	if value == 0 and bModifyAmount then
		self.ticks = self.ability:GetSpecialValueFor("max_ticks")
		self.amount = self.amount + self.ability:GetSpecialValueFor("init_amount")
	end

	self.ticks = self.ticks + value
	if bModifyAmount then self.amount = self.amount * (100 - self.amount_reduction) * 0.01 end

	if IsServer() then self:SetStackCount(self.ticks) end
end

function striker_3_modifier_debuff:CheckRoot()
	if self.root_count > 0 then
		self.root_count = self.root_count - 1
		if self.root_count == 0 then
			if self.particle_root then ParticleManager:DestroyParticle(self.particle_root, false) end
			self.root = false
		end
	end
end

function striker_3_modifier_debuff:ApplyPurge()
	if RandomFloat(1, 100) <= 10 then
		self.parent:Purge(true, false, false, false, false)
		self:PlayEfxPurge()
	end
end

-- EFFECTS -----------------------------------------------------------

function striker_3_modifier_debuff:PlayEfxStart()
	if self.particle then ParticleManager:DestroyParticle(self.particle, false) end

	local string = "particles/econ/events/fall_2021/blink_dagger_fall_2021_end.vpcf"
    local particle = ParticleManager:CreateParticle(string, PATTACH_WORLDORIGIN, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())

	local string_2 = "particles/econ/events/fall_2021/radiance_fall_2021.vpcf"
	self.particle = ParticleManager:CreateParticle(string_2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.particle, 0, self.parent:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 1, self.parent:GetAbsOrigin())
	self:AddParticle(self.particle, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Abaddon.DeathCoil.Target") end
end

function striker_3_modifier_debuff:PlayEfxRoot()
	if self.particle_root then ParticleManager:DestroyParticle(self.particle_root, false) end

	local string_1 = "particles/striker/portal_root/striker_portal_root_cast_tgt.vpcf"
	local particle_1 = ParticleManager:CreateParticle(string_1, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:ReleaseParticleIndex(particle_1)

	local string_2 = "particles/striker/portal_root/striker_portal_root_aoe.vpcf"
	local particle_2 = ParticleManager:CreateParticle(string_2, PATTACH_WORLDORIGIN, self.caster)
	ParticleManager:SetParticleControl(particle_2, 0, self.parent:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_2, 2, Vector(175, 175, 175))
	ParticleManager:ReleaseParticleIndex(particle_2)

	local string_3 = "particles/striker/portal_root/striker_portal_root_dmg.vpcf"
	local particle_3 = ParticleManager:CreateParticle(string_3, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle_3, 1, self.parent:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_3, 3, self.parent:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_3)

	local string_4 = "particles/striker/portal_root/striker_portal_root_purge.vpcf"
	self.particle_root = ParticleManager:CreateParticle(string_4, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.particle_root, 0, self.parent:GetOrigin())
end

function striker_3_modifier_debuff:PlayEfxPurge()
	local string = "particles/striker/portal_purge/striker_portal_purge_hit.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(particle, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle)

	if IsServer() then self.parent:EmitSound("Hero_Leshrac.Diabolic_Edict") end
end