http     = require 'http'
os       = require 'os'
exec     = require('child_process').exec
ioClient = require 'socket.io-client'

if not process.argv[2]?
  console.error "Need ip-address as argument to connect to dipole-server"
  process.exit()

connectIp = process.argv[2]
  
socket    = ioClient.connect "http://#{connectIp}:10001",
  {
    'max reconnection attempts': 'Infinity'
    'reconnection delay': 1000
  }

socket.on 'error', (e) ->
  console.log e

socket.on 'connect', ->
  console.log 'SOCK -> CONNECT'
  exec 'hostname', (e, stdout, stderr) ->
    socket.emit 'hostname', stdout.split('\n')[0]

socket.on 'disconnect', ->
  console.log 'SOCK -> DISCONNECT'
  
socket.on 'reconnect', (a, b) ->
  console.log 'SOCK -> RECONNECT'
  console.dir a
  console.dir b
  
socket.on 'command', (command) ->
  try
    exec command.cmd, {maxBuffer: 10*1024*1024}, (e, stdout, stderr) ->
      code = signal = 0
      if e?
        code   = e.code
        signal = e.signal
      socket.emit 'command-done', {code:code, signal:signal, stdout:stdout, stderr:stderr, id:command.id}
