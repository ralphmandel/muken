hunter_4__bandage = class({})
LinkLuaModifier("hunter_4_modifier_bandage", "heroes/nature/hunter/hunter_4_modifier_bandage", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function hunter_4__bandage:OnSpellStart()
    local caster = self:GetCaster()
    local tree = self:GetCursorTarget()

    --local item = caster:AddItemByName("item_tango")
    tree:CutDownRegrowAfter(180, caster:GetTeamNumber())
    AddModifier(caster, self, "hunter_4_modifier_bandage")
	end

-- EFFECTS