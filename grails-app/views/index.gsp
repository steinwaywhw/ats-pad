<!DOCTYPE HTML>
<html ng-app="ats-pad">
<head>
	<title>Online Editor for ATS</title>

	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">

	<script src="http://ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"></script>
<!--    <script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.4/jquery-ui.min.js"></script>-->
<!--    <link rel="stylesheet" href="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.4/themes/smoothness/jquery-ui.css" />-->
    
	<script src="http://cdnjs.cloudflare.com/ajax/libs/socket.io/0.9.16/socket.io.min.js"></script>
    <script src="js/markdown.min.js"></script>

	<script src="http://ajax.googleapis.com/ajax/libs/angularjs/1.2.12/angular.min.js"></script>
	<script src="http://ajax.googleapis.com/ajax/libs/angularjs/1.2.12/angular-route.min.js"></script>
	<script src="http://ajax.googleapis.com/ajax/libs/angularjs/1.2.12/angular-sanitize.min.js"></script>

	<script src="http://cdn.jsdelivr.net/ace/1.1.3/min/ace.js"></script>

	<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
	<link href="http://netdna.bootstrapcdn.com/font-awesome/4.0.3/css/font-awesome.css" rel="stylesheet">
	<link rel="stylesheet" type="text/css" href="http://netdna.bootstrapcdn.com/bootswatch/3.1.1/superhero/bootstrap.min.css">
    
	
	<link rel="stylesheet/less" type="text/css" href="css/main.less">
</head>

<body class="container-fluid" ng-controller="MainController" ng-init="init()">

	
	<div class="row">
		<div class="col-md-8 col-md-offset-1 ats-pad-logo">
			<h1><b>atspad</b></h1>
			<i>your online ats playground</i>
		</div>
	</div>
     
    
	<div class="row">
        
        <!------------------------------------------------------------>
        <!--EDITOR---------------------------------------------------->
        <!------------------------------------------------------------>
		<div class="col-md-8 col-md-offset-1">
            <div class="row" ng-controller="MarkdownController">
                <div class="col-md-12">
                    <div class="panel panel-info" id="ats-pad-readme">
                        <div class="panel-heading" ng-click="toggle_readme()">
                            <h3 class="panel-title">README</h3>
                        </div>
                        <div class="panel-body">
                            <div id="ats-pad-markdown"></div>
                        </div>
                    </div>

                    
                </div>   
            </div>
            
            <div class="row">
            	<div class="col-md-3 helper-no-right-padding" ng-controller="FilelistController" >
                    
                    <div class="ats-pad-filetoolbar">
                        <div class="btn-toolbar" role="toolbar">
                            <div class="btn-group btn-group-sm" >
                                <button class="btn btn-default" disabled="disabled">
                                    <span class="fa fa-folder-open-o"></span>
                                </button>
                            </div>


                            <div class="pull-right btn-group btn-group-sm">
                                <button type="button" class="btn btn-default"><span class="fa fa-cloud-upload"></span></button>
                                <button type="button" class="btn btn-default"><span class="fa fa-cloud-download"></span></button>
                                <button type="button" class="btn btn-default" ng-click="create_file();"><span class="fa fa-plus"></span></button>
                            </div>
                            
                            <div class="pull-right btn-group btn-group-sm">
                                <button class="btn btn-default"><span class="fa fa-refresh"></span></button>               
<!--
                                <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown"><span class="fa fa-gear"></span></button>
                                <ul class="dropdown-menu" role="menu">
                                    <li><a href="#">Action</a></li>
                                    <li><a href="#">Another action</a></li>
                                    <li><a href="#">Something else here</a></li>
                                    <li class="divider"></li>
                                    <li><a href="#">Separated link</a></li>
                                  </ul>
-->
                            </div>

                        </div>
                    </div>
            		
                    
                    <div class="ats-pad-filelist"  >
                        <div ats-filelist></div>                        
                    </div>
            		
            	</div>
                
                
                 <!-- Editor -->
            	<div class="col-md-9 helper-no-left-padding">
            		<div id="ats-pad-editor"></div>

                    <div id="ats-pad-statusbar" ng-controller="StatusBarController">
                        Line {{env.bar.row}}, Column {{env.bar.col}} 
                        <span ng-show="env.bar.has_sel">
                            ({{env.bar.sel.srow}}:{{env.bar.sel.scol}} - {{env.bar.sel.erow}}:{{env.bar.sel.ecol}})
                        </span>	
                        
                    </div>
            		
            	</div>
            	
            
            </div>
           

			<!-- <div> -->
                
				
<!--
				
-->

			<!-- </div> -->

			<div class="row">
                <div class="col-md-12">
                    <div class="ats-pad-terminal">
                        <h4>Terminal</h4>
                        <div id="terminal"></div>
                    </div>	
                </div>
            </div>
			
		</div>

        <!------------------------------------------------------------>
        <!--SIDEBARS-------------------------------------------------->
        <!------------------------------------------------------------>
		<div class="col-md-2">
			<div class="ats-pad-menu">
				<button class="btn btn-block btn-default">New Pad</button>
				<button class="btn btn-block btn-default">Delete Pad</button>
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
        <!------------------------------------------------------------>
        
	</div>
	<div class="row">
		<div class="col-md-10 col-md-offset-1">
			<hr>
			<div class="ats-pad-footer">
				Copyright Hanwen Wu
			</div>
		</div>
	</div>
		

<script src="js/application.js"></script>
<script src="js/services.js"></script> 
<script src="js/controllers.js"></script>
<script src="js/term.js"></script>
<script src="js/client.js"></script>
<script src="js/directives.js"></script>


<script src="https://cdnjs.cloudflare.com/ajax/libs/less.js/1.7.0/less.min.js"></script>

</body>
</html>