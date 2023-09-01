var PANEL_MODEL;
var possible_hero = {}

function OnUpdateHeroSelection() {
  if (Game.GetState() == DOTA_GameState.DOTA_GAMERULES_STATE_HERO_SELECTION) {
    if (PANEL_MODEL) {PANEL_MODEL.DeleteAsync(0)}

    var sound_name = "";
    var hero = Game.GetLocalPlayerInfo().possible_hero_selection;

    if (possible_hero[Game.GetLocalPlayerInfo().player_id] != hero) {
      possible_hero[Game.GetLocalPlayerInfo().player_id] = hero

      if (hero == "pudge") {sound_name = "Bocuse"}
      if (hero == "muerta") {sound_name = "Lawbreaker"}
      if (hero == "slark") {sound_name = "Fleaman"}
      if (hero == "shadow_demon") {sound_name = "Bloodstained"}
    
      if (hero == "sniper") {sound_name = "Hunter"}
      if (hero == "shadow_shaman") {sound_name = "Dasdingo"}
    
      if (hero == "riki") {sound_name = "Icebreaker"}
      if (hero == "drow_ranger") {sound_name = "Genuine"}
    
      if (hero == "elder_titan") {sound_name = "Ancient"}
      if (hero == "dawnbreaker") {sound_name = "Paladin"}
      if (hero == "omniknight") {sound_name = "Templar"}
      if (hero == "bristleback") {sound_name = "Baldur"}
    
      Game.EmitSound("JP." + sound_name);
    
      PANEL_MODEL = $.CreatePanel("DOTAScenePanel", $.GetContextPanel(), "Preview3DItems", {
        class: "PreviewHero",
        antialias: "false",
        particleonly: "false",
        class: "SceneLoaded",
        allowrotation: "true",
        camera: "default_camera",
        unit: "npc_dota_hero_" + hero
      });
    }
  }
}

(function() {
	GameEvents.Subscribe("dota_player_hero_selection_dirty", OnUpdateHeroSelection);
})();

