base_hero_mod = class ({})

function base_hero_mod:IsHidden()
    return true
end

function base_hero_mod:IsPurgable()
    return false
end

-----------------------------------------------------------

function base_hero_mod:OnCreated(kv)
	self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.ability:LoadHeroNames()
	self.activity = ""

	if self.ability.hero_name == "genuine" then self.activity = "ti6" end

	Timers:CreateTimer((0.5), function()
		if self.parent then
			if IsValidEntity(self.parent) then
				if self.ability.hero_name == "bocuse" then
					self.parent:SetModelScale(1.15)
					self.parent:SetHealthBarOffsetOverride(200 * self.parent:GetModelScale())
				end
			end
		end
	end)

	--self:StartIntervalThink(1)
end

function base_hero_mod:OnRefresh(kv)
end

------------------------------------------------------------

function base_hero_mod:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}

	return funcs
end

function base_hero_mod:OnTakeDamage(keys)
	if self.parent:IsIllusion() then return end
	if keys.unit ~= self.parent then return end
	local tp = self.parent:FindAbilityByName("item_tp")
	if tp then tp:StartCooldown(5) end
end

function base_hero_mod:OnAttack(keys)
	if keys.attacker ~= self.parent then return end

	if IsServer() then
		local attack_sound = ""
		if self.ability.hero_name == "genuine" then attack_sound = "Hero_DrowRanger.Attack" end

		self.parent:EmitSound(attack_sound)
	end
end

function base_hero_mod:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	
	if IsServer() then
		local attack_sound = ""
		if self.ability.hero_name == "bocuse" then attack_sound = "Hero_Pudge.Attack" end
		if self.ability.hero_name == "genuine" then attack_sound = "Hero_DrowRanger.ProjectileImpact" end

		self.parent:EmitSound(attack_sound)
	end
end

function base_hero_mod:GetAttackSound(keys)
    return ""
end

function base_hero_mod:GetActivityTranslationModifiers(keys)
    return self.activity
end

function base_hero_mod:ChangeActivity(string)
    self.activity = string
end

-- function base_hero_mod:OnIntervalThink()
--     print("x", self.parent:GetAbsOrigin().x, "| y", self.parent:GetAbsOrigin().y, "| z", self.parent:GetAbsOrigin().z)
-- end