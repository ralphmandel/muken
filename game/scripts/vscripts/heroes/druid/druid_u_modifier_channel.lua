druid_u_modifier_channel = class({})

function druid_u_modifier_channel:IsHidden()
	return true
end

function druid_u_modifier_channel:IsPurgable()
	return false
end

function druid_u_modifier_channel:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_u_modifier_channel:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.interval = self.ability:GetSpecialValueFor("interval")

	if IsServer() then
		self:StartIntervalThink(self.interval)
		self:SoundLoop(self.parent)
		self:PlayEfxStart()
	end
end

function druid_u_modifier_channel:OnRefresh(kv)
end

function druid_u_modifier_channel:OnRemoved()
	if self.efx_channel then ParticleManager:DestroyParticle(self.efx_channel, false) end
	if self.efx_channel2 then ParticleManager:DestroyParticle(self.efx_channel2, false) end
	if self.fow then RemoveFOWViewer(self.parent:GetTeamNumber(), self.fow) end
	if IsServer() then self.parent:StopSound("Druid.Channel") end
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_u_modifier_channel:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}

	return funcs
end

function druid_u_modifier_channel:GetModifierConstantManaRegen()
	return -self:GetAbility():GetManaCost(self:GetAbility():GetLevel())
end

function druid_u_modifier_channel:OnIntervalThink()
	local chance_lvl = self.ability:GetSpecialValueFor("chance_lvl")
	local mana_loss = self.ability:GetSpecialValueFor("mana_loss")
	local max_dominate = self.ability:GetSpecialValueFor("max_dominate")

	if self.parent:GetMana() == 0 then self.parent:InterruptChannel() return end

	-- UP 6.32
	if self.ability:GetRank(32) then
		max_dominate = max_dominate + 10
	end

	local units = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.ability.point, nil, self.ability:GetAOERadius(),
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false
	)

	for _,unit in pairs(units) do
		if not unit:IsHero() then
			local unit_lvl = unit:GetLevel()
			local chance = 100 / (unit_lvl * chance_lvl)

			if RandomFloat(1, 100) <= chance
			and unit_lvl <= max_dominate
			and unit:GetUnitName() ~= "summoner_spider" then
				unit:Purge(false, true, false, false, false)
				unit:AddNewModifier(self.caster, self.ability, "druid_u_modifier_conversion", {})
				
				if IsServer() then unit:EmitSound("Druid.Finish") end
			end

			break
		end
	end

	-- UP 6.11
	if self.ability:GetRank(11) then
		self:ApplySlow()
	end

	-- UP 6.21
	if self.ability:GetRank(21) then
		self:ConvertTrees()
	end

	if IsServer() then self:StartIntervalThink(self.interval) end
end

-- UTILS -----------------------------------------------------------

function druid_u_modifier_channel:ApplySlow()
	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.ability.point, nil, self.ability:GetAOERadius(),
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false
	)

	for _,enemy in pairs(enemies) do
		local mod = enemy:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
			duration = self.interval,
			percent = 70
		})

		mod:AddParticle(
			ParticleManager:CreateParticle(
				"particles/units/heroes/hero_enchantress/enchantress_enchant_slow.vpcf",
				PATTACH_ABSORIGIN_FOLLOW, enemy
			),
			false, false, -1, false, false
		)
	end
end

function druid_u_modifier_channel:ConvertTrees()
	local chance_lvl = self.ability:GetSpecialValueFor("chance_lvl")
	local treants = {
		[1] = "npc_druid_treant_lv1",
		[2] = "npc_druid_treant_lv2",
		[3] = "npc_druid_treant_lv3",
	}

	local trees = GridNav:GetAllTreesAroundPoint(self.ability.point, self.ability:GetAOERadius(), false)
	if trees == nil then return end

	for _,tree in pairs(trees) do
		local unit_lvl = RandomInt(1, 3)
		local chance = 100 / (unit_lvl * chance_lvl)

		if RandomFloat(1, 100) <= chance then
			local origin = tree:GetOrigin()
			tree:CutDown(self.parent:GetTeamNumber())

			local treant = CreateUnitByName(treants[unit_lvl], origin, true, self.caster, self.caster, self.caster:GetTeamNumber())
			treant:AddNewModifier(self.caster, self.ability, "druid_u_modifier_conversion", {
				duration = self.ability:CalcStatus(60, self.caster, self.parent)
			})

			if IsServer() then treant:EmitSound("Hero_Furion.TreantSpawn") end
		end

		break
	end
end

function druid_u_modifier_channel:SoundLoop(target)
	self.fow = AddFOWViewer(target:GetTeamNumber(), self.ability.point, self.ability:GetAOERadius(), 3, true)
	if IsServer() then target:EmitSound("Druid.Channel") end

	Timers:CreateTimer((3), function()
		if target then
			if IsValidEntity(target) then
				local mod = target:FindModifierByName("druid_u_modifier_channel")
				if mod then mod:SoundLoop(target) end
			end
		end
	end)
end

-- EFFECTS -----------------------------------------------------------

function druid_u_modifier_channel:PlayEfxStart()
	self.efx_channel = ParticleManager:CreateParticle("particles/druid/druid_skill1_channeling.vpcf", PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(self.efx_channel, 0, self.parent:GetOrigin())

	self.efx_channel2 = ParticleManager:CreateParticle("particles/druid/druid_skill1_channeling.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(self.efx_channel2, 0, self.ability.point)
	ParticleManager:SetParticleControl(self.efx_channel2, 5, Vector(math.floor(self.ability:GetAOERadius() * 0.1), 0, 0))
end

function druid_u_modifier_channel:PlayEfxHeal(target)
	local particle = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect_parent = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(effect_parent, 1, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_parent)

	if IsServer() then target:EmitSound("Hero_Dasdingo.Heal") end
end