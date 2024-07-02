
const port = 5000
const app = require('./app');
const socketIO = require('socket.io');
const http = require('http');
const db = require('./database/database');
let server = http.createServer(app)
let io = socketIO(server)
let join_data
// process.on('unhandledRejection', err => {
//   console.log("Error : ${err.message}");
//   console.log("sutting down the server due to Uncaught Exception");
//   process.exit(1);
// })
//socket connection circute
io.on('connection', (socket, cb) => {
  console.log("socket connected");
  console.log("socket id is ", socket.id);

  let roomMap = io.sockets.adapter.rooms
  //send socket isd to user
  socket.on('get_socket', (args, callback) => {
    console.log('ioio okkk khokha..............................', socket.id)
    callback(socket.id)
  })
  //user want to connent another user
  socket.on('join-message', async (arg, callback) => {
    console.log("want to connect another user",JSON.stringify(arg))
    let args = JSON.parse(arg);
    join_data = arg
    let user_details = JSON.stringify({ "user_details": args.user, "socket_id": socket.id, 'roomId': args.roomId });
    console.log("user_details in server.js", user_details);
    let roomId = args.roomId
    await getSocketId(roomId, (callback) => {
      console.log("room id is",roomId)
      if (callback != 'offline') {
        // user access message 
        console.log('callbackvalue is', callback)
        io.to(callback).emit('access-request', user_details, (callback) => {
          console.log("access-request is working");
        })
      }
      else {
        // user is offline send to request user
        io.to(socket.id).emit('user-offline', 'user offline');
      }
    });
  })

  socket.on('reject', (data) => {
    let jsondata = JSON.parse(data);
    io.to(jsondata.socket_id).emit('you-reject', data)
  })
  //accept message to request user
  socket.on('accept', (data) => {
    let jsondata = JSON.parse(data);
    roomId = parseInt(jsondata.roomId)
    //remote user join in a room
    socket.join(roomId)
    io.to(jsondata.socket_id).emit('join-you', data)
  })
  //request user join in a room
  socket.on('join', (data) => {
    let jsondata = JSON.parse(data);
    roomId = parseInt(jsondata.roomId)
    socket.join(roomId)
  })
  socket.on('shere-user-join', (roomId) => {
    if (!roomMap.has(socket.id)) {
      socket.join(roomId);
    }
  })
  //user is present or not in a database and he is online or not 
  // getSocketId = async (uniqueId, callback) => {
  //   await db.poolconnect
  //   try {
  //     const request = db.pool.request();
  //     request.input('uniqueId', db.mssql.Int, uniqueId)
  //     request.output('response', db.mssql.VarChar(2000))
  //       .execute('[dbo].[get_socket_id]').then(function (recordsets, err, returnValue, affected) {
  //         console.log("recordsets for get socket id", recordsets);
  //         callback(recordsets.output.response);
  //       })
  //   }
  //   catch {
  //     return
  //   }
  // }
  //leavea the room and join another room
  const leaveOtherRooms = (socketID) => {
    if (roomMap.has(socketID)) {
      roomMap.forEach((value, key) => {
        if (value.size > 1) {
          console.log("i m val", key, value)
          let setVal = value
          setVal.forEach((value, key) => {
            if (value == socketID) {
              setVal.delete(value)
            }
          })
        }
      })
    }
  }
  //leave the room when user disconnect
  socket.on('room-leave', (roomId) => {
    socket.leave(roomId);
  })
  //user disconnect
  socket.on("disconnect", async () => {
    console.log("i m disconnecting..")
    leaveOtherRooms(socket.id);
  })
  //screen share start
  socket.on("screen-data", (data) => {
    data = JSON.parse(data);
    var room = data.room;
    var imgStr = data.image;
    let id = join_data.UniqueId
    socket.to(room).emit("scree-image", imgStr);
  })

  //mouse movement
  socket.on('mouse-move', (data) => {
    var room = parseInt(JSON.parse(data).room);
    socket.to(room).emit("move-mouse", data);
  })
  // mouse click event
  socket.on('mouse-click', (data) => {
    var room = parseInt(JSON.parse(data).room);
    socket.to(room).emit("click-mouse", data);

  })
  //mouse scroll event
  socket.on("scroll", (data) => {
    var room = parseInt(JSON.parse(data).room);
    socket.to(room).emit("scroll", data)

  })
  //mouse type event
  socket.on("type", (data) => {
    var room = parseInt(JSON.parse(data).room);
    socket.to(room).emit("type", data);

  })
  //mouse double click
  socket.on("dobule-click", (data) => {
    var room = parseInt(JSON.parse(data).room);
    socket.to(room).emit("dobule-click", data);
  })

  //mouse right click event
  socket.on("right-click", (data) => {
    var room = parseInt(JSON.parse(data).room);
    socket.to(room).emit("right-click", data);
  })
  //mouse auxious click
  socket.on("auxclick", (data) => {
    var room = parseInt(JSON.parse(data).room);
    socket.to(room).emit("auxclick", data);
  })



});
//server
const server1 = server.listen(port, () => {
  console.log("server is runing http://localhost:${port}");
});
//unhandle promise Rejection
process.on('unhandledRejection', (err) => {
  server1.close(() => {
    process.exit(1);
  })
})
