#!/usr/bin/env ruby -w
# Original author is http://www.sitepoint.com/ruby-tcp-chat/
require "socket"
class Server
  def initialize( port, ip )
    @server = TCPServer.open( ip, port )
    @connections = Hash.new
    @clients = Hash.new
    @connections[:server] = @server
    @connections[:clients] = @clients
    run
  end
 
  def run
    loop {
      Thread.start(@server.accept) do | client |
        nick_name = client.gets.chomp.to_sym
        @connections[:clients].each do |other_name, other_client|
          if nick_name == other_name || client == other_client
            client.puts "Такой никнейм уже существует"
            Thread.kill self
          end
        end
        puts "#{nick_name} #{client}"
        @connections[:clients][nick_name] = client
        client.puts "Вы подключены, приятного общения"
        listen_user_messages( nick_name, client )
      end
    }.join
  end
 
  def listen_user_messages( username, client )
    loop {
      msg, receiver = client.gets.chomp.split("to: ")
      @connections[:clients].each do |other_name, other_client|
        if receiver
          if other_name == receiver.to_sym
            other_client.puts "#{username.to_s} (личное сообщение): #{msg}"
          end
        else
          unless other_name == username
            other_client.puts "#{username.to_s} (ко всем): #{msg}"
          end
        end
      end
    }
  end
end
 
Server.new( 3000, "localhost" )