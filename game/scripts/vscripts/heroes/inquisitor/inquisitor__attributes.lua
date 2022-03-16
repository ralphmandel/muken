inquisitor__attributes = class ({})
LinkLuaModifier("inquisitor__modifier_effect", "heroes/inquisitor/inquisitor__modifier_effect", LUA_MODIFIER_MOTION_NONE)
require("talent_tree")

--TALENT FUNCTIONS
	inquisitor__attributes.talents = {
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

	inquisitor__attributes.skills = {
		[1] = "inquisitor_1__shield",
		[2] = "inquisitor_2__portal",
		[3] = "inquisitor_3__blow",
		[4] = "inquisitor_u__autocast"
	}

	function inquisitor__attributes:UpgradeRank(skill, id, level)
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
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_SHARD, caster, level, caster)
			return
		end

		local ability = nil
		if skill == 1 then ability = caster:FindAbilityByName("inquisitor_1__shield") end
		if skill == 2 then ability = caster:FindAbilityByName("inquisitor_2__portal") end
		if skill == 3 then ability = caster:FindAbilityByName("inquisitor_3__blow") end
		if skill == 4 then ability = caster:FindAbilityByName("inquisitor_u__autocast") end

		self.talents[skill][id] = true

		if not ability then return end
		if not ability:IsTrained() then return end
		ability:SetLevel(ability:GetLevel() + level)
		caster:AddExperience(level * 10, 0, false, false)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_SHARD, caster, level, caster)
	end

	function inquisitor__attributes:CheckNewAbility(skill, id, level)
		local caster = self:GetCaster()

		if skill == 5 and id == 1 then caster:FindAbilityByName("inquisitor_x1__hammer"):SetLevel(level) end
		if skill == 5 and id == 2 then caster:FindAbilityByName("inquisitor_x2__redemption"):SetLevel(level) end
	end

--SHOW ATTRIBUTES FUNCTIONS
	function inquisitor__attributes:GetIntrinsicModifierName()
		return "inquisitor__modifier_effect"
	end

	function inquisitor__attributes:GetAbilityTextureName()
		if self:GetToggleState() then
			return "attributes_off"
		else
			return "attributes_on"
		end
	end

	function inquisitor__attributes:OnToggle()
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
	function inquisitor__attributes:Spawn()
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

	function inquisitor__attributes:OnHeroLevelUp()
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

	function inquisitor__attributes:OnUpgrade()
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

	function inquisitor__attributes:SetBasicFraction(secondary_att, fraction)
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
	function inquisitor__attributes:Precache(context)
		PrecacheResource( "particle", "particles/econ/items/lanaya/ta_ti9_immortal_shoulders/ta_ti9_refraction.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_oracle/oracle_false_promise_attacked.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/effigies/status_fx_effigies/se_effigy_fm16_rad_lvl2.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_oracle/oracle_false_promise_attacked.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_phoenix/phoenix_supernova_egg.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_witchdoctor/witchdoctor_voodoo_restoration_heal.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_treant/treant_bramble_root.vpcf", context )
		PrecacheResource( "particle", "particles/econ/events/ti9/blink_dagger_ti9_start_lvl2.vpcf", context )
		PrecacheResource( "particle", "particles/econ/events/ti9/blink_dagger_ti9_end_sparkles_outer.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/effigies/status_fx_effigies/aghs_statue_boss_ambient.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/phantom_assassin/pa_fall20_immortal_shoulders/pa_fall20_blur_start.vpcf", context )
		PrecacheResource( "particle", "particles/econ/events/ti10/blink_dagger_end_ti10_lvl2.vpcf", context )
		PrecacheResource( "particle", "particles/econ/events/ti10/blink_dagger_start_ti10_splash.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_spawn_v2.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/centaur/centaur_ti6_gold/centaur_ti6_warstomp_gold.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/lifestealer/lifestealer_immortal_backbone_gold/lifestealer_immortal_backbone_gold_rage.vpcf", context )
		PrecacheResource( "particle", "particles/inquisitor/inquisitor_dark_sonic.vpcf", context )
		PrecacheResource( "particle", "particles/status_fx/status_effect_phantom_assassin_fall20_active_blur.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_centaur/centaur_return_buff.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_oracle/oracle_fatesedict.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_oracle/oracle_false_promise_cast_enemy.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_beam_shaft.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_ti6_immortal.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_immortal_cast.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_gold_call.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/earthshaker/earthshaker_totem_ti6/earthshaker_totem_ti6_blur_impact.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/dazzle/dazzle_ti6_gold/dazzle_ti6_shallow_grave_gold.vpcf", context )
	end