---
layout: article
navbar: false
---

## Blog


  <ul class="posts">
    {% for post in site.posts %}
      <li>
        <h2><a class="post-link" href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a></h2>
        <span class="post-date">{{ post.date | date: "%b %-d, %Y" }}</span>
        <p>{{ post.description }}</p>
      </li>
    {% else %}
    <p>No posts yet</p>
    {% endfor %}
  </ul>

  <p class="rss-subscribe">subscribe <a href="{{ "/feed.xml" | prepend: site.baseurl }}">via RSS</a></p>