var STATS_WINDOW, STATS_CONTAINER;
var STATS_LAYOUT = {};
var labels_name ={
    "STR": "STRENGHT", "AGI": "AGILITY", "INT": "INTELLIGENCE", "CON": "CONSTITUTION",
    "DEX": "DEXTERITY", "DEF": "DEFENSE", "RES": "RESISTANCE", "REC": "RECOVERY", "LCK": "LUCK", "MND": "MIND",
}

var isWindowOpened = false;

function OnStatsWindowButtonClick() {
    isWindowOpened = !isWindowOpened;
    STATS_WINDOW.SetHasClass("WindowIn", isWindowOpened)
    SetOpenState(isWindowOpened)
    Game.EmitSound("General.SelectAction");
}

function SetOpenState(isOpen) {
    STATS_WINDOW.SetHasClass("WindowIn", isOpen)
    STATS_LAYOUT["STAT_BASE"].SetHasClass("Hide", !isOpen)
    STATS_LAYOUT["STAT_BONUS"].SetHasClass("Hide", !isOpen)
    STATS_LAYOUT["STAT_TOTAL"].SetHasClass("Hide", isOpen)
    STATS_LAYOUT["STAT_PLUS"].SetHasClass("Hide", !isOpen)

    for (const [column_name, row] of Object.entries(STATS_LAYOUT["STAT_NAME"])) {
        for (const [name_short, name_long] of Object.entries(labels_name)) {
            if (name_short == column_name){
                if (isOpen == true) {
                    STATS_LAYOUT["STAT_NAME"][column_name]["label"].text = name_long
                } else {
                    STATS_LAYOUT["STAT_NAME"][column_name]["label"].text = name_short
                }
            }
        }
    }
}

function CreateLayout() {
    CreateColumn("STAT_NAME")
    CreateColumn("STAT_BASE")
    CreateColumn("STAT_BONUS")
    CreateColumn("STAT_TOTAL")
    CreateColumn("STAT_PLUS")
}

function CreateColumn(column) {
    var statColumnPanel = $.CreatePanel("Panel", STATS_CONTAINER, "");
    statColumnPanel.SetHasClass("StatColumn", true);
    STATS_LAYOUT[column] = statColumnPanel;

    CreateRow(column, "STR")
    CreateRow(column, "AGI")
    CreateRow(column, "INT")
    CreateRow(column, "CON")

    CreateRow(column, "DEX")
    CreateRow(column, "DEF")
    CreateRow(column, "RES")
    CreateRow(column, "REC")
    CreateRow(column, "LCK")
    CreateRow(column, "MND")
}

function CreateRow(column, row) {
    var StatRowPanel = $.CreatePanel("Panel", STATS_LAYOUT[column], "");
    StatRowPanel.SetHasClass("StatRow", true);
    STATS_LAYOUT[column][row] = StatRowPanel;

    var titleLabel = $.CreatePanel("Label", StatRowPanel, "");
    titleLabel.SetHasClass("TitleLabel", true);
    STATS_LAYOUT[column][row]["label"] = titleLabel;

    // if (column == "STAT_NAME") {
    //     STATS_LAYOUT[column][row]["label"].text = labels_name[row];
    // }
}

function OnStatsRefresh(event) {
    var bonus = event.bonus
    var base = event.base
    if (event.bonus >= 0) {
        if (bonus > 99) {bonus = 99}
        STATS_LAYOUT["STAT_BONUS"][event.stat]["label"].SetHasClass("PositiveStats", true)
        STATS_LAYOUT["STAT_BONUS"][event.stat]["label"].SetHasClass("NegativeStats", false)
        STATS_LAYOUT["STAT_BONUS"][event.stat]["label"].text = '+ ' + bonus
    } else {
        if (bonus < -99) {bonus = -99}
        STATS_LAYOUT["STAT_BONUS"][event.stat]["label"].SetHasClass("PositiveStats", false)
        STATS_LAYOUT["STAT_BONUS"][event.stat]["label"].SetHasClass("NegativeStats", true)
        STATS_LAYOUT["STAT_BONUS"][event.stat]["label"].text = bonus
    }

    if (base > 99) {base = 99}
    if (base < 0) {base = 0}
    STATS_LAYOUT["STAT_BASE"][event.stat]["label"].text = base;
    STATS_LAYOUT["STAT_TOTAL"][event.stat]["label"].text = event.total;

    STATS_LAYOUT["STAT_PLUS"][event.stat]["label"].SetHasClass("TitleLabel", false)
    STATS_LAYOUT["STAT_PLUS"][event.stat]["label"].SetHasClass("Plus", true)
    STATS_LAYOUT["STAT_PLUS"][event.stat]["label"].text = "+";
}

(function() {	
    STATS_WINDOW = $("#StatsWindowContainer")
    STATS_WINDOW.SetHasClass("WindowOut", true)
    STATS_WINDOW.SetHasClass("WindowIn", true)
    STATS_CONTAINER = $("#StatsColumnContainer");

    GameEvents.Subscribe("stats_state_from_server", OnStatsRefresh);

    CreateLayout()
    SetOpenState(isWindowOpened)
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