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
            client.puts "Name is not avalible"
            Thread.kill self
          end
        end
        puts "#{nick_name} #{client}"
        @connections[:clients][nick_name] = client
        client.puts "Welcome #{nick_name}! You are connected."
        Thread.start{ start_message_listener( nick_name, client, self ) }
      end
    }.join
  end
 
  def start_message_listener  username, client, thread
    loop do
      begin
        client.puts("heartbeat:check")
        time_hb = Time.now
        puts "Sent heartbeat to #{username}"
        callback = client.gets
        if callback 
          callback = callback.chomp
          if callback.chomp == "heartbeat:200"
            puts "Received heartbeat from #{username}"
            puts "response time: #{Time.now-time_hb} seconds"
            true
          else
            msg, receiver = callback.split("to: ")
            @connections[:clients].each do |other_name, other_client|
              if receiver
                if other_name == receiver.to_sym
                  other_client.puts "#{username.to_s} (private message): #{msg}"
                end
              else
                #unless other_name == username
                  other_client.puts "#{username.to_s} (to all): #{msg}"
                #end
              end
            end
          end
        else
          raise NoMethodError
        end

      rescue Exception => bang
        @connections[:clients].each do |other_name, other_client|
          unless other_name == username
            other_client.puts "#{username.to_s} has gone offline"
          end
        end
        puts "#{username.to_s} has gone offline"
        @connections[:clients].delete username.to_sym
        Thread.kill(thread)
      end
    end
  end

end
 
Server.new( 3000, "localhost" )