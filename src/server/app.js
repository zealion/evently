var express = require('express');
var fs = require('fs');
var app = module.exports = express.createServer();
var io = require('socket.io').listen(app);
var mysql = require('mysql');
var settings = require('./settings');

var db = mysql.createConnection({
  host: settings.db_host,
  user: settings.db_login,
  password: settings.db_pass,
  database: settings.db_name
  });

db.connect();
io.set('log level',1)

io.sockets.on('connection',function(socket){
	console.log('socket_start');
	reload();
})


app.configure(function(){
	app.use(express.bodyParser());
	app.use(express.methodOverride());
	app.use(express.static(__dirname + '/public'));
})

//event/:id/guests - GET all guests
app.get('/event/:id/guests',function(req,res){
	console.log(req.params.id);
	var sql = "SELECT * FROM " + settings.db_table + " where qrcode_id like '"+req.params.id+"%'";
	console.log(sql);
	db.query(sql,function(err,rows){
	if (!err) {
        var arr = {};
        res.json({'status': 'success', 'body': rows});
      } else {
        console.log(err);
        res.json({'status': 'error','body': err.message});
      }
    });
});

//event/:id/guests/arrived - GET all guests arrived
app.get('/event/:id/guests/arrived',function(req,res){
	console.log(sql);
	var sql = "SELECT * FROM " + settings.db_table + " where qrcode_id like '"+req.params.id+"%' and is_arrived = 1";
	db.query(sql,function(err,rows){
	if (!err) {
        var arr = {};
        arr['normal'] = rows;
        res.json({'status': 'success', 'body': arr});
      } else {
        console.log(err);
        res.json({'status': 'error','body': err.message});
      }
    });
});

//event/:eid/guest/:id - GET a guest
app.get('/evnent/:id/guest/:id',function(req, res){
  	var sql;
  	
	sql = "SELECT * FROM " + settings.db_table + " WHERE qrcode_id LIKE " + "'" + req.params.id + "'";
	console.log(sql);
	db.query(sql,function(err,rows){
	  if (!err) {
	    res.json({'status': 'success', 'body': rows});
	  } else {
	    console.log(err);
	    res.json({'status': 'error','body': err.code});
	  }
    });
});

//event/:id/guests - PUT create a new guest
app.put('/event/:eid/guests',function(req,res){
	var current_time = get_time();
	var item = {
		qrcode_id:req.body.qrcode_id,
		name:req.body.name,
		created_at:current_time(),
		updated_at:current_time()
	}
	sql = "insert into " +settings.db_name+ " set ?"
	db.query(sql,item,function(err,result){
		if(err){
			console.log(err.message);
		}
	})	
})

//event/:id/guest/:id - PUT update a guest , check
app.post('/event/:eid/guest/:id',function(req,res){
	console.log(req);
	var new_name = req.body.qrcode_id + '.jpg';
	var new_path = './public/img';
	var full_name = new_path + "/" +new_name;
	var node_path = 'img/'+new_name;
	var current_time = get_time();
	console.log(req.files);
	fs.exists(new_path,function(exist){
		if(!exist){
			fs.mkdirSync(new_path);
		}
		var is = fs.createReadStream(req.files.pic_data.path);
		var os = fs.createWriteStream(full_name);
		is.pipe(os);
		is.on('end',function(errs){
			fs.unlinkSync(req.files.pic_data.path);
			if (!errs){
				var item = {
					qrcode_id:req.body.qrcode_id,
					name:req.body.name,
					photo_url:node_path,
					is_arrived:req.body.is_arrived,
					updated_at:current_time
				}
				if ( Number(item.is_arrived) == 1 ){
					item.arrived_at = current_time
				}
				sql = "update " +settings.db_table+ " set ? where qrcode_id = "+mysql.escape(req.body.qrcode_id);
				db.query(sql,item,function(err,result){
					if(err){
						console.log(err.message);
						res.json({'status': 'error', 'message':err.message});
					} else {
						if ( Number(item.is_arrived) == 1 )
							io.sockets.emit('do_arrive',item);
						res.json({'status': 'success'});
					}
				})	
			} else {
				res.json({'status':'error','message':err.code})
			}
		})
	});
})
	
//event/:id/guest/:id - DELETE a guest
app.delete('/event/:eid/guest/:id',function(req,res){
	sql = "delete " +settings.db_table + " where qrcode_id = "+mysql.escape(req.body.qrcode_id);
	db.query(sql,item,function(err,result){
		if(err){
			console.log(err.message);
			res.json({'status': 'error', 'message':err.message});
		} else {
			res.json({'status': 'success'});
		}
	})	
})

app.get('/',function(req,res){
	res.sendfile("/index.html",{root:__dirname+'/public'});
	//do judgment and send data to web 
});


function reload(){
	var sql = "SELECT * FROM " + settings.db_table + " WHERE is_arrived = 1 ORDER BY rand() LIMIT 5"
	db.query(sql,function(err,rows){
	if (!err) {
        var arr = {};
        io.sockets.emit('reload',rows);
      } else {
        console.log(err);
      }
    });
}

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