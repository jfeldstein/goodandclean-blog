#!/usr/bin/env ruby
require 'date'
require 'fileutils'
require 'yaml'
require 'open-uri'
require 'nokogiri'
require 'down'
require 'optparse'

# Parse command line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: add_product.rb [options]"
  
  opts.on("-u", "--url URL", "Amazon product URL") do |url|
    options[:amazon_url] = url
  end
  
  opts.on("-t", "--title TITLE", "Override product title") do |title|
    options[:title] = title
  end
  
  opts.on("-c", "--category CATEGORY", "Override product category") do |category|
    options[:category] = category
  end
  
  opts.on("-p", "--pros PROS", "Comma-separated list of pros") do |pros|
    options[:pros] = pros
  end
  
  opts.on("-n", "--cons CONS", "Comma-separated list of cons") do |cons|
    options[:cons] = cons
  end
  
  opts.on("-i", "--[no-]image", "Download image (default: true)") do |download_image|
    options[:download_image] = download_image
  end
  
  opts.on("--non-interactive", "Run without prompting for input") do
    options[:non_interactive] = true
  end
  
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!

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

# Function to download an image and save it to assets/images
def download_image(image_url, slug)
  begin
    puts "Downloading image from #{image_url}..."
    
    # Create the directory if it doesn't exist
    FileUtils.mkdir_p('assets/images')
    
    # Generate the local file path
    local_path = "assets/images/#{slug}.jpg"
    
    # Download the image
    Down.download(image_url, destination: local_path)
    
    puts "Image saved to #{local_path}"
    return "/assets/images/#{slug}.jpg"
  rescue => e
    puts "Error downloading image: #{e.message}"
    return nil
  end
end

# Function to fetch product title, category, and image URL from Amazon
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
    
    # Extract the product image URL
    # Try the main image first
    image_url = doc.css('#landingImage').attr('src')&.value
    
    # If not found, try the main image data-old-hires attribute
    if image_url.nil?
      image_url = doc.css('#landingImage').attr('data-old-hires')&.value
    end
    
    # If still not found, try other image elements
    if image_url.nil?
      image_url = doc.css('#imgBlkFront').attr('src')&.value || 
                 doc.css('#ebooksImgBlkFront').attr('src')&.value ||
                 doc.css('img.a-dynamic-image').first&.attr('src')&.value
    end
    
    return { title: title, category: category, image_url: image_url }
  rescue => e
    puts "Error fetching product details: #{e.message}"
    return { title: nil, category: nil, image_url: nil }
  end
end

# Function to get user input with default value
def get_input_with_default(prompt, default, non_interactive = false)
  if non_interactive
    puts "#{prompt} (using default: #{default})"
    return default
  else
    puts "#{prompt} (default: #{default}):"
    response = gets.chomp
    return response.empty? ? default : response
  end
end

# Function to confirm with default yes in non-interactive mode
def confirm_with_default(prompt, non_interactive = false)
  if non_interactive
    puts "#{prompt} (using default: Y)"
    return true
  else
    puts "#{prompt} (Y/n):"
    response = gets.chomp.downcase
    return response != 'n'
  end
end

# Get Amazon URL
if options[:amazon_url]
  amazon_url = options[:amazon_url]
else
  if options[:non_interactive]
    puts "Error: Amazon URL is required in non-interactive mode"
    puts "Use: add_product.rb --url AMAZON_URL --non-interactive"
    exit 1
  else
    puts "Enter Amazon product URL:"
    amazon_url = gets.chomp
  end
end

# Extract product details
puts "Fetching product details from Amazon..."
product_details = fetch_product_details(amazon_url)

# Use fetched title or override with provided title
if options[:title]
  title = options[:title]
  puts "Using provided title: #{title}"
elsif product_details[:title] && !product_details[:title].empty?
  title = product_details[:title]
  puts "Title: #{title}"
  unless options[:non_interactive]
    if !confirm_with_default("Is this title correct?")
      puts "Please enter the correct product title:"
      title = gets.chomp
    end
  end
else
  title = get_input_with_default("Could not fetch title automatically. Please enter product title", "Untitled Product", options[:non_interactive])
end

# Use fetched category or override with provided category
if options[:category]
  category = options[:category]
  puts "Using provided category: #{category}"
elsif product_details[:category] && !product_details[:category].empty?
  category = product_details[:category]
  puts "Category: #{category}"
  unless options[:non_interactive]
    if !confirm_with_default("Is this category correct?")
      puts "Please enter the correct product category:"
      category = gets.chomp
    end
  end
else
  category = get_input_with_default("Could not fetch category automatically. Please enter product category", "Uncategorized", options[:non_interactive])
end

# Handle pros
if options[:pros]
  pros_input = options[:pros]
  puts "Using provided pros: #{pros_input}"
else
  pros_input = options[:non_interactive] ? "" : get_input_with_default("Enter comma-separated list of pros (e.g. 'Good battery life, Durable, Easy to use')", "", options[:non_interactive])
end
pros = pros_input.split(',').map(&:strip)

# Handle cons
if options[:cons]
  cons_input = options[:cons]
  puts "Using provided cons: #{cons_input}"
else
  cons_input = options[:non_interactive] ? "" : get_input_with_default("Enter comma-separated list of cons (e.g. 'Expensive, Heavy, Limited color options')", "", options[:non_interactive])
end
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

# Download the product image if available
image_path = "/assets/images/product-placeholder.jpg"  # Default placeholder
if product_details[:image_url]
  puts "Image URL found: #{product_details[:image_url]}"
  # Check if download_image option is set or ask user in interactive mode
  should_download = options.key?(:download_image) ? options[:download_image] : confirm_with_default("Would you like to download this image?", options[:non_interactive])
  
  if should_download
    downloaded_image_path = download_image(product_details[:image_url], slug)
    image_path = downloaded_image_path if downloaded_image_path
  end
end

# Create product file content
product_content = <<~CONTENT
---
layout: product
title: "#{title}"
slug: #{slug}
category: #{category}
image: #{image_path}
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

if image_path == "/assets/images/product-placeholder.jpg"
  puts "\nNo image was downloaded. To add an image for this product, place it at: assets/images/#{slug}.jpg"
  puts "Then update the image path in the product file."
else
  puts "\nProduct image downloaded to: #{image_path}"
end

puts "\nRemember to update your affiliate ID in _config.yml" 