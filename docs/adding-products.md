# Adding Products to Good&Clean.shop

This guide explains how to add new products to the Good&Clean.shop website using the automated GitHub Actions workflow.

## Using the GitHub Actions Workflow (For Non-Technical Users)

### Step 1: Navigate to Actions Tab

Go to the GitHub repository and click on the "Actions" tab at the top.

![GitHub Actions Tab](https://docs.github.com/assets/cb-25535/mw-1440/images/help/repository/actions-tab.webp)

### Step 2: Select the "Add New Product" Workflow

Locate and click on the "Add New Product" workflow in the left sidebar.

### Step 3: Run the Workflow

Click the "Run workflow" dropdown button, then:

1. Enter the Amazon product URL (required)
   - This should be a direct product link from Amazon (example: https://www.amazon.com/dp/B08JSTP3HL)

2. Optional: Enter a custom product title
   - If left blank, the title will be extracted automatically from Amazon

3. Optional: Enter a custom category
   - If left blank, the category will be extracted automatically from Amazon

4. Optional: Enter product pros
   - Enter as a comma-separated list (example: "Durable, Waterproof, Easy to use")

5. Optional: Enter product cons
   - Enter as a comma-separated list (example: "Expensive, Heavy")

6. Click the green "Run workflow" button

### Step 4: Wait for Completion

The workflow will:
- Extract product information from Amazon
- Download the product image
- Create the product file
- Commit the changes to the repository
- Deploy the updated website

This process typically takes 1-2 minutes to complete.

### Step 5: Verify the New Product

After the workflow completes, your new product will be automatically published to the website. You can view it by:

1. Going to the website: https://jfeldstein.github.io/goodandclean.shop/
2. Navigating to the products section
3. Finding your newly added product

## Troubleshooting

### Invalid Amazon URL

If the workflow fails, the most common reason is an invalid Amazon URL. Make sure:
- The URL is a direct link to an Amazon product
- The URL contains a product ID (looks like: B08JSTP3HL)
- The product is publicly accessible

### Image Download Issues

Sometimes Amazon product images may not be downloadable. In this case:
1. The product will still be added, but with a placeholder image
2. You can manually upload an image later if needed

### Need Help?

If you encounter any issues with adding products, please contact the site administrator for assistance. 