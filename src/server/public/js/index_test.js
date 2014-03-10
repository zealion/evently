var guest_test = {
	photo_url:'uploads/photos/UNIP2014010405.jpg',
	qrcode_id:'nup20140001'
}
var guest_init = {
	photo_url:'img/back.jpg'
}
var date_update = new Date();

// setInterval(autoReload,5000);


function getRandom(n)
{
	return Math.floor(Math.random()*n+1)-1;
}
function guest_arrive(guest){
	if($("[guest_id='"+guest.qrcode_id+"']").length > 0 ){

		$("[guest_id='"+guest.qrcode_id+"']").fadeOut()
			.attr('src',window.document.location.href+guest.photo_url)
			.attr('arrive','true')
			.attr('guest_id',guest.qrcode_id)
			.load(function(){
				console.log('load-ok');
				$(this).fadeIn(2000);	
			})
		var date_update = new Date();	
		return 
	}
	var sum = $("[arrive='false']").length-1;
	if (sum != -1){
		var img_id = getRandom(sum);
		$("[arrive='false']:eq("+img_id+")").fadeOut()
			.attr('src',window.document.location.href+guest.photo_url)
			.attr('arrive','true')
			.attr('guest_id',guest.qrcode_id)
			.load(function(){
				console.log('load=ok');
				$(this).fadeIn(2000);	
			})
		var date_update = new Date();
	} else {
		console.log('full');
		var img_id = getRandom($('.img-item').length);
		$("[arrive='true']:eq("+img_id+")").fadeOut()
			.attr('src',window.document.location.href+guest.photo_url)
			.attr('arrive','true')
			.attr('guest_id',guest.qrcode_id)
			.load(function(){
				console.log('load=ok');
				$(this).fadeIn(2000);	
			})
		var date_update = new Date();
	}	
}
function guest_left(guest){
	$("[guest_id='"+guest.qrcode_id+"']").fadeOut()
		.attr('src','')
		.attr('arrive','false')
		.attr('guest_id','init')
		.fadeIn(2000);
}

function guest_update(){
	$.ajax({
	     type: "put",
	     url: "/event/1/guest/nup20140001",
	     data: {name:'test',is_arrived:'1',qrcode_id:'nup20140001'},
	     async:false,
	     success: function(result){
	     	console.log(result);
	     }
	 });
}

