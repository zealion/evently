var guest_test = {
	photo_url:'uploads/photos/test.jpg'
}
var guest_init = {
	photo_url:'img/back.jpg'
}
var date_update = new Date();

// function autoReload (){
// 	$.ajax({
// 		type:'get',
// 		url:'http://localhost:4000/show',
// 		success:function(data){
// 			console.log('auto created');
// 		},
// 		fail:function(){
// 			console.log('error');
// 		}
// 	})
// }
// setInterval(autoReload,1000*4);

small_index = 0;
huge_index = 0;
$(document).on('ready',function(){
	// guest = guest_test;
	// for(var i =0 ;i<11;i++){
	// 	guest_arrive(guest);
	// }
})

function start_marquee(){
	$('.marquee').marquee({
    //speed in milliseconds of the marquee
    duration: 20000,
    //gap in pixels between the tickers
    gap: 12,
    //time in milliseconds before the marquee will start animating
    delayBeforeStart: 0,
    //'left' or 'right'
    direction: 'left',
    //true or false - should the marquee be duplicated to show an effect of continues flow
    duplicated: true
	});
}

function getRandom(n)
{
	return Math.floor(Math.random()*n+1)-1;
}


function guest_arrive(guest){

	// 重复登录
	// if($("[guest_id='"+guest.qrcode_id+"']").length > 0 ){
	// 	$("[guest_id='"+guest.qrcode_id+"']").fadeOut()
	// 		.attr('src',window.document.location.href+guest.photo_url)
	// 		.attr('arrive','true')
	// 		.attr('guest_id',guest.qrcode_id)
	// 		.load(function(){
	// 			console.log('load-ok');
	// 			$(this).fadeIn(2000);	
	// 		})
	// 	var date_update = new Date();	
	// 	return 
	// }



	$('.img-huge').eq(huge_index%4).attr('src','/'+guest.photo_url).show()
	huge_index++;
	guest_move();
	//setInterval(guest_move(guest), 4*100000);	
}


function guest_move(){
	console.log(small_index);
	$('.img-small').eq(small_index%10).attr('src','/'+guest.photo_url).show()
	$('.img-small').eq(small_index%10+10).attr('src','/'+guest.photo_url).show()	
	
	if(small_index == 10){
		console.log('start');
		start_marquee();
	}
	small_index++;
	
	
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

