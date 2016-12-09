# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

class RawPacketData < ActiveRecord::Base
  
  cattr_accessor :ssh_gateway
 
#  after_initialize  :after_initialize_call
# 
#  def after_initialize_call
#    puts "You have initialized an object!"
#  end
# 
#  def initialize
#    puts "Initialized an object!"
#  end
 
  establish_connection $DATABASE_CONF["cloud_#{ENV["AppEnv"]}"]

  #  def self.establish_connection
  #   puts ("establish_connection called !! ")  
  #   super.establish_connection
  #  end
  #  
  #  
  ##  
  ##  self.table_name  = "raw_packet_data";
  ##  
  ##  self.primary_key = :id
  ##  
  ##  
#  def self.connection
#
#    puts("making connection....")
#   self.open_ssh_connection
#
#    if (super.respond_to?(:connection)) then
#      puts("self.class: ", self.class.to_s)
#      puts("super.class", super.class.to_s)
#      super.connection
#    else
#      puts("self.class: ", self.class.to_s)
#      puts("super.class", super.class.to_s)
#
#    end    
#  end
  
  ##  
#  def open_ssh_connection
#    "puts After Initialization!!!"
#    self.open_ssh_connection
#  end
#  
  def self.open_ssh_connection

    puts("Starting to open SSH Tunnel.")
    ssh_gateway = @@ssh_gateway

    if ssh_gateway.nil?  then
      puts("Opening SSH Gateway!!")
      @@ssh_gateway = Net::SSH::Gateway.new('dev.playfootbowl.com', 'bitnami', port: "22") 
      puts(@@ssh_gateway.inspect)
      if ssh_gateway != -1  then
        port = @@ssh_gateway.open("127.0.0.1",3306,3307)
        puts "You have opened the SSH gateway!!!"
      else
        puts("Gateway failed!!!")
      end
    end

  end
  
end
