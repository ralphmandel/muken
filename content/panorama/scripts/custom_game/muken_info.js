var INFO_WINDOW, INFO_CONTAINER, INFO_LAYOUT = {};
var isWindowOpened = false;

// LAYOUT CREATION
  function CreateLayout() {
    CreateColumn("INFO_NAME")
    CreateColumn("INFO_VALUE")
  }

  function CreateColumn(column) {
    var InfoColumnPanel = $.CreatePanel("Panel", INFO_CONTAINER, "");
    InfoColumnPanel.SetHasClass("InfoColumn", true);
    INFO_LAYOUT[column] = InfoColumnPanel;

    CreateRow(column, "physical_damage")
    CreateRow(column, "crit_damage")
    CreateRow(column, "crit_chance")
    CreateRow(column, "attack_speed")
  }

  function CreateRow(column, row) {
    var InfoRowPanel = $.CreatePanel("Panel", INFO_LAYOUT[column], "");
    InfoRowPanel.SetHasClass("InfoRow", true);
    INFO_LAYOUT[column][row] = InfoRowPanel;
    
    var titleLabel = $.CreatePanel("Label", InfoRowPanel, "");
    titleLabel.SetHasClass("TitleLabel", true);
    INFO_LAYOUT[column][row]["label"] = titleLabel;

    if (column == "INFO_NAME") {
      titleLabel.text = $.Localize("#tooltip_" + row);
      //INFO_LAYOUT[column][row]["label"].text = row
    }
  }

// STAT BUTTON
  function OnInfoButtonClick() {
    isWindowOpened = !isWindowOpened;
    INFO_WINDOW.SetHasClass("WindowIn", isWindowOpened)
    Game.EmitSound("General.SelectAction");
  }

// UPDATE FUNCTIONS
  function OnInfoUpdate(event) {
    //$.Msg("update");

    for (const [name, value] of Object.entries(event)) {
      //$.Msg(key, value);
      INFO_LAYOUT["INFO_VALUE"][name]["label"].text = Number((value).toFixed(1));;
    }
  }

//INIT
  (function() {
    INFO_WINDOW = $("#InfoContainer");
    INFO_WINDOW.SetHasClass("WindowOut", true);
    INFO_WINDOW.SetHasClass("WindowIn", true);
    INFO_CONTAINER = $("#InfoColumnContainer");
    INFO_BUTTON = $("#InfoButton")

    GameEvents.Subscribe("info_state_from_server", OnInfoUpdate);

    CreateLayout()
    SetOpenState(isWindowOpened)
  })();