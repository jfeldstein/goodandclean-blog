#!/usr/bin/env ruby
require 'date'
require 'fileutils'
require 'yaml'
require 'open-uri'
require 'nokogiri'

# Function to generate a slug from a title
def slugify(title)
  title.downcase.strip.gsub(/[^\w\s-]/, '').gsub(/\s+/, '-')
end

# Function to extract ASIN from Amazon URL
def extract_asin(url)
  if url =~ /amazon\.com.*\/dp\/([A-Z0-9]{10})/
    return $1
  elsif url =~ /amazon\.com.*\/gp\/product\/([A-Z0-9]{10})/
    return $1
  else
    puts "Could not extract ASIN from URL. Using URL as is."
    return nil
  end
end

# Function to fetch product title and category from Amazon
def fetch_product_details(url)
  begin
    user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36"
    html_content = URI.open(url, "User-Agent" => user_agent).read
    doc = Nokogiri::HTML(html_content)
    
    # Extract title
    title = doc.css('#productTitle').text.strip
    
    # Extract category (this might vary depending on Amazon's HTML structure)
    # Try to get the main category from breadcrumbs
    category = doc.css('#wayfinding-breadcrumbs_feature_div ul li:not(:last-child) a').first&.text&.strip
    
    # If breadcrumbs not found, try alternative methods
    if category.nil? || category.empty?
      category = doc.css('.a-link-normal.a-color-tertiary').first&.text&.strip
    end
    
    # If still no category, check product details
    if category.nil? || category.empty?
      doc.css('.a-section.a-spacing-small.a-spacing-top-small td.a-span3').each do |td|
        if td.text.strip.downcase.include?('category')
          category = td.next_element.text.strip
          break
        end
      end
    end
    
    # Default category if unable to extract
    category = "Uncategorized" if category.nil? || category.empty?
    
    return { title: title, category: category }
  rescue => e
    puts "Error fetching product details: #{e.message}"
    return { title: nil, category: nil }
  end
end

# Get product URL from user
puts "Enter Amazon product URL:"
amazon_url = gets.chomp

# Extract product details
puts "Fetching product details from Amazon..."
product_details = fetch_product_details(amazon_url)

# Use fetched title or ask user if not found
if product_details[:title].nil? || product_details[:title].empty?
  puts "Could not fetch title automatically. Please enter product title:"
  title = gets.chomp
else
  title = product_details[:title]
  puts "Title: #{title}"
  puts "Is this title correct? (Y/n):"
  response = gets.chomp.downcase
  if response == 'n'
    puts "Please enter the correct product title:"
    title = gets.chomp
  end
end

# Use fetched category or ask user if not found
if product_details[:category].nil? || product_details[:category].empty?
  puts "Could not fetch category automatically. Please enter product category:"
  category = gets.chomp
else
  category = product_details[:category]
  puts "Category: #{category}"
  puts "Is this category correct? (Y/n):"
  response = gets.chomp.downcase
  if response == 'n'
    puts "Please enter the correct product category:"
    category = gets.chomp
  end
end

puts "Enter comma-separated list of pros (e.g. 'Good battery life, Durable, Easy to use'):"
pros_input = gets.chomp
pros = pros_input.split(',').map(&:strip)

puts "Enter comma-separated list of cons (e.g. 'Expensive, Heavy, Limited color options'):"
cons_input = gets.chomp
cons = cons_input.split(',').map(&:strip)

# Generate slug from title
slug = slugify(title)

# Extract ASIN if possible and format the Amazon URL
asin = extract_asin(amazon_url)
if asin
  amazon_link = "https://www.amazon.com/dp/#{asin}/"
else
  amazon_link = amazon_url
end

# Create product file content
product_content = <<~CONTENT
---
layout: product
title: "#{title}"
slug: #{slug}
category: #{category}
image: /assets/images/product-placeholder.jpg
amazon_link: #{amazon_link}
pros:
#{pros.map { |pro| "  - #{pro}" }.join("\n")}
cons:
#{cons.map { |con| "  - #{con}" }.join("\n")}
---

Write your detailed product review here. Include your personal experience, product features, and who would benefit from this product.

## Product Features

- Feature 1: 
- Feature 2: 
- Feature 3: 
- Feature 4: 

## My Experience

Share your personal experience with this product here.

## Who Is This For?

Describe the ideal user for this product.

## Value for Money

Discuss whether this product provides good value for its price.
CONTENT

# Ensure the _products directory exists
FileUtils.mkdir_p('_products') unless Dir.exist?('_products')

# Write the product file
File.write(File.join('_products', "#{slug}.md"), product_content)

puts "\nProduct added successfully!"
puts "Product file created at: _products/#{slug}.md"
puts "\nTo add an image for this product, place it at: assets/images/#{slug}.jpg"
puts "Then update the image path in the product file."
puts "\nRemember to update your affiliate ID in _config.yml" 