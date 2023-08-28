"use strict";
const MUTE_ALL_BUTTON = $("#MuteAll");
var g_ScoreboardHandle = null;
var visible_state = false;

function SetFlyoutScoreboardVisible(bVisible) {
	visible_state = bVisible;
	visible_state = bVisible;
	$.GetContextPanel().SetHasClass("flyout_scoreboard_visible", bVisible);
	if (bVisible) {
		ScoreboardUpdater_SetScoreboardActive(g_ScoreboardHandle, true);
		GameEvents.SendCustomGameEventToServer("game_perks:check_perks_for_players", {});
	} else {
		ScoreboardUpdater_SetScoreboardActive(g_ScoreboardHandle, false);
	}
}

const team_root = $("#TeamsContainer");
function MuteAll() {
	for (const player_id of Game.GetAllPlayerIDs()) {
		const player_panel = team_root.FindChildTraverse(`_dynamic_player_${player_id}`);
		if (MUTE_ALL_BUTTON.checked) {
			player_panel.SetHasClass("player_muted", true);
			Game.SetPlayerMuted(player_id, true);
		} else if (!player_panel.custom_mute) {
			player_panel.SetHasClass("player_muted", false);
			Game.SetPlayerMuted(player_id, false);
		}
	}
}

function OnScoreUpdate(event) {
	if (visible_state == true) {
		SetFlyoutScoreboardVisible(false);
		SetFlyoutScoreboardVisible(true);
	}
	if (visible_state == true) {
		SetFlyoutScoreboardVisible(false);
		SetFlyoutScoreboardVisible(true);
	}
}

(function () {
	if (ScoreboardUpdater_InitializeScoreboard === null) {
		$.Msg("WARNING: This file requires shared_scoreboard_updater.js to be included.");
	}
	
	
	var scoreboardConfig = {
		teamXmlName: "file://{resources}/layout/custom_game/multiteam_flyout_scoreboard_team.xml",
		playerXmlName: "file://{resources}/layout/custom_game/multiteam_flyout_scoreboard_player.xml",
	};
	g_ScoreboardHandle = ScoreboardUpdater_InitializeScoreboard(scoreboardConfig, $("#TeamsContainer"));
	
	
	SetFlyoutScoreboardVisible(false);
	
	
	var teamOverlayShadow = $.GetContextPanel().GetParent().GetParent().FindChildTraverse( "TeamsContainer" );
	for(var i = 0; i <= teamOverlayShadow.GetChildCount() - 1; i++) {
		var lastChar = teamOverlayShadow.GetChild(i).id;
		lastChar = lastChar.charAt(lastChar.length - 1);
		if ( lastChar == Game.GetLocalPlayerInfo().player_team_id ){
			var teamFlyoutChild = teamOverlayShadow.GetChild(i).FindChildTraverse( "PlayersContainer" );
			$.Msg( teamFlyoutChild, 'HUNTERHUNTER4' );
			// $.Msg( GameUI.CustomUIConfig().team_colors, 'TE100' )
			if ( teamFlyoutChild && GameUI.CustomUIConfig().team_colors )
			{
				
				var localPlayerInfo = Game.GetLocalPlayerInfo();
				var localPlayerTeamId = localPlayerInfo.player_team_id;
				
				var teamColor1 = GameUI.CustomUIConfig().team_colors[ localPlayerTeamId ];
				teamColor1 = teamColor1.replace( ";", "" );
				var playerLayoutShadow = GameUI.CustomUIConfig().team_colors[ localPlayerTeamId ];
				playerLayoutShadow = playerLayoutShadow.replace( ";", "" );
				var layoutBox = 'fill ' + teamColor1 + ' 0px 0px 5px 1px ;';
				//			$.Msg( gradientText );
				teamFlyoutChild.style.boxShadow = layoutBox;
				
			}
		}
	}
	
	
	
	
	$.RegisterEventHandler("DOTACustomUI_SetFlyoutScoreboardVisible", $.GetContextPanel(), SetFlyoutScoreboardVisible);
	GameEvents.Subscribe("score_state_from_server", OnScoreUpdate);


	var changeIndex = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("CustomUIRoot");
	changeIndex.FindChildTraverse("CustomUIContainer_FlyoutScoreboard").style.zIndex = "-1";
})();