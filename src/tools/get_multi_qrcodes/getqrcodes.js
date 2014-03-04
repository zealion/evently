var http = require("http");
var fs = require("fs");
var url = require("url");
var util = require('util');

var api = 'http://qr.liantu.com/api.php?text=%s&w=430&el=h' ;
var gid_pre = 'UNIP201401';
var out_dir = __dirname + "/codes/";

function gen(i){
    if(i>9999) return;

    var str = '' + i;
    while(str.length<4){
        str = '0'+str;
    }
    var gid = gid_pre + str;

    var req_url = util.format(api, gid);

    var out_url = out_dir + gid + '.png';

    var options = {
        host: url.parse(req_url).hostname,
        port: 80,
        path: url.parse(req_url).path
    };

    http.get(options, function(res){
        console.log("response: " + res.statusCode);
        res.setEncoding('binary');
        var imageData = '';
        res.on('data', function(chunk){
            imageData+=chunk;
        });
        res.on('end', function(){
            fs.writeFile(out_url, imageData, 'binary', function(err){
                if(err) throw err;
                console.log('saved: ' + gid);
            });
        });
    }).on('error', function(e){
        console.log("error: " + e.message);
    });
}

var gid_min = 1;
var gid_max = 500;

for(var i=gid_min; i<=gid_max; i++){
    gen(i);
}