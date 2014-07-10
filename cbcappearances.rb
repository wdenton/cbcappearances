#!/usr/bin/env ruby

# This file is part of CBC Appearances.
#
# CBC Appearances is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# CBC Appearances is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with CBC Appearances.  If not, see <http://www.gnu.org/licenses/>.
#
# Copyright 2014 William Denton

# https://developers.google.com/google-apps/spreadsheets/
# https://spreadsheets.google.com/feeds/list/1qqXnT1--bKn2qXigFqoaH09T9vBm4dXlQNQgTjS60tE/6/public/values

require 'date'
require 'open-uri'
require 'json'
require 'csv'

appearances = []

news_and_local_id = "11Kk-vaj_MKGZdImP54YEh-KxhUMjzDINtZLohfnvbLU"
network_radio_id  = "1qqXnT1--bKn2qXigFqoaH09T9vBm4dXlQNQgTjS60tE"

spreadsheet_url = "https://spreadsheets.google.com/feeds/list/::ID::/::SHEET::/public/values?alt=json"

month_number = Time.now.strftime("%m").to_i

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

# # Total paid appearances

# paid = Hash.new(0)

# appearances.each do |a|
#   next unless a["fee"] == "Paid"
#   paid[a["name"]] += 1
# end

# paid.each do |name, count|
#   puts "#{name}: #{count}"
# end
