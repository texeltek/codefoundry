function blueprint_tabs() {
	$("ul.tabs li.label").hide(); 
	$("#tab-set > div").hide(); 
	$("#tab-set > div").eq(0).show(); 
	$("ul.tabs li a").click( 
		function() { 
			$("ul.tabs li a.selected").removeClass('selected'); 
			$("#tab-set > div").hide();
			$(""+$(this).attr("href")).fadeIn('fast'); 
			$(this).addClass('selected'); 
			return false; 
		}
	);
	$("#toggle-label").click( function() {
		$(".tabs li.label").toggle(); 
		return false; 
	});
};