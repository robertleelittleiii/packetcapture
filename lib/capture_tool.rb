#!/usr/bin/env ruby

def sniffDNSPacket()
  pkt_array = PacketFu::Capture.new(:iface => $APP_CONFIG["interface"], :start=> true, :filter=>$APP_CONFIG["ip_filter"], :save=>true)
	caught = false
	while caught == false do
		pkt_array.stream.each do |p|
			pkt = PacketFu::Packet.parse(p)
			puts("-" * 80)
			# puts(pkt.dissect)
			# puts(pkt.payload)
			#pkt.payload.split("").each do |item|
			#	puts("*"* 80)
			#	puts("inspect:" + item.inspect)
			#	puts("item:--------")
			#	puts(item)
			#	puts("hex:--------")
			#	puts(item.unpack('H*')[0])
			#	# puts("size: " + item.size.to_s)	
			#end
			#puts(pkt.payload[2].inspect)
			#puts(pkt.payload[3].inspect)
      #puts(pkt.payload[2][0].inspect)
      #puts(pkt.payload[3].hex.chr)
			#  puts(pkt.payload[2].to_s(16))

      # $dnscount = pkt.payload[2].to_s(base=16)+pkt.payload[3].to_s(base=16)
			$dnscount = pkt.payload[2] + pkt.payload[3]
			#puts($dnscount.unpack('H*')[0])
			#puts($dnscount == "\x01\x00")
			$domainName = ""
      if $dnscount == "\x01\x00" then
				puts("building DNS Name")
				g=10
				while g < 100
					if pkt.payload[g]  == "\x03" or pkt.payload[g]  == "\x06" or pkt.payload[g]  == "\x10" then
						# puts("Start Domain")
						$domainName += "."
					elsif pkt.payload[g] == "\x03" then
						# puts("next domain")
						break
					else    
						# puts("build Domain Name [" + g.to_s + "]")
						# puts(pkt.payload[g].to_s)
						$domainName += pkt.payload[g].to_s if pkt.payload[g].to_s >= "\x20" 
					end
					g+=1
				end
        puts($domainName)
        packet_info = CaptureCache.new
        packet_info.packet_type = $APP_CONFIG["ip_filter"]
        packet_info.captured_data = $domainName
        packet_info.raw_data = pkt.payload
        packet_info.save
      else
        puts("DNS port accessed, but a query not a response (ignored)")
			end
		
    
		end
	end
end

# sniffDNSPacket()
