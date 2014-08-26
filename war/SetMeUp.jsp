<%@ page language="java" contentType="text/html; charset=US-ASCII"
	pageEncoding="US-ASCII"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.*"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=US-ASCII">
<title>SMU - Set Me Up</title>

<link rel="stylesheet" href="static/ilija.css" type="text/css">
<link rel="stylesheet" type="text/css" href="//code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css">
<link rel="stylesheet" type="text/css" href=
	"//cdn.datatables.net/plug-ins/725b2a2115b/integration/jqueryui/dataTables.jqueryui.css">

<script type="text/javascript" language="javascript" src="//code.jquery.com/jquery-1.11.1.min.js"></script>
<script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
<script type="text/javascript" language="javascript" src="//cdn.datatables.net/1.10.2/js/jquery.dataTables.min.js"></script>

</head>
<body>


	<script>

		window.onload = function() {
			//	alert("welcome");
		}

		$(document).ready(
				function() {

					$.ajaxSetup({
						async : false
					});
					$("#loading").show();
					var GD;
					$.getJSON("repeater", {}, function(data) {
						GD=data;
					});
					$("#loading").hide();

					$("#dugme").button().click(function() {
						$.post("repeater", {
							"reset" : ""
						}, function(data) {});
					});

				    $('#resTableSpace').dataTable( {
				    	"bJQueryUI": true,
				        "data": GD.results,
				        "columns": GD.headers
				    } );    
					
					
				});
	</script>
	<div class="maincolumn">

		<div class="mainheading">
			<a href="http://atlas.web.cern.ch/Atlas/Collaboration/"> <img
				border="0" src="static/atlas_logo.jpg" alt="ATLAS main page">
			</a>
			<div id="maintitle">SMU - Set Me Up</div>
		</div>

		<br>
		<table cellpadding="0" cellspacing="0" border="0" class="display"
			id="resTableSpace" width="100%">
			<thead></thead>
			<tbody></tbody>
		</table>
		<br>
		<button id="dugme">Reset</button>
	</div>

	<div id="loading" style="display: none">
		<br> <br>Loading data. Please wait...<br> <br> <img
			src="static/wait_animated.gif" alt="loading" />
	</div>


</body>
</html>