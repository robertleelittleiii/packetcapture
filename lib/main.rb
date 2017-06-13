#!/usr/bin/env ruby

# app uses gemfile
require 'bundler/setup'
Bundler.require

# app using a DB
require 'active_record'  
require 'sqlite3'

# Set app path
$APP_PATH = File.expand_path(File.dirname(__FILE__)).split("/")[0...-1].join("/")
 
# use this def for irb testing
# $APP_PATH = File.expand_path(File.dirname(__FILE__))

$LOAD_PATH << $APP_PATH << $APP_PATH + "/lib"

# for ssh tunnel connections
require 'net/ssh/gateway'

# Includes for apps

require 'yaml'
require 'packetfu'
#set the app env to development by default.

ENV["AppEnv"] = ENV["AppEnv"].blank? ? "development" : ENV["AppEnv"]

$APP_CONFIG = YAML.load_file($APP_PATH + '/config/app_config.yml')[ENV["AppEnv"]]


$ipcfg = PacketFu::Utils.whoami?(:iface=>$APP_CONFIG["interface"]) rescue "n/a"
$yourPIAddresquits="192.168.1.4"


# load yaml database config file

$DATABASE_CONF = YAML.load_file($APP_PATH + '/db/config.yml')

Dir[$APP_PATH + '/models/*.rb'].each {|file| load file } # changed from require to load to force changes to load


# ActiveRecord::Base.establish_connection database_conf[ENV["AppEnv"]]

# ActiveRecord::Base.establish_connection $DATABASE_CONF["cloud_#{ENV["AppEnv"]}"]
# ActiveRecord::Base.connection.tables

#       @@ssh_gateway = Net::SSH::Gateway.new('dev.playfootbowl.com', 'bitnami', port: "22") rescue -1

#      port = @@ssh_gateway.open("127.0.0.1",3306,3307)

# ActiveRecord::Base.establish_connection $DATABASE_CONF["cloud_#{ENV["AppEnv"]}"]
# ActiveRecord::Base.connection.tables
 

# Open Connection to cloud server for data push
# RawPacketData.open_ssh_connection


puts ($APP_CONFIG.inspect)
puts ($DATABASE_CONF.inspect)
puts (ENV["AppEnv"])
puts ($ipcfg.inspect)
  

require "capture_tool"
require "push_tool"
require "reset_tool"

puts(" Start of main program! ")
#
## To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

# sniffDNSPacket()

@last_record_pushed = 5
@hold_last_item_pushed = 0
@is_push_running=false

#@t3=Thread.new(reset_loop())
#@t3.priority = 2
## @t3.join
#
#puts("* - " * 40)
#puts("* - "* 10 + "  Starting reset loop : #{@t3.status}" + "* - "* 10)
#puts("* - " * 40)
#puts
#
#sleep 10

#@t2=Thread.new{pushDataToCloud()}
#@t2.priority = 1
## @t2.join
#
#puts("* - " * 40)
#puts("* - "* 10 + "  Starting push to cloud thread : #{@t2.status}" + "* - "* 10)
#puts("* - " * 40)
#puts
# sleep 10

@t1=Thread.new{sniffPacket()}
@t1.priority = 100
# @t1.join

puts("* - " * 40)
puts("* - "* 10 + "  Starting sniff packet : #{@t1.status}" + "* - "* 10)
puts("* - " * 40)
puts

# sleep 10


#
#@t3.join
#@t2.join
#@t1.join



while true
    
      if @hold_last_item_pushed == @last_record_pushed and @last_record_pushed != 0 then
        puts("* " * 80)
        puts("!-ERROR-! "*16)
        puts("pushDataToCloud is hung")
        puts("Status is: #{@t2.status rescue "Not running!"}")
        puts("values--->  hold_last_item_pushed: #{ @hold_last_item_pushed},  @last_record_pushed: #{@last_record_pushed}")
        puts("Restarting!!")
        puts("!-ERROR-! "*16)
        puts("* " * 80)

        if !@t2.blank? then
          @t2.exit
        end
      
        puts("Status is NOW----> : #{@t2.status rescue "Not running!"}")
        @is_push_running = false
        
        @t2=Thread.new{pushDataToCloud()}
        @t2.priority = 1
        puts("Status is NOW----> : #{@t2.status rescue "Not running!"}")
      
        @last_record_pushed = 0
      end
      puts("* " * 80)
      puts(" Gateway is working, sleeping 10 seconds...")
      puts("values--->  hold_last_item_pushed: #{ @hold_last_item_pushed},  @last_record_pushed: #{@last_record_pushed}")
      puts("* " * 80)
      @hold_last_item_pushed = @last_record_pushed
      sleep 10
    end