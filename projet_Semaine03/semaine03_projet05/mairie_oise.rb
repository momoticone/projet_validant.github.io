require 'google_drive'
require 'rubygems'
require 'nokogiri'
require 'open-uri'

OISE_URL = "http://annuaire-des-mairies.com/oise.html"

session = GoogleDrive::Session.from_config("config.json")


$worksheet = session.spreadsheet_by_title("mairie_oise").worksheets[0]

def set_worksheet
	$worksheet[1, 1] = "Ville"
	$worksheet[1, 2] = "Adresse email"
	$worksheet.save
end

set_worksheet

def get_the_email_of_a_townhal_from_its_webpage(url)
	page = Nokogiri::HTML(open(url))
	email = page.xpath('//table/tr[3]/td/table/tr[1]/td[1]/table[4]/tr[2]/td/table/tr[4]/td[2]/p/font')
	#puts email.text
	email.text
end

def get_all_the_urls_of_oise_townhalls(url)
	towns_mail_list = Hash.new()
	page = Nokogiri::HTML(open(url))
	page.xpath('//table/tr[2]/td/table/tr/td/p/a').each do |town|
		town_name = town.text.downcase
		proper_town_name = town_name.capitalize
		town_name = town_name.split(' ').join('-')
		url = "http://annuaire-des-mairies.com/60/#{town_name}.html"
		towns_mail_list[proper_town_name.to_sym] = get_the_email_of_a_townhal_from_its_webpage(url)
      
	end
	counter = 2
	towns_mail_list.each do |key, value|
		$worksheet[counter, 1] = key
		$worksheet[counter, 2] = value
		counter += 1
		$worksheet.save
	end

end


get_all_the_urls_of_oise_townhalls(OISE_URL)