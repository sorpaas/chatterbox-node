module.exports = function(io) {
  io.sockets.on('connection', function (socket) {

    io.sockets.emit('blast', {msg:"<span style=\"color:red !important\">someone connected</span>"});

    socket.on('blast', function(data, fn){
      console.log(data);
      io.sockets.emit('blast', {msg:data.msg});

      fn();//call the client back to clear out the field
    });

  });
}
