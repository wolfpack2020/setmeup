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
		var resTable;
		
		function preload() {
			$.getJSON("creator", {what:'project_names'}, function(data) {
				d = data.projects;
				for (i in d){
					$(".s_session").append('<option value="'+d[i]+'">' + d[i] + '</option>');
				}
			});
		}

		function showProject() {
			$("#et").find("tr:gt(2)").remove();
			$.getJSON("creator", {what:'project_details', project : $("#s_edit option:selected").val()}, 
				function(data) {
					alert(data.from);
					$("#dp_from_edit").datepicker().datepicker('setDate', data.from);
					$("#dp_to_edit").datepicker().datepicker('setDate', data.to);
					cols=data.columns;
					for (var c=0;c<cols.length; c++){
						col=cols[c];
						addPrefilledColumn(col.name,col.key,col.type,col.index);
					}
				});
		}
		
		function addColumn(){
			$('#ct tr:last').after('<tr><td><input class="tb_cn" type="text" value="ColumnName"></input></td><td>key:<input type="checkbox" class="cb_key"></td><td>type:<select class="s_type"></select></td><td>position:<input class="spinner" value="1"></td></tr>');
			
			$("#ct .spinner:last").spinner({ min : 1, width : 60, value: 1 });

			$("#ct .s_type:last").each(function(index) {
				$(this).append('<option value="s">String</option>');
				$(this).append('<option value="i">Integer</option>');
				$(this).append('<option value="f">Float</option>');
				$(this).append('<option value="b">Boolean</option>');
				$(this).append('<option value="d">Date</option>');
			});
		
		}
		
		function addPrefilledColumn(name, key, type, position ){
			cn='<td><input class="tb_cn" type="text" value="'+name+'"></input></td>';
			if (key==true) 
				ke='<td>key:<input type="checkbox" checked class="cb_key"></td>';
			else
				ke='<td>key:<input type="checkbox" class="cb_key"></td>';
			$('#et tr:last').after('<tr>'+cn+ke+'<td>type:<select class="s_type"></select></td><td>position:<input class="spinner" value="'+position+'"></td></tr>');
			
			$("#et .spinner:last").spinner({ min : 1, width : 60 });
			
			$("#et .s_type:last").each(function(index) {
				$(this).append('<option value="s">String</option>');
				$(this).append('<option value="i">Integer</option>');
				$(this).append('<option value="f">Float</option>');
				$(this).append('<option value="b">Boolean</option>');
				$(this).append('<option value="d">Date</option>');
				$(this).val(type);
			});
		
		}
		
		function showCurrentSession() {
			var GD;
			$.getJSON("repeater", {
				project : $("#s_show option:selected").val()
			}, function(data) {
				GD = data;
			});
			if (GD.headers.length == 0) return;
			if (resTable != null) {
		        resTable.fnDestroy();
				$("#resTableSpace").empty();
			}
 			resTable=$('#resTableSpace').dataTable({
				"bDestroy" : true,
				"bJQueryUI" : true,
				"lengthMenu": [ [-1, 10, 25, 50], [ "All", 10, 25, 50] ],
				"data" : GD.results,
				"columns" : GD.headers
			}); 
		}


		function showCurlExample() {
			example = 'curl -d result="{project:';
			example += '\\"' + $("#tb_title").val() + '\\",';
			cols = [];
			$(".tb_cn").each(function(index) {
				if ($(this).val() != "ColumnName" && $(this).val() != "") {
					typ = $(".s_type:eq(" + index.toString() + ")").val();
					co = '\\"'+$(this).val() + '\\":';
					if (typ == 's')
						co += '\\"SomeString\\"';
					if (typ == 'i')
						co += '999';
					if (typ == 'f')
						co += '123.456';
					if (typ == 'b')
						co += 'True';
					if (typ == 'd')
						co += 'Date';
					cols.push(co);
				}
			});
			example += cols.join();
			alert(example + '}" "http://setmeup-atlas.appspot.com/repeater"');
		}

		window.onload = function() {
			//	alert("welcome");
		}

		$(document).ready(
				function() {

					$("#tabs").tabs({
						activate : function(event, ui) {
							if (ui.newPanel.index() == 1) { // loading current sessions
								console.log("loading tab 1.");
								$("#loading").show();
								showCurrentSession();
								$("#loading").hide();
							} 

							if (ui.newPanel.index() == 2) { // create new session
								console.log("loading tab 2.");
							} 

							if (ui.newPanel.index() == 3) { // Edit
								console.log("loading tab 3.");
								$("#loading").show();
								showProject();
								$("#loading").hide();
							} 
						}
					});


					$.ajaxSetup({
						async : false
					});

					$("#loading").show();
						preload();
						showCurrentSession();
					$("#loading").hide();

					
					$("#dp_from").datepicker().datepicker('setDate', new Date());
					$("#dp_to").datepicker().datepicker('setDate', new Date());
/* 					$("#dp_from_edit").datepicker();
					$("#dp_to_edit").datepicker(); */
					$("#dp_from_clone").datepicker().datepicker('setDate', new Date());
					$("#dp_to_clone").datepicker().datepicker('setDate', new Date());

					$("#b_Refresh").button().click(function() {	
							showCurrentSession(); 
						});
					$("#b_ShowCURLexample").button().click(function() {	
						showCurlExample(); 
					});
					$('#s_show').change(function(){
						showCurrentSession();
					});
					$('#s_edit').change(function(){
						showProject();
					});
					$('#b_Save').button().click(function(){
						alert('not implemented yet');
					});
					$('#b_Clone').button().click(function(){
						alert('not implemented yet');
					});
					$('#b_Delete').button().click(function(){
						alert('not implemented yet');
					});
					$("#b_AddColumn").button().click(function() {	
						addColumn();
					});

					addColumn();
					addColumn();

					$("#b_Create").button().click(
							function() {
								project = {};
								project.title = $("#tb_title").val();
								project.from = new Date($("#dp_from").datepicker("getDate")).getTime();
								project.to = new Date($("#dp_to").datepicker("getDate")).getTime();
								project.cols = [];
								$(".tb_cn").each( function(index) {
											col = {};
											col.name = $(this).val();
											col.key =  $(".cb_key:eq(" + index.toString() + ")").is(':checked');
											col.type = $(".s_type:eq(" + index.toString() + ")").val();
											col.index= $( ".spinner:eq(" + index.toString() + ")").spinner("value");
											if (col.name != "ColumnName" && col.name != "")	project.cols.push(col);
										});
								$.post("creator", 
										JSON.stringify(project),
										function(msg) {  alert("project "+ $("#tb_title").val()+" "+msg);  },
										"json");
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
				<li><a href="#tabs-2">New </a></li>
				<li><a href="#tabs-3">Edit </a></li>
				<li><a href="#tabs-4">Clone</a></li>
				<li><a href="#tabs-5">Delete</a></li>
			</ul>
			<div id="tabs-1">
				<br> Select session: <select class="s_session" id="s_show"></select>
				<button id="b_Refresh">Refresh</button>
				<br>
				<table cellpadding="0" cellspacing="0" border="0" class="display"
					id="resTableSpace" width="100%">
					<thead></thead> <tbody></tbody>
				</table>

			</div>

			<div id="tabs-2">			
				<table cellpadding="3" cellspacing="0" border="0" class="display" id="ct" width="80%">
					<tbody>
						<tr>
							<th>Title:</th>
							<td><input id="tb_title" type="text" value="Session Title"></input> </td>
						</tr>
						<br>
						<tr>
							<th>From:</th>
							<td><input id="dp_from" type="text"></input></td>
						</tr>
						<tr>
							<th>To:</th>
							<td><input id="dp_to" type="text"></input></td>
						</tr>
						<br>
						<tr></tr>
					</tbody>
				</table>
				<br>
				<button id="b_AddColumn">Add column</button>
				<hr>
				<button id="b_Create">Create</button>
				<button id="b_ShowCURLexample">Show curl example</button>
			</div>

			<div id="tabs-3">
				<br> Select session to edit: <select class="s_session" id="s_edit"></select>
				<br>
				<table cellpadding="3" cellspacing="0" border="0" class="display" id="et" width="80%">
					<tbody>
						<tr>
							<th>From:</th>
							<td><input id="dp_from_edit" type="text"></input></td>
						</tr>
						<tr>
							<th>To:</th>
							<td><input id="dp_to_edit" type="text"></input></td>
						</tr>
						<br>
						<tr></tr>
					</tbody>
				</table>
				<br>
				<button id="b_EAddColumn">Add column</button>
				<hr>
				<button id="b_Save">Save</button>
				<br>
			</div>
			<div id="tabs-4">
				<br> Select session to clone: <select class="s_session" id="s_clone"></select>
				<table cellpadding="3" cellspacing="0" border="0" class="display"
					id="clonetable" width="50%">
					<tbody>
						<tr>
							<th>Title:</th>
							<td><input id="tb_title" type="text" value="Session Title"></input>
							</td>
						</tr>
						<br>
						<tr>
							<th>From:</th>
							<td><input id="dp_from_clone" type="text"></input></td>
						</tr>
						<tr>
							<th>To:</th>
							<td><input id="dp_to_clone" type="text"></input></td>
						</tr>
					</tbody>
				</table>
				<hr>
				<button id="b_Clone">Clone</button>
				<br>
			</div>
			<div id="tabs-5">
				<br> Select session to delete: <select class="s_session" id="s_delete"></select>
				<hr>
				<button id="b_Delete">Delete</button>
				<br>
			</div>
		</div>



	</div>

	<div id="loading" style="display: none">
		<br> <br>Loading data. Please wait...<br> <br> <img
			src="static/wait_animated.gif" alt="loading" />
	</div>


</body>
</html>