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
		function preload(){
			$.getJSON("creator", {} , function(data) {
				d=data.projects;
				for (i in d)  $("#s_session").append( '<option value="'+d[i]+'">' + d[i] + '</option>');
				
			});
		}
		
		function showCurrentSession() {
			var GD;
			$.getJSON("repeater", {project:$("#s_session option:selected").val()}, function(data) {
				GD = data;
			});
			if (GD.headers.length==0) return;
			$('#resTableSpace').dataTable({
				"bJQueryUI" : true,
				"data" : GD.results,
				"columns" : GD.headers
			});
		}

		function showArchive(){
			
		}
		
		function showCurlExample(){
			example='curl -d result="{project:';
			example+='\"' + $("#tb_title").val() + '\"';
			alert(example+',s_domain:\"triumf.ca\",s_nickname:\"desilva\",s_identity:\"/C=CA/O=Grid/OU=westgrid.ca/CN=Asoka De Silva mwt-125\",b_os:True,b_grid:True,b_env:False,b_inputFiles:False,b_panda:True,b_fax:True,b_asg:False}" "http://setmeup-atlas.appspot.com/repeater"');
		}
		
		window.onload = function() {
			//	alert("welcome");
		}

		$(document).ready(function() {

			preload();
			
			$.ajaxSetup({
				async : false
			});
			
			$('#s_session').change(showCurrentSession);
			
			$("#loading").show();
			showCurrentSession();
			$("#loading").hide();
			
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
			 
			$("#b_Refresh").button().click(function(){showCurrentSession});			
			
			$("#b_Create").button().click(function() {
				project = {};
				project.title=$("#tb_title").val();
				project.from=new Date( $("#dp_from").datepicker( "getDate" ) ).getTime();
				project.to=new Date( $("#dp_to").datepicker( "getDate" ) ).getTime();
 				project.cols = [];
				$(".tb_cn").each(function(index) { 
						col={};
						col.name=$(this).val();
						col.key=$(".cb_key:eq("+index.toString()+")").is(':checked');
						col.type=$(".s_type:eq("+index.toString()+")").val();
						col.index= $(".spinner:eq("+index.toString()+")").spinner("value");
						if(col.name!="ColumnName" && col.name!="")
							project.cols.push(col);
					}); 
				$.post("creator", JSON.stringify(project), function(data) {}, "json");
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
				Select session: <select id="s_session"></select> <button id="b_Refresh">Refresh</button>
				<br>
				<table cellpadding="0" cellspacing="0" border="0" class="display"
					id="resTableSpace" width="100%">
					<thead></thead>
					<tbody></tbody>
				</table>
				
			</div>

			<div id="tabs-2">
				<br>
				<table cellpadding="3" cellspacing="0" border="0" class="display" id="ct" width="100%">
					<tbody>
					<tr><th>Title:</th> <td><input id="tb_title" type="text" value="Session Title"></input> </td> </tr><br>
					<tr><th>From:</th> <td><input id="dp_from" type="text" ></input> </td> <th>To:</th> <td><input id="dp_to" type="text" ></input> </td> </tr><br>
					<tr><th>Add columns</th> </tr>
					<tr>
						<!-- <th><input type="checkbox" id="check1"></th>  -->
						<td><input class="tb_cn" type="text" value="ColumnName"></input> </td>
						<td>key:<input type="checkbox" class="cb_key"></td> 
						<td>type:<select class="s_type"></select></td>
						<td>position:<input class="spinner" name="value"></td> 
					</tr>
					<tr>
						<!-- <th><input type="checkbox" id="check2"></th>  -->
						<td><input class="tb_cn" type="text" value="ColumnName"></input> </td>
						<td>key:<input type="checkbox" class="cb_key"></td> 
						<td>type:<select class="s_type"></select></td>
						<td>position:<input class="spinner" name="value"></td> 
					</tr>
					<tr>
						<!-- <th><input type="checkbox" id="check3"></th> --> 
						<td><input class="tb_cn" type="text" value="ColumnName"></input> </td>
						<td>key:<input type="checkbox" class="cb_key"></td> 
						<td>type:<select class="s_type"></select></td>
						<td>position:<input class="spinner" name="value"></td> 
					</tr>
					<tr>
						<!-- <th><input type="checkbox" id="check4"></th>  -->
						<td><input class="tb_cn" type="text" value="ColumnName"></input> </td>
						<td>key:<input type="checkbox" class="cb_key"></td> 
						<td>type:<select class="s_type"></select></td>
						<td>position:<input class="spinner" name="value"></td> 
					</tr>
					<tr>
						<!-- <th><input type="checkbox" id="check5"></th>  -->
						<td><input class="tb_cn" type="text" value="ColumnName"></input> </td>
						<td>key:<input type="checkbox" class="cb_key"></td> 
						<td>type:<select class="s_type"></select></td>
						<td>position:<input class="spinner" name="value"></td> 
					</tr>
					<tr>
						<!-- <th><input type="checkbox" id="check6"></th>  -->
						<td><input class="tb_cn" type="text" value="ColumnName"></input> </td>
						<td>key:<input type="checkbox" class="cb_key"></td> 
						<td>type:<select class="s_type"></select></td>
						<td>position:<input class="spinner" name="value"></td> 
					</tr>
					<tr>
						<!-- <th><input type="checkbox" id="check7"></th>  -->
						<td><input class="tb_cn" type="text" value="ColumnName"></input> </td>
						<td>key:<input type="checkbox" class="cb_key"></td> 
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