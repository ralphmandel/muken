spike_armor = class({})
LinkLuaModifier( "spike_armor_modifier", "neutrals/spike_armor_modifier", LUA_MODIFIER_MOTION_NONE )

function spike_armor:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	caster:AddNewModifier(caster, self, "spike_armor_modifier", {duration = duration})

	if IsServer() then caster:EmitSound("DOTA_Item.BladeMail.Activate") end
end