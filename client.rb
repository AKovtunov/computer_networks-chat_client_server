#!/usr/bin/env ruby -w
# Original author is http://www.sitepoint.com/ruby-tcp-chat/
require "socket"
require 'io/console'

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
        if msg == "heartbeat:check"
          @server.puts "heartbeat:200\n"
        else
          puts "#{msg}"
        end
      }
    end
  end

  ##{username.to_s} (to all): #{msg}
  def send
    puts "Please, input your name:"
    username = $stdin.gets.chomp
    @server.puts( username )
    @request = Thread.new do
      loop {
        msg = STDIN.noecho {|i| i.gets}.chomp
        @server.puts( msg )
      }
    end
  end

end
 
server = TCPSocket.open( "localhost", 3000 )
Client.new( server )