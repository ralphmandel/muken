bald_4_modifier_passive = class({})

function bald_4_modifier_passive:IsHidden() return true end
function bald_4_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_4_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.exeptions_old = {
		"_modifier_ban",
		"_modifier_bkb",
		"_modifier_blind",
		"_modifier_blind_stack",
		"_modifier_break",
		"_modifier_disarm",
		"_modifier_ethereal",
		"_modifier_generic_arc",
		"_modifier_generic_custom_indicator",
		"_modifier_generic_knockback_lua",
		"_modifier_hide",
		"_modifier_immunity",
		"_modifier_invisible",
		"_modifier_invulnerable",
		"_modifier_lighting",
		"_modifier_movespeed_buff",
		"_modifier_movespeed_debuff",
		"_modifier_no_bar",
		"_modifier_path",
		"_modifier_petrified",
		"_modifier_phase",
		"_modifier_pull",
		"_modifier_restrict",
		"_modifier_root",
		"_modifier_silence",
		"_modifier_stun",
		"_modifier_tracking",
		"_modifier_truesight",
		"_modifier_untargetable",
		"_modifier_root",
	}

	self.exeptions = {
		"_1_AGI_modifier_stack", "_1_CON_modifier_stack",
		"_1_INT_modifier_stack", "_1_STR_modifier_stack",
		"_2_DEF_modifier_stack", "_2_DEX_modifier_stack",
		"_2_LCK_modifier_stack", "_2_MND_modifier_stack",
		"_2_REC_modifier_stack", "_2_RES_modifier_stack",
		"_modifier_blind_stack", "shadowmancer_1_modifier_debuff_stack",
	}
end

function bald_4_modifier_passive:OnRefresh(kv)
end

function bald_4_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_4_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_MODIFIER_ADDED
	}

	return funcs
end

function bald_4_modifier_passive:OnModifierAdded(keys)
	if keys.unit ~= self.parent then return end
	if keys.added_buff:IsDebuff() == false then return end
	if self.parent:PassivesDisabled() then return end

	for _,mod_name in pairs(self.exeptions) do
		if mod_name == keys.added_buff:GetName() then
			return
		end
	end

	local heal = self.ability:GetSpecialValueFor("heal")
	local base_stats = self.caster:FindAbilityByName("base_stats")
	if base_stats then heal = heal * base_stats:GetHealPower() end

	self.parent:Heal(heal, self.ability)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------
--print("IsDebuff", keys.added_buff:GetName(), keys.added_buff:IsDebuff())