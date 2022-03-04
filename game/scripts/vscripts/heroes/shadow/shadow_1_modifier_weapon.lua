shadow_1_modifier_weapon = class({})

function shadow_1_modifier_weapon:IsPurgable()
	return false
end

function shadow_1_modifier_weapon:IsHidden()
	return false
end

-------------------------------------------------------------------

function shadow_1_modifier_weapon:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.hp_loss = self.ability:GetSpecialValueFor("hp_loss") * 0.01
	self.effect_radius = 0
	self.phase = false

	-- UP 1.2
	if self.ability:GetRank(2) then
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {percent = 15})
		self.phase = true
	end

	-- UP 1.4
	if self.ability:GetRank(4)
	and self.parent:IsIllusion() == false then
		self.ability:AddBonus("_1_AGI", self.parent, 15, 0, nil)
	end

	-- UP 1.5
	if self.ability:GetRank(5) then
		self.effect_radius = 200
	end

	local effect = self.parent:FindModifierByName("shadow__modifier_effect")
	if effect then effect:StopEfxStart() end
	self:PlayEfxStart()

	if IsServer() then
		if self.parent:IsIllusion() == false then
			local shadows = FindUnitsInRadius(
				self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil,
				FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false
			)

			for _,shadow in pairs(shadows) do
				if shadow:HasModifier("shadow_3_modifier_illusion") then
					shadow:AddNewModifier(self.caster, self.ability, "shadow_1_modifier_weapon", {})
				end
			end
		end

		self.delay_enable = 2
		self.intervals = 0.5
		self:StartIntervalThink(self.intervals)
	end
end

function shadow_1_modifier_weapon:OnRefresh(kv)
end

function shadow_1_modifier_weapon:OnRemoved()
	local effect = self.parent:FindModifierByName("shadow__modifier_effect")
	if effect then effect:PlayEfxStart() end
	if self.parent:IsIllusion() then return end

	if IsServer() then self.parent:EmitSound("Hero_Grimstroke.InkSwell.Target") end

	local shadows = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil,
		FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false
	)

	for _,shadow in pairs(shadows) do
		if shadow:HasModifier("shadow_3_modifier_illusion") then
			shadow:RemoveModifierByName("shadow_1_modifier_weapon")
		end
	end

	local disable = self.caster:FindAbilityByName("shadow_1__disable")
	if disable then
		if disable:IsTrained() then
			disable:SetHidden(true)
		end
	end
	
	self.ability:RemoveBonus("_1_AGI", self.parent)

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-------------------------------------------------------------------

function shadow_1_modifier_weapon:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = self.phase,
	}

	return state
end

function shadow_1_modifier_weapon:DeclareFunctions()

    local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
    }
 
    return funcs
end

function shadow_1_modifier_weapon:GetModifierIncomingDamage_Percentage(keys)
	local damage_reduction = self.ability:GetSpecialValueFor("damage_reduction")
    local mod = keys.attacker:FindModifierByName("shadow_0_modifier_poison")
	if mod == nil then return 0 end

	-- UP 1.3
	if self.ability:GetRank(3) then
		damage_reduction = damage_reduction + 2
	end
	
	local percent = 0
	local total = 1
	local stacks = mod:GetStackCount()
	for i = 1, stacks, 1 do
		percent = percent + (total * damage_reduction)
		total = total - (total * damage_reduction * 0.01)
	end

	return -percent
end

function shadow_1_modifier_weapon:GetModifierProcAttack_Feedback(keys)
	if keys.attacker ~= self.parent then return end
	local chance = self.ability:GetSpecialValueFor("chance") * 10
	local radius = 100

	if self.parent:IsIllusion() then chance = self.ability:GetSpecialValueFor("shadow_chance") * 10 end

	if RandomInt(1, 1000) <= chance
	and keys.target:IsMagicImmune() == false then
		-- UP 1.1
		if self.ability:GetRank(1) then
			radius = 250
			local enemies = FindUnitsInRadius(
				self.caster:GetTeamNumber(), keys.target:GetOrigin(), nil, radius,
				DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				0, 0, false
			)

			for _,enemy in pairs(enemies) do
				enemy:AddNewModifier(self.caster, self.ability, "shadow_0_modifier_poison", {})
			end
		else
			keys.target:AddNewModifier(self.caster, self.ability, "shadow_0_modifier_poison", {})
		end

		self:PlayEfxHit(keys.target, radius)
		self:StartIntervalThink(1)
	end

	-- UP 1.4
	if self.ability:GetRank(4) then
		local mod_poison = keys.target:FindModifierByName("shadow_0_modifier_poison")
		if mod_poison then
			local lifesteal = mod_poison:GetPoisonDamage() * 0.5
			if lifesteal > 0 then keys.attacker:Heal(lifesteal, nil) end
			self:PlayEfxLifesteal(keys.attacker)
		end
	end
end

function shadow_1_modifier_weapon:OnIntervalThink()
	if self.parent:IsIllusion() == false then
		if self.delay_enable > 0 then
			self.delay_enable = self.delay_enable - 1
		else
			self.ability:SetActivated(true)
		end
	end

	local total = self.parent:GetHealth() - (self.parent:GetMaxHealth() * self.hp_loss * self.intervals)
	self.parent:ModifyHealth(total, self.ability, false, 0)

	-- UP 1.5
	if self.ability:GetRank(5) then
		local enemies = FindUnitsInRadius(
			self.caster:GetTeamNumber(),	-- int, your team number
			self.parent:GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.effect_radius + 50,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)
	
		for _,enemy in pairs(enemies) do
			enemy:AddNewModifier(self.caster, self.ability, "shadow_1_modifier_faster", {duration = 1})
		end
	end

	self:StartIntervalThink(-1)
	self:StartIntervalThink(self.intervals)
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function shadow_1_modifier_weapon:GetEffectName()
	return "particles/bioshadow/bioshadow_drain.vpcf"
end

function shadow_1_modifier_weapon:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function shadow_1_modifier_weapon:PlayEfxStart()
	local particle_cast = "particles/bioshadow/bioshadow_deaddly_potion.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 2, Vector(self.effect_radius, self.effect_radius, self.effect_radius))
	ParticleManager:SetParticleControlEnt(effect_cast, 3, self.parent, PATTACH_ABSORIGIN_FOLLOW, nil, self.parent:GetOrigin(), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 4, self.parent, PATTACH_ABSORIGIN_FOLLOW, nil, self.parent:GetOrigin(), true)
	self:AddParticle(effect_cast, false, false, -1, false, true)
end

function shadow_1_modifier_weapon:PlayEfxHit(target, radius)
	local effect = ParticleManager:CreateParticle("particles/bioshadow/bioshadow_poison_hit.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effect, 1, Vector(radius, 0, 0))
	if IsServer() then target:EmitSound("Hero_Bioshadow.Poison") end
end

function shadow_1_modifier_weapon:PlayEfxLifesteal()
	local particle_cast = "particles/bioshadow/bioshadow_lifetseal.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)
end