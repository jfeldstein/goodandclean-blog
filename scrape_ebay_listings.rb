#!/usr/bin/env ruby
require 'open-uri'
require 'nokogiri'
require 'fileutils'
require 'down'
require 'yaml'
require 'date'
require 'uri'

# Function to generate a slug from a title
def slugify(title)
  title.downcase.strip.gsub(/[^\w\s-]/, '').gsub(/\s+/, '-')
end

# Function to download an image and save it to assets/images
def download_image(image_url, slug)
  begin
    puts "Downloading image from #{image_url}..."
    
    # Create the directory if it doesn't exist
    FileUtils.mkdir_p('assets/images/leatherman')
    
    # Generate the local file path
    local_path = "assets/images/leatherman/#{slug}.jpg"
    
    # Download the image
    Down.download(image_url, destination: local_path)
    
    puts "Image saved to #{local_path}"
    return "/assets/images/leatherman/#{slug}.jpg"
  rescue => e
    puts "Error downloading image: #{e.message}"
    return nil
  end
end

# Function to fetch eBay listings for the store
def fetch_ebay_listings(store_url)
  begin
    puts "Fetching eBay listings from: #{store_url}"
    
    # Do not add any search terms to the URL - use it exactly as provided
    user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36"
    
    puts "Using URL: #{store_url}"
    html_content = URI.open(store_url, "User-Agent" => user_agent).read
    doc = Nokogiri::HTML(html_content)
    
    puts "Loaded eBay page..."
    
    listings = []
    
    # Output the HTML structure for debugging
    # File.write("ebay_debug.html", html_content)
    # puts "Wrote debug HTML to ebay_debug.html"
    
    # Find all listing items - try an alternative selector that works with eBay's current structure
    items = doc.css('li.s-item')
    puts "Found #{items.size} li.s-item elements"
    
    items.each do |item|
      # Debug the item structure
      # puts "Item HTML: #{item.to_html}"
      
      title_element = item.css('.s-item__title')
      price_element = item.css('.s-item__price')
      link_element = item.css('.s-item__link')
      
      # For images, use the data-src attribute which is commonly used for lazy loading
      image_element = item.css('.s-item__image-img')
      image_src = image_element.attr('src')&.value || image_element.attr('data-src')&.value
      
      condition_element = item.css('.SECONDARY_INFO')
      
      if title_element.empty?
        puts "- Skipping item: No title element"
        next
      end
      
      title = title_element.text.strip
      
      # Skip "results matching" header item
      if title.include?("results matching") || title.include?("Shop on eBay")
        puts "- Skipping header item: '#{title}'"
        next
      end
      
      if price_element.empty?
        puts "- Skipping item: No price element for '#{title}'"
        next
      end
      
      if link_element.empty?
        puts "- Skipping item: No link element for '#{title}'"
        next
      end
      
      # Extract data
      price_text = price_element.text.strip
      price = price_text.match(/\$([0-9.]+)/)&.[](1) || "0.00"
      link = link_element.attr('href').value
      condition = condition_element.text.strip
      
      # Allow missing images - just log a warning
      if image_src.nil?
        puts "- Warning: No image for '#{title}' - will use placeholder"
        image_src = "placeholder" # Will be handled during processing
      end
      
      # Add the listing
      puts "- Found item: #{title} - $#{price}"
      listings << {
        title: title,
        price: price,
        link: link,
        image_url: image_src,
        condition: condition.empty? ? "Used" : condition
      }
    end
    
    # If we still can't find listings, try a different selector approach
    if listings.empty?
      puts "Trying alternative selector approach..."
      
      doc.css('.s-item__info').each do |info|
        title_element = info.css('.s-item__title')
        next if title_element.empty?
        
        title = title_element.text.strip
        next if title.include?("results matching") || title.include?("Shop on eBay")
        
        # Find related image by going back up and then down to the image
        item_wrapper = info.parent
        image_element = item_wrapper.css('.s-item__image-img')
        image_src = image_element.attr('src')&.value || image_element.attr('data-src')&.value
        
        price_element = info.css('.s-item__price')
        link_element = item_wrapper.css('.s-item__link')
        condition_element = info.css('.SECONDARY_INFO')
        
        # Only require price and link, not image
        next if price_element.empty? || link_element.empty?
        
        price_text = price_element.text.strip
        price = price_text.match(/\$([0-9.]+)/)&.[](1) || "0.00"
        link = link_element.attr('href').value
        condition = condition_element.text.strip
        
        # If image is missing, use a placeholder
        if image_src.nil?
          puts "- Warning: No image for '#{title}' (alt method) - will use placeholder"
          image_src = "placeholder"
        end
        
        puts "- Found item (alt method): #{title} - $#{price}"
        listings << {
          title: title,
          price: price,
          link: link,
          image_url: image_src,
          condition: condition.empty? ? "Used" : condition
        }
      end
    end
    
    puts "Found #{listings.size} valid listings"
    return listings
  rescue => e
    puts "Error fetching eBay listings: #{e.message}"
    puts e.backtrace.join("\n")
    return []
  end
end

# Create the _leatherman directory if it doesn't exist
FileUtils.mkdir_p('_leatherman') unless Dir.exist?('_leatherman')
FileUtils.mkdir_p('assets/images/leatherman') unless Dir.exist?('assets/images/leatherman')

# Fetch eBay listings - use the exact URL provided by the user
ebay_store_url = "https://www.ebay.com/sch/i.html?_nkw=&_in_kw=1&_ex_kw=&_sacat=0&_udlo=&_udhi=&_ftrt=901&_ftrv=1&_sabdlo=&_sabdhi=&_samilow=&_samihi=&_sadis=15&_stpos=94531-8437&_sargn=-1%26saslc%3D1&_salic=1&_fss=1&_fsradio=%26LH_SpecificSeller%3D1&_saslop=1&_sasl=Goodandclean.shop&_sop=12&_dmd=1&_ipg=50"
listings = fetch_ebay_listings(ebay_store_url)

# Inform if no listings were found
if listings.empty?
  puts "No listings were found from your eBay store."
  puts "This could be due to one of the following reasons:"
  puts "1. The store might not have any active listings"
  puts "2. eBay's page structure might have changed, making our selectors ineffective"
  puts "3. eBay might be blocking our request (anti-scraping measures)"
  puts "\nPlease check your eBay store directly to confirm listings are available."
  exit
end

# Process each listing
listings.each do |listing|
  puts "\nProcessing listing: #{listing[:title]}"
  
  # Generate slug from title
  slug = slugify(listing[:title])
  
  # Download image or use placeholder if image URL is 'placeholder' or download fails
  if listing[:image_url] == "placeholder"
    puts "Using placeholder image for #{listing[:title]}"
    image_path = "/assets/images/product-placeholder.jpg"
  else
    # Try to download the image, but fall back to placeholder if it fails
    image_path = download_image(listing[:image_url], slug)
    if image_path.nil?
      puts "Download failed, using placeholder image for #{listing[:title]}"
      image_path = "/assets/images/product-placeholder.jpg"
    end
  end
  
  # Extract Leatherman model if possible (or use generic description)
  if listing[:title].downcase.include?("leatherman")
    model = listing[:title].match(/Leatherman\s+([^\s,]+)/i)&.[](1) || "Tool"
    
    # Generic features for Leatherman tools
    features = [
      "Stainless steel construction",
      "Compact and portable design",
      "Multiple tools in one",
      "Lifetime warranty"
    ]
    
    description = <<~DESCRIPTION
#{listing[:title]} - A reliable Leatherman multi-tool for everyday tasks.

This premium Leatherman tool features stainless steel construction and multiple built-in tools to help you tackle any job. Perfect for DIY projects, camping, hiking, or keeping in your vehicle for emergencies.

## About This Item

This listing is for a #{listing[:condition].downcase} Leatherman #{model} multi-tool.

## Leatherman Quality

Leatherman Tools are made in the USA and backed by a 25-year warranty. Known for their durability and versatility, Leatherman tools are trusted by professionals and enthusiasts worldwide.
DESCRIPTION
  else
    # For non-Leatherman products
    features = [
      "High quality construction",
      "Durable design",
      "Excellent value",
      "Practical functionality"
    ]
    
    description = <<~DESCRIPTION
#{listing[:title]}

This quality item is available from our eBay store. Check out the listing for full details and specifications.

## About This Item

This listing is for a #{listing[:condition].downcase} item in excellent condition.

## Quality Guarantee

We only sell high-quality items that meet our standards for durability and performance.
DESCRIPTION
  end
  
  # Create content for the product file
  content = <<~CONTENT
---
layout: leatherman
title: "#{listing[:title]}"
slug: #{slug}
price: #{listing[:price]}
condition: #{listing[:condition]}
image: #{image_path}
ebay_link: #{listing[:link]}
features:
#{features.map { |feature| "  - #{feature}" }.join("\n")}
---

#{description}
CONTENT

  # Write the product file
  file_path = File.join('_leatherman', "#{slug}.md")
  File.write(file_path, content)
  
  puts "Created product file at: #{file_path}"
end

puts "\nAll eBay listings processed!"
puts "#{listings.size} products were created." 