var PANEL_MODEL, PANEL_ROOT, PANEL_HERO, WINDOWN_LAYOUT = {}, PANEL_LAYOUT = {
  ["selfoff"]: {},
  ["selfdef"]: {},
  ["selfescape"]: {},
  ["supoff"]: {},
  ["supdef"]: {},
  ["supcontrol"]: {}
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

    Game.EmitSound("General.SelectAction");
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

function OnOverSelfOff() {
  $.DispatchEvent("DOTAShowTextTooltip", WINDOWN_LAYOUT["core_off"], "Assassin");
  Game.EmitSound("Config.Move");
}
function OnOverSelfDef() {
  $.DispatchEvent("DOTAShowTextTooltip", WINDOWN_LAYOUT["core_def"], "Tanker");
  Game.EmitSound("Config.Move");
}
function OnOverSelfEscape() {
  $.DispatchEvent("DOTAShowTextTooltip", WINDOWN_LAYOUT["core_ctr"], "Escaper");
  Game.EmitSound("Config.Move");
}
function OnOverSupOff() {
  $.DispatchEvent("DOTAShowTextTooltip", WINDOWN_LAYOUT["team_off"], "Offensive Support");
  Game.EmitSound("Config.Move");
}
function OnOverSupDef() {
  $.DispatchEvent("DOTAShowTextTooltip", WINDOWN_LAYOUT["team_def"], "Defensive Support");
  Game.EmitSound("Config.Move");
}
function OnOverSupControl() {
  $.DispatchEvent("DOTAShowTextTooltip", WINDOWN_LAYOUT["team_ctr"], "Disabler");
  Game.EmitSound("Config.Move");
}
function OnOutSelfOff() {
  $.DispatchEvent("DOTAHideTextTooltip", WINDOWN_LAYOUT["core_off"]);
}
function OnOutSelfDef() {
  $.DispatchEvent("DOTAHideTextTooltip", WINDOWN_LAYOUT["core_def"]);
}
function OnOutSelfEscape() {
  $.DispatchEvent("DOTAHideTextTooltip", WINDOWN_LAYOUT["core_ctr"]);
}
function OnOutSupOff() {
  $.DispatchEvent("DOTAHideTextTooltip", WINDOWN_LAYOUT["core_off"]);
}
function OnOutSupDef() {
  $.DispatchEvent("DOTAHideTextTooltip", WINDOWN_LAYOUT["core_def"]);
}
function OnOutSupControl() {
  $.DispatchEvent("DOTAHideTextTooltip", WINDOWN_LAYOUT["core_ctr"]);
}

function CreatePanels(id_name) {
  for(var i = 0; i <= $("#" + id_name).GetChildCount() - 1; i++) {
    PANEL_LAYOUT[id_name][i+1] = $("#" + id_name).GetChild(i);
  }
}

(function() {
  WINDOWN_LAYOUT["core_off"] = $("#item_selfoff");
  WINDOWN_LAYOUT["core_def"] = $("#item_selfdef");
  WINDOWN_LAYOUT["core_ctr"] = $("#item_selfescape");
  WINDOWN_LAYOUT["team_off"] = $("#item_supoff");
  WINDOWN_LAYOUT["team_def"] = $("#item_supdef");
  WINDOWN_LAYOUT["team_ctr"] = $("#item_supcontrol");
  PANEL_ROOT = $.GetContextPanel();
  PANEL_ROOT.SetHasClass("column", false);
  PANEL_ROOT.GetChild(1).SetHasClass("column", true);
  PANEL_HERO = $("#hero_panel");
  PANEL_HERO.SetHasClass("root", false);
  PANEL_HERO.SetHasClass("column", false);
  
  CreatePanels("selfoff");
  CreatePanels("selfdef");
  CreatePanels("selfescape");
  CreatePanels("supoff");
  CreatePanels("supdef");
  CreatePanels("supcontrol");

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

