var PANEL_MODEL = {};

function OnUpdateHeroSelection() {
  if (Game.GetState() == DOTA_GameState.DOTA_GAMERULES_STATE_HERO_SELECTION) {
    var sound_name = "";
    var hero = Game.GetLocalPlayerInfo().possible_hero_selection;
    var player_id = Game.GetLocalPlayerInfo().player_id;

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

    hero = "npc_dota_hero_" + hero

    if (PANEL_MODEL[player_id]) {
      if (PANEL_MODEL[player_id].unit != hero) {
        PANEL_MODEL[player_id].DeleteAsync(0);
        Create3DPanel(player_id, hero, sound_name);
      }
    } else {
      Create3DPanel(player_id, hero, sound_name);
    }
  }
}

function Create3DPanel(player_id, hero, sound_name) {
  Game.EmitSound("JP." + sound_name);
  PANEL_MODEL[player_id] = $.CreatePanel("DOTAScenePanel", $.GetContextPanel(), "Preview3DItems", {
    antialias: "false",
    particleonly: "false",
    class: "SceneLoaded",
    allowrotation: "true",
    camera: "default_camera",
    unit: hero
  });
}

(function() {
	//GameEvents.Subscribe("dota_player_hero_selection_dirty", OnUpdateHeroSelection);
})();

