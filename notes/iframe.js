<script>
$(document).ready(function(){
if (!window.jQuery) {
	// inject JQuery
	var jq = document.createElement('script');
	jq.src = "https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js";
	document.getElementsByTagName('head')[0].appendChild(jq);
}

// assign ids for all elements
var count = 0;
random = Math.random().toString();
$("*").each(function(index, element){
	if (!$( this ).attr('id')) {
		count ++;
		$( this ).attr('id', count + random);
	}
});

// only get the smallest element when clicked
var clicked = [];
$("*").click(function(event) {
	var now = new Date().getTime();

	// dont take it if it's only a few millisecs after the last
	if (clicked[now] == undefined) {
		clicked[now] = $(this).attr('id');
		console.log(now +'   '+ $(this).attr('id'));

		// send to server
	}

    // must NOT use event.stopPropagation(), it messes up client's js
});

});
</script>