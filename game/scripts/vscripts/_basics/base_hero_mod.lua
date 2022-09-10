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
	self:LoadActivity()
	self:LoadModel()
	self:LoadSounds()
end

function base_hero_mod:OnRefresh(kv)
end

------------------------------------------------------------

function base_hero_mod:DeclareFunctions()
	local funcs = {}
	
	if self:GetCaster():GetUnitName() == "npc_dota_hero_spectre" then
		funcs = {
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_PRE_ATTACK,
			MODIFIER_EVENT_ON_ATTACK,
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
			MODIFIER_PROPERTY_MODEL_CHANGE,
			MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
		}
	else
		funcs = {
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_PRE_ATTACK,
			MODIFIER_EVENT_ON_ATTACK,
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
			MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
		}
	end

	return funcs
end

function base_hero_mod:OnTakeDamage(keys)
	if self.parent:IsIllusion() then return end
	if keys.unit ~= self.parent then return end
	local tp = self.parent:FindItemInInventory("item_tp")
	if tp then tp:StartCooldown(5) end
end

function base_hero_mod:GetModifierPreAttack(keys)
	if keys.attacker ~= self.parent then return end
	if IsServer() then self.parent:EmitSound(self.pre_attack_sound) end
end

function base_hero_mod:OnAttack(keys)
	if keys.attacker ~= self.parent then return end
	if IsServer() then self.parent:EmitSound(self.attack_sound) end
end

function base_hero_mod:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if IsServer() then self.parent:EmitSound(self.attack_landed_sound) end
end

function base_hero_mod:GetAttackSound(keys)
    return ""
end

function base_hero_mod:GetModifierModelChange()
	return self.model
end

function base_hero_mod:GetActivityTranslationModifiers()
    return self.activity
end

function base_hero_mod:ChangeActivity(string)
    self.activity = string
end

function base_hero_mod:ChangeSounds(pre_attack, attack, attack_landed)
	if pre_attack then self.pre_attack_sound = pre_attack end
	if attack then self.attack_sound = attack end
	if attack_landed then self.attack_landed_sound = attack_landed end
end

function base_hero_mod:LoadActivity()
	Timers:CreateTimer((0.5), function()
		self.activity = ""
		if self.ability.hero_name == "genuine" then self.activity = "ti6" end
		if self.ability.hero_name == "dasdingo" then self.activity = "fall20" end
		if self.ability.hero_name == "bocuse" then self.activity = "trapper" end
		if self.ability.hero_name == "druid" then self.activity = "when_nature_attacks" end
		if self.ability.hero_name == "ancient" then self.activity = "et_2021" end
	end)
end

function base_hero_mod:LoadModel()
	if self.ability.hero_name == "shadow" then
		self.model = "models/heroes/phantom_assassin/phantom_assassin.vmdl"
		self.parent:SetOriginalModel(self.model)
	end

	Timers:CreateTimer((0.5), function()
		if self.parent then
			if IsValidEntity(self.parent) then
				if self.ability.hero_name == "bocuse" then
					self.parent:SetModelScale(1.15)
					self.parent:SetHealthBarOffsetOverride(200 * self.parent:GetModelScale())
					self.parent:SetMaterialGroup("1")
				end
				if self.ability.hero_name == "shadow" then
					self.parent:SetModelScale(1)
				end
				if self.ability.hero_name == "krieger" then
					self.parent:SetModelScale(1.10)
				end
				if self.ability.hero_name == "ancient" then
					self.parent:SetModelScale(1.10)
					self.parent:SetHealthBarOffsetOverride(200 * self.parent:GetModelScale())
				end
			end
		end
	end)
end

function base_hero_mod:LoadSounds()
	self.pre_attack_sound = ""
	if self.ability.hero_name == "striker" then self.pre_attack_sound = "Hero_Dawnbreaker.PreAttack" end
	if self.ability.hero_name == "krieger" then self.pre_attack_sound = "Krieger.Pre.Attack" end
	if self.ability.hero_name == "druid" then self.pre_attack_sound = "Hero_OgreMagi.PreAttack" end

	self.attack_sound = ""
	if self.ability.hero_name == "genuine" then self.attack_sound = "Hero_DrowRanger.Attack" end
	if self.ability.hero_name == "dasdingo" then self.attack_sound = "Hero_ShadowShaman.Attack" end

	self.attack_landed_sound = ""
	if self.ability.hero_name == "dasdingo" then self.attack_landed_sound = "Hero_ShadowShaman.ProjectileImpact" end
	if self.ability.hero_name == "icebreaker" then self.attack_landed_sound = "Hero_Riki.Attack" end
	if self.ability.hero_name == "genuine" then self.attack_landed_sound = "Hero_DrowRanger.ProjectileImpact" end
	if self.ability.hero_name == "striker" then self.attack_landed_sound = "Hero_Dawnbreaker.Attack" end
	if self.ability.hero_name == "krieger" then self.attack_landed_sound = "krieger.Attack" end
	if self.ability.hero_name == "bocuse" then self.attack_landed_sound = "Hero_Pudge.Attack" end
	if self.ability.hero_name == "shadow" then self.attack_landed_sound = "Hero_Spectre.Attack" end
	if self.ability.hero_name == "bloodstained" then self.attack_landed_sound = "Hero_Nightstalker.Attack" end
	if self.ability.hero_name == "druid" then self.attack_landed_sound = "Hero_OgreMagi.Attack.TI8" end
	if self.ability.hero_name == "ancient" then self.attack_landed_sound = "Hero_ElderTitan.Attack" end
end

-----------------------------------------------------------

function base_hero_mod:PlayEfxAmbient(ambient, attach)
	if self.ability.hero_name == "shadow" then
		local effect_cast = ParticleManager:CreateParticle(ambient, PATTACH_POINT_FOLLOW, self.parent)
		ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
		ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, attach, Vector(0,0,0), true)
		self:AddParticle(effect_cast, false, false, -1, false, false)
	end
end

-- function base_hero_mod:OnIntervalThink()
--     print("x", self.parent:GetAbsOrigin().x, "| y", self.parent:GetAbsOrigin().y, "| z", self.parent:GetAbsOrigin().z)
-- end