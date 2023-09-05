var PANEL_MODEL, PANEL_ROOT, PANEL_HERO, WINDOWN_LAYOUT = {}, PANEL_LAYOUT = {
  ["core_atk"]: {},
  ["core_def"]: {},
  ["core_ctr"]: {},
  ["team_atk"]: {},
  ["team_def"]: {},
  ["team_ctr"]: {}
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

function OnOverCoreAtk() {
  $.DispatchEvent("DOTAShowTextTooltip", WINDOWN_LAYOUT["core_off"], "Assassin");
  Game.EmitSound("Config.Move");
}
function OnOverCoreDef() {
  $.DispatchEvent("DOTAShowTextTooltip", WINDOWN_LAYOUT["core_def"], "Tanker");
  Game.EmitSound("Config.Move");
}
function OnOverCoreCtr() {
  $.DispatchEvent("DOTAShowTextTooltip", WINDOWN_LAYOUT["core_ctr"], "Escape");
  Game.EmitSound("Config.Move");
}
function OnOverTeamAtk() {
  $.DispatchEvent("DOTAShowTextTooltip", WINDOWN_LAYOUT["team_off"], "Offensive Support");
  Game.EmitSound("Config.Move");
}
function OnOverTeamDef() {
  $.DispatchEvent("DOTAShowTextTooltip", WINDOWN_LAYOUT["team_def"], "Defensive Support");
  Game.EmitSound("Config.Move");
}
function OnOverTeamCtr() {
  $.DispatchEvent("DOTAShowTextTooltip", WINDOWN_LAYOUT["team_ctr"], "Disabler");
  Game.EmitSound("Config.Move");
}
function OnOutCoreAtk() {
  $.DispatchEvent("DOTAHideTextTooltip", WINDOWN_LAYOUT["core_off"]);
}
function OnOutCoreDef() {
  $.DispatchEvent("DOTAHideTextTooltip", WINDOWN_LAYOUT["core_def"]);
}
function OnOutCoreCtr() {
  $.DispatchEvent("DOTAHideTextTooltip", WINDOWN_LAYOUT["core_ctr"]);
}
function OnOutTeamAtk() {
  $.DispatchEvent("DOTAHideTextTooltip", WINDOWN_LAYOUT["core_off"]);
}
function OnOutTeamDef() {
  $.DispatchEvent("DOTAHideTextTooltip", WINDOWN_LAYOUT["core_def"]);
}
function OnOutTeamCtr() {
  $.DispatchEvent("DOTAHideTextTooltip", WINDOWN_LAYOUT["core_ctr"]);
}

function CreatePanels(id_name) {
  for(var i = 0; i <= $("#" + id_name).GetChildCount() - 1; i++) {
    PANEL_LAYOUT[id_name][i+1] = $("#" + id_name).GetChild(i);
  }
}

(function() {
  WINDOWN_LAYOUT["core_off"] = $("#item_core_atk");
  WINDOWN_LAYOUT["core_def"] = $("#item_core_def");
  WINDOWN_LAYOUT["core_ctr"] = $("#item_core_ctr");
  WINDOWN_LAYOUT["team_off"] = $("#item_team_atk");
  WINDOWN_LAYOUT["team_def"] = $("#item_team_def");
  WINDOWN_LAYOUT["team_ctr"] = $("#item_team_ctr");
  PANEL_ROOT = $.GetContextPanel();
  PANEL_ROOT.SetHasClass("column", false);
  PANEL_ROOT.GetChild(1).SetHasClass("column", true);
  PANEL_HERO = $("#hero_panel");
  PANEL_HERO.SetHasClass("root", false);
  PANEL_HERO.SetHasClass("column", false);
  
  CreatePanels("core_atk");
  CreatePanels("core_def");
  CreatePanels("core_ctr");
  CreatePanels("team_atk");
  CreatePanels("team_def");
  CreatePanels("team_ctr");

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

