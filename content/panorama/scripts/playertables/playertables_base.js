var reload = true;

var count = 0;
var PT = {
  listeners: {},
  tableListeners: {},
  nextListener: 0,
  tables: {},
  subs: []
};


$.Msg("[playertables_base.js] Loaded");

var PlayerTables = {};

PlayerTables.GetAllTableValues = function(tableName)
{
  var table = PT.tables[tableName];
  if (table)
    return JSON.parse(JSON.stringify(table));

  return null;
};


PlayerTables.GetTableValue = function(tableName, keyName)
{
  var table = PT.tables[tableName];
  if (!table)
    return null;

  var val = table[keyName];

  if (typeof val === 'object')
    return JSON.parse(JSON.stringify(val));

  return val;
};

PlayerTables.SubscribeNetTableListener = function(tableName, callback) 
{
  var listeners = PT.tableListeners[tableName];
  if (!listeners){
    listeners = {};
    PT.tableListeners[tableName] = listeners;
  }

  var ID = PT.nextListener;
  PT.nextListener++;

  listeners[ID] = callback;
  PT.listeners[ID] = tableName;

  return ID;
};

PlayerTables.UnsubscribeNetTableListener = function(callbackID)
{
  var tableName = PT.listeners[callbackID];
  if (tableName){
    if (PT.tableListeners[tableName]){
      var listener = PT.tableListeners[tableName][callbackID];
      if (listener){
        delete PT.tableListeners[tableName][callbackID];
      }
    }
 
    delete PT.listeners[callbackID];
  }
  
  return;
}; 

function isEquivalent(a, b) {
    var aProps = Object.getOwnPropertyNames(a);
    var bProps = Object.getOwnPropertyNames(b);

    if (aProps.length != bProps.length) {
        return false;
    }

    for (var i = 0; i < aProps.length; i++) {
        var propName = aProps[i];

        if (a[propName] !== b[propName]) {
            return false;
        }
    }

    return true;
}

function ProcessTable(newTable, oldTable, changes, dels)
{
  for (var k in newTable)
  {
    var n = newTable[k];
    var old = oldTable[k];

    if (typeof(n) == typeof(old) && typeof(n) == "object"){
      if (!isEquivalent(n, old)){
        changes[k] = n;
      }

      delete oldTable[k];
    }
    else if (n !== old){
      changes[k] = n;
      delete oldTable[k];
    }
    else if (n === old){
      delete oldTable[k];
    }
  }

  for (var k in oldTable)
  {
    dels[k] = true;
  }
}

function SendPID()
{
  var pid = Players.GetLocalPlayer();
  var spec = Players.IsSpectator(pid);
  //$.Msg(pid, ' -- ', spec);
  if (pid == -1 && !spec){
    $.Schedule(1/30, SendPID);
    return;
  }

  GameEvents.SendCustomGameEventToServer( "PlayerTables_Connected", {pid:pid} );
}



function TableFullUpdate(msg)
{
  //$.Msg('TableFullUpdate -- ', msg);
  //msg.table = UnprocessTable(msg.table);
  var newTable = msg.table;
  var oldTable = PT.tables[msg.name];

  if (!newTable)
    delete PT.tables[msg.name];
  else
    PT.tables[msg.name] = newTable;

  var listeners = PT.tableListeners[msg.name] || {};
  var len = Object.keys(listeners).length;
  var changes = null;
  var dels = null;

  if (len > -1 && newTable){
    if (!oldTable){
      changes = newTable;
      dels = {};
    }
    else {
      changes = {};
      dels = {};
      ProcessTable(newTable, oldTable, changes, dels);
    }
  }

  for (var k in listeners){
    try{ listeners[k](msg.name, changes, dels);} catch(err){$.Msg("PlayerTables.TableFullUpdate callback error for '", msg.name, " -- ", newTable, "': ", err.stack);};
  }
};

function UpdateTable(msg)
{
  //$.Msg('UpdateTable -- ', msg);
  //msg.changes = UnprocessTable(msg.changes);

  var table = PT.tables[msg.name];
  if (!table)
  {
    $.Msg("PlayerTables.UpdateTable invoked on nonexistent playertable.");
    return;
  }

  var t = {};

  for (var k in msg.changes){
    var value = msg.changes[k];

    table[k] = value;
    if (typeof value === 'object')
      t[k] = JSON.parse(JSON.stringify(value));
    else
      t[k] = value;
  }

  var listeners = PT.tableListeners[msg.name] || {};
  for (var k in listeners){
    if (listeners[k]){
      try{ listeners[k](msg.name, t, {});} catch(err){$.Msg("PlayerTables.UpdateTable callback error for '", msg.name, " -- ", t, "': ", err.stack);}      
    }
  }
}

function DeleteTableKeys(msg)
{
  //$.Msg('DeleteTableKeys -- ', msg);
  var table = PT.tables[msg.name];
  if (!table)
  {
    $.Msg("PlayerTables.DeleteTableKey invoked on nonexistent playertable.");
    return;
  }

  var t = {};

  for (var k in msg.keys){
    var value = msg.keys[k];

    delete table[k];
  }

  var listeners = PT.tableListeners[msg.name] || {};
  for (var k in listeners){
    if (listeners[k]){
      try{ listeners[k](msg.name, {}, msg.keys);} catch(err){$.Msg("PlayerTables.DeleteTableKeys callback error for '", msg.name, " -- ", msg.keys, "': ", err.stack);}
    }
  }
}
 
(function(){
  GameUI.CustomUIConfig().PlayerTables = PlayerTables;

  SendPID();

  GameEvents.Subscribe( "pt_fu", TableFullUpdate);
  GameEvents.Subscribe( "pt_uk", UpdateTable);
  GameEvents.Subscribe( "pt_kd", DeleteTableKeys);
  GameEvents.Subscribe("team_name_from_server", OnTeamNameUpdate);
  GameEvents.Subscribe("game_points_from_server", CreatePointsPanel);
  GameEvents.Subscribe("rune_panel_from_server", CreateRunePanel);
  //GameEvents.Subscribe("dota_player_hero_selection_dirty", OnUpdateHeroSelection1);
  var BuffPanel = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("HUDElements").FindChildTraverse("lower_hud").FindChildTraverse("BuffContainer");
  $.Msg("dota6" , BuffPanel.FindChildTraverse("buffs").actualyoffset);
})()

function CreatePointsPanel(){
  var TeamSelect = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("TeamSelectContainer").FindChildTraverse("TeamsList");
  TeamSelect.style.paddingTop = "100px";
  var TeamSelectPanel = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("CustomUIRoot").FindChildTraverse("CustomUIContainer");

  if ( TeamSelectPanel.FindChildrenWithClassTraverse("player_has_host_privileges") ) {

    if (SelectPoints != null) SelectPoints.DeleteAsync(0);
    var SelectPoints = $.CreatePanel( "Panel", TeamSelect, "" );

    SelectPoints.BLoadLayout( "file://{resources}/layout/custom_game/game_setup_points.xml", false, false );
  

    
    
  }
  //RadioButton.GetSelectedButton()
  var defaultCheck = TeamSelect.FindChildTraverse("PointsContainer").FindChildTraverse("defaultValue");
  defaultCheck.checked = true;
  $.Msg("99 checkado?",defaultCheck);
  //$.Msg('3NARNIA', TeamSelect.FindChildTraverse("PointsContainer").FindChildrenWithClassTraverse("bottom-radio-button"));

}

function CreateRunePanel(){
  var BuffPanel = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("HUDElements").FindChildTraverse("lower_hud").FindChildTraverse("BuffContainer");
  BuffPanel.style.marginBottom = "30px";
  var CenterPanel = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("HUDElements").FindChildTraverse("lower_hud").FindChildTraverse("center_with_stats").FindChildTraverse("center_block");
  CenterPanel.FindChildTraverse("stats_container").style.visibility = "collapse";
  var RuneContainer = $.CreatePanel( "Panel", CenterPanel, "" );
  RuneContainer.BLoadLayout( "file://{resources}/layout/custom_game/panel_runemaster.xml", false, false );
  CenterPanel.MoveChildBefore(RuneContainer, CenterPanel.GetChild(24));
  CenterPanel.FindChildTraverse("defaultValue").checked = true;
  $.Msg("skillet", BuffPanel.FindChildTraverse("buffs").style.transform == 0);

  
  
}

function OnTeamNameUpdate() {
  // var TeamName = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("PreGame").FindChildTraverse("MainContents").FindChildTraverse("GridCategories");
  // for(var i = 0; i <= TeamName.GetChildCount() - 1; i++) {
  //   var CategoryName = TeamName.GetChild(i).FindChildTraverse("HeroCategoryName");
  //   if (CategoryName.text == "STRENGTH") {
  //     CategoryName.text = "DEATH";
  //   }
  //    if (CategoryName.text == "AGILITY") {
  //     CategoryName.text = "NATURE";
  //   }
  //    if (CategoryName.text == "INTELLIGENCE") {
  //     CategoryName.text = "MOON";
  //   }
  //    if (CategoryName.text == "UNIVERSAL") {
  //     CategoryName.text = "SUN";
  //   }
  // }
  var TeamSelect = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("TeamSelectContainer").FindChildTraverse("TeamsList");
  $.Msg('DOTA 2 WARCRAFT', TeamSelect.FindChildTraverse("PointsContainer").FindChildrenWithClassTraverse("bottom-radio-button"));
  var PanelChecked = TeamSelect.FindChildTraverse("PointsContainer").FindChildTraverse("radioContainer");
  for(var i = 0; i <= PanelChecked.GetChildCount() - 1; i++) {
    var points_value = 0
    var radio_checked = PanelChecked.GetChild(i);
    if (radio_checked.checked == true){

        if (i == 0) {points_value = 25} else if (i == 1) {points_value = 50}else if (i == 2) {points_value = 75} else if (i == 3) {points_value = 100};
      GameEvents.SendCustomGameEventToServer("game_points_from_server", {match_points: points_value});
      break
    }
    
  }

  var PortraitSize = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("PreGame").FindChildTraverse("MainContents").FindChildTraverse("HeroPickScreen").FindChildTraverse("HeroPickScreenContents").FindChildTraverse("GridCategories");
  PortraitSize.style.flowChildren = "down";
  var PanelSize = PortraitSize = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("PreGame").FindChildTraverse("MainContents").FindChildTraverse("HeroPickScreen").FindChildTraverse("MainHeroPickScreenContents");
  PanelSize.style.height = "100%";
  PanelSize.style.marginLeft = "1px";
  PanelSize.FindChildTraverse("HeroPickLeftColumn").style.height = "100%";
  PanelSize.FindChildTraverse("HeroPickLeftColumn").FindChildTraverse("HeroGrid").style.height = "100%";

  for(var i = 0; i <= PortraitSize.GetChildCount() - 1; i++) {
    var HeroCategoryName = PortraitSize.GetChild(i);
    var HeroImg = HeroCategoryName.FindChildrenWithClassTraverse("HeroCard");
   
    HeroImg.forEach(HeroCard => {
     HeroCard.style.width = "74px";
     HeroCard.style.height = "98px";
     HeroCard.style.opacityMask =  "url('file://{images}/custom_game/hero_select_mask_selection.png')";
     HeroCard.style.transform = "skewX ( -5deg )";
     HeroCard.style.marginRight = "20px";
    });
  
  };
  var PortraitSize_alternate = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("PreGame").FindChildTraverse("MainContents").FindChildTraverse("HeroPickScreen").FindChildTraverse("HeroPickScreenContents").FindChildTraverse("GridCategories");
 
  var HeroCategoryName_death = PortraitSize_alternate.GetChild(0);
  HeroCategoryName_death.style.height = "130px";
  HeroCategoryName_death.style.margin = "75px 0px 0px 20px";
  var HeroCategoryName_nature = PortraitSize_alternate.GetChild(1);
  HeroCategoryName_nature.style.height = "130px";
  HeroCategoryName_nature.style.margin = "38px 0px 0px 20px";
  var HeroCategoryName_moon = PortraitSize_alternate.GetChild(2);
  HeroCategoryName_moon.style.height = "130px";
  HeroCategoryName_moon.style.margin = "38px 0px 0px 20px";
  var HeroCategoryName_sun = PortraitSize_alternate.GetChild(3);
  HeroCategoryName_sun.style.height = "130px";
  HeroCategoryName_sun.style.margin = "38px 0px 0px 20px";
  for(var i = 0; i <= PortraitSize_alternate.GetChildCount() - 1; i++) {
    var HeroCategoryBarName = PortraitSize_alternate.GetChild(i);
    var DotaIcon = HeroCategoryBarName.FindChildrenWithClassTraverse("HeroCategoryControls");
    DotaIcon.forEach(HeroCategoryControls => {
      HeroCategoryControls.style.visibility = "collapse";
    });
  };
 



}

//function OnUpdateHeroSelection1() {

  // var HeroContainer_death = PortraitSize.GetChild(0).FindChildTraverse("HeroListContainer");
  // HeroContainer_death.style.ignoreParentFlow = "true";
  // HeroContainer_death.style.position = "15px 138px 0px";
  // var HeroContainer_nature = PortraitSize.GetChild(1).FindChildTraverse("HeroListContainer");
  // HeroContainer_nature.style.ignoreParentFlow = "true";
  // HeroContainer_nature.style.position = "100px 400px 0px";
  // var HeroContainer_moon = PortraitSize.GetChild(0).FindChildTraverse("HeroListContainer");
  // HeroContainer_moon.style.ignoreParentFlow = "true";
  // HeroContainer_moon.style.position = "-55px 138px 0px";
  // var HeroContainer_sun = PortraitSize.GetChild(0).FindChildTraverse("HeroListContainer");
  // HeroContainer_sun.style.ignoreParentFlow = "true";
  // HeroContainer_sun.style.position = "-55px 438px 0px";
  


  // var HideHeroInfo = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("PreGame").FindChildTraverse("MainContents").FindChildTraverse("HeroPickScreen").FindChildTraverse("HeroPickScreenContents").FindChildTraverse("HeroPickRightColumn");
  // HideHeroInfo.style.verticalAlign = "bottom";
  // var HideHeroContainer = HideHeroInfo.FindChildrenWithClassTraverse("HeroInspectContainer");
  // HideHeroContainer.forEach(HeroInspectContainer => {
  //   HeroInspectContainer.style.visibility = "collapse";
  // });
//}