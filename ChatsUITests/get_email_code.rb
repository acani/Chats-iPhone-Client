#!/usr/bin/env ruby

require 'open-uri'

code = nil

base_url = "http://www.tempinbox.com"
username = 'acani.chats-'+ARGV[0]
path = "/cgi-bin/checkmail.pl?username=#{username}&button=Check+Mail&terms=on&large=1"

10.times do
    break if code

    sleep 5

    open(base_url+path) do |file|
        line = file.each_line.detect { |l| l.include?("Signup") }

        if line.nil?
            break
        end

        path = line[/\/cgi-bin.*$/]

        open(base_url+path) do |file|
            code = file.each_line.detect { |l| l =~ /^\d{4}$/ }
            puts code
        end
    end
end
