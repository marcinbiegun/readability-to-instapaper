#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"

require "mechanize"
require "json"
require "pry"
require "yaml"

CONFIG = YAML.load_file(File.expand_path(File.dirname(__FILE__)) + '/config.yml')
readability_data = {}
http = Mechanize.new

begin
  http.get('http://readability.com') do |login_page|
    # Sign in
    puts "Readability: signing in"
    login_page.form_with(:action => 'https://www.readability.com/readers/login/') do |form|
      form.username = CONFIG["readability_email"]
      form.password = CONFIG["readability_password"]
    end.click_button
    # Download data
    puts "Readability: downloading data"
    readability_data = JSON.parse(http.get('http://www.readability.com/n23/export/json/').content)
    puts "Readability: downloaded #{readability_data.size} articles"
  end
rescue => e
  puts "Readability: ERROR - #{e}"
  puts "Readability: ERROR - check if data in the config file is correct"
  exit
end



http.get('http://www.instapaper.com/user/login') do |login_page|
  begin
    # Sign in
    puts "Instapaper: signing in"
    login_page.form_with(:action => '/user/login') do |form|
      form.username = CONFIG["instapaper_email"]
      form.password = CONFIG["instapaper_password"]
    end.click_button

    # Add articles
    i = 0
    readability_data.reverse.each do |readability_article|
      i += 1
      http.get('http://www.instapaper.com/edit') do |add_page|
        add_page.form_with(:action => '/edit') do |form|
          form["bookmark[url]"] = readability_article["article__url"]
        end.click_button
        puts "Instapaper: added article #{i}/#{readability_data.size}"
      end
    end # readability_data
  rescue => e
    puts "Instapaper: ERROR - #{e}"
    puts "Instapaper: ERROR - check if data in the config file is correct"
    exit
  end
end # get login_page

puts "Done!"
