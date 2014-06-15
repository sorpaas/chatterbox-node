module.exports = function(io, app, db) {
  io.sockets.on('connection', function (socket) {

    io.sockets.emit('blast', {msg:"<span style=\"color:red !important\">someone connected</span>"});

    socket.on('blast', function(data, fn){
      console.log(data);
      io.sockets.emit('blast', {msg:data.msg});

      fn();//call the client back to clear out the field
    });

    socket.on('get', function(data, fn){

    });

    socket.on('post', function(data, fn){

    });

    socket.on('put', function(data, fn){

    });

    socket.on('delete', function(data, fn){

    });

  });
}
