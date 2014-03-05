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
	io.sockets.emit('socket_test');
	socket.on('back',function(data){
		console.log(data);
		socket.emit('socket_test');
	})
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
        arr['normal'] = rows;
        res.json({'status': 'success', 'body': arr});
      } else {
        console.log(err);
        res.json({'status': 'error','body': err.message});
      }
    });
});

//event/:id/guests/arrived - GET all guests arrived
app.get('/event/:id/guests/arrived',function(req,res){
	console.log(req.params.id);
	var sql = "SELECT * FROM " + settings.db_table + " where qrcode_id like '"+req.params.id+"%' and is_arrived = 1";
	console.log(sql);
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
app.get('/evnent/:eid/guest/:id',function(req, res){
  var sql;
  console.log(req.params.eid);
  if (req.params.id != undefined) {
    sql = "SELECT * FROM " + settings.db_table + " WHERE id = " + req.params.id;
    db.query(sql,function(err,rows){
      if (!err) {
        res.json({'status': 'success', 'body': rows[0]});
      } else {
        console.log(err);
        res.json({'status': 'error','body': err.code});
      }
    });
  } else {
    sql = "SELECT * FROM " + settings.db_table + " WHERE is_show = 1 ORDER BY id";
    db.query(sql,function(err,rows){
      if (!err) {
        res.json({'status': 'success', 'body': rows});
      } else {
        console.log(err);
        res.json({'status': 'error','body': err.code});
      }
    });
  }
});


app.get('/',function(req,res){
	res.sendfile("/index.html",{root:__dirname+'/public'});
	//do judgment and send data to web 
});

app.get("/guest/:id", function(req, res){
	console.log(req.params.id);
    // get qrcode_id, photo, is_arrived, etc. from req

    // save photo

    // update photo_url, is_arrived on qrcode_id

    // socket.emit("GUEST_CHANGED", obj); obj has qrcode_id, photo_url, is_arrived (if changed from 0 to 1)
});

app.listen(8000);