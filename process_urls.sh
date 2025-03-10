#!/bin/bash

# List of Amazon URLs to process
URLS=(
  "https://www.amazon.com/dp/B08JSTP3HL"
  "https://www.amazon.com/dp/B0CS3B7MD8"
  "https://www.amazon.com/dp/B07PDVTMM6"
  "https://www.amazon.com/dp/B0CBTMBNSV"
  "https://www.amazon.com/dp/B0949C3ZNQ"
  "https://www.amazon.com/dp/B000069EYA"
  "https://www.amazon.com/dp/B08R41STGF"
  "https://www.amazon.com/dp/B000GCRWCG"
  "https://www.amazon.com/dp/B07PHV9WZ5"
  "https://www.amazon.com/dp/B07ZB74ZLL"
  "https://www.amazon.com/dp/B07FC8MTPK"
  "https://www.amazon.com/dp/B004R1J464"
  "https://www.amazon.com/dp/B07ZV1P83W"
  "https://www.amazon.com/dp/B08DDBNXXG"
  "https://www.amazon.com/SandPiper-Premium-Natural-Sandbox-Texture/dp/B0DDV2816W"
)

# Process each URL
for url in "${URLS[@]}"; do
  echo "Processing: $url"
  ruby add_product.rb --url "$url" --non-interactive
  echo "Completed: $url"
  echo "------------------------"
  # Add a small delay to avoid overwhelming Amazon with requests
  sleep 3
done

echo "All URLs processed!" 