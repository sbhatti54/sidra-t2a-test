function checkForm()
{
    var numericExpression = /^[0-9]+$/;
    var phoneNumber = /^[2-9][0-8][0-9]\d+$/;
    var alphaExp = /^[a-zA-Z]+$/;
    var emailExp = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*\.(\w{2}|(com|net|org|edu|int|mil|gov|arpa|biz|aero|name|coop|info|pro|museum))/;
    var alphaExpCity = /^[a-zA-Z\s]+$/; 
    var name = /^[a-zA-Z\s\-\']+$/;   
    var address =  /^[{}()!%^=`~#$&<>,?\"':;*+?\\^$|\s\.]/;
 
	var date = /^([0-9]{2})\/([0-9]{2})\/([0-9]{4})$/;
	var date2 = /^([0-9]{2})\-([0-9]{2})\-([0-9]{4})$/;
	
	
  
  if(!document.form.first_name.value.match(alphaExp) || (document.form.first_name.value == ""))
  {
    	alert("Please enter your first name");
		document.form.first_name.focus();
		document.form.first_name.value = "";
        return false;
     }

  if(!document.form.last_name.value.match(alphaExp) || (document.form.last_name.value == ""))
  {
    	alert("Please enter your last name");
		document.form.last_name.focus();
		document.form.last_name.value = "";
        return false;
     }


  if(!document.form.mobile_phone.value.match(phoneNumber) || (document.form.mobile_phone.value == ""))
  {
    	alert("Please enter your phone number no dashes ex (3195554444)");
		document.form.mobile_phone.focus();
		document.form.mobile_phone.value = "";
        return false;
     }

	if(document.form.date_of_birth.value =="")
	    {
	    	alert("Please enter a valid date of birth 01/01/1975");
			document.form.date_of_birth.focus();
			document.form.date_of_birth.value = "";
	        return false;
	     }

	if(!document.form.date_of_birth.value.match(date) && !document.form.date_of_birth.value.match(date2))
	    {
	    	alert("Please enter a valid date of birth");
			document.form.date_of_birth.focus();
			document.form.date_of_birth.value = "";
	        return false;
	     }

  	if(document.form.address.value == "")
	  {
	    	alert("Please enter your address");
			document.form.address.focus();
			document.form.address.value = "";
	        return false;
	     }
 	
	if(document.form.city.value == "")
	{
		alert("Please enter your city");
		document.form.city.focus();
		document.form.city.value = "";
		return false;
	}

	if(!document.form.state.value.match(alphaExp) || (document.form.state.value == ""))
	{
		alert("Please enter your state");
		document.form.state.focus();
		document.form.state.value = "";
		return false;
	}
	
	if(!document.form.zip.value.match(numericExpression) || (document.form.zip.value == ""))
	{
		alert("Please enter your zip code");
		document.form.zip.focus();
		document.form.zip.value = "";
		return false;
	}

}