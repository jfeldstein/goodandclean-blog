#!/usr/bin/env ruby

# First, try to create a very simple text-based placeholder image
# This creates a text file that looks like an image when opened, but isn't a real image
# For our purposes, this is enough since we just need a file for Jekyll to reference

placeholder_content = <<-CONTENT
PRODUCT IMAGE
COMING SOON

This is a placeholder for a product image 
that could not be downloaded from eBay.
CONTENT

# Create the directory if it doesn't exist
require 'fileutils'
FileUtils.mkdir_p('assets/images')

# Write the placeholder content to the file
File.write('assets/images/product-placeholder.jpg', placeholder_content)

puts "Created a simple placeholder image at assets/images/product-placeholder.jpg" 