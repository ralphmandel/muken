function SwitchToHeroPreview( heroName ) {
    var TeamName = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("PreGame").FindChildTraverse("MainContents").FindChildTraverse("GridCategories");
    
	var previewPanel = $.CreatePanel("Panel", $('#PostPickScreen'), "HeroPreview");
	previewPanel.BLoadLayoutFromString('<root><Panel><DOTAScenePanel unit="'+heroName+'"/></Panel></root>', false, false );
}

/* Select a hero, called when a player clicks a hero panel in the layout */
function SelectHero( heroName ) {
	//Send the pick to the server
	GameEvents.SendCustomGameEventToServer( "hero_selected", { HeroName: heroName } );
}