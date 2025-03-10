#!/usr/bin/env ruby
require 'httparty'
require 'mailgun-ruby'
require 'json'
require 'uri'

# Configure email with Mailgun
def send_email(report)
  return if report.empty?
  
  # Initialize Mailgun client
  mailgun = Mailgun::Client.new(ENV['MAILGUN_API_KEY'])
  
  # Create a more detailed HTML report
  html_body = "<h1>Amazon Link Check Report</h1>"
  
  # Summary section
  html_body += "<h2>Summary</h2>"
  html_body += "<p>Found #{report.size} problematic links out of all links checked.</p>"
  
  # Group issues by status code
  status_groups = report.group_by { |item| item[:status] || 'Connection Error' }
  
  html_body += "<h3>Issues by status:</h3>"
  html_body += "<ul>"
  status_groups.each do |status, items|
    html_body += "<li><strong>#{status}:</strong> #{items.size} links</li>"
  end
  html_body += "</ul>"
  
  # Detailed table of all issues
  html_body += "<h2>Detailed Report</h2>"
  html_body += "<table border='1' cellpadding='5' style='border-collapse: collapse;'>"
  html_body += "<tr style='background-color: #f2f2f2;'><th>URL</th><th>Status</th><th>Error</th></tr>"
  
  report.each do |link|
    # Determine row color based on status
    row_color = case
                when link[:status].nil? then "#ffcccc" # Connection errors - light red
                when link[:status] >= 500 then "#ffffcc" # Server errors - light yellow
                when link[:status] >= 400 then "#ffddcc" # Client errors - light orange
                else "#ffffff" # Other (shouldn't occur) - white
                end
    
    html_body += "<tr style='background-color: #{row_color};'>"
    html_body += "<td><a href='#{link[:url]}'>#{link[:url]}</a></td>"
    html_body += "<td>#{link[:status] || 'Error'}</td>"
    html_body += "<td>#{link[:error] || 'N/A'}</td>"
    html_body += "</tr>"
  end
  html_body += "</table>"
  
  # Add troubleshooting information
  html_body += "<h2>Troubleshooting</h2>"
  html_body += "<ul>"
  html_body += "<li><strong>404 Not Found:</strong> The product may have been removed. Consider finding a replacement product.</li>"
  html_body += "<li><strong>503 Service Unavailable:</strong> Amazon may be temporarily blocking requests or experiencing issues. Retry manually.</li>"
  html_body += "<li><strong>Connection Error:</strong> Could not connect to the server. Possible network issues or URL format problems.</li>"
  html_body += "</ul>"
  
  html_body += "<p>Please review these links and update them if necessary.</p>"
  
  # Create email message
  message_params = {
    from: "Good&Clean Link Checker <postmaster@jfeldstein.mailgun.org>",
    to: 'jfeldstein@gmail.com',
    subject: "Good&Clean.shop: #{report.size} Broken Amazon Links Found",
    html: html_body
  }
  
  # Send email
  begin
    response = mailgun.send_message(ENV['MAILGUN_DOMAIN'], message_params)
    puts "Email report sent to jfeldstein@gmail.com (Mailgun response: #{response.to_h[:message]})"
  rescue => e
    puts "Failed to send email: #{e.message}"
  end
end

# Find all Amazon links in the repository
def find_amazon_links
  links = []
  
  # Search for Amazon links in _products directory
  Dir.glob('_products/*.md').each do |file|
    content = File.read(file)
    if content =~ /amazon_link:\s*(https:\/\/www\.amazon\.com\/[^\s]+)/
      links << $1.strip
    end
  end
  
  # Search for Amazon links in _posts directory
  Dir.glob('_posts/*.md').each do |file|
    content = File.read(file)
    content.scan(/\[.*?\]\((https:\/\/www\.amazon\.com\/[^\)]+)\)/) do |match|
      links << match[0].strip
    end
    # Also look for product links that might indirectly link to Amazon
    content.scan(/\[.*?\]\(\/products\/([^\)]+)\)/) do |match|
      product_slug = match[0].strip
      # Check if this product exists and has an Amazon link
      product_file = "_products/#{product_slug}.md"
      if File.exist?(product_file)
        product_content = File.read(product_file)
        if product_content =~ /amazon_link:\s*(https:\/\/www\.amazon\.com\/[^\s]+)/
          links << $1.strip
        end
      end
    end
  end
  
  # Return unique links
  links.uniq
end

# Check a link with retries for 5xx errors
def check_link(url, max_retries=5)
  retries = 0
  begin
    uri = URI.parse(url)
    response = HTTParty.head(url, 
      headers: {
        'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
      },
      timeout: 10,
      follow_redirects: true
    )
    
    status = response.code
    
    # If we get a 5xx error, retry
    if status >= 500 && status < 600 && retries < max_retries
      retries += 1
      puts "Got #{status} for #{url}, retrying (#{retries}/#{max_retries})..."
      sleep(2 * retries) # Exponential backoff
      retry
    end
    
    # Return the status
    if status >= 200 && status < 400
      puts "✅ #{url} - Status: #{status}"
      return { url: url, status: status, error: nil }
    else
      puts "❌ #{url} - Status: #{status}"
      return { url: url, status: status, error: "HTTP error: #{status}" }
    end
    
  rescue => e
    puts "❌ #{url} - Error: #{e.message}"
    # If the error is potentially temporary and we haven't retried too many times
    if (e.message.include?('execution expired') || e.message.include?('timed out')) && retries < max_retries
      retries += 1
      puts "Retrying (#{retries}/#{max_retries})..."
      sleep(2 * retries) # Exponential backoff
      retry
    end
    return { url: url, status: nil, error: e.message }
  end
end

# Main execution
puts "Starting Amazon link check..."
links = find_amazon_links
puts "Found #{links.size} Amazon links to check."

results = []
links.each do |link|
  results << check_link(link)
end

# Filter for issues
issues = results.select { |r| r[:status].nil? || r[:status] >= 400 }

if issues.empty?
  puts "All links are working correctly!"
else
  puts "Found #{issues.size} links with issues:"
  issues.each do |issue|
    puts "- #{issue[:url]}: #{issue[:status] || 'Error'} - #{issue[:error]}"
  end
  
  # Create a JSON report file for local debugging purposes
  File.write('link_check_report.json', JSON.pretty_generate(issues))
  puts "Debug report saved to link_check_report.json (not uploaded as an artifact)"
  
  # Send email report with detailed information
  send_email(issues)
end 