shadow_1__disable = class({})

function shadow_1__disable:Spawn()
    self:UpgradeAbility(true)
end

function shadow_1__disable:OnSpellStart()
    local caster = self:GetCaster()
    caster:RemoveModifierByName("shadow_1_modifier_weapon")
end