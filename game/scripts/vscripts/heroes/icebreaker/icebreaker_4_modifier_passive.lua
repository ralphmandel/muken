icebreaker_4_modifier_passive = class({})

function icebreaker_4_modifier_passive:IsHidden() return true end
function icebreaker_4_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_4_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.delay = false
end

function icebreaker_4_modifier_passive:OnRefresh(kv)
end

function icebreaker_4_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_4_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_ABSORB_SPELL
	}

	return funcs
end

function icebreaker_4_modifier_passive:OnAttackLanded(keys)
	if keys.target == self.parent
	and RandomFloat(1, 100) <= self.ability:GetSpecialValueFor("chance") then
		self:ApplyInvisibility(keys.attacker)
	end

	if keys.attacker == self.parent
	and self.delay == false then
    RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_invisible", self.ability)
	end
end

function icebreaker_4_modifier_passive:GetAbsorbSpell(keys)
	if RandomFloat(1, 100) <= self:GetAbility():GetSpecialValueFor("special_spell_chance") then
		self:ApplyInvisibility(keys.ability:GetCaster())
	end
end

function icebreaker_4_modifier_passive:OnIntervalThink()
	self.delay = false
	if IsServer() then self:StartIntervalThink(-1) end
end

-- UTILS -----------------------------------------------------------

function icebreaker_4_modifier_passive:ApplyInvisibility(target)
	if self.parent:PassivesDisabled() then return end

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_invisible", {
		duration = CalcStatus(self.ability:GetSpecialValueFor("invi_duration"), self.caster, self.parent),
		attack_break = 0
	})

	if self.parent:IsIllusion() then self.parent:MoveToTargetToAttack(target) end

	self:CreateMirror(target)
	self:SpreadIce(self.caster, self.parent, self.ability)

	self.delay = true
	if IsServer() then self:StartIntervalThink(1) end
end

function icebreaker_4_modifier_passive:CreateMirror(target)
	local illu_array = CreateIllusions(self.parent, self.parent, {
		outgoing_damage = -50,
		incoming_damage = 500,
		bounty_base = 0,
		bounty_growth = 0,
		duration = self.ability:GetSpecialValueFor("illusion_lifetime")
	}, 1, 64, false, true)

	for _,illu in pairs(illu_array) do
		local hero_loc = self.parent:GetAbsOrigin() + RandomVector(130)
		local illu_loc = self.parent:GetAbsOrigin()
		local attack_target = self.parent:GetAttackTarget()

		if attack_target then
			hero_loc = attack_target:GetAbsOrigin() + RandomVector(130)
		end

		self.parent:SetAbsOrigin(hero_loc)
		FindClearSpaceForUnit(self.parent, hero_loc, true)
		self.parent:MoveToTargetToAttack(attack_target)
		
		illu:SetAbsOrigin(illu_loc)
		illu:SetForwardVector((target:GetAbsOrigin() - illu_loc):Normalized())
		illu:MoveToTargetToAttack(target)
		FindClearSpaceForUnit(illu, illu_loc, true)
	end		
end

function icebreaker_4_modifier_passive:SpreadIce(caster, target, ability)
	local splash_radius = ability:GetSpecialValueFor("special_splash_radius")
	local instant_duration = ability:GetSpecialValueFor("special_instant_duration")
	local stack = ability:GetSpecialValueFor("special_stack")
	local stack_duration = ability:GetSpecialValueFor("special_stack_duration")
	if splash_radius == 0 then return end

	self:PlayEfxSpread(target)

	Timers:CreateTimer((0.1), function()
		if caster and target then
			if IsValidEntity(caster) and IsValidEntity(target) then
				local enemies = FindUnitsInRadius(
					caster:GetTeamNumber(), target:GetOrigin(),
					nil, splash_radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, 0, false
				)
				for _,enemy in pairs(enemies) do
					if enemy:HasModifier("icebreaker__modifier_frozen") == false then
						enemy:AddNewModifier(caster, ability, "icebreaker__modifier_instant", {
							duration = instant_duration
						})
						enemy:AddNewModifier(caster, ability, "icebreaker__modifier_hypo", {
							duration = CalcStatus(stack_duration, caster, enemy), stack = stack
						})
					end
				end
			end
		end
	end)
end

-- EFFECTS -----------------------------------------------------------

function icebreaker_4_modifier_passive:PlayEfxSpread(target)
	local particle = "particles/econ/items/ancient_apparition/aa_blast_ti_5/ancient_apparition_ice_blast_explode_ti5.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())

	if IsServer() then target:EmitSound("Hero_Lich.IceSpire.Destroy") end
end