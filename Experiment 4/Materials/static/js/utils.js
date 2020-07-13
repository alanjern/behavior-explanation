
function AssertException(message) { this.message = message; }
AssertException.prototype.toString = function () {
	return 'AssertException: ' + this.message;
};

function assert(exp, message) {
	if (!exp) {
		throw new AssertException(message);
	}
}

// Mean of booleans (true==1; false==0)
function boolpercent(arr) {
	var count = 0;
	for (var i=0; i<arr.length; i++) {
		if (arr[i]) { count++; } 
	}
	return 100* count / arr.length;
}

// fixes padding to keep a fixed, dynamic header.
function check_width() {
	var headerHeight = $('#header').height();
	var responseHtml = document.getElementById('responses');
	if (responseHtml != null) {
		responseHtml.style.padding = (headerHeight+10) + "px 0px 10px 0px";
	}
}

String.prototype.capitalizeFirstLetter = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
};
String.prototype.strong = function() {
    return '<strong>' + this + '</strong>';
};
function randomProperty(obj) {
    var keys = Object.keys(obj)
    return obj[keys[ keys.length * Math.random() << 0]];
};


// $(document).ready(check_width);
$(window).resize(check_width);
$(document).ready(function(){
	check_width();
});