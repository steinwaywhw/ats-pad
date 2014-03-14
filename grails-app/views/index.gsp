<!DOCTYPE HTML>
<html ng-app="ats-pad">
<head>
	<title>Online Editor for ATS</title>

	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">

	<script src="http://ajax.googleapis.com/ajax/libs/angularjs/1.2.12/angular.min.js"></script>
	<script src="http://ajax.googleapis.com/ajax/libs/angularjs/1.2.12/angular-route.min.js"></script>
	<script src="http://ajax.googleapis.com/ajax/libs/angularjs/1.2.12/angular-sanitize.min.js"></script>

	<script src="http://ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"></script>
	<script src="http://cdn.jsdelivr.net/ace/1.1.01/min/ace.js"></script>

	<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
	<link href="http://netdna.bootstrapcdn.com/font-awesome/4.0.3/css/font-awesome.css" rel="stylesheet">
	<link rel="stylesheet" type="text/css" href="http://netdna.bootstrapcdn.com/bootswatch/3.1.1/simplex/bootstrap.min.css">
	
	<link rel="stylesheet/less" type="text/css" href="css/main.less">
</head>

<body class="container-fluid" ng-controller="MainController" ng-init="init()">

	
	<div class="row ">
		<div class="col-md-8 col-md-offset-1 ats-pad-logo">
			<h1><b>atspad</b></h1>
			<i>your online ats playground</i>
		</div>
	</div>
	<div class="row">
		<div class="col-md-8 col-md-offset-1">
			
			<div class="ats-pad-filetabs">
				<ul class="nav navbar-nav nav-pills">
					<li ng-repeat="name in pg.filenames" ng-class="{active: active_file() == $index}">
						<a href="" ng-click="switch_file($index)">{{name}}</a>
					</li>
				</ul>
				<button class="btn btn-default pull-right" data-toggle="modal" data-target="#modal-new-file">New File</button>

				<!-- Modal -->
				<div class="modal fade" id="modal-new-file" tabindex="-1" role="dialog" aria-labelledby="label-new-file" aria-hidden="true">
					<div class="modal-dialog">
						<div class="modal-content">
							<div class="modal-header">
								<button type="button" class="close" data-dismiss="modal" aria-hidden="true"><span class="fa fa-times"></span></button>
								<h4 class="modal-title" id="label-new-file">New File</h4>
							</div>
							<div class="modal-body">

								<form name="form_new_file" 
										 
										class="form"
										ng-class="{'has-error': form_new_file.$invalid && form_new_file.$dirty}">
				
									<input type="text" 
										class="form-control" 
										ng-pattern="/^.+\.(dats|cats|sats|hats)$/" 
										ng-model="input.filename" 
										required="required" 
										id="input-filename" 
										name="input_filename"
										placeholder="Please input a file name ...">
									<label class="control-label" ng-show="form_new_file.$invalid && form_new_file.$dirty">
								     Please input a filename ending with "sats", "dats", "cats", "hats"</label>	
								</form>
							</div>
							<div class="modal-footer">
								<button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
								<button type="button" class="btn btn-primary" ng-click="newfile()" ng-disabled="!form_new_file.$valid">OK</button>
							</div>
						</div>
					</div>
				</div>
			</div>

			<div class="clearfix"></div>

			<div>

				<div id="ats-pad-editor">function foo(items) {
					var x = "All this is syntax highlighted";
					return x;
				}
				</div>

				<div id="ats-pad-statusbar" class="bg-grey">
					Line {{bar.row}}, Column {{bar.col}} 
					<span ng-show="bar.has_sel">
						({{bar.sel.srow}}:{{bar.sel.scol}} - {{bar.sel.erow}}:{{bar.sel.ecol}})
					</span>	
				</div>

			</div>

			<div class="ats-pad-input">
				<h3>stdin</h3>
				<div class="content">
					Lorem ipsum dolor sit amet, consectetur adipisicing elit. Animi, voluptas voluptates pariatur neque expedita reiciendis ut magnam deleniti qui quisquam officiis accusamus minima. Qui, nobis, cupiditate provident vel animi eos.
				</div>
			</div>
			<div class="ats-pad-output" ng-show="stdout">
				<h3>stdout</h3>
				<div class="content">
					<ul>
						<li ng-repeat="line in stdout track by $index" ng-bind-html="line"></li>
					</ul>
				</div>
			</div>	

			
		</div>

		<div class="col-md-2">
			<div class="ats-pad-menu">
				<button class="btn btn-block btn-default">New Playground</button>
				<button class="btn btn-block btn-default">Delete Playground</button>
			</div>
			<hr>
			<div class="ats-pad-controls">
			
				<button class="btn btn-primary btn-block" ng-click="run()">Run</button>
				<button class="btn btn-default btn-block">Type Check</button>
			</div>
			<hr>
			<div class="ats-pad-embed">
				<h3>Embed</h3>
				<div class="content">
					asdlkjasd;lkjdsa
				</div>
				<h3>Share</h3>

			</div>
		</div>
	</div>
	<div class="row">
		<div class="col-md-10 col-md-offset-1">
			<hr>
			<div class="ats-pad-footer">
				Copyright Hanwen Wu
			</div>
		</div>
	</div>
		

<script type="text/javascript" src="js/application.js"></script>
<script type="text/javascript" src="js/services.js"></script> 
<script type="text/javascript" src="js/controllers.js"></script>

<script src="https://cdnjs.cloudflare.com/ajax/libs/less.js/1.7.0/less.min.js"></script>

</body>
</html>