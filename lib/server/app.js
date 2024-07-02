const express = require('express');
const { createServer } = require('node:http');
const { Server } = require('socket.io');

const app = express();
const server = createServer(app);
const io = new Server(server);

io.on('connection', (socket) => {
  socket.on('requestData', (data) => {
    console.log('requestData', data);
    io.emit('responseData', data);
  });
  socket.on('acceptRequest', (data) => {
    console.log('acceptRequest', data);
    // io.emit('acceptResponse', data);
  });
});

server.listen(3000, () => {
  console.log('server running at http://localhost:3000');
});