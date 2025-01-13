---
title: "3D Slicer Training Compendium"
subtitle: Step-by-step how-to guides with matching sample datasets to help you effectively use 3D Slicer for a variety of tasks.
layout: page
permalink:
---

<h2 id="introduction">Introduction</h2>
<p>
This page provides hands-on tutorials designed to help users navigate and utilize the 3D Slicer environment for different applications. Each tutorial includes a structured walkthrough with sample datasets to facilitate learning.</p>
{% include notification.html
  status="is-info"
  message="For detailed reference documentation, please visit the [Slicer manual on ReadTheDocs](https://slicer.readthedocs.io/en/latest/).
" %}
{% include notification.html
  status="is-warning"
  message="Some tutorials are based on older 3D Slicer versions and are being updated for Slicer 5.0. While the core concepts remain relevant, some interface elements or features may have changed.
" %}

{% for category in site.data.tutorials %}
<h2 id="{{ category.id }}">{{ category.title }}</h2>

<div class="columns is-multiline">
  {% assign count = category.tutorials | size %}
  {% assign column_class = 'is-half' %}
  {% if count == 1 %}
    {% assign column_class = 'is-full' %}
  {% endif %}
  {% for tutorial in category.tutorials %}
  <div class="column {{ column_class }}">
    <div class="box tutorial">
      <div class="columns">
        <div class="column is-two-thirds">
          <div class="has-text-centered-mobile">
            {% if tutorial.id %}
            <h3 id="{{ tutorial.id }}">{{ tutorial.id }}: {{ tutorial.title }}</h3>
            {% else %}
            <h3>{{ tutorial.title }}</h3>
            {% endif %}
            <p>{{ tutorial.description }}</p>
          </div>
          <ul>
            {% if tutorial.details.audience %}
            <li><strong>Audience:</strong> {{ tutorial.details.audience }}</li>
            {% endif %}
            {% if tutorial.details.length %}
            <li><strong>Length:</strong> {{ tutorial.details.length }}</li>
            {% endif %}
            {% if tutorial.details.modules %}
            <li><strong>Modules:</strong> {{ tutorial.details.modules }}</li>
            {% endif %}
            {% if tutorial.details.authors %}
            <li><strong>Authors:</strong>
              {% for author in tutorial.details.authors %}
                {{ author }}{% unless forloop.last %}, {% endunless -%}
              {% endfor %}
            </li>
            {% endif %}
            {% if tutorial.datasets %}
            <li><strong>Data:</strong>
            {% for dataset in tutorial.datasets %}
              <a href="{{ dataset.url }}" class="is-link" target="_blank">{{ dataset.label }}</a>{% unless forloop.last %}, {% endunless -%}
            {% endfor %}
            </li>
            {% endif %}
          </ul>
          {% if tutorial.details.application_version %}
          <div>Tutorial based of <i>{{ tutorial.details.application_version }}</i></div>
          {% endif %}
        </div>
        <div class="column">
          {% if tutorial.image %}
          <figure class="image">
            <img src="{{ tutorial.image }}" alt="{{ tutorial.title }}">
          </figure>
          {% endif %}
        </div>
      </div>
      <div class="has-text-centered-mobile">
        {% if tutorial.links %}
        <p>
          {% for link in tutorial.links %}
          <a href="{{ link.url }}" class="button is-link" target="_blank">{{ link.label }}</a>
          {% endfor %}
        </p>
        {% endif %}
      </div>
    </div>
  </div>
  {% endfor %}
</div>
{% endfor %}

<div class="box" markdown="1">
## Other Tutorial Collections

- [SlicerMorph Tutorials](https://github.com/SlicerMorph/Tutorials)
- SlicerIGT [User Tutorials](https://www.slicerigt.org/wp/user-tutorials/) and [Developer Tutorials](https://www.slicerigt.org/wp/developer-tutorial/)
- [SlicerRT Tutorials](https://www.slicer.org/wiki/Documentation/Nightly/Extensions/SlicerRT#Tutorials)

</div>
