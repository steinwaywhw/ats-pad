<!DOCTYPE HTML>
<html ng-app="ats-pad">
<head>
	<title>atspad - your online ats playground</title>

	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">

	<script src="http://ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"></script>

	<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
	<link rel="stylesheet" type="text/css" href="http://netdna.bootstrapcdn.com/bootswatch/3.1.1/superhero/bootstrap.min.css">
    
    <script src="http://cdnjs.cloudflare.com/ajax/libs/spin.js/2.0.0/spin.min.js"></script>

 
	<style type="text/css">

		    h3 {
		    	width: 100%;
		    	position: absolute;
		    	text-align: center;
		    	top: calc(50% - 1.2em);
		    	margin: 0 auto;
		    }

	    	#spinner {
	    		margin: 0 auto;
	    	}
		</style>
</head>

<body>
<h3>minutes away from your ats playground ...</h3>
<br>
<span id="spinner"></span>

    <script type="text/javascript">
	    var opts = {
	      lines: 15, // The number of lines to draw
	      length: 7, // The length of each line
	      width: 2, // The line thickness
	      radius: 10, // The radius of the inner circle
	      corners: 1, // Corner roundness (0..1)
	      rotate: 0, // The rotation offset
	      direction: 1, // 1: clockwise, -1: counterclockwise
	      color: '#FFF', // #rgb or #rrggbb or array of colors
	      speed: 1, // Rounds per second
	      trail: 54, // Afterglow percentage
	      shadow: false, // Whether to render a shadow
	      hwaccel: false, // Whether to use hardware acceleration
	      className: 'spinner', // The CSS class to assign to the spinner
	      zIndex: 2e9, // The z-index (defaults to 2000000000)
	      top: 'calc(50% + 2em)', // Top position relative to parent
	      left: '50%' // Left position relative to parent
	    };
	    var target = document.getElementById('spinner');
	    var spinner = new Spinner(opts).spin(target);
	    
    </script>

    <script type="text/javascript">
    	var setting = {
    		url: "api/pad",
    		success: function (id, status, req) {
    			window.location.href = id;
    		},
    		error: function (req, status, err) {
    			$("body h3").get(0).text("Oops, something is not right. Please reload the page.");
    			$("#spinner").hide();
    		}
    	};

    	$.ajax(setting);
    </script>

</body>
</html>