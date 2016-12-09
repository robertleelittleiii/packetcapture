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

$ipcfg = PacketFu::Utils.whoami?(:iface=>$APP_CONFIG["interface"])
$yourPIAddresquits="192.168.1.4"

#set the app env to development by default.

ENV["AppEnv"] = ENV["AppEnv"].blank? ? "development" : ENV["AppEnv"]

$APP_CONFIG = YAML.load_file($APP_PATH + '/config/app_config.yml')[ENV["AppEnv"]]

# load yaml database config file

$DATABASE_CONF = YAML.load_file($APP_PATH + '/db/config.yml')

Dir[$APP_PATH + '/models/*.rb'].each {|file| require file }


 # ActiveRecord::Base.establish_connection database_conf[ENV["AppEnv"]]

 # ActiveRecord::Base.establish_connection $DATABASE_CONF["cloud_#{ENV["AppEnv"]}"]
 # ActiveRecord::Base.connection.tables

 #       @@ssh_gateway = Net::SSH::Gateway.new('dev.playfootbowl.com', 'bitnami', port: "22") rescue -1

 #      port = @@ssh_gateway.open("127.0.0.1",3306,3307)

 # ActiveRecord::Base.establish_connection $DATABASE_CONF["cloud_#{ENV["AppEnv"]}"]
 # ActiveRecord::Base.connection.tables
 

# Open Connection to cloud server for data push
RawPacketData.open_ssh_connection


puts ($APP_CONFIG.inspect)
puts ($DATABASE_CONF.inspect)
puts (ENV["AppEnv"])
puts ($ipcfg.inspect)
  

require "capture_tool"
require "push_tool"

puts(" Start of main program! ")
#
## To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

# sniffDNSPacket()


t1=Thread.new{sniffDNSPacket()}
t1.priority = 100
t2=Thread.new{pushDataToCloud()}
t2.priority = 1

t1.join
t2.join