module.exports = function(app, db) {
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
    console.log({method:req.method, url: req.url, device: req.device});
    next();
  });

  //parse session
  app.use(function(req, res, next){
    req.session = req.header("Session-Id")
    next();
  })

  app.get("/", function(req, res){
    res.render('index', {});
  });

  //Create new session
  app.put("/session", function(req, res){
    if(req.session) {
      res.status(403);
      return;
    } //forbid creating new session if we have already got one.

    db.sessions.save({}, function(err, doc) {
      if(err) {
        res.status(500);
        return;
      }

      res.send(201, doc);
    })
  });

  app.get("/session", function(req, res){
    db.sessions.findOne({_id: req.session}, function(err, doc){
      if(err) {
        res.status(500);
        return;
      }

      if(!doc) {
        res.status(403);
        return;
      }

      res.send(200, doc)
    });
  });
};
