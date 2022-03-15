crusader__attributes = class ({})
LinkLuaModifier("crusader__modifier_effect", "heroes/crusader/crusader__modifier_effect", LUA_MODIFIER_MOTION_NONE)
require("talent_tree")

--TALENT FUNCTIONS
	crusader__attributes.talents = {
		[1] = {
			[0] = false, [1] = false, [2] = false, [3] = false, [4] = false, [5] = false,
			[6] = false, [7] = false, [8] = false, [9] = false, [10] = false, [11] = false
		},
		[2] = {
			[0] = false, [1] = false, [2] = false, [3] = false, [4] = false, [5] = false,
			[6] = false, [7] = false, [8] = false, [9] = false, [10] = false, [11] = false
		},
		[3] = {
			[0] = false, [1] = false, [2] = false, [3] = false, [4] = false, [5] = false,
			[6] = false, [7] = false, [8] = false, [9] = false, [10] = false, [11] = false
		},
		[4] = {
			[0] = false, [1] = false, [2] = false, [3] = false, [4] = false, [5] = false,
			[6] = false, [7] = false, [8] = false, [9] = false, [10] = false, [11] = false
		}
	}

	crusader__attributes.skills = {
		[1] = "crusader_1__summon",
		[2] = "crusader_2__shield",
		[3] = "crusader_3__counter",
		[4] = "crusader_u__aura"
	}

	function crusader__attributes:UpgradeRank(skill, id, level)
		local caster = self:GetCaster()
		self:CheckNewAbility(skill, id, level)

		if skill == 5 then
			if id == 0 then
				self.stats_bonus = self.stats_bonus + 1
				
				local base_str = self:GetSpecialValueFor("base_STR") + self.stats_bonus
				local skill_str = caster:FindAbilityByName("_1_STR"):SetBasePts(base_str)
		
				local base_agi = self:GetSpecialValueFor("base_AGI") + self.stats_bonus
				local skill_agi = caster:FindAbilityByName("_1_AGI"):SetBasePts(base_agi)
				
				local base_int = self:GetSpecialValueFor("base_INT") + self.stats_bonus
				local skill_int = caster:FindAbilityByName("_1_INT"):SetBasePts(base_int)

				local base_con = self:GetSpecialValueFor("base_CON") + self.stats_bonus
				local skill_con = caster:FindAbilityByName("_1_CON"):SetBasePts(base_con)

				local void = caster:FindAbilityByName("_void")
				if void then void:SetLevel(1) end

				caster:AddExperience(10, 0, false, false)
				return
			end
			self.extras_unlocked = self.extras_unlocked + 1
			caster:AddExperience(level * 10, 0, false, false)
			return
		end

		local ability = nil
		if skill == 1 then ability = caster:FindAbilityByName("crusader_1__summon") end
		if skill == 2 then ability = caster:FindAbilityByName("crusader_2__shield") end
		if skill == 3 then ability = caster:FindAbilityByName("crusader_3__counter") end
		if skill == 4 then ability = caster:FindAbilityByName("crusader_u__aura") end

		self.talents[skill][id] = true

		if not ability then return end
		if not ability:IsTrained() then return end
		ability:SetLevel(ability:GetLevel() + level)
		caster:AddExperience(level * 10, 0, false, false)
	end

	function crusader__attributes:CheckNewAbility(skill, id, level)
		local caster = self:GetCaster()

		if skill == 5 and id == 1 then caster:FindAbilityByName("crusader_x1__extra1"):SetLevel(level) end
		if skill == 5 and id == 2 then caster:FindAbilityByName("crusader_x2__extra2"):SetLevel(level) end
	end

--SHOW ATTRIBUTES FUNCTIONS
	function crusader__attributes:GetIntrinsicModifierName()
		return "crusader__modifier_effect"
	end

	function crusader__attributes:GetAbilityTextureName()
		if self:GetToggleState() then
			return "attributes_off"
		else
			return "attributes_on"
		end
	end

	function crusader__attributes:OnToggle()
		local caster = self:GetCaster()
		local ATTs = {
			[1] = caster:FindAbilityByName("_2_DEX"),
			[2] = caster:FindAbilityByName("_2_DEF"),
			[3] = caster:FindAbilityByName("_2_RES"),
			[4] = caster:FindAbilityByName("_2_REC"),
			[5] = caster:FindAbilityByName("_2_MND"),
			[6] = caster:FindAbilityByName("_2_LCK"),
		}

		if self:GetToggleState() then
			for _,att in pairs(ATTs) do
				att:SetHidden(false)
			end
		else
			for _,att in pairs(ATTs) do
				att:SetHidden(true)
			end
		end
	end

--LEVELUP ATTRIBUTES FUNCTIONS
	function crusader__attributes:Spawn()
		local caster = self:GetCaster()
		caster:SetAbilityPoints(1)
		
		Timers:CreateTimer((0.2), function()
			if caster:IsIllusion() == false then
				caster:Heal(1000, nil)
				if self:IsTrained() then TalentTree:SetupForHero(caster) end
			end
		end)
		
		self:SetHidden(false)
		self.extras_unlocked = 0
		self.stats_bonus = 0
		self.base_upgrade = false
		
		self.str = 0
		self.agi = 0
		self.int = 0
		self.con = 0
		self.basic_fraction_dex = 0
		self.basic_fraction_def = 0
		self.basic_fraction_res = 0
		self.basic_fraction_rec = 0
		self.basic_fraction_mnd = 0
		self.basic_fraction_lck = 0

		if self:IsTrained() == false then self:UpgradeAbility(true) end
	end

	function crusader__attributes:OnHeroLevelUp()
		local caster = self:GetCaster()
		local level = caster:GetLevel()
		if caster:IsIllusion() then return end

		local gain = 0
		if level ~= 2 and level ~= 5 and level ~= 8 then gain = -1 end
		if level > 0 then gain = gain + 1 end
		if level > 4 then gain = gain + 1 end
		if level > 8 then gain = gain + 1 end
		if level > 12 then gain = gain + 1 end
		if level > 16 then gain = gain + 1 end
		caster:SetAbilityPoints((caster:GetAbilityPoints() + gain))

		self:UpgradeAbility(true)

		if level == 24 then
			for i = 1, 5, 1 do
				self:UpgradeAbility(true)
			end
		end
	end

	function crusader__attributes:OnUpgrade()
		local caster = self:GetCaster()

		local skill_str = caster:FindAbilityByName("_1_STR")
		local base_str = self:GetSpecialValueFor("base_STR")
		local str = self:GetSpecialValueFor("STR")

		local skill_agi = caster:FindAbilityByName("_1_AGI")
		local base_agi = self:GetSpecialValueFor("base_AGI")
		local agi = self:GetSpecialValueFor("AGI")

		local skill_int = caster:FindAbilityByName("_1_INT")
		local base_int = self:GetSpecialValueFor("base_INT")
		local int = self:GetSpecialValueFor("INT")

		local skill_con = caster:FindAbilityByName("_1_CON")
		local base_con = self:GetSpecialValueFor("base_CON")
		local con = self:GetSpecialValueFor("CON")

		if self.base_upgrade == false then
			self.base_upgrade = true
			self.str = base_str
			self.agi = base_agi
			self.int = base_int
			self.con = base_con

			skill_str:SetBasePts(base_str)
			skill_agi:SetBasePts(base_agi)
			skill_int:SetBasePts(base_int)
			skill_con:SetBasePts(base_con)
		end

		if caster:IsIllusion() then return end

		self.str = self.str + str
		str = math.floor(self.str)
		self.agi = self.agi + agi
		agi = math.floor(self.agi)
		self.int = self.int + int
		int = math.floor(self.int)
		self.con = self.con + con
		con = math.floor(self.con)

		if str > 0 then
			for x = 1, str, 1 do
				skill_str:UpgradeAbility(true)
				self.basic_fraction_lck = self.basic_fraction_lck + 1
				self.basic_fraction_res = self.basic_fraction_res + 1
				self.basic_fraction_def = self.basic_fraction_def + 1
			end
		end
		
		if agi > 0 then
			for x = 1, agi, 1 do
				skill_agi:UpgradeAbility(true)
				self.basic_fraction_lck = self.basic_fraction_lck + 1
				self.basic_fraction_dex = self.basic_fraction_dex + 1
				self.basic_fraction_rec = self.basic_fraction_rec + 1
			end
		end

		if int > 0 then
			for x = 1, int, 1 do
				skill_int:UpgradeAbility(true)
				self.basic_fraction_res = self.basic_fraction_res + 1
				self.basic_fraction_rec = self.basic_fraction_rec + 1
				self.basic_fraction_mnd = self.basic_fraction_mnd + 1
			end
		end

		if con > 0 then
			for x = 1, con, 1 do
				skill_con:UpgradeAbility(true)
				self.basic_fraction_def = self.basic_fraction_def + 1
				self.basic_fraction_mnd = self.basic_fraction_mnd + 1
				self.basic_fraction_dex = self.basic_fraction_dex + 1
			end
		end

		self:SetBasicFraction("_2_DEX", self.basic_fraction_dex)
		self:SetBasicFraction("_2_DEF", self.basic_fraction_def)
		self:SetBasicFraction("_2_RES", self.basic_fraction_res)
		self:SetBasicFraction("_2_REC", self.basic_fraction_rec)
		self:SetBasicFraction("_2_MND", self.basic_fraction_mnd)
		self:SetBasicFraction("_2_LCK", self.basic_fraction_lck)

		self.str = self.str % 1
		self.agi = self.agi % 1
		self.int = self.int % 1
		self.con = self.con % 1
		self.basic_fraction_dex = self.basic_fraction_dex % 2
		self.basic_fraction_def = self.basic_fraction_def % 2
		self.basic_fraction_res = self.basic_fraction_res % 2
		self.basic_fraction_rec = self.basic_fraction_rec % 2
		self.basic_fraction_mnd = self.basic_fraction_mnd % 2
		self.basic_fraction_lck = self.basic_fraction_lck % 2
	end

	function crusader__attributes:SetBasicFraction(secondary_att, fraction)
		local caster = self:GetCaster()
		local sub = caster:FindAbilityByName(secondary_att)
		if sub == nil then return end

		local levels = math.floor(fraction / 2)
		if levels > 0 then
			for x = 1, levels, 1 do
				sub:EnableBasicUpgrade()
				sub:UpgradeAbility(true)
			end
		end
	end

--PRECACHE
	function crusader__attributes:Precache(context)
		PrecacheResource( "particle", "particles/crusader/crusader_aura.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_reincarn.vpcf", context )
		PrecacheResource( "particle", "particles/crusader/crusader_resist.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_rubick/rubick_spell_steal.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell_fear_debuff.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_abaddon/abaddon_aphotic_shield.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_hit.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_abaddon/abaddon_borrowed_time_heal.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/pugna/pugna_ti9_immortal/pugna_ti9_immortal_netherblast.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/terrorblade/terrorblade_back_ti8/terrorblade_sunder_ti8.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/underlord/underlord_ti8_immortal_weapon/underlord_ti8_immortal_pitofmalice_stun_light.vpcf", context )
		PrecacheResource( "particle", "particles/status_fx/status_effect_wraithking_ghosts.vpcf", context )
		PrecacheResource( "particle", "particles/crusader/crusader_trigger.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/phantom_assassin/pa_ti8_immortal_head/pa_ti8_immortal_dagger_debuff_arcana_combined.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_legion_commander/legion_commander_courage_hit.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_explosion.vpcf", context )
		PrecacheResource( "particle", "particles/items3_fx/octarine_core_lifesteal.vpcf", context )
		PrecacheResource( "particle", "particles/crusader/crusader_aura_buff_caster.vpcf", context )
		PrecacheResource( "particle", "particles/crusader/crusader_aura_buff.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_skeletonking/wraith_king_ghosts_ambient.vpcf", context )
	end