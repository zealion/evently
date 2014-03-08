var guest_test = {
	photo_url:'img/l_line.png',
	qrcode_id:'nup20140001'
}
var guest_init = {
	photo_url:'http://m3.img.papaapp.com/farm4/d/2012/0911/20/E338B821CB08C2FF9B30D3AAEAD6C00C_B500_900_500_707.JPEG'
}
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
			.fadeIn();	
			return 
	}
	var sum = $("[arrive='false']").length-1;
	if (sum != -1){
		var img_id = getRandom(sum);
		$("[arrive='false']:eq("+img_id+")").fadeOut()
			.attr('src',window.document.location.href+guest.photo_url)
			.attr('arrive','true')
			.attr('guest_id',guest.qrcode_id)
			.fadeIn();	
	} else {
		console.log('full');
		var img_id = getRandom($('.img-item').length);
		$("[arrive='true']:eq("+img_id+")").fadeOut()
			.attr('src',window.document.location.href+guest.photo_url)
			.attr('arrive','true')
			.attr('guest_id',guest.qrcode_id)
			.fadeIn();	
	}	
}
function guest_left(guest){
	$("[guest_id='"+guest.qrcode_id+"']").fadeOut()
		.attr('src','')
		.attr('arrive','false')
		.attr('guest_id','init')
		.fadeIn();
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

