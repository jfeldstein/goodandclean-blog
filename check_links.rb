#!/usr/bin/env ruby
# check_links.rb - Standalone Amazon link checker
# Usage: ruby check_links.rb [--email] [--verbose]

require 'net/http'
require 'uri'
require 'json'
require 'optparse'

# Parse command line options
options = {email: false, verbose: false}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby check_links.rb [options]"
  
  opts.on("--email", "Send email report to jfeldstein@gmail.com") do
    options[:email] = true
  end
  
  opts.on("--verbose", "Show detailed progress") do
    options[:verbose] = true
  end
  
  opts.on("-h", "--help", "Show this help message") do
    puts opts
    exit
  end
end.parse!

puts "Good&Clean.shop Amazon Link Checker"
puts "---------------------------------"

# Configure email if the mail gem is available and email option is enabled
if options[:email]
  begin
    require 'mail'
    email_available = true
    puts "Email reporting enabled"
  rescue LoadError
    puts "Warning: Mail gem not installed. Run 'gem install mail' to enable email reporting."
    email_available = false
  end
end

# Find all Amazon links in the repository
def find_amazon_links
  links = []
  
  # Search for Amazon links in _products directory
  Dir.glob('_products/*.md').each do |file|
    content = File.read(file)
    if content =~ /amazon_link:\s*(https:\/\/www\.amazon\.com\/[^\s]+)/
      links << {url: $1.strip, source: file}
    end
  end
  
  # Search for Amazon links in _posts directory
  Dir.glob('_posts/*.md').each do |file|
    content = File.read(file)
    content.scan(/\[.*?\]\((https:\/\/www\.amazon\.com\/[^\)]+)\)/) do |match|
      links << {url: match[0].strip, source: file}
    end

    # Also look for product links that might indirectly link to Amazon
    content.scan(/\[.*?\]\(\/products\/([^\)]+)\)/) do |match|
      product_slug = match[0].strip
      # Check if this product exists and has an Amazon link
      product_file = "_products/#{product_slug}.md"
      if File.exist?(product_file)
        product_content = File.read(product_file)
        if product_content =~ /amazon_link:\s*(https:\/\/www\.amazon\.com\/[^\s]+)/
          links << {url: $1.strip, source: file, referenced_product: product_slug}
        end
      end
    end
  end
  
  # Return unique links (by URL)
  links.uniq { |link| link[:url] }
end

# Check a link with retries for 5xx errors
def check_link(link_data, max_retries=5, verbose=false)
  url = link_data[:url]
  source = link_data[:source]
  retries = 0
  
  begin
    uri = URI.parse(url)
    request = Net::HTTP::Head.new(uri)
    request["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', read_timeout: 10) do |http|
      http.request(request)
    end
    
    status = response.code.to_i
    
    # Follow redirects (up to 5 levels)
    redirect_count = 0
    while response.code.to_i >= 300 && response.code.to_i < 400 && redirect_count < 5
      redirect_url = response['location']
      redirect_uri = URI.parse(redirect_url.start_with?('http') ? redirect_url : "#{uri.scheme}://#{uri.host}#{redirect_url}")
      
      if verbose
        puts "Following redirect to #{redirect_uri}"
      end
      
      redirect_request = Net::HTTP::Head.new(redirect_uri)
      redirect_request["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
      
      response = Net::HTTP.start(redirect_uri.host, redirect_uri.port, use_ssl: redirect_uri.scheme == 'https', read_timeout: 10) do |http|
        http.request(redirect_request)
      end
      
      redirect_count += 1
      status = response.code.to_i
    end
    
    # If we get a 5xx error, retry
    if status >= 500 && status < 600 && retries < max_retries
      retries += 1
      puts "Got #{status} for #{url}, retrying (#{retries}/#{max_retries})..."
      sleep(2 * retries) # Exponential backoff
      retry
    end
    
    # Return the status
    if status >= 200 && status < 400
      print verbose ? "✅ " : "."
      $stdout.flush
      return { url: url, source: source, status: status, error: nil }
    else
      print verbose ? "❌ " : "E"
      $stdout.flush
      return { url: url, source: source, status: status, error: "HTTP error: #{status}" }
    end
    
  rescue => e
    print verbose ? "❌ " : "E"
    $stdout.flush
    
    # If the error is potentially temporary and we haven't retried too many times
    if (e.message.include?('execution expired') || e.message.include?('timed out')) && retries < max_retries
      retries += 1
      puts "Retrying #{url} (#{retries}/#{max_retries})..." if verbose
      sleep(2 * retries) # Exponential backoff
      retry
    end
    
    return { url: url, source: source, status: nil, error: e.message }
  end
end

# Send email report
def send_email(report)
  return if report.empty?
  
  # Check if we have the required environment variables
  unless ENV['EMAIL_USERNAME'] && ENV['EMAIL_PASSWORD']
    puts "Error: EMAIL_USERNAME and EMAIL_PASSWORD environment variables are required for sending emails."
    puts "Example usage: EMAIL_USERNAME=your.email@gmail.com EMAIL_PASSWORD=your_app_password ruby check_links.rb --email"
    return false
  end
  
  Mail.defaults do
    delivery_method :smtp, {
      address: "smtp.gmail.com",
      port: 587,
      domain: "gmail.com",
      user_name: ENV['EMAIL_USERNAME'],
      password: ENV['EMAIL_PASSWORD'],
      authentication: :plain,
      enable_starttls_auto: true
    }
  end
  
  mail = Mail.new do
    from    ENV['EMAIL_USERNAME']
    to      'jfeldstein@gmail.com'
    subject 'Good&Clean.shop: Amazon Link Check Report'
    
    html_part do
      content_type 'text/html; charset=UTF-8'
      body "<h1>Amazon Link Check Report</h1>
           <p>The following links have issues:</p>
           <table border='1' cellpadding='5'>
           <tr><th>URL</th><th>Source File</th><th>Status</th><th>Error</th></tr>
           #{report.map { |link| "<tr><td>#{link[:url]}</td><td>#{link[:source]}</td><td>#{link[:status]}</td><td>#{link[:error]}</td></tr>" }.join}
           </table>
           <p>Please review these links and update them if necessary.</p>"
    end
  end
  
  mail.deliver!
  puts "Email report sent to jfeldstein@gmail.com"
  return true
end

# Main execution
puts "Scanning repository for Amazon links..."
links = find_amazon_links
puts "Found #{links.size} Amazon links to check."

results = []
puts "Checking links#{options[:verbose] ? ' (verbose mode)' : ''}:"
links.each_with_index do |link, index|
  if options[:verbose]
    puts "[#{index+1}/#{links.size}] Checking #{link[:url]} (from #{link[:source]})"
  end
  results << check_link(link, 5, options[:verbose])
end
puts "\nLink check completed."

# Filter for issues
issues = results.select { |r| r[:status].nil? || r[:status] >= 400 }

if issues.empty?
  puts "✅ All links are working correctly!"
else
  puts "\n❌ Found #{issues.size} links with issues:"
  issues.each do |issue|
    puts "- #{issue[:url]} (in #{issue[:source]}): #{issue[:status] || 'Error'} - #{issue[:error]}"
  end
  
  # Create a JSON report file
  File.write('link_check_report.json', JSON.pretty_generate(issues))
  puts "Report saved to link_check_report.json"
  
  # Send email report if requested
  if options[:email] && email_available
    send_email(issues)
  end
end

# Return success/failure exit code
exit(issues.empty? ? 0 : 1) 