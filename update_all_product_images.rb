#!/usr/bin/env ruby
require 'open-uri'
require 'nokogiri'
require 'fileutils'
require 'down'
require 'yaml'

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

# Function to fetch product image URL from Amazon
def fetch_product_image(url)
  begin
    user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36"
    html_content = URI.open(url, "User-Agent" => user_agent).read
    doc = Nokogiri::HTML(html_content)
    
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
    
    return image_url
  rescue => e
    puts "Error fetching product image: #{e.message}"
    return nil
  end
end

# Create the _products directory if it doesn't exist
FileUtils.mkdir_p('_products') unless Dir.exist?('_products')

# Get all product files
product_files = Dir.glob('_products/*.md')

puts "Found #{product_files.size} product file(s)"

# Process each product file
product_files.each do |product_file|
  puts "\nProcessing #{product_file}..."
  
  # Read the file and extract front matter
  content = File.read(product_file)
  
  # Simple front matter parsing
  if content =~ /^---\s*$(.+?)^---\s*$/m
    front_matter = $1
    
    # Extract the amazon_link and slug
    amazon_link = front_matter.match(/amazon_link:\s*(.+)/)&.[](1)&.strip
    slug = front_matter.match(/slug:\s*(.+)/)&.[](1)&.strip
    current_image = front_matter.match(/image:\s*(.+)/)&.[](1)&.strip
    
    if amazon_link && slug
      puts "Found Amazon link: #{amazon_link}"
      puts "Product slug: #{slug}"
      
      # Check if the product is already using a downloaded image
      if current_image && current_image !~ /product-placeholder/
        puts "Product already has a custom image: #{current_image}"
        puts "Skipping..."
        next
      end
      
      # Fetch the image URL
      puts "Fetching image for the product..."
      image_url = fetch_product_image(amazon_link)
      
      if image_url
        puts "Image URL found: #{image_url}"
        image_path = download_image(image_url, slug)
        
        if image_path
          # Update the product file with the new image path
          updated_content = content.gsub(/image:.*$/, "image: #{image_path}")
          
          # Write the updated content back
          File.write(product_file, updated_content)
          
          puts "Updated product with the downloaded image."
        else
          puts "Failed to download the image. No changes made to the product file."
        end
      else
        puts "No image URL found for the product."
      end
    else
      puts "Could not extract Amazon link or slug from front matter."
    end
  else
    puts "Could not parse front matter from #{product_file}."
  end
end

puts "\nAll products processed." 