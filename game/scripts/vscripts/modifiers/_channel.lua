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
			[2] = "models/items/elder_titan/warden_of_the_gong_arms/warden_of_the_gong_arms.vmdl", -- arms
			[3] = "models/items/elder_titan/warden_of_the_gong_back/warden_of_the_gong_back.vmdl", -- back
			[4] = "models/items/elder_titan/ti9_cache_et_monuments_head/ti9_cache_et_monuments_head.vmdl", -- head
			[5] = "models/items/elder_titan/warden_of_the_gong_shoulder/warden_of_the_gong_shoulder.vmdl" -- shoulder
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