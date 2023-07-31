hunter_4__bandage = class({})

-- INIT

-- SPELL START

	function hunter_4__bandage:OnSpellStart()
    if IsServer() then
      local caster = self:GetCaster()
      local tree = self:GetCursorTarget()

      local item = caster:AddItemByName("item_tango")
      --caster:DropItemAtPosition(caster:GetOrigin(), item)
      tree:CutDownRegrowAfter(180, caster:GetTeamNumber())
    end
	end

-- EFFECTS