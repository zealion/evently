
var express = require('express');
var fs = require('fs');
var app = module.exports = express.createServer();
var io = require('socket.io').listen(app);

var settings = require('./example.settings');

io.set('log level',1)

io.sockets.on('connection',function(socket){
	console.log('socket_start');
})


app.configure(function(){
	app.use(express.bodyParser());
	app.use(express.methodOverride());
	app.use(express.static(__dirname + '/public'));
})

app.get('/touch',function(req,res){
	res.json({'status':'success'})
})
//event/:id/guests - GET all guests


app.post('/upload',function(req,res){
	var new_name = get_time()+'.jpg';
	var new_path = './public/uploads/photos';
	var full_name = new_path + '/' + new_name ;
	var node_path = 'uploads/photos/' + new_name;
	var current_time = get_time();
	fs.exists(new_path,function(exist){
		if(!exist){
			fs.fs.mkdirSync(new_path);
		}
		var is = fs.createReadStream(req.files.pic_data.path);
		var os = fs.createWriteStream(full_name);
		is.pipe(os);
		is.on('end',function(errs){
			fs.unlinkSync(req.files.pic_data.path);
			if(!errs){
				var item = {
					photo_url:node_path,
					update_at:current_time
				};
				io.sockets.emit('do_arrive',item);
				res.json({'status':'success'})
			}
		})
	});
})
//event/:id/guest/:id - post update a guest , check

	
//event/:id/guest/:id - DELETE a guest


app.get('/api_test',function(req,res){
	res.sendfile("/index_test.html",{root:__dirname+'/public'});
	//do api_test
});

function get_time(){
	var d=new Date();
	var dateString=(d.getFullYear() + "-" + (d.getMonth() + 1) + "-" + d.getDate() + " " + d.getHours() + ":" + d.getMinutes() + ":"+ d.getSeconds());
	return dateString
}

// app.get("/guest/:id", function(req, res){
// 	console.log(req.params.id);
//     // get qrcode_id, photo, is_arrived, etc. from req

//     // save photo

//     // update photo_url, is_arrived on qrcode_id

//     // socket.emit("GUEST_CHANGED", obj); obj has qrcode_id, photo_url, is_arrived (if changed from 0 to 1)
// });

app.listen(4000);
