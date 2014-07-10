#!/usr/bin/env ruby

require 'date'
require 'open-uri'
require 'json'
require 'csv'

appearances = []

news_and_local_id = "11Kk-vaj_MKGZdImP54YEh-KxhUMjzDINtZLohfnvbLU"
network_radio_id  = "1qqXnT1--bKn2qXigFqoaH09T9vBm4dXlQNQgTjS60tE"

spreadsheet_url = "https://spreadsheets.google.com/feeds/list/::ID::/::SHEET::/public/values?alt=json"

month_number = Time.now.strftime("%m").to_i # .gsub(/^0/, '')

# Example news and local sheet: https://spreadsheets.google.com/feeds/list/11Kk-vaj_MKGZdImP54YEh-KxhUMjzDINtZLohfnvbLU/5/public/values?alt=json

csv = CSV.generate do |csv|
  csv << ["name", "date", "event", "role", "fee"]
  for id in [news_and_local_id, network_radio_id]
    for i in 1..month_number
      url = spreadsheet_url.gsub(/::ID::/, id).gsub(/::SHEET::/, i.to_s)
      # puts url
      open(url) do |f|
        unless f.status[0] == "200"
          STDERR.puts "Cannot load sheet #{i}: #{f.status}"
          # TODO Fail nicely
        else
          data = JSON.parse(f.read)
          if ! data["feed"]["entry"].nil? # There are entries for this month
            data["feed"]["entry"].each do |f|
              name = f["gsx$name"]["$t"].gsub(/\s*$/, '')
              # Date is in [M]M/[D]D/YYYY format ... simply awful.
              (month, day, year) = f["gsx$date"]["$t"].split("/")
              day = "0#{day}" if day.length == 1
              month = "0#{month}" if month.length == 1
              date = "#{year}-#{month}-#{day}"
              event = f["gsx$event"]["$t"]
              role = f["gsx$role"]["$t"]
              fee = f["gsx$fee"]["$t"]
              next unless name.length > 0
              csv << [name, date, event, role, fee]
              # appearances << {
              #   "name" => name,
              #   "event" => event,
              #   "date" => date,
              #   "role" => role,
              #   "fee" => fee
              # }
            end
          end
        end
      end
    end
  end
end

puts csv

# Total paid appearances

paid = Hash.new(0)

appearances.each do |a|
  next unless a["fee"] == "Paid"
  paid[a["name"]] += 1
end

paid.each do |name, count|
  puts "#{name}: #{count}"
end


# https://developers.google.com/google-apps/spreadsheets/


# http://spreadsheets.google.com/feeds/list/key/worksheet/public/values?alt=json-in-script&callback=myFunc



# https://spreadsheets.google.com/feeds/list/1qqXnT1--bKn2qXigFqoaH09T9vBm4dXlQNQgTjS60tE/6/public/values
