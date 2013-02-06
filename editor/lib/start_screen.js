$(document).ready(function() {

	var selectedTile = null;

	// User default tile selection
    var tiles = $('.tile_wrap');
    $('[id^="tileid-"]').click(function () {
        if ($(this).hasClass('selected')) {
            $(this).removeClass('selected');
            selectedTile = null;
            console.log(selectedTile);
        } else {
            tiles.removeClass('selected');
            $(this).addClass('selected');
            selectedTile = $(this).attr("name");
            console.log(selectedTile);
        }
    });

	// Loads the editor with the user defined properties when create map is clicked
	$("#create_map").click(function () {

		// The map properies defined by the user
		row = $("#userRows").val(); 
		column = $("#userCols").val(); 
		defaultTileName = selectedTile

		window.location = '/editor?r=' + row + '&c=' + column + '&t=' + defaultTileName
    });
});