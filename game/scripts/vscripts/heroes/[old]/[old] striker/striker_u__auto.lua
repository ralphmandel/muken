striker_u__auto = class({})
LinkLuaModifier("striker_u_modifier_autocast", "heroes/sun/striker/striker_u_modifier_autocast", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function striker_u__auto:GetIntrinsicModifierName()
		return "striker_u_modifier_autocast"
	end

	function striker_u__auto:OnSpellStart()
		local caster = self:GetCaster()
		self:ToggleAutoCast()
		self:OnAutoCastChange(true)
	end

	function striker_u__auto:OnAutoCastChange(state)
		local caster = self:GetCaster()
		local cosmetics = caster:FindAbilityByName("cosmetics")

		if self:GetAutoCastState() == state then
			if cosmetics then
				local model = "models/items/dawnbreaker/judgment_of_light_weapon/judgment_of_light_weapon.vmdl"
				local ambients = {["particles/econ/items/dawnbreaker/dawnbreaker_judgement_of_light/dawnbreaker_judgement_of_light_weapon_ambient.vpcf"] = "nil"}
				cosmetics:ApplyAmbient(ambients, caster, cosmetics:FindModifierByModel(model))
			end
		else
			if cosmetics then
				cosmetics:DestroyAmbient(
					"models/items/dawnbreaker/judgment_of_light_weapon/judgment_of_light_weapon.vmdl",
					"particles/econ/items/dawnbreaker/dawnbreaker_judgement_of_light/dawnbreaker_judgement_of_light_weapon_ambient.vpcf",
					false
				)
			end
		end
	end

-- EFFECTS
