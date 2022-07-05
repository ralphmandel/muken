-- INIT
	if BattleArena == nil then
		BattleArena = class({})
	end

	require("game_setup")
	require("talent_tree")
	require("hero_stats_table")

	function Precache(context)
		--[[
			Precache things we know we'll use.  Possible file types include (but not limited to):
				PrecacheResource( "model", "*.vmdl", context )
				PrecacheResource( "soundfile", "*.vsndevts", context )
				PrecacheResource( "particle", "*.vpcf", context )
				PrecacheResource( "particle_folder", "particles/folder", context )
		]]

		XP_PER_LEVEL_TABLE = {
			30, 40, 50, 60, 70,
			83, 96, 109, 122, 135,
			152, 169, 186, 203, 220,
			242, 264, 286, 308, 330
		}

		LinkLuaModifier("modifier_wearable", "components/modifiers/modifier_wearable.lua", LUA_MODIFIER_MOTION_NONE )

		--precache particle
			--general
				PrecacheResource( "model", "models/creeps/lane_creeps/creep_radiant_ranged/radiant_ranged_crystal.vmdl", context )
				PrecacheResource( "model", "models/creeps/ice_biome/frostbitten/n_creep_frostbitten_swollen01.vmdl", context )
				PrecacheResource( "model", "models/creeps/lane_creeps/ti9_crocodilian_dire/ti9_crocodilian_dire_ranged_mega.vmdl", context )
				PrecacheResource( "model", "models/creeps/neutral_creeps/n_creep_eimermole/n_creep_eimermole_lamp.vmdl", context )
				PrecacheResource( "model", "models/items/broodmother/spiderling/elder_blood_heir_of_elder_blood/elder_blood_heir_of_elder_blood.vmdl", context )
				PrecacheResource( "model", "models/items/broodmother/spiderling/dplus_malevolent_mother_malevoling/dplus_malevolent_mother_malevoling.vmdl", context )
				PrecacheResource( "model", "models/creeps/neutral_creeps/n_creep_dragonspawn_a/n_creep_dragonspawn_a.vmdl", context )
				PrecacheResource( "model", "models/creeps/neutral_creeps/n_creep_dragonspawn_b/n_creep_dragonspawn_b.vmdl", context )
				PrecacheResource( "model", "models/creeps/lane_creeps/ti9_chameleon_radiant/ti9_chameleon_radiant_melee_mega.vmdl", context )
				PrecacheResource( "model", "models/creeps/lane_creeps/ti9_chameleon_radiant/ti9_chameleon_radiant_melee.vmdl", context )
				PrecacheResource( "model", "models/creeps/lane_creeps/ti9_crocodilian_dire/ti9_crocodilian_dire_melee_mega.vmdl", context )
				PrecacheResource( "model", "models/creeps/lane_creeps/ti9_crocodilian_dire/ti9_crocodilian_dire_melee.vmdl", context )
				PrecacheResource( "model", "models/creeps/neutral_creeps/n_creep_black_dragon/n_creep_black_dragon.vmdl", context )
				PrecacheResource( "model", "models/items/lone_druid/bear/tarzan_and_kingkong_spirit/tarzan_and_kingkong_spirit.vmdl", context )
				PrecacheResource( "model", "models/props_structures/good_fountain001.vmdl", context )
				PrecacheResource( "model", "models/props_gameplay/rune_goldxp.vmdl", context )
				
				PrecacheResource( "particle", "particles/items_fx/blademail.vpcf", context )
				PrecacheResource( "particle", "particles/econ/wards/ti8_ward/ti8_ward_true_sight_ambient.vpcf", context )
				PrecacheResource( "particle", "particles/basics/silence.vpcf", context )
				PrecacheResource( "particle", "particles/basics/silence__red.vpcf", context )
				PrecacheResource( "particle", "particles/basics/restrict.vpcf", context )
				PrecacheResource( "particle", "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", context )
				PrecacheResource( "particle", "particles/items2_fx/teleport_start.vpcf", context )
				PrecacheResource( "particle", "particles/items2_fx/teleport_end.vpcf", context )
				PrecacheResource( "particle", "particles/msg_fx/msg_heal.vpcf", context )
				PrecacheResource( "particle", "particles/msg_fx/msg_gold.vpcf", context )
				PrecacheResource( "particle", "particles/msg_fx/msg_crit.vpcf", context )
				PrecacheResource( "particle", "particles/msg_fx/msg_blocked.vpcf", context )
				PrecacheResource( "particle", "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", context )
				PrecacheResource( "particle", "particles/generic/give_mana.vpcf", context )
				PrecacheResource( "particle", "particles/generic_gameplay/generic_stunned.vpcf", context )
				PrecacheResource( "particle", "particles/units/heroes/hero_alchemist/alchemist_acid_spray_debuff.vpcf", context )
				PrecacheResource( "particle", "particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf", context )
				PrecacheResource( "particle", "particles/units/heroes/hero_mars/mars_spear_impact_debuff.vpcf", context )
				PrecacheResource( "particle", "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf", context )
				PrecacheResource( "particle", "particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail_dragonform_proj.vpcf", context )
				PrecacheResource( "particle", "particles/econ/events/ti7/fountain_regen_ti7_lvl3.vpcf", context )
				PrecacheResource( "particle", "particles/units/heroes/hero_phantom_assassin/phantom_assassin_blur.vpcf", context )
				PrecacheResource( "particle", "particles/econ/items/omniknight/omni_ti8_head/omniknight_repel_buff_ti8.vpcf", context )
				PrecacheResource( "particle", "particles/econ/items/gyrocopter/gyro_ti10_immortal_missile/gyro_ti10_immortal_missile_explosion.vpcf", context )
				PrecacheResource( "particle", "particles/econ/items/sven/sven_warcry_ti5/sven_warcry_cast_arc_lightning_impact.vpcf", context )
				PrecacheResource( "particle", "particles/status_fx/status_effect_combo_breaker.vpcf", context )
				PrecacheResource( "particle", "particles/units/heroes/hero_centaur/centaur_double_edge.vpcf", context )
				PrecacheResource( "particle", "particles/units/heroes/hero_treant/treant_bramble_root.vpcf", context )
				PrecacheResource( "particle", "particles/econ/items/dark_willow/dark_willow_chakram_immortal/dark_willow_chakram_immortal_bramble_root.vpcf", context )
				PrecacheResource( "particle", "particles/units/heroes/heroes_underlord/abyssal_underlord_pitofmalice_stun.vpcf", context )

			--creatures
				PrecacheResource( "particle", "particles/econ/items/alchemist/alchemist_aurelian_weapon/alchemist_chemical_rage_aurelian.vpcf", context )
				PrecacheResource( "particle", "particles/status_fx/status_effect_life_stealer_rage.vpcf", context )
				PrecacheResource( "particle", "particles/druid/druid_ult_projectile.vpcf", context )
				PrecacheResource( "particle", "particles/econ/items/centaur/centaur_ti6/centaur_ti6_warstomp.vpcf", context )
				PrecacheResource( "particle", "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", context )

				PrecacheResource( "particle", "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf", context )
				PrecacheResource( "particle", "particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail_dragonform_proj.vpcf", context )
				PrecacheResource( "particle", "particles/econ/events/ti7/fountain_regen_ti7_lvl3.vpcf", context )
				PrecacheResource( "particle", "particles/items_fx/blademail.vpcf", context )
				PrecacheResource( "particle", "particles/units/heroes/hero_alchemist/alchemist_acid_spray_debuff.vpcf", context )
				PrecacheResource( "particle", "particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf", context )	

		--precache soundfile
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_broodmother.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_lone_druid.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_meepo.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_ogre_magi.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_skywrath_mage.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_alchemist.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_clinkz.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_viper.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_brewmaster.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_crystalmaiden.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_queenofpain.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_phantom_assassin.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_drowranger.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_death_prophet.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_terrorblade.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_centaur.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_legion_commander.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dawnbreaker.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_abaddon.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dazzle.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_mirana.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_life_stealer.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dark_willow.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_medusa.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_invoker.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_lich.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_antimage.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_puck.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_tiny.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_pangolier.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_spirit_breaker.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_void_spirit.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_necrolyte.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_nevermore.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_slardar.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_techies.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_grimstroke.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_batrider.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dark_seer.vsndevts", context ) 
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_bane.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_warlock.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_winter_wyvern.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_rubick.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_lion.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_enigma.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_huskar.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_marci.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_monkey_king.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_leshrac.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_abyssal_underlord.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_earthshaker.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_earth_spirit.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_ancient_apparition.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_bounty_hunter.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_templar_assassin.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_stormspirit.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_nightstalker.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_venomancer.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_magnataur.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_visage.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_bloodseeker.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_bristleback.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_night_stalker.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_skeletonking.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_juggernaut.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_enchantress.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_faceless_void.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_chaos_knight.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_elder_titan.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_spectre.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_shredder.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_oracle.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_rattletrap.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_windrunner.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_pugna.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_omniknight.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_keeper_of_the_light.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_mars.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_treant.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_witchdoctor.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_sandking.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_announcer_killing_spree.vsndevts", context )
			PrecacheResource( "soundfile", "soundevents/soundevent_bloodstained.vsndevts", context)
			PrecacheResource( "soundfile", "soundevents/soundevent_bocuse.vsndevts", context)
			PrecacheResource( "soundfile", "soundevents/soundevent_vo.vsndevts", context)
			PrecacheResource( "soundfile", "soundevents/soundevent_muken_items.vsndevts", context)
			PrecacheResource( "soundfile", "soundevents/soundevent_muken_config.vsndevts", context)
	end

	function Activate()
		GameRules.AddonTemplate = BattleArena()
		GameRules.AddonTemplate:InitGameMode()
	end

	function BattleArena:InitGameMode()
		GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
		GameSetup:init()

		GameRules.DropTable = LoadKeyValues("scripts/kv/item_drops.kv")
		self.rare_item_bundle = {
			[1] = "item_rare_serluc_armor",
			[2] = "item_rare_eternal_wings",
			[3] = "item_rare_wild_axe",
			[4] = "item_rare_lacerator",
			[5] = "item_rare_killer_dagger",
			[6] = "item_rare_emperor_crown",
			[7] = "item_rare_arcane_hammer",
			[8] = "item_rare_mystic_brooch"
		}

		ListenToGameEvent("entity_killed", Dynamic_Wrap(self, "OnUnitKilled"), self)
		ListenToGameEvent("dota_team_kill_credit", Dynamic_Wrap(self, "OnTeamKill"), self)
		ListenToGameEvent("npc_spawned", Dynamic_Wrap(self, "OnUnitSpawn"), self)

		local GameMode = GameRules:GetGameModeEntity()

		GameMode:SetBountyRunePickupFilter(
			function(ctx, event)
				event.xp_bounty = 0
				event.gold_bounty = 0

				if math.floor(GameRules:GetDOTATime(false, true)) >= self.vo_time then
					self.vo = self.vo + 1
					Timers:CreateTimer((1), function()
						self.vo = self.vo - 1
						if self.vo == 0 then
							if RandomInt(1,2) == 1 then
								EmitAnnouncerSound("Vo.Rune.1")
								self.vo_time = math.floor(GameRules:GetDOTATime(false, true)) + 6
							else
								EmitAnnouncerSound("Vo.Rune.2")
								self.vo_time = math.floor(GameRules:GetDOTATime(false, true)) + 7
							end
						end
					end)				
				end

				for _,player in pairs(self.players) do
					if player[1]:GetPlayerID() == event.player_id_const then
						local team_index = self:GetTeamIndex(player[1]:GetTeamNumber())
						--local score = self.score_bounty / self.teams[team_index][4]
						local score = 50
						self.teams[team_index][2] = self.teams[team_index][2] + score
						local message = self.teams[team_index][3] .. " SCORE: " .. self.teams[team_index][2]
						GameRules:SendCustomMessage(self.teams[team_index][5] .. message .."</font>",-1,0)

						if self.teams[team_index][2] >= self.score then
							local message = self.teams[team_index][3] .. " VICTORY!"
							GameRules:SetCustomVictoryMessage(message)
							GameRules:SetGameWinner(self.teams[team_index][1])
							return
						end
					end
				end
				return true
			end
		, self)

		GameMode:SetModifyExperienceFilter(
			function(ctx, event)
				return false
			end
		, self)

		GameMode:SetModifyGoldFilter(
			function(ctx, event)
				if event.reason_const == 18 then
					return true
				end
				return false
			end
		, self)

		GameMode:SetItemAddedToInventoryFilter(
			function(ctx, event)
				local unit = EntIndexToHScript(event.inventory_parent_entindex_const)
				local item = EntIndexToHScript(event.item_entindex_const)

				if item:GetName() == "item_branch_green" then item:SetCombineLocked(true) end
				if item:GetName() == "item_branch_red" then item:SetCombineLocked(true) end
				if item:GetName() == "item_branch_blue" then item:SetCombineLocked(true) end
				if item:GetName() == "item_branch_yellow" then item:SetCombineLocked(true) end

				return true
			-- 		if unit:IsHero() and unit:IsIllusion() == false then
			-- 			local observer = 0
			-- 			local sentry = 0
			-- 			for i = 0, 8, 1 do
			-- 				local item_slot = unit:GetItemInSlot(i)
			-- 				if item_slot then
			-- 					item_slot:SetCombineLocked(true)
			-- 					if item_slot:GetName() == "item_ward_observer" then
			-- 						observer = observer + 1
			-- 					end
			-- 					if item_slot:GetName() == "item_ward_sentry" then
			-- 						sentry = sentry + 1
			-- 					end
			-- 				end
			-- 			end
			-- 			if item:GetName() == "item_ward_observer" then
			-- 				if observer >= 2 then return false end
			-- 			end
			-- 			if item:GetName() == "item_ward_sentry" then
			-- 				if sentry >= 2 then return false end
			-- 			end
			-- 		end
			-- 		return true
			end
		, self)

		self.score = 2000
		self.score_kill = 60
		self.score_bounty = 120
		self.first_blood = true
		self.vo = 0
		self.vo_time = -60

		self.players = {}
		self.teams = { -- [1] Team, [2] Score, [3] Team Name, [4] number of players, [5] team colour bar
			[1] = {[1] = DOTA_TEAM_CUSTOM_1, [2] = 0, [3] = "Team Green",  [4] = 0, [5] = "<font color='#009900'>"},
			[2] = {[1] = DOTA_TEAM_CUSTOM_2, [2] = 0, [3] = "Team Red",    [4] = 0, [5] = "<font color='#990000'>"},
			[3] = {[1] = DOTA_TEAM_CUSTOM_3, [2] = 0, [3] = "Team Yellow", [4] = 0, [5] = "<font color='#cc9900'>"},
			[4] = {[1] = DOTA_TEAM_CUSTOM_4, [2] = 0, [3] = "Team Cyan",   [4] = 0, [5] = "<font color='#0099cc'>"},
			[5] = {[1] = DOTA_TEAM_CUSTOM_5, [2] = 0, [3] = "Team Purple", [4] = 0, [5] = "<font color='#9900cc'>"}
		}

		local fountain = CreateUnitByName("fountain_building", Vector(-250,-300,0), true, nil, nil, DOTA_TEAM_NEUTRALS)
		--fountain:RemoveModifierByName("modifier_invulnerable")
		Timers:CreateTimer((0.2), function()
			fountain:SetAbsOrigin(Vector(-250,-300,0))
		end)
		
		self.boss = {[1] = nil, [2] = nil}
		self.spots = {
			[1] = { [1] = {}, [2] = Vector(3960, -2963, 0), [3] = -30, [4] = 1},
			[2] = { [1] = {}, [2] = Vector(1604, -4734, 0), [3] = -30, [4] = 1},
			[3] = { [1] = {}, [2] = Vector(509, -3086, 0), [3] = -30, [4] = 1},
			[4] = { [1] = {}, [2] = Vector(-2429, -3974, 0), [3] = -30, [4] = 1},
			[5] = { [1] = {}, [2] = Vector(-3011, -1664, 0), [3] = -30, [4] = 1},
			[6] = { [1] = {}, [2] = Vector(-4274, -455, 0), [3] = -30, [4] = 1},
			[7] = { [1] = {}, [2] = Vector(-4017, 1468, 0), [3] = -30, [4] = 1},
			[8] = { [1] = {}, [2] = Vector(-2820, 2420, 0), [3] = -30, [4] = 1},
			[9] = { [1] = {}, [2] = Vector(-1410, 2232, 0), [3] = -30, [4] = 1},
			[10] = { [1] = {}, [2] = Vector(-3515, 3128, 0), [3] = -30, [4] = 1},
			[11] = { [1] = {}, [2] = Vector(-1796, 3575, 0), [3] = -30, [4] = 1},
			[12] = { [1] = {}, [2] = Vector(-1727, 5223, 0), [3] = -30, [4] = 1},
			[13] = { [1] = {}, [2] = Vector(65, 5298, 0), [3] = -30, [4] = 1},
			[14] = { [1] = {}, [2] = Vector(3459, 4393, 0), [3] = -30, [4] = 1},
			[15] = { [1] = {}, [2] = Vector(4269, 2743, 0), [3] = -30, [4] = 1},
			[16] = { [1] = {}, [2] = Vector(1457, 1858, 0), [3] = -30, [4] = 1},
			[17] = { [1] = {}, [2] = Vector(4728, 1130, 0), [3] = -30, [4] = 1},
			[18] = { [1] = {}, [2] = Vector(4412, -1042, 0), [3] = -30, [4] = 1},
			[19] = { [1] = {}, [2] = Vector(2624, -896, 0), [3] = -30, [4] = 1},
			[20] = { [1] = {}, [2] = Vector(2188, -2578, 0), [3] = -30, [4] = 1}
		}

		local count = 0
		for _,spot in pairs(self.spots) do
			count = count + 1
			self:CreateSpot(count)
		end
	end

-- UTIL FUNCTIONS
	-- GAME EVENTS
		function BattleArena:EventPreBounty()
			local rand = RandomInt(1,6)
			if rand == 1 then self.pos = Vector(-255,-2114,136) end
			if rand == 2 then self.pos = Vector(2686,-4038,136) end
			if rand == 3 then self.pos = Vector(-3197,61,136) end
			if rand == 4 then self.pos = Vector(315,3317,8) end
			if rand == 5 then self.pos = Vector(2558,2298,264) end
			if rand == 6 then self.pos = Vector(-4606,-2052,392) end
			
			for _,player in pairs(self.players) do
				MinimapEvent(player[1]:GetTeamNumber(), player[1]:GetAssignedHero(), self.pos.x, self.pos.y, 128, 40)
			end

			for _,team in pairs(self.teams) do
				GameRules:ExecuteTeamPing(team[1], self.pos.x, self.pos.y, nil, 0)
			end
		end

		function BattleArena:EventBountyRune()
			CreateRune(self.pos, DOTA_RUNE_BOUNTY)

			for _,player in pairs(self.players) do
				MinimapEvent(player[1]:GetTeamNumber(), player[1]:GetAssignedHero(), self.pos.x, self.pos.y, 256, 0.5)
			end
		end

		function BattleArena:EventBoss(ping)
			local loc_x = {[1] = -3748, [2] = 5745}
			local loc_y = {[1] = -3774, [2] = 2317}

			if ping == 1 then
				self.mini_boss_ping = RandomInt(1, 2)
			else
				if self.mini_boss_ping == 1 then self.mini_boss_ping = 2 else self.mini_boss_ping = 1 end
			end

			for _,player in pairs(self.players) do
				MinimapEvent(
					player[1]:GetTeamNumber(), player[1]:GetAssignedHero(),
					loc_x[self.mini_boss_ping], loc_y[self.mini_boss_ping],
					512, 20
				)
			end
		end

		function BattleArena:CreateBoss(boss_name, spot)
			local spot_vec = {
				[1] = Vector(-3748, -3774, 0),
				[2] = Vector(5745, 2317, 0)
			}

			if self.boss[spot] == nil then
				self.boss[spot] = CreateUnitByName(boss_name, spot_vec[spot], true, nil, nil, DOTA_TEAM_NEUTRALS)
			end
		end

		function BattleArena:GenerateEvent(includeNegativeTime)
			local time = math.floor(GameRules:GetDOTATime(false, includeNegativeTime))
			local sync_time = time % 600
			if self.event_time == nil then self.event_time = -60 end
			if self.event_time == math.floor(time) then return end
			self.event_time = math.floor(time)

			if time == -40 then self:EventPreBounty() end
			if includeNegativeTime then return end

			if time == 0 then self:EventBountyRune() return end
			if sync_time == 140 then self:EventPreBounty() end
			if sync_time == 180 then self:EventBountyRune() end
			if sync_time == 320 then self:EventPreBounty() end
			if sync_time == 360 then self:EventBountyRune() end
			if sync_time == 520 then self:EventBoss(1) end
			if sync_time == 540 then self:CreateBoss("boss_gorillaz", 1) end
			if sync_time == 580 then self:EventBoss(2) end
			if sync_time == 0 then self:CreateBoss("boss_gorillaz", 2) end
		end

	-- COSMETICS UTIL
		function BattleArena:SpawnPlayerCosmetics(includeNegativeTime)
			local time = math.floor(GameRules:GetDOTATime(false, includeNegativeTime))
			if time == -55 then
				if not self.cosmetic_set then
					self.cosmetic_set = true

					for _,player in pairs(self.players) do
						local hero = player[1]:GetAssignedHero()
						self:ApplyUnitCosmetics(hero)

						if IsInToolsMode() then
							hero:FindAbilityByName("cosmetics"):ChangeTeam(hero:GetTeamNumber())
						end
					end
				end
			end
		end

		function BattleArena:ApplyUnitCosmetics(unit)
			local cosmetics = unit:FindAbilityByName("cosmetics")
			if cosmetics then
				cosmetics:LoadCosmetics()
				if unit:GetUnitName() == "npc_dota_hero_riki" then
					cosmetics:SetStatusEffect(nil, "icebreaker_0_modifier_passive_status_efx", true)
				end
			end
		end

	-- SPOTS
		function BattleArena:CalculateNeutralQuantity()
			local quantity = 0
			for i = 1, 20, 1 do
				local empty = true
				for _,unit in pairs(self.spots[i][1]) do
					if unit ~= nil then
						if IsValidEntity(unit) then
							if unit:IsAlive() then
								empty = false
							end
						end
					end
				end
				if empty == false then quantity = quantity + 1 end
			end

			if quantity >= 12 then return end

			local index = 0
			for _,spot in pairs(self.spots) do
				index = index + 1
				self:CreateSpot(index)
			end
		end

		function BattleArena:CreateSpot(number)
			local time = GameRules:GetDOTATime(false, false)
			local spawn_time = 30
			local respawn_time = 60
			local new = true
			for _,unit in pairs(self.spots[number][1]) do
				if unit ~= nil then
					if IsValidEntity(unit) then
						if unit:IsAlive() then
							new = false
						end
					end
				end
			end
			
			if new then
				if self.spots[number][3] == nil then
					self.spots[number][3] = time
				end

				if time >= spawn_time and time - self.spots[number][3] >= respawn_time then
					self:RandomizeNeutrals(number)
				end
			end
		end

		function BattleArena:RandomizeNeutrals(number)
			local time = GameRules:GetDOTATime(false, false)
			local factor_quantity = 1 + math.floor(time / 150)
			if factor_quantity > 16 then factor_quantity = 16 end

			local tier_3 = RandomInt(1, 100)

			local total = 0
			local t3_quantity = 0
			for _,spot in pairs(self.spots) do
				if spot[4] == 3 then
					t3_quantity = t3_quantity + 1
				end
			end

			if tier_3 <= 50 and t3_quantity < factor_quantity then
				local rand_3 = RandomInt(1,3)

				if rand_3 == 1 then
					local unit = CreateUnitByName("neutral_lamp", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
					table.insert(self.spots[number][1], unit)
					local ai = unit:FindModifierByName("_modifier__ai")
					if ai then ai.spot_origin = self.spots[number][2] end
				
					self.spots[number][3] = nil
					self.spots[number][4] = 3
					return
				end

				if rand_3 == 2 then
					local unit = CreateUnitByName("neutral_spider", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
					table.insert(self.spots[number][1], unit)
					local ai = unit:FindModifierByName("_modifier__ai")
					if ai then ai.spot_origin = self.spots[number][2] end
					
					self.spots[number][3] = nil
					self.spots[number][4] = 3
					return
				end
			
				if rand_3 == 3 then
					local unit = CreateUnitByName("neutral_skydragon", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
					table.insert(self.spots[number][1], unit)
					local ai = unit:FindModifierByName("_modifier__ai")
					if ai then ai.spot_origin = self.spots[number][2] end
					
					unit = CreateUnitByName("neutral_dragon", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
					table.insert(self.spots[number][1], unit)
					ai = unit:FindModifierByName("_modifier__ai")
					if ai then ai.spot_origin = self.spots[number][2] end
					
					self.spots[number][3] = nil
					self.spots[number][4] = 3
					return
				end
			end

			local tier_1 = RandomInt(1,5)

			if tier_1 == 1 then
				local unit = CreateUnitByName("neutral_basic_chameleon", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
				table.insert(self.spots[number][1], unit)
				local ai = unit:FindModifierByName("_modifier__ai")
				if ai then ai.spot_origin = self.spots[number][2] end

				unit = CreateUnitByName("neutral_basic_chameleon", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
				table.insert(self.spots[number][1], unit)
				ai = unit:FindModifierByName("_modifier__ai")
				if ai then ai.spot_origin = self.spots[number][2] end

				unit = CreateUnitByName("neutral_basic_chameleon_b", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
				table.insert(self.spots[number][1], unit)
				ai = unit:FindModifierByName("_modifier__ai")
				if ai then ai.spot_origin = self.spots[number][2] end

				unit = CreateUnitByName("neutral_basic_chameleon_b", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
				table.insert(self.spots[number][1], unit)
				ai = unit:FindModifierByName("_modifier__ai")
				if ai then ai.spot_origin = self.spots[number][2] end
				
				self.spots[number][3] = nil
				self.spots[number][4] = 1
				return
			end

			if tier_1 == 2 then
				local unit = CreateUnitByName("neutral_basic_crocodilian", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
				table.insert(self.spots[number][1], unit)
				local ai = unit:FindModifierByName("_modifier__ai")
				if ai then ai.spot_origin = self.spots[number][2] end
				
				unit = CreateUnitByName("neutral_basic_crocodilian_b", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
				table.insert(self.spots[number][1], unit)
				ai = unit:FindModifierByName("_modifier__ai")
				if ai then ai.spot_origin = self.spots[number][2] end
				
				self.spots[number][3] = nil
				self.spots[number][4] = 1
				return
			end

			if tier_1 == 3 then
				local unit = CreateUnitByName("neutral_basic_gargoyle", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
				table.insert(self.spots[number][1], unit)
				local ai = unit:FindModifierByName("_modifier__ai")
				if ai then ai.spot_origin = self.spots[number][2] end

				unit = CreateUnitByName("neutral_basic_gargoyle_b", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
				table.insert(self.spots[number][1], unit)
				ai = unit:FindModifierByName("_modifier__ai")
				if ai then ai.spot_origin = self.spots[number][2] end
				
				unit = CreateUnitByName("neutral_basic_gargoyle_b", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
				table.insert(self.spots[number][1], unit)
				ai = unit:FindModifierByName("_modifier__ai")
				if ai then ai.spot_origin = self.spots[number][2] end

				self.spots[number][3] = nil
				self.spots[number][4] = 1
				return
			end

			if tier_1 == 4 then
				local unit = CreateUnitByName("neutral_igor", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
				table.insert(self.spots[number][1], unit)
				local ai = unit:FindModifierByName("_modifier__ai")
				if ai then ai.spot_origin = self.spots[number][2] end
				
				unit = CreateUnitByName("neutral_frostbitten", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
				table.insert(self.spots[number][1], unit)
				ai = unit:FindModifierByName("_modifier__ai")
				if ai then ai.spot_origin = self.spots[number][2] end
				
				unit = CreateUnitByName("neutral_frostbitten", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
				table.insert(self.spots[number][1], unit)
				ai = unit:FindModifierByName("_modifier__ai")
				if ai then ai.spot_origin = self.spots[number][2] end
				
				self.spots[number][3] = nil
				self.spots[number][4] = 2
				return
			end

			if tier_1 == 5 then
				local unit = CreateUnitByName("neutral_crocodile", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
				table.insert(self.spots[number][1], unit)
				local ai = unit:FindModifierByName("_modifier__ai")
				if ai then ai.spot_origin = self.spots[number][2] end
				
				unit = CreateUnitByName("neutral_crocodile", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
				table.insert(self.spots[number][1], unit)
				ai = unit:FindModifierByName("_modifier__ai")
				if ai then ai.spot_origin = self.spots[number][2] end

				self.spots[number][3] = nil
				self.spots[number][4] = 2
				return
			end
		end

	-- PLAYERS
		function BattleArena:RandomizePlayerSpawn(unit)
			local further_loc = nil
			local further_distance = nil

			local spawn_pos = {
				[1] = Vector(455, -1394, 0),
				[2] = Vector(-1040, -3661, 0),
				[3] = Vector(-2724, -2628, 0),
				[4] = Vector(-2563, -923, 0),
				[5] = Vector(-3144, 1596, 0),
				[6] = Vector(-828, 1413, 0),
				[7] = Vector(-2047, 4349, 0),
				[8] = Vector(1858, 5903, 0),
				[9] = Vector(935, 2619, 0),
				[10] = Vector(3291, 2578, 0),
				[11] = Vector(1084, 875, 0),
				[12] = Vector(3587, -670, 0),
				[13] = Vector(3848, -1969, 0),
				[14] = Vector(3920, -3897, 0),
				[15] = Vector(2175, -3259, 0)
			}

			local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
			local enemies = FindUnitsInRadius(
				unit:GetTeamNumber(),	-- int, your team number
				unit:GetOrigin(),	-- point, center point
				nil,	-- handle, cacheUnit. (not known)
				FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
				DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
				DOTA_UNIT_TARGET_HERO,	-- int, type filter
				flags,	-- int, flag filter
				0,	-- int, order filter
				false	-- bool, can grow cache
			)
			for _,loc in pairs(spawn_pos) do
				local closer = nil
				local distance = 0
				
				for _,enemy in pairs(enemies) do
					if (enemy:IsAlive() == false and enemy:IsReincarnating()) or enemy:IsAlive() then
						if closer == nil then
							closer = loc
							distance = (loc - enemy:GetAbsOrigin()):Length()
						end
						if (loc - enemy:GetAbsOrigin()):Length() < distance then
							closer = loc
							distance = (loc - enemy:GetAbsOrigin()):Length()
						end
					end
				end

				if further_loc == nil then
					further_loc = closer
					further_distance = distance
				else
					if distance > further_distance then
						further_loc = closer
						further_distance = distance
					end
				end
			end

			if further_loc == nil then
				further_loc = spawn_pos[RandomInt(1, 12)]
			end

			unit:SetOrigin(further_loc)
			FindClearSpaceForUnit(unit, further_loc, true)
		end

		function BattleArena:GetTeamIndex(team_number)
			for i = #self.teams, 1, -1 do
				if team_number == self.teams[i][1] then
					return i
				end
			end
		end

		function BattleArena:GetKillingSpreeAnnouncer(kills)
			local rand = RandomInt(1,2)

			if kills == 4 then
				if rand == 1 then return "announcer_killing_spree_announcer_kill_dominate_01" end
				if rand == 2 then return "announcer_killing_spree_announcer_kill_mega_01" end
			end
			if kills == 5 then
				if rand == 1 then return "announcer_killing_spree_announcer_kill_unstop_01" end
				if rand == 2 then return "announcer_killing_spree_announcer_kill_wicked_01" end
			end
			if kills == 6 then
				if rand == 1 then return "announcer_killing_spree_announcer_kill_godlike_01" end
				if rand == 2 then return "announcer_killing_spree_announcer_ownage_01" end
			end
			if kills >= 7 then
				if rand == 1 then return "announcer_killing_spree_announcer_kill_holy_01" end
				if rand == 2 then return "announcer_killing_spree_announcer_kill_monster_01" end
			end

			return "announcer_killing_spree_announcer_kill_spree_01"
		end

	-- DROPS
		function BattleArena:RollDrops(unit)
			local DropInfo = GameRules.DropTable[unit:GetUnitName()]
			if DropInfo then
				local chance = 0
				local item_list = {}
				for table_name, table_chance in pairs(DropInfo) do
					if table_name == "chance" then
						chance = table_chance
					else
						for i = 1, table_chance, 1 do
							if #item_list then
								item_list[#item_list + 1] = table_name
							else
								item_list[1] = table_name
							end
						end
					end
				end

				if RandomInt(1, 100) <= chance then
					local item_name = item_list[RandomInt(1, #item_list)]
					local item = CreateItem(item_name, nil, nil)
					local pos = unit:GetAbsOrigin()
					local drop = CreateItemOnPositionSync(pos, item)
					local pos_launch = pos + RandomVector(RandomFloat(150,200))
					item:LaunchLoot(false, 200, 0.75, pos_launch)

					Timers:CreateTimer((15), function()
						if drop then
							if IsValidEntity(drop) then
								UTIL_Remove(drop)
							end
						end
					end)
				end
			end
		end

		function BattleArena:RollBossDrops(unit)
			local item_name = self:GetBundleItem("rare_item_bundle")
			if item_name == nil then return end
			local item = CreateItem(item_name, nil, nil)
			local pos = unit:GetAbsOrigin()
			local drop = CreateItemOnPositionSync( pos, item )
			local pos_launch = pos+RandomVector(RandomFloat(150,200))
			item:LaunchLoot(false, 200, 0.75, pos_launch)
		end

		function BattleArena:GetBundleItem(package_name)
			if package_name == "rare_item_bundle" then
				--if RandomInt(1, 100) <= 4 then return "item_legend_serluc" end
				return self.rare_item_bundle[RandomInt(1, #self.rare_item_bundle)]
			end
		end

-- LISTENERS
	function BattleArena:OnUnitKilled(args)
		local unit = EntIndexToHScript(args.entindex_killed)
		local killer = EntIndexToHScript(args.entindex_attacker)
		if unit == nil or killer == nil then return end
		if killer:IsBaseNPC() == false then return end
		if unit:IsReincarnating() then return end

		for _,player in pairs(self.players) do
			if player[1]:GetAssignedHero() == unit then
				player[2] = 0

				if killer:GetTeamNumber() == DOTA_TEAM_NEUTRALS
				and math.floor(GameRules:GetDOTATime(false, true)) >= self.vo_time then
					self.vo = self.vo + 1
					Timers:CreateTimer((1.5), function()
						self.vo = self.vo - 1
						if self.vo == 0 then
							EmitAnnouncerSound("Vo.Suicide")
							self.vo_time = math.floor(GameRules:GetDOTATime(false, true)) + 3
						end
					end)
				end
			end
		end

		if unit == self.boss[1] then
			self.boss[1] = nil
			self:RollBossDrops(unit)
		end
		if unit == self.boss[2] then
			self.boss[2] = nil
			self:RollBossDrops(unit)
		end

		if unit:IsCreature() and unit:GetTeamNumber() == DOTA_TEAM_NEUTRALS then
			if IsServer() then
				unit:EmitSound("Creature.Kill")
				self:RollDrops(unit)
			end
			
			for _,spot in pairs(self.spots) do
				for i = #spot[1], 1, -1 do
					local neutral = spot[1][i]
					if neutral == unit then
						table.remove(spot[1],i)
						break
					end
				end
			end
		end

		local gold = 0
		local number = 1

		if killer:GetClassname() == "ability_lua" then return end

		local player_owner = killer:GetPlayerOwner()
		if player_owner == nil then return end
		local assigned_hero = player_owner:GetAssignedHero()
		if assigned_hero == nil then return end

		if unit:IsCreature()
		and unit:IsDominated() == false
		and unit:IsIllusion() == false
		and assigned_hero:GetTeamNumber() ~= unit:GetTeamNumber() then
			number = 0

			local allies = FindUnitsInRadius(
				assigned_hero:GetTeamNumber(),	-- int, your team number
				unit:GetOrigin(),	-- point, center point
				nil,	-- handle, cacheUnit. (not known)
				750,	-- float, radius. or use FIND_UNITS_EVERYWHERE
				DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
				DOTA_UNIT_TARGET_HERO,	-- int, type filter
				0,	-- int, flag filter
				0,	-- int, order filter
				false	-- bool, can grow cache
			)
			for _,unit in pairs(allies) do
				if unit:IsIllusion() == false then
					number = number + 1
				end
			end

			local average_gold_bounty = RandomInt(unit:GetMinimumGoldBounty(), unit:GetMaximumGoldBounty())
			gold = average_gold_bounty / number

			if math.floor(gold) > 0 and number > 0 then
				for _,unit in pairs(allies) do
					if unit:IsIllusion() == false then
						unit:ModifyGold(math.floor(gold), false, 18)
						SendOverheadEventMessage(unit:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, unit, gold, unit)
						
						local base_hero = unit:FindAbilityByName("base_hero")
						if base_hero then base_hero:AddGold(gold) end
					end
				end
			end
		end
	end

	function BattleArena:OnTeamKill(args)
		local killer = PlayerResource:GetPlayer(args.killer_userid)
		local victim = PlayerResource:GetPlayer(args.victim_userid)
		local team_number = args.teamnumber
		local hero_kills = args.herokills

		if victim:GetAssignedHero():IsReincarnating() then return end
		local team_index = self:GetTeamIndex(team_number)
		--local score = self.score_kill / self.teams[self:GetTeamIndex(victim:GetTeamNumber())][4]
		local score = 25

		if self.first_blood == true then
			EmitAnnouncerSound("announcer_killing_spree_announcer_1stblood_01")
			self.first_blood = false
			score = 100
		end

		if math.floor(GameRules:GetDOTATime(false, true)) >= self.vo_time then
			if RandomInt(1,2) > 1 then
				self.vo = self.vo + 1
				Timers:CreateTimer((2), function()
					self.vo = self.vo - 1
					if self.vo == 0 then
						local rand_vo = RandomInt(1, 5)
						if rand_vo == 1 or rand_vo == 2 then
							EmitAnnouncerSound("Vo.Kill.1")
							self.vo_time = math.floor(GameRules:GetDOTATime(false, true)) + 8
						elseif rand_vo == 3 or rand_vo == 4 then
							EmitAnnouncerSound("Vo.Kill.2")
							self.vo_time = math.floor(GameRules:GetDOTATime(false, true)) + 3
						else
							EmitAnnouncerSound("Vo.Kill.3")
							self.vo_time = math.floor(GameRules:GetDOTATime(false, true)) + 28
						end
					end
				end)
			end
			for _,player in pairs(self.players) do
				if player[1] == killer then
					player[2] = player[2] + 1
					local string = self:GetKillingSpreeAnnouncer(player[2])
					if player[2] > 2 then EmitAnnouncerSound(string) end
					break
				end
			end
		end

		self.teams[team_index][2] = self.teams[team_index][2] + score
		local message = self.teams[team_index][3] .. " SCORE: " .. self.teams[team_index][2]
		GameRules:SendCustomMessage(self.teams[team_index][5] .. message .."</font>",-1,0)

		if self.teams[team_index][2] >= self.score then
			local message = self.teams[team_index][3] .. " VICTORY!"
			GameRules:SetCustomVictoryMessage(message)
			GameRules:SetGameWinner(self.teams[team_index][1])
		end
	end

	function BattleArena:OnUnitSpawn(args)
		local unit = EntIndexToHScript(args.entindex)
		if unit == nil then return end
		if unit:IsReincarnating() then return end
		if unit:IsHero() and unit:IsIllusion() == false then
			--self:RandomizePlayerSpawn(unit)
			
			local playerID = unit:GetPlayerOwnerID()
			if playerID ~= nil then
				CenterCameraOnUnit(playerID, unit)
			end

			if unit:HasItemInInventory("item_tp") == false then
				unit:AddItemByName("item_tp")

				if IsInToolsMode() then
					--unit:AddItemByName("item_legend_serluc")

					if self.temp == nil then
						self.temp = 6
					else
						self.temp = self.temp + 1
						unit:SetTeam(self.temp)
					end
				end

				local team_index = self:GetTeamIndex(unit:GetTeamNumber())
				self.teams[team_index][4] = self.teams[team_index][4] + 1
				local player = {[1] = unit:GetPlayerOwner(), [2] = 0}
				table.insert(self.players, player)

				local channel = unit:FindAbilityByName("_channel")
				unit:AddNewModifier(unit, channel, "_modifier_restrict", {duration = 5})
				unit:AddNewModifier(unit, channel, "_modifier_no_bar", {duration = 5})
			end
		end

		if unit:IsHero() and unit:IsIllusion() then
			self:ApplyUnitCosmetics(unit)
		end
	end

-- ON THINK
	function BattleArena:OnThink()
		if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
			self:GenerateEvent(true)
			self:SpawnPlayerCosmetics(true)
		end

		if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
			local myTable = CustomNetTables:GetTableValue("game_state", "round_data")

			if myTable == nil then
				CustomNetTables:SetTableValue("game_state", "round_data", { value = 0 })
			else
				local nextValue = myTable.value + 1
				CustomNetTables:SetTableValue("game_state", "round_data", { value = nextValue })
			end

			self:CalculateNeutralQuantity()
			self:GenerateEvent(false)
		end
		
		if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
			return nil
		end
		
		return 1
	end