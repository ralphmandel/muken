"use strict";

var g_ScoreboardHandle = null;

function UpdateScoreboard()
{
	ScoreboardUpdater_SetScoreboardActive( g_ScoreboardHandle, true );

	$.Schedule( 0.2, UpdateScoreboard );
}

(function()
{
	var shouldSort = true;

	if ( GameUI.CustomUIConfig().multiteam_top_scoreboard )
	{
		var cfg = GameUI.CustomUIConfig().multiteam_top_scoreboard;
		if ( cfg.LeftInjectXMLFile )
		{
			$( "#LeftInjectXMLFile" ).BLoadLayout( cfg.LeftInjectXMLFile, false, false );
		}
		if ( cfg.RightInjectXMLFile )
		{
			$( "#RightInjectXMLFile" ).BLoadLayout( cfg.RightInjectXMLFile, false, false );
		}

		if ( typeof(cfg.shouldSort) !== 'undefined')
		{
			shouldSort = cfg.shouldSort;
		}
	}

	
	
	if ( ScoreboardUpdater_InitializeScoreboard === null ) { $.Msg( "WARNING: This file requires shared_scoreboard_updater.js to be included." ); }

	var scoreboardConfig =
	{
		"teamXmlName" : "file://{resources}/layout/custom_game/multiteam_top_scoreboard_team.xml",
		"playerXmlName" : "file://{resources}/layout/custom_game/multiteam_top_scoreboard_player.xml",
		"shouldSort" : shouldSort
	};
	g_ScoreboardHandle = ScoreboardUpdater_InitializeScoreboard( scoreboardConfig, $( "#MultiteamScoreboard" ) );

	UpdateScoreboard();

	var teamTopbarShadow = $.GetContextPanel().GetParent().GetParent().FindChildTraverse( "TopBarScoreboard" ).FindChildTraverse( "MultiteamScoreboard" );
	for(var i = 0; i <= teamTopbarShadow.GetChildCount() - 1; i++) {
		var lastChar = teamTopbarShadow.GetChild(i).id;
		lastChar = lastChar.charAt(lastChar.length - 1);
		if ( lastChar == Game.GetLocalPlayerInfo().player_team_id ){
			var teamTopBarChild = teamTopbarShadow.GetChild(i).FindChildTraverse( "LocalTeamOverlay" );
			$.Msg( teamTopBarChild, 'HUNTERHUNTER4' );
			// $.Msg( GameUI.CustomUIConfig().team_colors, 'TE100' )
			if ( teamTopBarChild && GameUI.CustomUIConfig().team_colors )
			{
				var localTopbarInfo = Game.GetLocalPlayerInfo();
				var localTopbarTeamId = localTopbarInfo.player_team_id;
				
				
				var teamColor1 = GameUI.CustomUIConfig().team_colors[ localTopbarTeamId ];
				teamColor1 = teamColor1.replace( ";", "" );
				var playerTopbarShadow = GameUI.CustomUIConfig().team_colors[ localTopbarTeamId ];
				playerTopbarShadow = playerTopbarShadow.replace( ";", "" );
				var layoutBox = 'fill ' + teamColor1 + ' 0px 0px 5px 1px ;';
				//			$.Msg( gradientText );
				teamTopBarChild.style.boxShadow = layoutBox;
				//$.Msg( teamTopbarShadow.style.boxShadow, 'AUDIOON')
			}
		}

		
	}
	
	
	

})();

