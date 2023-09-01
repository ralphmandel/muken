var WINDOWN_LAYOUT = {};

var PANEL_LAYOUT = {
  ["selfoff"]: {},
  ["selfdef"]: {},
  ["selfescape"]: {},
  ["supoff"]: {},
  ["supdef"]: {},
  ["supcontrol"]: {}
};
var transition = false;
var possible_hero = {};

function OnUpdateHeroSelection() {
  var hero = Game.GetLocalPlayerInfo().possible_hero_selection;
  
  if (possible_hero[Game.GetLocalPlayerInfo().player_id] != hero) {
    possible_hero[Game.GetLocalPlayerInfo().player_id] = hero
    
    Game.EmitSound("General.SelectAction");
    GameEvents.SendCustomGameEventToServer("role_bar_update", {id_name: Game.GetLocalPlayerInfo().possible_hero_selection});
  }
}

function OnRoleBarUpdate(event) {
  for (const [event_name, event_value] of Object.entries(event)) {
    for (var i = 1; i <= 6; i++ ){
      var enabled = i <= event_value;
      PANEL_LAYOUT[event_name][i].GetChild(0).SetHasClass("owned", enabled);
    }
  }
}

function OnOverSelfOff() {
  $.DispatchEvent("DOTAShowTextTooltip", WINDOWN_LAYOUT["core_off"], "Offensive");
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
  
  CreatePanels("selfoff");
  CreatePanels("selfdef");
  CreatePanels("selfescape");
  CreatePanels("supoff");
  CreatePanels("supdef");
  CreatePanels("supcontrol");

  for (const [window, container] of Object.entries(PANEL_LAYOUT)) {
    for (const [index, panel] of Object.entries(container)) {
      panel.SetHasClass("marks", true);
      // panel.GetChild(0).SetHasClass("owned", true);
     }
  }
  
  GameEvents.Subscribe("dota_player_hero_selection_dirty", OnUpdateHeroSelection);
  GameEvents.Subscribe("role_bar_state_from_server", OnRoleBarUpdate);
})();

