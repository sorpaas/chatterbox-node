var bodyParser = require('body-parser');

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

  // parse json body
  app.use(bodyParser.json({ strict: false }));

  // parse session
  app.use(function(req, res, next){
    var sessionId = req.header("Session-Id");
    db.sessions.findOne({_id: sessionId}, function(err, doc){
      if(!err && doc) {
        req.session = doc;
      }
      next();
    });
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
    if(req.session) {
      res.send(200, doc);
    } else {
      res.status(403);
    }
  });

  app.get("/groups", function(req, res){
    db.groups.find({}, function(err, doc){
      if(err) {
        res.status(500);
        return;
      }

      res.send(200, doc.map(function(x) { return { _id: x._id, name: x.name, description: x.description }}))
    });
  });

  app.put("/groups", function(req, res){
    //require log in
    if(!req.session || !req.session.userId){
      res.status(403);
      return;
    }

    db.groups.save({ name: req.body.name, description: req.body.description });
  });

  app.get("/groups/:groupId", function(req, res){
    db.groups.findOne({ _id: req.params.groupId }, function(err, doc){
      if(err){
        res.status(500);
        return;
      }

      db.topics.find({ groupId: req.params.groupId }, function(err, topics){
        if(err){
          res.status(500);
          return;
        }

        doc.topics = topics;
        res.send(200, doc);
      })
    })
  });

  app.get("/groups/:groupId/members", function(req, res){
    db.groups.findOne({ _id: req.params.groupId }, function(err, doc){
      if(err){
        res.status(500);
        return;
      }

      function findUsersIterate(array, cur, users, callback) {
        if(cur == array.length) {
          callback(null, users);
        }

        db.users.findOne({ _id: array[cur] }, function(err, doc){
          if(err) {
            callback(err, null);
            return;
          }

          users[cur] = doc;
          findUsersIterate(array, cur + 1, users, callback);
        });
      }

      findUsersIterate(doc.members, 0, [], function(err, users){
        if(err){
          res.status(500);
          return;
        }

        res.send(200, users);
      })
    });
  });

  app.put("/groups/:groupId/members", function(req, res){
    var userId = req.body.userId;

    db.groups.findAndModify({
      query: { _id: req.params.groupId },
      update: { $addToSet: { members: userId } },
      new: true
    }, function(err) {
      if(err){
        res.status(500);
        return;
      }

      res.status(201);
    });
  });
};
