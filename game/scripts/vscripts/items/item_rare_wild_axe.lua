item_rare_wild_axe = class({})
LinkLuaModifier("item_rare_wild_axe_mod_passive", "items/item_rare_wild_axe_mod_passive", LUA_MODIFIER_MOTION_NONE)

-----------------------------------------------------------

function item_rare_wild_axe:GetIntrinsicModifierName()
	return "item_rare_wild_axe_mod_passive"
end

function item_rare_wild_axe:OnSpellStart()
	local caster = self:GetCaster()
	local tree = self:GetCursorTarget()

	local branches = {
		[1] = "item_branch_blue",
		[2] = "item_branch_red",
		[3] = "item_branch_green"
	}

	local chance = self:GetSpecialValueFor("chance")
	if RandomInt(1, 100) <= chance then
		local item = CreateItem(branches[RandomInt(1, 3)], nil, nil)
		local pos = tree:GetAbsOrigin()
		local drop = CreateItemOnPositionSync(pos, item)
		local pos_launch = pos + RandomVector(RandomFloat(150,200))
		item:LaunchLoot(false, 100, 0.5, pos_launch)
    self:PlayEfxDropItem(pos_launch)
	end

	tree:CutDownRegrowAfter(180, caster:GetTeamNumber())
end

-----------------------------------------------------------

function item_rare_wild_axe:PlayEfxDropItem(pos_launch)
  local string = "particles/neutral_fx/neutral_item_drop_lvl4.vpcf"
  local particle = ParticleManager:CreateParticle(string, PATTACH_WORLDORIGIN, nil)
  ParticleManager:SetParticleControl(particle, 0, pos_launch)
  ParticleManager:ReleaseParticleIndex(particle)

  if IsServer() then EmitSoundOnLocationForAllies(pos_launch, "NeutralLootDrop.Spawn", self:GetCaster()) end
end