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

puts ("* " * 20)
puts (" S t a r t   o f   M a i n t e n a n c e ")
puts ("* " * 20)

items_to_delete = CaptureCache.where(:processed => true)
start_time = DateTime.now

  puts ("Will now remove #{items_to_delete.count} processed packets from local database.  Started: @#{Time.now.strftime("%d/%m/%Y %H:%M:%S")}")

items_to_delete.each do |item|
  item.destroy
end
puts("Recurring Delete of Processed packets is complete. Ended @#{Time.now.strftime("%d/%m/%Y %H:%M:%S")}. Took #{DateTime.now.to_i - start_time.to_i} seconds.")
        
puts ("* " * 20)
