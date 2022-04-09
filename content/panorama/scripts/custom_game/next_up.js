var TALENTS_LAYOUT;

// update talents
function OnNextState(event) {
    var talentPoints = event.points;
    TALENTS_LAYOUT.text = 'NEXT        ' + talentPoints;//$.Localize("next_up_label").replace("%POINTS%", talentPoints);
}

(function() {	

    TALENTS_LAYOUT = $("#NextUp_label");
    GameEvents.Subscribe("next_up_from_server", OnNextState);
})();

