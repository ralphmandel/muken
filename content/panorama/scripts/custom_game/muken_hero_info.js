var PANEL_LAYOUT = {}, WINDOWN_LAYOUT = {};
var transition = false;

function OnUpdateHeroSelection() {
  // WINDOWN_LAYOUT["core_off"].SetHasClass("hero-transition", true);
  // WINDOWN_LAYOUT["core_def"].SetHasClass("hero-transition", true);
  // WINDOWN_LAYOUT["core_ctr"].SetHasClass("hero-transition", true);
  // WINDOWN_LAYOUT["team_off"].SetHasClass("hero-transition", true);
  // WINDOWN_LAYOUT["team_def"].SetHasClass("hero-transition", true);
  // WINDOWN_LAYOUT["team_ctr"].SetHasClass("hero-transition", true);

  // for (const [name, panel] of Object.entries(WINDOWN_LAYOUT)) {
  //   WINDOWN_LAYOUT[name].SetHasClass("hero-transition", true);
  //   PANEL_LAYOUT[name].SetHasClass("hero-transition", true);

  //   for(var i = 0; i <= PANEL_LAYOUT[name].GetChildCount() - 1; i++) {
  //     PANEL_LAYOUT[name].GetChild(i).SetHasClass("hero-transition", true);
  //   }
  // }

  Game.EmitSound("General.SelectAction");
	GameEvents.SendCustomGameEventToServer("role_bar_update", {id_name: Game.GetLocalPlayerInfo().possible_hero_selection});
}

function OnRoleBarUpdate(event) {
  var max_level = 6;
  transition = !transition;

  for (const [event_name, event_value] of Object.entries(event)) {
    var percent = (100 / max_level) * parseInt(event_value);
    PANEL_LAYOUT[event_name].style.width = percent.toString() + '%';
    // PANEL_LAYOUT[event_name].SetHasClass("hero-transition", false);
    // WINDOWN_LAYOUT[event_name].SetHasClass("hero-transition", false);

    // for(var i = 0; i <= PANEL_LAYOUT[event_name].GetChildCount() - 1; i++) {
    //   PANEL_LAYOUT[event_name].GetChild(i).SetHasClass("hero-transition", false);
    // }
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

(function() {
  PANEL_LAYOUT["core_off"] = $("#selfoff");
  PANEL_LAYOUT["core_def"] = $("#selfdef");
  PANEL_LAYOUT["core_ctr"] = $("#selfescape");
  PANEL_LAYOUT["team_off"] = $("#supoff");
  PANEL_LAYOUT["team_def"] = $("#supdef");
  PANEL_LAYOUT["team_ctr"] = $("#supcontrol");
  WINDOWN_LAYOUT["core_off"] = $("#item_selfoff");
  WINDOWN_LAYOUT["core_def"] = $("#item_selfdef");
  WINDOWN_LAYOUT["core_ctr"] = $("#item_selfescape");
  WINDOWN_LAYOUT["team_off"] = $("#item_supoff");
  WINDOWN_LAYOUT["team_def"] = $("#item_supdef");
  WINDOWN_LAYOUT["team_ctr"] = $("#item_supcontrol");

	GameEvents.Subscribe("dota_player_hero_selection_dirty", OnUpdateHeroSelection);
  GameEvents.Subscribe("role_bar_state_from_server", OnRoleBarUpdate);
})();

