var PANEL_MODEL, PANEL_ROOT, PANEL_HERO, WINDOWN_LAYOUT = {}, PANEL_LAYOUT = {
  ["category_atk"]: {},
  ["category_def"]: {},
  ["category_esc"]: {},
  ["category_ctr"]: {},
};

var possible_hero = {};

function OnUpdateHeroSelection() {
  var hero = Game.GetLocalPlayerInfo().possible_hero_selection;
  var sound_name = "nil";

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
  
  if (possible_hero[Game.GetLocalPlayerInfo().player_id] != hero && sound_name != "nil") {
    possible_hero[Game.GetLocalPlayerInfo().player_id] = hero;
    
    if (PANEL_MODEL) {PANEL_MODEL.DeleteAsync(0)}
    PANEL_MODEL = $.CreatePanel("DOTAScenePanel", PANEL_HERO, "Preview3DItems", {
      antialias: "false",
      particleonly: "false",
      class: "SceneLoaded",
      allowrotation: "true",
      camera: "default_camera",
      unit: "npc_dota_hero_" + hero
    });

    Game.EmitSound("Config.Select");
    Game.EmitSound("JP." + sound_name);
    GameEvents.SendCustomGameEventToServer("role_bar_update", {id_name: Game.GetLocalPlayerInfo().possible_hero_selection});
  }
}

function OnHeroPickUp(event) {
  if (possible_hero[Game.GetLocalPlayerInfo().player_id] == event.hero) {    
    if (PANEL_MODEL) {PANEL_MODEL.DeleteAsync(0)}
  }
}

function OnRoleBarUpdate(event) {
  for (const [event_name, event_value] of Object.entries(event)) {
    for (var i = 1; i <= 6; i++){
      var enabled = i <= event_value;
      PANEL_LAYOUT[event_name][i].GetChild(0).SetHasClass("owned", enabled);
    }
  }
}

function OnOverCategoryAtk() {
  $.DispatchEvent("DOTAShowTextTooltip", WINDOWN_LAYOUT["category_atk"], "Offensive");
  Game.EmitSound("Config.Move");
}
function OnOverCategoryDef() {
  $.DispatchEvent("DOTAShowTextTooltip", WINDOWN_LAYOUT["category_def"], "Defensive");
  Game.EmitSound("Config.Move");
}
function OnOverCategoryEsc() {
  $.DispatchEvent("DOTAShowTextTooltip", WINDOWN_LAYOUT["category_esc"], "Escapist");
  Game.EmitSound("Config.Move");
}
function OnOverCategoryCtr() {
  $.DispatchEvent("DOTAShowTextTooltip", WINDOWN_LAYOUT["category_ctr"], "Disabler");
  Game.EmitSound("Config.Move");
}

function OnOutCategoryAtk() {
  $.DispatchEvent("DOTAHideTextTooltip", WINDOWN_LAYOUT["category_atk"]);
}
function OnOutCategoryDef() {
  $.DispatchEvent("DOTAHideTextTooltip", WINDOWN_LAYOUT["category_def"]);
}
function OnOutCategoryEsc() {
  $.DispatchEvent("DOTAHideTextTooltip", WINDOWN_LAYOUT["category_esc"]);
}
function OnOutCategoryCtr() {
  $.DispatchEvent("DOTAHideTextTooltip", WINDOWN_LAYOUT["category_ctr"]);
}

function CreatePanels(id_name) {
  for(var i = 0; i <= $("#" + id_name).GetChildCount() - 1; i++) {
    PANEL_LAYOUT[id_name][i+1] = $("#" + id_name).GetChild(i);
  }
}

(function() {
  WINDOWN_LAYOUT["category_atk"] = $("#item_category_atk");
  WINDOWN_LAYOUT["category_def"] = $("#item_category_def");
  WINDOWN_LAYOUT["category_esc"] = $("#item_category_esc");
  WINDOWN_LAYOUT["category_ctr"] = $("#item_category_ctr");
  PANEL_ROOT = $.GetContextPanel();
  PANEL_ROOT.SetHasClass("column", false);
  PANEL_ROOT.GetChild(1).SetHasClass("column", true);
  PANEL_HERO = $("#hero_panel");
  PANEL_HERO.SetHasClass("root", false);
  PANEL_HERO.SetHasClass("column", false);
  
  CreatePanels("category_atk");
  CreatePanels("category_def");
  CreatePanels("category_esc");
  CreatePanels("category_ctr");

  for (const [window, container] of Object.entries(PANEL_LAYOUT)) {
    for (const [index, panel] of Object.entries(container)) {
      panel.SetHasClass("marks", true);
      panel.GetChild(0).SetHasClass("owned", false);
     }
  }
  
  GameEvents.Subscribe("dota_player_hero_selection_dirty", OnUpdateHeroSelection);
  GameEvents.Subscribe("dota_player_pick_hero", OnHeroPickUp);
  GameEvents.Subscribe("role_bar_state_from_server", OnRoleBarUpdate);
})();

