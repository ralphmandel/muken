_channel = class ({})
LinkLuaModifier("_modifier_cosmetics", "modifiers/_modifier_cosmetics", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_status_effect", "modifiers/_modifier_status_effect", LUA_MODIFIER_MOTION_NONE)

function _channel:Spawn()
	self:UpgradeAbility(true)
	self.models = {}
	self.cosmetic = {}
	self:AddCosmetics()
end

function _channel:AddCosmetics()
	local caster = self:GetCaster()

	if caster:GetUnitName() == "npc_dota_hero_elder_titan" then
		self.models = {
			[1] = "models/items/elder_titan/harness_of_the_soulforged_weapon/harness_of_the_soulforged_weapon.vmdl", -- weapon
			[2] = "models/items/elder_titan/harness_of_the_soulforged_arms/harness_of_the_soulforged_arms.vmdl", -- arms
			[3] = "models/items/elder_titan/elder_titan_immortal_back/elder_titan_immortal_back.vmdl", -- back
			[4] = "models/items/elder_titan/ti9_cache_et_monuments_head/ti9_cache_et_monuments_head.vmdl", -- head
			[5] = "models/items/elder_titan/harness_of_the_soulforged_shoulder/harness_of_the_soulforged_shoulder.vmdl" -- shoulder
		}
	elseif caster:GetUnitName() == "npc_dota_hero_pudge" then
		self.models = {
			[1] = "models/items/pudge/pudge_lord_of_decay_weapon/pudge_lord_of_decay_weapon.vmdl", -- weapon
			[2] = "models/items/pudge/pudge_insanity_chooper/pudge_insanity_chooper.vmdl", -- offhand
			[3] = "models/items/pudge/pudge_frozen_pig_face_head/pudge_frozen_pig_face_head.vmdl", -- head
			[4] = "models/items/pudge/the_ol_choppers_shoulder/the_ol_choppers_shoulder.vmdl", -- left hand
			[5] = "models/items/pudge/delicacies_back/delicacies_back.vmdl", -- back
			[6] = "models/items/pudge/doomsday_ripper_belt/doomsday_ripper_belt.vmdl", -- belt
			[7] = "models/items/pudge/delicacies_arms/delicacies_arms.vmdl" -- arms
		}
	elseif caster:GetUnitName() == "npc_dota_hero_shadow_demon" then
		self.models = {
			[1] = "models/items/shadow_demon/ti7_immortal_back/sd_ti7_immortal_back.vmdl", -- back
			[2] = "models/items/shadow_demon/sd_crown_of_the_nightworld_armor/sd_crown_of_the_nightworld_armor.vmdl", -- armor
			[3] = "models/items/shadow_demon/mantle_of_the_shadow_demon_belt/mantle_of_the_shadow_demon_belt.vmdl", -- belt
			[4] = "models/items/shadow_demon/sd_crown_of_the_nightworld_tail/sd_crown_of_the_nightworld_tail.vmdl", -- tail
		}
	elseif caster:GetUnitName() == "npc_dota_hero_queenofpain" then
		self.models = {
			[1] = "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana_base_armor.vmdl", -- base armor
			[2] = "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana_armor_legacy.vmdl", -- armor
			[3] = "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana_head.vmdl", -- head
			[4] = "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana_modest_wings.vmdl", -- wings
			[5] = "models/items/queenofpain/queenofpain_arcana/queenofpain_arcana_dagger.vmdl", -- weapon
		}
	elseif caster:GetUnitName() == "npc_dota_hero_shadow_shaman" then
		self.models = {
			[1] = "models/items/shadowshaman/ti8_ss_mushroomer_weapon/ti8_ss_mushroomer_weapon.vmdl", -- weapon
			[2] = "models/items/shadowshaman/shaman_charmer_of_firesnake_off_hand/shaman_charmer_of_firesnake_off_hand.vmdl", -- off-hand
			[3] = "models/items/shadowshaman/ss_fall20_immortal_head/ss_fall20_immortal_head.vmdl", -- head
			[4] = "models/items/shadowshaman/shaman_charmer_of_firesnake_arms/shaman_charmer_of_firesnake_arms.vmdl", -- arms
			[5] = "models/items/shadowshaman/ti8_ss_mushroomer_belt/ti8_ss_mushroomer_belt.vmdl", -- belt
		}
	end

	for i = 1, #self.models, 1 do
		self.cosmetic[i] = CreateUnitByName("npc_dummy", caster:GetOrigin(), false, nil, nil, caster:GetTeamNumber())
		self.cosmetic[i]:AddNewModifier(caster, self, "_modifier_cosmetics", {item = i, model = self.models[i]})
	end
end

function _channel:SetStatusEffect(string, enable)
	local caster = self:GetCaster()

	for i = 1, #self.models, 1 do
		if enable == true then
			self.cosmetic[i]:AddNewModifier(caster, self, string, {})
		else
			self.cosmetic[i]:RemoveModifierByName(string)
		end
	end
end