def pushDataToCloud()

  puts("* * "* 10)
  puts("Starting pushDataToCloud...");
  puts("* * "* 10)

  if !@is_push_running then
    
    begin
      while (true)
      
        @is_push_running = true
      
        items_to_push = CaptureCache.where(:processed => false)
 
        # uncomment for sample data to push.
        #    items_to_push = CaptureCache.where(:captured_data => "xml-sample")
    
        if items_to_push.size == 0 then
          last_item_pushed = 0
          puts("")
        else
          break_and_restart_process=false
      
          items_to_push.each do |item|
            last_item_pushed = item.id
     
            begin
          
              Timeout::timeout(10) do
                new_item = RawPacketData.new do |ni|
                  ni.packet_type = item.packet_type
                  ni.captured_data = item.captured_data
                  ni.raw_data = item.raw_data
                  ni.location = $APP_CONFIG["location"] || "not known: " + $ipcfg.to_s
                  ni.time_stamp = item.created_at
                  ni.processed = false
                end
            
                new_items_saved = new_item.save
                
                item.processed = true
                packet_item_saved = item.save
                
                if new_items_saved then
                  last_item_pushed = 0
                else
                  break_and_restart_process = true
                end
              end
        
            rescue
              puts("! " * 10)
              puts("SSH and Database Connection failed.  Trying to Reastablish")
              puts("! " * 10)
              begin 
                RawPacketData.reestablish_ssh_connection
              rescue
            
              end
              # puts("! " * 10)
              break_and_restart_process = true
            end
            #  puts("*" * 80)
            puts("record: #{item.id} processed (#{item.captured_data})")
            #  puts("*" * 80)
            if break_and_restart_process then
              break
            end
            @last_record_pushed = last_item_pushed
          end
        end
  
    
        sleep(1)
        puts("running...")
      end
    rescue => e
      puts("!-ERROR-! "*4)
      puts ("pushDataToCloud Failed with following Error: #{e.message} @#{Time.now.strftime("%d/%m/%Y %H:%M:%S")}" )
      puts e.inspect
      puts e.backtrace
      puts("!-ERROR-! "*4)

    end
  end
end