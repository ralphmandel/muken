var STATS_WINDOW, STATS_CONTAINER;
var STATS_LAYOUT = {};
var labels_name = {
  "STR": "STRENGTH", "AGI": "AGILITY", "INT": "INTELLIGENCE", "CON": "CONSTITUTION",
  "DEX": "DEXTERITY", "DEF": "DEFENSE", "RES": "RESISTANCE", "REC": "RECOVERY", "LCK": "LUCK", "MND": "MIND",
}
var stats_group = {
  "STR": {1: "LCK", 2: "DEF", 3: "RES"}, "AGI": {1: "LCK", 2: "REC", 3: "DEX"},
  "INT": {1: "MND", 2: "RES", 3: "REC"}, "CON": {1: "MND", 2: "DEF", 3: "DEX"},
  "DEX": {1: "CON", 2: "AGI"}, "DEF": {1: "STR", 2: "CON"}, "RES": {1: "INT", 2: "STR"},
  "REC": {1: "INT", 2: "AGI"}, "LCK": {1: "STR", 2: "AGI"}, "MND": {1: "CON", 2: "INT"}
}
var primary_stats = {
  1: "STR", 2: "AGI", 3: "INT", 4: "CON"
}
var secondary_stats = {
  1: "DEX", 2: "DEF", 3: "RES", 4: "REC", 5: "LCK", 6: "MND"
}

var isWindowOpened = false;
var isPlusHover = false;

// STAT BUTTON
  function OnStatsWindowButtonClick() {
    isWindowOpened = !isWindowOpened;
    STATS_WINDOW.SetHasClass("WindowIn", isWindowOpened);
    PTS_WINDOW.SetHasClass("PtsIn", isWindowOpened);
    SetOpenState(isWindowOpened);
    Game.EmitSound("General.SelectAction");
  }

  function SetOpenState(isOpen) {
    STATS_WINDOW.SetHasClass("WindowIn", isOpen);
    PTS_WINDOW.SetHasClass("PtsIn", isOpen);
    INFO_WINDOW.SetHasClass("InfoIn", isOpen);
    INFO_WINDOW.SetHasClass("InfoOut", !isOpen);
    STATS_LAYOUT["STAT_BASE"].SetHasClass("Hide", !isOpen);
    STATS_LAYOUT["STAT_BONUS"].SetHasClass("Hide", !isOpen);
    STATS_LAYOUT["STAT_TOTAL"].SetHasClass("Hide", isOpen);
    STATS_LAYOUT["STAT_PLUS"].SetHasClass("Hide", !isOpen);

    for (const [column_name, row] of Object.entries(STATS_LAYOUT["STAT_NAME"])) {
      for (const [name_short, name_long] of Object.entries(labels_name)) {
        if (name_short == column_name) {
          STATS_LAYOUT["STAT_NAME"][column_name].SetHasClass("StatCollapsed", !isOpen);
          STATS_LAYOUT["STAT_NAME"][column_name].SetHasClass("StatRow", isOpen);
          if (isOpen == true) {
            STATS_LAYOUT["STAT_NAME"][column_name]["label"].text = name_long;
          } else {
            STATS_LAYOUT["STAT_NAME"][column_name]["label"].text = name_short;
          }
        }
      }
    }
  }

// LAYOUT CREATION
  function CreateLayout() {
    CreateColumn("STAT_NAME");
    CreateColumn("STAT_BASE");
    CreateColumn("STAT_BONUS");
    CreateColumn("STAT_TOTAL");
    CreateColumn("STAT_PLUS");
  }

  function CreateColumn(column) {
    var statColumnPanel = $.CreatePanel("Panel", STATS_CONTAINER, "");
    statColumnPanel.SetHasClass("StatColumn", true);
    STATS_LAYOUT[column] = statColumnPanel;

    CreateRow(column, "STR");
    CreateRow(column, "AGI");
    CreateRow(column, "INT");
    CreateRow(column, "CON");

    CreateRow(column, "DEX");
    CreateRow(column, "DEF");
    CreateRow(column, "RES");
    CreateRow(column, "REC");
    CreateRow(column, "LCK");
    CreateRow(column, "MND");
  }

  function CreateRow(column, row) {
    var statId = row;
    if (column == "STAT_PLUS") {
      var statPanel = $.CreatePanel("Panel", STATS_LAYOUT[column], "HeroStat" + statId);
      statPanel.BLoadLayout("file://{resources}/layout/custom_game/muken_plus.xml", false, false);
      statPanel.hittest = true;
      statPanel.hittestchildren = false;
      statPanel.Data().OnStatClick = OnStatClick;
      statPanel.Data().OnStatOver = OnStatOver;
      statPanel.Data().OnStatOut = OnStatOut;
      statPanel.SetHasClass("PlusBox", true);
      STATS_LAYOUT[column][row] = statPanel;

      var titleLabel = $.CreatePanel("Label", statPanel, "");
      titleLabel.SetHasClass("PlusCrossX", true);
      STATS_LAYOUT[column][row]["crossX"] = titleLabel;
      var titleLabel = $.CreatePanel("Label", statPanel, "");
      titleLabel.SetHasClass("PlusCrossY", true);
      STATS_LAYOUT[column][row]["crossY"] = titleLabel;

    } else if (column == "STAT_NAME"){
      var StatRowPanel = $.CreatePanel("Panel", STATS_LAYOUT[column], "HeroStat" + statId);
      StatRowPanel.BLoadLayout("file://{resources}/layout/custom_game/muken_stats_info.xml", false, false);
      StatRowPanel.hittest = true;
      StatRowPanel.hittestchildren = false;
      StatRowPanel.Data().OnNameOver = OnNameOver;
      StatRowPanel.Data().OnNameOut = OnNameOut;
      StatRowPanel.SetHasClass("StatCollapsed", true);
      STATS_LAYOUT[column][row] = StatRowPanel;
      
      var titleLabel = $.CreatePanel("Label", StatRowPanel, "");
      titleLabel.SetHasClass("TitleLabel", true);
      STATS_LAYOUT[column][row]["label"] = titleLabel;

      var activePanel = $.CreatePanel("Panel", StatRowPanel, "");
      //activePanel.SetHasClass("StatRowSelected", true);
      STATS_LAYOUT[column][row]["Active"] = activePanel;

    } else {
      var StatRowPanel = $.CreatePanel("Panel", STATS_LAYOUT[column], "");
      StatRowPanel.SetHasClass("StatValues", !(column == "STAT_BONUS"));
      StatRowPanel.SetHasClass("StatBonus", (column == "STAT_BONUS"));
      STATS_LAYOUT[column][row] = StatRowPanel;
      
      var titleLabel = $.CreatePanel("Label", StatRowPanel, "");
      titleLabel.SetHasClass("TitleLabel", true);
      STATS_LAYOUT[column][row]["label"] = titleLabel;
    }
  }

// UPDATE FUNCTIONS
  function OnStatUpdate(event) {
    var bonus = event.bonus;
    var base = event.base;
    if (event.bonus >= 0) {
      if (bonus > 99) {bonus = 99}
      STATS_LAYOUT["STAT_BONUS"][event.stat]["label"].SetHasClass("PositiveStats", true);
      STATS_LAYOUT["STAT_BONUS"][event.stat]["label"].SetHasClass("NegativeStats", false);
      STATS_LAYOUT["STAT_BONUS"][event.stat]["label"].text = '+ ' + bonus;
    } else {
      if (bonus < -99) {bonus = -99}
      STATS_LAYOUT["STAT_BONUS"][event.stat]["label"].SetHasClass("PositiveStats", false);
      STATS_LAYOUT["STAT_BONUS"][event.stat]["label"].SetHasClass("NegativeStats", true);
      STATS_LAYOUT["STAT_BONUS"][event.stat]["label"].text = bonus;
    }

    if (base > 99) {base = 99}
    if (base < 0) {base = 0}
    STATS_LAYOUT["STAT_BASE"][event.stat]["label"].text = base;
    STATS_LAYOUT["STAT_TOTAL"][event.stat]["label"].text = event.total;
  }

  function OnPointsUpdate(event) {
    $("#StatsWindowButtonActive").SetHasClass("Hide", !(event.total_points > 0));
    $("#StatsWindowButtonActive").SetHasClass("Animate", (event.total_points > 0));

    for (const [stat, enabled] of Object.entries(event.stats)) {
      STATS_LAYOUT["STAT_PLUS"][stat].hittest = enabled;
      STATS_LAYOUT["STAT_PLUS"][stat].SetHasClass("PlusBox", enabled);
      STATS_LAYOUT["STAT_PLUS"][stat].SetHasClass("NoPoints", !enabled);
      STATS_LAYOUT["STAT_PLUS"][stat]["crossX"].SetHasClass("PlusCrossX", enabled);
      STATS_LAYOUT["STAT_PLUS"][stat]["crossY"].SetHasClass("PlusCrossY", enabled);
      STATS_LAYOUT["STAT_NAME"][stat]["Fraction"] = event.stats_fraction[stat];
    }

    PTS_WINDOW.GetChild(0).text = 'POINTS:      ' + event.total_points;

    if (!(event.upgraded_stat == "nil") && isPlusHover) {
      OnStatOut(event.upgraded_stat, false)
      OnStatOver(event.upgraded_stat, false)
    }
  }

// PLUS
  function OnStatClick(statId, disabled) {
    Game.EmitSound("Config.Select");
    GameEvents.SendCustomGameEventToServer("leveling_stat", {"stat": statId});
  }

  function OnStatOver(statId, disabled) {
    isPlusHover = true;
    Game.EmitSound("Config.Move");
    for (const [stat, group] of Object.entries(stats_group)) {
      if (stat == statId){
        STATS_LAYOUT["STAT_NAME"][stat]["Active"].SetHasClass("StatRowSelected", true);
        STATS_LAYOUT["STAT_NAME"][stat]["Active"].SetHasClass("Animate2", true);

        for (const [index, sub_stat] of Object.entries(group)) {
          var enabled = (STATS_LAYOUT["STAT_NAME"][sub_stat]["Fraction"]);
          STATS_LAYOUT["STAT_NAME"][sub_stat]["Active"].SetHasClass("StatRowSelected", enabled);
          STATS_LAYOUT["STAT_NAME"][sub_stat]["Active"].SetHasClass("Animate2", enabled);
        }
      }
    }
  }

  function OnStatOut(statId, disabled) {
    isPlusHover = false;
    for (const [stat, group] of Object.entries(stats_group)) {
      if (stat == statId){
        STATS_LAYOUT["STAT_NAME"][stat]["Active"].SetHasClass("StatRowSelected", false);
        STATS_LAYOUT["STAT_NAME"][stat]["Active"].SetHasClass("Animate2", false);

        for (const [index, sub_stat] of Object.entries(group)) {
          STATS_LAYOUT["STAT_NAME"][sub_stat]["Active"].SetHasClass("StatRowSelected", false);
          STATS_LAYOUT["STAT_NAME"][sub_stat]["Active"].SetHasClass("Animate2", false);
        }
      }
    }
  }

// NAME INFO
function OnNameOver(statId, disabled) {
  Game.EmitSound("Config.Move");
  INFO_WINDOW.GetChild(0).text = $.Localize("#tooltip_" + statId);
  INFO_WINDOW.SetHasClass("Hide", false);

  for (const [stat, name] of Object.entries(labels_name)) {
    var enabled = false;
    var string = stat + '_info';

    if (stat == statId) {enabled = true}
    INFO_WINDOW.SetHasClass(string, enabled);
  }
}

function OnNameOut(statId, disabled) {
  INFO_WINDOW.SetHasClass("Hide", true);
}

(function() {	
  STATS_WINDOW = $("#StatsWindowContainer");
  STATS_WINDOW.SetHasClass("WindowOut", true);
  STATS_WINDOW.SetHasClass("WindowIn", true);
  STATS_CONTAINER = $("#StatsColumnContainer");
  STATS_BUTTON = $("#StatsWindowButton");
  PTS_WINDOW = $("#PtsWindowContainer");
  PTS_WINDOW.SetHasClass("PtsOut", true);
  PTS_WINDOW.SetHasClass("PtsIn", true);
  PTS_WINDOW.GetChild(0).text = 'POINTS:      0';
  INFO_WINDOW = $("#InfoWindowContainer");
  INFO_WINDOW.SetHasClass("Hide", true);

  GameEvents.Subscribe("stats_state_from_server", OnStatUpdate);
  GameEvents.Subscribe("points_state_from_server", OnPointsUpdate);

  CreateLayout();
  SetOpenState(isWindowOpened);
})();

// function TableLayoutExample() {
    // for (let index = 1; index <= 4; index++) {
    //     var statColumnPanel = $.CreatePanel("Panel", STATS_CONTAINER, "");
    //     statColumnPanel.SetHasClass("StatColumn", true);
    //     STATS_LAYOUT[index] = statColumnPanel;

    //     for (let row_index = 1; row_index <= 10; row_index++) {
    //         var StatRowPanel = $.CreatePanel("Panel", STATS_LAYOUT[index], "");
    //         StatRowPanel.SetHasClass("StatRow", true);
    //         STATS_LAYOUT[index][row_index] = StatRowPanel;
    //         var titleLabel = $.CreatePanel("Label", StatRowPanel, "");
    //         titleLabel.SetHasClass("TitleLabel", true);
    //         titleLabel.text = 'STAT' + row_index;
    //     }
    // }
// }