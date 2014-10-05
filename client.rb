#!/usr/bin/env ruby -w
# Original author is http://www.sitepoint.com/ruby-tcp-chat/
require "socket"
class Client
  def initialize( server )
    @server = server
    @request = nil
    @response = nil
    listen
    send
    @request.join
    @response.join
  end
 
  def listen
    @response = Thread.new do
      loop {
        msg = @server.gets.chomp
        puts "#{msg}"
      }
    end
  end
 
  def send
    puts "Введите Ваше имя:"
    @request = Thread.new do
      loop {
        msg = $stdin.gets.chomp
        @server.puts( msg )
      }
    end
  end
end
 
server = TCPSocket.open( "localhost", 3000 )
Client.new( server )