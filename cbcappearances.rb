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

# require 'date'
require 'open-uri'
require 'nokogiri'
# require 'json'
require 'csv'

url = "http://www.cbc.ca/appearances/"

appearances_csv = CSV.generate do |csv|
  csv << ["name", "date", "event", "role", "fee"]

  open(url) do |f|
    unless f.status[0] == "200"
      STDERR.puts "Cannot load sheet #{i}: #{f.status}"
    # TODO Fail nicely
    else
      doc = Nokogiri::HTML(f.read)
      data_tbody = doc.css("//div[class='data-content']/table/tbody")
      data_tbody.css("/tr").each do |tr|
        name  = tr.css("/td")[0].text.strip
        date  = tr.css("/td")[1].text.strip
        event = tr.css("/td")[2].text.strip
        role  = tr.css("/td")[3].text.strip
        fee   = tr.css("/td")[4].text.strip
        # Date is in [M]M/[D]D/YYYY format ... simply awful.
        (month, day, year) = date.split("/")
        day = "0#{day}" if day.length == 1
        month = "0#{month}" if month.length == 1
        iso_date = "#{year}-#{month}-#{day}"
        csv << [name, iso_date, event, role, fee]
      end
    end
  end

end

puts appearances_csv
