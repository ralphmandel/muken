(function(){
  $.Msg("Kubo ------------------");
  var panel = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("HUDElements").FindChildTraverse("abilities");

  for(var i = 0; i <= panel.GetChildCount() - 1; i++) {
    var id = "rank_panel" + i
    var plus_rank_button = $.CreatePanel("Panel", panel.GetChild(i), id);
    plus_rank_button.BLoadLayout("file://{resources}/layout/custom_game/rank_system.xml", false, false);
    plus_rank_button.hittest = true;
    panel.GetChild(i).MoveChildBefore(plus_rank_button, panel.GetChild(i).FindChildTraverse("ButtonAndLevel"));
    panel.GetChild(i).FindChildTraverse("LevelUp0").style.visibility = "collapse";
  }
})()