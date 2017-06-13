# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.


def reset_loop()
  
  puts("* * "* 40)
  puts("Starting reset_loop....");
  puts("* * "* 40)
  begin
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
      
        @t2=Thread.new{pushDataToCloud()}
        @t2.priority = 1
        puts("Status is NOW----> : #{@t2.status rescue "Not running!"}")
      
        @last_record_pushed = 0
      end
      puts("* " * 80)
      puts(" Gateway is working, sleeping 30 seconds...")
      puts("values--->  hold_last_item_pushed: #{ @hold_last_item_pushed},  @last_record_pushed: #{@last_record_pushed}")
      puts("* " * 80)
      @hold_last_item_pushed = @last_record_pushed
      sleep 5
    end
  rescue Exception => e  
    puts e.message  
    puts e.backtrace.inspect  
  end
end