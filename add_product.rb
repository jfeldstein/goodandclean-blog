#!/usr/bin/env ruby
require 'date'
require 'fileutils'
require 'yaml'

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

# Get product information from user
puts "Enter Amazon product URL:"
amazon_url = gets.chomp

puts "Enter product title:"
title = gets.chomp

puts "Enter product category:"
category = gets.chomp

puts "Enter product rating (1-5, can use decimals like 4.5):"
rating = gets.chomp.to_f

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
rating: #{rating}
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