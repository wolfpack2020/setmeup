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
<link rel="stylesheet" type="text/css"
	href="//code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css">
<link rel="stylesheet" type="text/css"
	href="//cdn.datatables.net/plug-ins/725b2a2115b/integration/jqueryui/dataTables.jqueryui.css">

<script type="text/javascript" language="javascript"
	src="//code.jquery.com/jquery-1.11.1.min.js"></script>
<script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
<script type="text/javascript" language="javascript"
	src="//cdn.datatables.net/1.10.2/js/jquery.dataTables.min.js"></script>

</head>
<body>


	<script>
	
		function showCurrentSession() {
			var GD;
			$.getJSON("repeater", {}, function(data) {
				GD = data;
			});
			$('#resTableSpace').dataTable({
				"bJQueryUI" : true,
				"data" : GD.results,
				"columns" : GD.headers
			});
		}

		function createSession() {

		}

		function showArchive(){
			
		}
		
		function showCurlExample(){
			alert('curl -d result="{s_tutorial:\"triumf-sep2014\",s_domain:\"triumf.ca\",s_nickname:\"desilva\",s_identity:\"/C=CA/O=Grid/OU=westgrid.ca/CN=Asoka De Silva mwt-125\",b_os:True,b_grid:True,b_env:False,b_inputFiles:False,b_panda:True,b_fax:True,b_asg:False}" "http://setmeup-atlas.appspot.com/repeater"');
		}
		
		window.onload = function() {
			//	alert("welcome");
		}

		$(document).ready(function() {

			$("#tabs").tabs({
				activate : function(event, ui) {
					if (ui.newPanel.index() == 1) { // loading current sessions
						console.log("loading tab 1.");
						$("#loading").show();
						showCurrentSession();
						$("#loading").hide();
					} else {
						//epTable.fnClearTable();
					}

					if (ui.newPanel.index() == 2) { // create new session
						console.log("loading tab 2.");
						$("#loading").show();
						createSession();
						$("#loading").hide();
					} else {
						resTableSpace.fnClearTable();
					}

					if (ui.newPanel.index() == 3) { // Archive
						console.log("loading tab 3.");
						$("#loading").show();
						showArchive();
						$("#loading").hide();
					} else {

					}
				}
			});

			$.ajaxSetup({
				async : false
			});
			
			$( "#dp_from" ).datepicker();
			$( "#dp_to" ).datepicker();
			$( ".spinner" ).each(function( index ) {
				$(this).spinner({ min: 1, max: 7, width: 60 }).val(index+1);
				});
			$( ".s_type" ).each(function( index ) {
				$( this ).append( '<option value="s">String</option>');
				$( this ).append( '<option value="i">Integer</option>');
				$( this ).append( '<option value="f">Float</option>');
				$( this ).append( '<option value="b">Boolean</option>');
				$( this ).append( '<option value="d">Date</option>');
				});
			 
			$("#b_Refresh").button().click(function() {
				$.post("repeater", {
					"reset" : ""
				}, function(data) {
				});
			});			
			
			$("#b_Create").button().click(function() {
				$.post("creator", {
				}, function(data) {
				});
			});

			$("#b_ShowCURLexample").button().click(function() {
				showCurlExample();
			});


		});
	</script>
	<div class="maincolumn">

		<div class="mainheading">
			<a href="http://atlas.web.cern.ch/Atlas/Collaboration/"> <img
				border="0" src="static/atlas_logo.jpg" alt="ATLAS main page">
			</a>
			<div id="maintitle">SMU - Set Me Up</div>
		</div>

		<div id="tabs">
			<ul>
				<li><a href="#tabs-1">Current Sessions</a></li>
				<li><a href="#tabs-2">New session</a></li>
				<li><a href="#tabs-3">Archived</a></li>
			</ul>
			<div id="tabs-1">
				<br>
				<table cellpadding="0" cellspacing="0" border="0" class="display"
					id="resTableSpace" width="100%">
					<thead></thead>
					<tbody></tbody>
				</table>
				<br>
				<button id="b_Refresh">Refresh</button>
			</div>

			<div id="tabs-2">
				<br>
				<table cellpadding="3" cellspacing="0" border="0" class="display"
					id="ct" width="100%">
					<tbody>
					<tr><th>Title:</th> <td><input id="tb_title" type="textbox" value="Session Title"></input> </td> </tr><br>
					<tr><th>From:</th> <td><input id="dp_from" type="text" ></input> </td> <th>To:</th> <td><input id="dp_to" type="text" ></input> </td> </tr><br>
					<tr><th>Add columns</th> </tr>
					<tr>
						<th><input type="checkbox" id="check1"></th> 
						<td><input id="tb_c1" type="textbox" value="column name"></input> </td>
						<td>key:<input type="checkbox" id="check1"></td> 
						<td>type:<select class="s_type"></select></td>
						<td>position:<input class="spinner" name="value"></td> 
					</tr>
					<tr>
						<th><input type="checkbox" id="check2"></th> 
						<td><input id="tb_c2" type="textbox" value="column name"></input> </td>
						<td>key:<input type="checkbox" id="check2"></td> 
						<td>type:<select class="s_type"></select></td>
						<td>position:<input class="spinner" name="value"></td> 
					</tr>
					<tr>
						<th><input type="checkbox" id="check3"></th> 
						<td><input id="tb_c3" type="textbox" value="column name"></input> </td>
						<td>key:<input type="checkbox" id="check3"></td> 
						<td>type:<select class="s_type"></select></td>
						<td>position:<input class="spinner" name="value"></td> 
					</tr>
					<tr>
						<th><input type="checkbox" id="check4"></th> 
						<td><input id="tb_c4" type="textbox" value="column name"></input> </td>
						<td>key:<input type="checkbox" id="check4"></td> 
						<td>type:<select class="s_type"></select></td>
						<td>position:<input class="spinner" name="value"></td> 
					</tr>
					<tr>
						<th><input type="checkbox" id="check5"></th> 
						<td><input id="tb_c5" type="textbox" value="column name"></input> </td>
						<td>key:<input type="checkbox" id="check5"></td> 
						<td>type:<select class="s_type"></select></td>
						<td>position:<input class="spinner" name="value"></td> 
					</tr>
					<tr>
						<th><input type="checkbox" id="check6"></th> 
						<td><input id="tb_c6" type="textbox" value="column name"></input> </td>
						<td>key:<input type="checkbox" id="check6"></td> 
						<td>type:<select class="s_type"></select></td>
						<td>position:<input class="spinner" name="value"></td> 
					</tr>
					<tr>
						<th><input type="checkbox" id="check7"></th> 
						<td><input id="tb_c7" type="textbox" value="column name"></input> </td>
						<td>key:<input type="checkbox" id="check7"></td> 
						<td>type:<select class="s_type"></select></td>
						<td>position:<input class="spinner" name="value"></td> 
					</tr>
					</tbody>
				</table>
				
				<br>
				<button id="b_Create">Create</button>
				<button id="b_ShowCURLexample">Show curl example</button>
			</div>

			<div id="tabs-3">
				<br>
				<table cellpadding="0" cellspacing="0" border="0" class="display"
					id="asdfStatus" width="100%">
					<thead></thead>
					<tbody></tbody>
				</table>
			</div>
		</div>



	</div>

	<div id="loading" style="display: none">
		<br> <br>Loading data. Please wait...<br> <br> <img
			src="static/wait_animated.gif" alt="loading" />
	</div>


</body>
</html>