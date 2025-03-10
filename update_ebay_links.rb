#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

# This script allows you to update the eBay links for existing product files
# It reads in a mapping of product slugs to eBay links and updates the corresponding files

# ==========================================
# CONFIGURATION: Add your link updates here
# ==========================================

link_updates = {
  # Format: 'product-slug' => 'new-ebay-link'
  'a--retired-leatherman-juice-c2-1st-gen-1-red-rare-look' => 'https://www.ebay.com/itm/284346264414',
  
  # Add more product updates as needed:
  # 'product-slug-2' => 'https://www.ebay.com/itm/new-item-number-2',
  # 'product-slug-3' => 'https://www.ebay.com/itm/new-item-number-3',
}

# ==========================================
# Process each file update
# ==========================================

puts "eBay Link Update Script"
puts "======================="
puts "This script will update eBay links in your product files."
puts "Found #{link_updates.size} link updates to process."

updated_count = 0

link_updates.each do |slug, new_link|
  file_path = "_leatherman/#{slug}.md"
  
  if !File.exist?(file_path)
    puts "⚠️ File not found: #{file_path}"
    next
  end
  
  # Read the file content
  content = File.read(file_path)
  
  # Extract front matter
  if content =~ /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
    front_matter = $1
    
    # Find current eBay link
    if front_matter =~ /ebay_link: (.*?)(\n|$)/
      current_link = $1.strip
      
      # Only update if the link is different
      if current_link != new_link
        # Update the link
        updated_front_matter = front_matter.gsub(/ebay_link: (.*?)(\n|$)/, "ebay_link: #{new_link}\\2")
        updated_content = content.gsub(front_matter, updated_front_matter)
        
        # Write the updated content back to the file
        File.write(file_path, updated_content)
        
        puts "✅ Updated #{slug}: #{current_link} → #{new_link}"
        updated_count += 1
      else
        puts "ℹ️ No change needed for #{slug} (already has correct link)"
      end
    else
      puts "⚠️ Could not find ebay_link in #{file_path}"
    end
  else
    puts "⚠️ Could not parse front matter in #{file_path}"
  end
end

puts "\nUpdate complete! #{updated_count} files were updated."
puts "Remember to restart your Jekyll server to see the changes." 