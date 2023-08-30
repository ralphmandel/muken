var PANEL_MODEL;

function OnUpdateHeroSelection() {
  if (PANEL_MODEL) {PANEL_MODEL.DeleteAsync(0)}

  var sound_name = "";
  var hero = Game.GetLocalPlayerInfo().possible_hero_selection;

  if (hero == "pudge") {sound_name = "Bocuse"}
  if (hero == "riki") {sound_name = "Icebreaker"}
  if (hero == "elder_titan") {sound_name = "Ancient"}
  if (hero == "sniper") {sound_name = "Hunter"}

  Game.EmitSound("JP." + sound_name);

  PANEL_MODEL = $.CreatePanelWithProperties("DOTAScenePanel", $.GetContextPanel(), "Preview3DItems", {
    class: "PreviewHero",
    antialias: "false",
    particleonly: "false",
    class: "SceneLoaded",
    allowrotation: "true",
    camera: "default_camera",
    unit: "npc_dota_hero_" + hero
  });
}

(function() {
	GameEvents.Subscribe("dota_player_hero_selection_dirty", OnUpdateHeroSelection);
})();

