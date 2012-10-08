#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"

require "mechanize"
require "json"

readability_data = {}
config = {}
http = Mechanize.new

puts "Enter you Readability username: "
config[:readability_username] = gets.chomp
puts "Enter you Readability password: "
config[:readability_password] = gets.chomp
puts "Enter you Instapaper email: "
config[:instapaper_email] = gets.chomp
puts "Enter you Instapaper password: "
config[:instapaper_password] = gets.chomp

begin
  puts "\nReadability: signing in"
  http.get('https://www.readability.com/readers/login/') do |login_page|
    login_page.form_with(:action => 'https://www.readability.com/readers/login/') do |form|
      form.username = config[:readability_username]
      form.password = config[:readability_password]
    end.click_button

    puts "Readability: downloading data"
    readability_data = JSON.parse(http.get("http://www.readability.com/#{config[:readability_username]}/export/json/").content)
    puts "Readability: downloaded #{readability_data.size} articles"
  end
rescue => e
  puts "Readability: ERROR - #{e}"
  puts "Readability: ERROR - check if your credentails are correct"
  exit
end

http.get('http://www.instapaper.com/user/login') do |login_page|
  begin
    puts "\nInstapaper: signing in"
    login_page.form_with(:action => '/user/login') do |form|
      form.username = config[:instapaper_email]
      form.password = config[:instapaper_password]
    end.click_button

    i = 0
    readability_data.reverse.each do |readability_article|
      i += 1
      http.get('http://www.instapaper.com/edit') do |add_page|
        add_page.form_with(:action => '/edit') do |form|
          form["bookmark[url]"] = readability_article["article__url"]
        end.click_button
        puts "Instapaper: imported article #{i}/#{readability_data.size}"
      end
    end

  rescue => e
    puts "Instapaper: ERROR - #{e}"
    puts "Readability: ERROR - check if your credentails are correct"
    exit
  end
end

puts "\nDone!"
