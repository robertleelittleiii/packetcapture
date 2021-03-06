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

# for new http push process
require "uri"
require "net/http"

# fix for sqlite

module SqliteTransactionFix
  def begin_db_transaction
    log('begin immediate transaction', nil) { @connection.transaction(:immediate) }
    puts("***** TESTING *****")
  end
end

module ActiveRecord
  module ConnectionAdapters
    class SQLiteAdapter < AbstractAdapter
      prepend SqliteTransactionFix
    end
  end
end

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

# CaptureCache.delete_all
# CaptureCache.all.count

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
@push_last_seen=Time.now

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
# @t1.join

last_check = Time.now

while true
  pushDataStatus = @t2.status.to_s rescue ""
  if (@push_last_seen + 30 < Time.now) or ! "sleep,run".include?(pushDataStatus) then
    last_check = Time.now
    #  puts("* " * 10)
    puts("!-ERROR-! "*4)
    puts("pushDataToCloud is hung @#{Time.now.strftime("%d/%m/%Y %H:%M:%S")}")
    puts("Status is: #{@t2.status rescue "Not running!"}")
    if !$APP_CONFIG["use_http"] then
      # puts("values--->  hold_last_item_pushed: #{ @hold_last_item_pushed},  @last_record_pushed: #{@last_record_pushed}")
      puts("Closing ssh tunnel")
      RawPacketData.close_ssh_connection()
      puts("Restarting!!")
    end
    puts("!-ERROR-! "*4)
    # puts("* " * 10)

    if !@t2.blank? then
      @t2.exit
    end
      
    # puts("Status is NOW----> : #{@t2.status rescue "Not running!"}")
    @is_push_running = false
        
    @t2= $APP_CONFIG["use_http"] ? Thread.new{pushDataToCloudviaHTTP()} : Thread.new{pushDataToCloud()}
    @t2.priority = 1
    # @t2.join

    # puts("Status is NOW----> : #{@t2.status rescue "Not running!"}")
      
    @last_record_pushed = 0
  end
  
  
  puts("* " * 20)
  puts("Time: #{Time.now.strftime("%d/%m/%Y %H:%M:%S")}")
  puts(" sniffPacket status: #{@t1.status rescue "!! not running !!"}")
  
  sniffPacketStatus = @t1.status.to_s rescue ""
  if !"sleep,run".include?(sniffPacketStatus) or sniffPacketStatus.blank? then
    puts("!-ERROR-! "*4)
    puts("sniffPacket is hung @#{Time.now.strftime("%d/%m/%Y %H:%M:%S")}")
    puts("Status is: #{@t1.status rescue "Not running!"}")
    # puts("values--->  hold_last_item_pushed: #{ @hold_last_item_pushed},  @last_record_pushed: #{@last_record_pushed}")
    puts("Restarting!!")
    puts("!-ERROR-! "*4)
    if !@t1.blank? then
      @t1.exit
    end
    @t1=Thread.new{sniffPacket()}
    @t1.priority = 100
  end
  
  puts(" pushDataToCloud status: #{@t2.status rescue "!! not running !!"}")
  puts("* " * 20)
  #puts("values--->  hold_last_item_pushed: #{ @hold_last_item_pushed},  @last_record_pushed: #{@last_record_pushed}")
  #puts("* " * 10)
  @hold_last_item_pushed = @last_record_pushed
  sleep 10
end
 
