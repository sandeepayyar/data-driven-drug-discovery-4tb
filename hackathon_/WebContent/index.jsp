<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">	
    <link rel="icon" href="http://sadiframework.org/favicon.ico" type="image/x-icon">
    <link rel="stylesheet" type="text/css" href="http://sadiframework.org/style/new.css">
    <link rel="stylesheet" type="text/css" href="estilo.css">
	<script type="text/javascript" src="knockout-3.3.0.js"></script>
	<script type="text/javascript" src="jquery-2.1.4.js"></script>
	<title>Insert title here</title>
</head>
<body>
<span class="blink">CHOOSE DATA TYPE</span>


<select id="class" onchange="facetchange()">
  <option value="Drug">Drug</option>
  <option value="Indication">Disease</option>
  <option value="Target">Target</option>
</select>


<div class="scroll-left">
<p>D4TB DATA DRIVEN DRUG DISCOVERY FOR TB</p>
</div>






<div class="box0">
	<div class="box">
		<p id="state1" class="state">ready</p>		
		<input id="primer" class="input-xxlarge" type="text" name="complteList" list="complteList" placeholder="type here in a drug name to search" data-bind='value: text, valueUpdate: "afterkeydown"'>
		<datalist id="complteList" data-bind="foreach:completeList">
			<option data-bind="value:$data" />
		</datalist>
		<INPUT id="button" class="state" TYPE="BUTTON" VALUE="SEARCH" ONCLICK="button1()">
		
		<table><tr><td> <div class="box" id="description"></div></td><td> <div class="box" id="disease"></div> </td></tr></table>
		
		
	</div> 
</div>

<script type="text/javascript">


var endpoint = "localhost:8890";

var facet='Drug';
function facetchange(e){
	 facet=$("#class").val();	
	 document.getElementById("primer").placeholder = ("type a " + facet + " name to search...");
	};	

function dissearch(dis)
{
	document.getElementById("disease").innerHTML = "searching disease info.."+dis;

 	var htmlstuff = "<div><h1>"+dis+"</h1><ul>";
	
	var res = $.ajax({
		url:'http://localhost:8890/sparql?default-graph-uri=&query=PREFIX+db%3A+%3Chttp%3A%2F%2Fbio2rdf.org%2Fdrugbank_vocabulary%3A%3E%0D%0APREFIX+tb%3A+%3Chttp%3A%2F%2Fbio2rdf.org%2Ftb%2Fontology%2F%3E%0D%0APREFIX+dc%3A+%3Chttp%3A%2F%2Fpurl.org%2Fdc%2Fterms%2F%3E%0D%0APREFIX+sider%3A+%3Chttp%3A%2F%2Fbio2rdf.org%2Fsider_vocabulary%3A%3E%0D%0ASELECT+DISTINCT+%3Fdrugname+%3Fdisease%0D%0AWHERE+%7B%0D%0A%3Fy+rdf%3Atype+db%3ADrug+.%0D%0A%3Fy+dc%3Atitle+%3Fdrugname+.%0D%0A%3Fy+db%3Aindication+%3Findication.%0D%0A%3Findication+dc%3Adescription+%3Fdisease.%0D%0AFILTER+%28regex%28%3Fdisease%2C%22'+dis+'%22%29%29%0D%0A%7D+&format=application%2Fsparql-results%2Bjson&timeout=1000000000000&debug=on',
		data: {},
        dataType: 'json'
	})
	
	 res.done(function (data) 
		     {  	try
				{
				 htmlstuff = htmlstuff + "</ul></div><div><div><u><b>"+"DRUGS (SIDER)"+"</b></u></div><ul>";
				
				 for (i = 0; i < data.results.bindings.length; i++) 
		    	 {
						htmlstuff = htmlstuff + '<li><a href="#" onclick="drugsearch(\''+ data.results.bindings[i].drugname.value+'\')">'+  data.results.bindings[i].drugname.value +'</a></li>' ;
		    	 }
				 
					document.getElementById("disease").innerHTML = htmlstuff + "</ul></div>";
					
				
					generalInfo(dis, htmlstuff, "disease");
					}catch(e)
					{
						alert(e);
					}
		     });
			 
			 res.fail(function (data) 
			{  
				 htmlstuff = htmlstuff + "</ul></div><div><div color='red'><u><b>"+"DRUGS (SIDER) FAILED !"+"</b></u></div><ul>";
				 
					document.getElementById("disease").innerHTML = htmlstuff + "</ul></div>";
			});
	
}

function generalInfo(t, htmlstuff, target)
{
	// all spo
	 var res2 = $.ajax({ 
        url: 'http://'+endpoint+'/sparql?default-graph-uri=&query=select+distinct+COALESCE%28%3Fpl%2C+%3Fp%29+AS+%3Fplabel+%3Fo+%3Folabel%0D%0A+where+%0D%0A%7B+%3Fd+%3Chttp%3A%2F%2Fpurl.org%2Fdc%2Fterms%2Ftitle%3E+%27'+t+'%27%40en.%0D%0A%3Fd+%3Fp+%3Fo.%0D%0AOPTIONAL%7B%3Fp+%3Chttp%3A%2F%2Fpurl.org%2Fdc%2Fterms%2Ftitle%3E+%3Fpl%7D%0D%0AOPTIONAL%7B%3Fo+%3Chttp%3A%2F%2Fpurl.org%2Fdc%2Fterms%2Ftitle%3E+%3Folabel%7D%0D%0A%7DORDER+BY+%3Fplabel&format=application%2Fsparql-results%2Bjson&timeout=0&debug=on',
        data: {},
        dataType: 'json'
    });
	 
	 res2.done(function (data) 
    {  
		document.getElementById(target).innerHTML = "done!";
		     	
    	var currentP = "";
    	
    	for (i = 0; i < data.results.bindings.length; i++) 
    	{
    		if(currentP.localeCompare(data.results.bindings[i].plabel.value)!=0)
    		{	
    			currentP = data.results.bindings[i].plabel.value;

    			htmlstuff = htmlstuff + "</ul></div><div><div><u><b>"+currentP+"</b></u></div><ul>";
    		}
    		
    		var label;
    		
    		if(data.results.bindings[i].olabel != null)
    		{
    			label = data.results.bindings[i].olabel.value;
    		}
    		else
    		{
    			label = data.results.bindings[i].o.value;
    		}
    		
    		if((data.results.bindings[i].o.type).localeCompare("uri")==0)
    		{
    			htmlstuff = htmlstuff + '<li><a href="' + data.results.bindings[i].o.value + '">'+ label +'</a></li>' ;
    		}
    		else
    		{
    			htmlstuff = htmlstuff + '<li>' +label + "</li>";
    		}     		
    	}
    	

   	document.getElementById(target).innerHTML = htmlstuff + "</ul></div>";
   	
   	if(data.results.bindings.length == 0)
   	{
       	document.getElementById(target).innerHTML = "no result";
   	}
    	
   	self.completeList(datos);     		
    });        
    res2.fail(function (data) 
    {
    	document.getElementById(target).innerHTML ="fail";
    });     
}
	
function drugsearch(t)
{
	var htmlstuff = "<div><h1>"+t+"</h1><ul>";
	
	// indication
	try{
		 var res = $.ajax({ 
	         url: 'http://'+endpoint+'/sparql?default-graph-uri=&query=PREFIX+db%3A+%3Chttp%3A%2F%2Fbio2rdf.org%2Fdrugbank_vocabulary%3A%3E%0D%0APREFIX+tb%3A+%3Chttp%3A%2F%2Fbio2rdf.org%2Ftb%2Fontology%2F%3E%0D%0APREFIX+dc%3A+%3Chttp%3A%2F%2Fpurl.org%2Fdc%2Fterms%2F%3E%0D%0APREFIX+sider%3A+%3Chttp%3A%2F%2Fbio2rdf.org%2Fsider_vocabulary%3A%3E%0D%0ASELECT+DISTINCT+%3Fsiderdrug+%3Fdis++%3Fdislabel+%3Fgrouptitle+%0D%0AWHERE+%7B%0D%0A%3Fy+rdf%3Atype+db%3ADrug+.%0D%0A%3Fy+dc%3Atitle+%22'+t+'%22%40en.%0D%0A%3Fy+db%3Aindication+%3Findication.%0D%0A%3Findication+dc%3Adescription+%3Findications.%0D%0A%3Fz+rdf%3Atype+sider%3ADrug+.%0D%0A%3Fz+rdfs%3Alabel+%3Fsiderdrug.%0D%0A%3Fz+sider%3Aindication+%3Fdis+.%0D%0A%3Fdis+dc%3Atitle+%3Fdislabel+.%0D%0A%3Fy+db%3Agroup+%3Fgroup.%0D%0A%3Fgroup+dc%3Atitle+%3Fgrouptitle.%0D%0AFILTER+regex%28str%28%3Fsiderdrug%29%2C+%22'+t+'%22%29%0D%0A%7D+LIMIT+100000%0D%0A%0D%0A&format=application%2Fsparql-results%2Bjson&timeout=1000000000000&debug=on',
	         data: {},
	         dataType: 'json'
	     });
		 
		 
		 res.done(function (data) 
	     {  
			if( data.results.bindings.length>0) htmlstuff = htmlstuff + "</ul></div><div><div><u><b>"+"INDICATIONS (SIDER)"+"</b></u></div><ul>";
			
			 for (i = 0; i < data.results.bindings.length; i++) 
	    	 {
					htmlstuff = htmlstuff + '<li><a href="#" onclick="dissearch(\''+ data.results.bindings[i].dislabel.value+'\')">'+  data.results.bindings[i].dislabel.value +'</a></li>' ;
	    	 }
			 
				document.getElementById("description").innerHTML = htmlstuff + "</ul></div>";
				
				try
				{
				generalInfo(t, htmlstuff, "description");
				}catch(e)
				{
					alert(e);
				}
	     });
		 
		 res.fail(function (data) 
		{  
			 htmlstuff = htmlstuff + "</ul></div><div><div color='red'><u><b>"+"INDICATIONS (SIDER) FAILED !"+"</b></u></div><ul>";
			 
				document.getElementById("description").innerHTML = htmlstuff + "</ul></div>";
		});
		 
	}catch(err)
	{
		alert(err);
	}

	$("#primer").val(t);
}
	
function button1()
{
	document.getElementById("description").innerHTML = "searching..."+facet;
	
	var t = $("#primer").val();
	drugsearch(t);
	
}
	
var datos=[];
function AutoCompleteVM() {
    var self = this; 
    self.completeList = ko.observableArray([]);
    self.completeList2 = ko.observableArray([]);
    self.completeList3 = ko.observableArray([]);
    self.text = ko.observable();
    self.text2 = ko.observable();
    self.text3 = ko.observable();

    self.updated = ko.computed(function (val) {
    	document.getElementById("state1").innerHTML = "searching...";
        var res = $.ajax({ 
            url: 'http://'+endpoint+'/sparql?default-graph-uri=&query=select+distinct+%3Fl+where+%7B+%3Fd+a+%3Chttp%3A%2F%2Fbio2rdf.org%2Fdrugbank_vocabulary%3A'+facet+'%3E.+%3Fd+%3Chttp%3A%2F%2Fpurl.org%2Fdc%2Fterms%2Ftitle%3E+%3Fl.+FILTER%28strStarts%28UCASE%28%3Fl%29%2C+UCASE%28%22'+self.text()+'%22%29%29%29%7D+LIMIT+10&format=application%2Fsparql-results%2Bjson&timeout=0&debug=on',
            data: {},
            dataType: 'json'
        });
        res.done(function (data) 
        {    
        	document.getElementById("state1").innerHTML = "ready";
        	
        	datos=[];
        	for (i = 0; i < data.results.bindings.length; i++) {datos.push(data.results.bindings[i].l.value);}
       		self.completeList(datos); 
       		
       		document.getElementById("state1").innerHTML =""+data.results.bindings.length+" results";      
        });        
        res.fail(function (data) 
        {
        	document.getElementById("state1").innerHTML ="fail";
        });           
        
 
    }, this).extend({
        throttle: 250
    });
    
}


var autoComplete = new AutoCompleteVM();
ko.applyBindings(autoComplete);

</script>		
</body>
</html>
<!-- //http://www.w3schools.com/website/Customers_MYSQL.php  -->