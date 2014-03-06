var guest_test = {
	photo_url:'http://m3.img.papaapp.com/farm2/d/2011/1119/14/42703A6CD0BA04A9FECF5A74681907CD_B500_900_500_704.JPEG',
	qrcode_id:'nup20140001'
}
function getRandom(n)
{
	return Math.floor(Math.random()*n+1)-1;
}
function guest_arrive(guest){
	var sum = $("[arrive='false']").length-1;
	if (sum != -1){
		var img_id = getRandom(sum);
		$("[arrive='false']:eq("+img_id+")").fadeOut()
			.attr('src',guest.photo_url)
			.attr('arrive','true')
			.attr('guest_id',guest.qrcode_id)
			.fadeIn();	
	} else {
		console.log('full');
		var img_id = getRandom($('.img-item').length);
		$("[arrive='true']:eq("+img_id+")").fadeOut()
			.attr('src',guest.pic_path)
			.attr('arrive','true')
			.attr('guest_id',guest.qrcode_id)
			.fadeIn();	
	}	
}
function guest_left(guest){
	$("[guest_id='"+guest.qrcode_id+"']").fadeOut()
		.attr('src',guest_test.photo_url)
		.attr('arrive','false')
		.attr('guest_id',guest.qrcode_id)
		.fadeIn();
}

function guest_update(){
	$.ajax({
	     type: "PUT",
	     url: "/event/1/guest/nup20140001",
	     data: {name:'test',is_arrived:'1',qrcode_id:'nup20140001',photo_url:'test'},
	     async:false,
	     success: function(result){
	     	console.log(result);
	     }
	 });
}