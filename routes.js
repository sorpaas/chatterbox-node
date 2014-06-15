module.exports = function(app) {
  app.configure(function(){
    // I need to access everything in '/public' directly
    app.use(express.static(__dirname + '/public'));

    //set the view engine
    app.set('view engine', 'ejs');
    app.set('views', __dirname +'/views');

    app.use(device.capture());
  });


  // logs every request
  app.use(function(req, res, next){
    // output every request in the array
    console.log({method:req.method, url: req.url, device: req.device});

    // goes onto the next function in line
    next();
  });

  app.get("/", function(req, res){
    res.render('index', {});
  });
};
