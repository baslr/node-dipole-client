http     = require 'http'
os       = require 'os'
exec     = require('child_process').exec
ioClient = require 'socket.io-client'

if not process.argv[2]?
  console.error "Need ip-address as argument to connect to dipole-server"
  process.exit()

connectIp = process.argv[2]
socket    = ioClient.connect "http://#{connectIp}:10001"

socket.on 'connect', ->
  console.log "SOCK -> CONNECT"
  exec 'hostname', (e, stdout, stderr) ->
    socket.emit 'hostname', stdout.split('\n')[0]

socket.on 'disconnect', ->
  console.error "SOCK -> DISCONNECT"
  
socket.on 'reconnect', (a, b) ->
  console.error "SOCK -> RECONNECT"
  console.dir a
  console.dir b
  
socket.on 'command', (command) ->
  console.log "#{command.id}, COMMAND: #{command.cmd}"
  exec command.cmd, {maxBuffer: 10*1024*1024}, (e, stdout, stderr) ->
    code = signal = 0
    if e?
      code   = e.code
      sig	nal = e.signal
    socket.emit 'command-done', {code:code, signal:signal, stdout:stdout, stderr:stderr, id:command.id}
