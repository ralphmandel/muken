bocuse_3_modifier_mark = class({})

function bocuse_3_modifier_mark:IsHidden()
	return false
end

function bocuse_3_modifier_mark:IsPurgable()
	return true
end

function bocuse_3_modifier_mark:IsDebuff()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_3_modifier_mark:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.damage_stack = 0

	self.max_stack = self.ability:GetSpecialValueFor("max_stack")

	if IsServer() then
		self:SetStackCount(1)
		self:CheckCounterEfx()
		self:PlayEfxStart()
	end
end

function bocuse_3_modifier_mark:OnRefresh(kv)	
	if IsServer() then
		if self:GetStackCount() < self.max_stack then
			self:IncrementStackCount()
		end
	end
end

function bocuse_3_modifier_mark:OnRemoved()
	if self.pidx then ParticleManager:DestroyParticle(self.pidx, false) end
	self:CheckCounterEfx()

	if self.damage_stack > 0 then
		ApplyDamage({
			victim = self.parent, attacker = self.caster,
			damage = self.damage_stack, damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.ability
		})
	end

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	local mod = self.parent:FindAllModifiersByName("_modifier_break")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	local mod = self.parent:FindAllModifiersByName("_modifier_silence")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_3_modifier_mark:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function bocuse_3_modifier_mark:OnAttacked(keys)
	if keys.target ~= self.parent then return end
	--self:CalcLifesteal(keys.original_damage, keys.attacker)
end

function bocuse_3_modifier_mark:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end
	-- if keys.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
	-- 	self:CalcLifesteal(keys.original_damage, keys.attacker)
	-- end
end

function bocuse_3_modifier_mark:OnStackCountChanged(old)
	self:ChangeDuration()
end

-- UTILS -----------------------------------------------------------

-- function bocuse_3_modifier_mark:CalcDamageStack(damage, attacker)
-- 	if attacker == nil then return end
-- 	if attacker:IsBaseNPC() == false then return end
-- 	if attacker:GetTeamNumber() ~= self.caster:GetTeamNumber() then return end

-- 	local calc = damage * 0.05 * self:GetStackCount()
-- 	self.damage_stack = self.damage_stack + calc
-- end

-- function bocuse_3_modifier_mark:CalcLifesteal(damage, attacker)
-- 	if attacker == nil then return end
-- 	if attacker:IsBaseNPC() == false then return end
-- 	if attacker:GetTeamNumber() ~= self.caster:GetTeamNumber() then return end
-- 	if self:GetStackCount() ~= self.max_stack then return end

-- 	local heal = damage * 0.25
-- 	attacker:Heal(heal, self.ability)
-- 	self:PlayEfxLifesteal(attacker)
-- end

function bocuse_3_modifier_mark:ChangeDuration()
	local stack = self:GetStackCount()
	local damage_stack = self.ability:GetSpecialValueFor("damage_stack")
	local slow = self.ability:GetSpecialValueFor("slow")
	local init_duration = self.ability:GetSpecialValueFor("init_duration")
	local duration_reduction = self.ability:GetSpecialValueFor("duration_reduction")
	local duration = init_duration - (duration_reduction * (stack - 1))

	self:SetDuration(duration, true)
	self:PopupSauce(false)

	-- UP 3.11
	if self.ability:GetRank(11) then
		slow = slow + 25
	end
	
	-- UP 3.31
	if self.ability:GetRank(31) then
		damage_stack = damage_stack + 10
	end

	ApplyDamage({
		attacker = self.caster, victim = self.parent, ability = self.ability,
		damage = damage_stack * stack, damage_type = self.ability:GetAbilityDamageType()
	})

	if stack == self.max_stack then
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
			duration = self:GetRemainingTime(),
			percent = slow
		})

		-- UP 3.41
		if self.ability:GetRank(41) then
			self.parent:AddNewModifier(self.caster, self.ability, "_modifier_disarm", {
				duration = self:GetRemainingTime()
			})
		end

		-- UP 3.42
		if self.ability:GetRank(42) then
			self.parent:AddNewModifier(self.caster, self.ability, "_modifier_silence", {
				duration = self:GetRemainingTime(),
				special = 2
			})
		end
	end
end

-- EFFECTS -----------------------------------------------------------

function bocuse_3_modifier_mark:PlayEfxStart()
	local particle_cast_1 = "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodrage_ground_eztzhok.vpcf"
	local effect_cast_1 = ParticleManager:CreateParticle( particle_cast_1, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt(effect_cast_1, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
    self:AddParticle(effect_cast_1, false, false, -1, false, false)
end

function bocuse_3_modifier_mark:CheckCounterEfx()
	local mod = self.parent:FindModifierByName("icebreaker_1_modifier_hypo")
	if mod then mod:PopupIce(true) end
end

function bocuse_3_modifier_mark:PopupSauce(immediate)
	if self.pidx ~= nil then ParticleManager:DestroyParticle(self.pidx, immediate) end

    local particle = "particles/bocuse/bocuse_3_counter.vpcf"
    if self.parent:HasModifier("icebreaker_0_modifier_slow") then particle = "particles/bocuse/bocuse_3_double_counter.vpcf" end
    self.pidx = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(self.pidx, 2, Vector(self:GetStackCount(), 0, 0))
end

function bocuse_3_modifier_mark:PlayEfxLifesteal(attacker)
	local particle_cast = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, attacker)
	ParticleManager:SetParticleControl(effect_cast, 1, attacker:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)
end