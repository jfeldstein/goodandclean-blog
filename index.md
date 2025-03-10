---
layout: default
title: Recommended Products
---

# Recommended Products

Browse our carefully selected product recommendations for all your needs.

<div class="product-grid">
  {% for product in site.products %}
    <div class="product-card">
      <a href="{{ product.url | relative_url }}">
        <img src="{{ product.image | relative_url }}" alt="{{ product.title }}" />
        <h3>{{ product.title }}</h3>
        <p class="category">{{ product.category }}</p>
        
        {% if product.pros.size > 0 %}
          <div class="pros">
            <strong>Pros:</strong>
            <ul>
              {% for pro in product.pros limit:2 %}
                <li>{{ pro }}</li>
              {% endfor %}
            </ul>
          </div>
        {% endif %}
        
        <div class="view-details">View Details →</div>
      </a>
    </div>
  {% endfor %}
</div> 