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
  
  # Create HTML email body
  html_body = "<h1>Amazon Link Check Report</h1>
           <p>The following links have issues:</p>
           <table border='1' cellpadding='5'>
           <tr><th>URL</th><th>Status</th><th>Error</th></tr>
           #{report.map { |link| "<tr><td>#{link[:url]}</td><td>#{link[:status]}</td><td>#{link[:error]}</td></tr>" }.join}
           </table>
           <p>Please review these links and update them if necessary.</p>"
  
  # Create email message
  message_params = {
    from: "Good&Clean Link Checker <linkcheck@#{ENV['MAILGUN_DOMAIN']}>",
    to: 'jfeldstein@gmail.com',
    subject: 'Good&Clean.shop: Amazon Link Check Report',
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
  
  # Create a JSON report file for GitHub Actions artifact
  File.write('link_check_report.json', JSON.pretty_generate(issues))
  
  # Send email report
  send_email(issues)
end 