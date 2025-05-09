---
layout: tintoy
navbar: false
title: Tin Toy
js: /_tintoy/code.js
imagebase: "/images/blog/tintoy/"
---

<div class="heading-section" markdown="1">
![Icon](/images/projects/tintoy-icon.png)
# Tin Toy
## Metal shaders made easy

<a target="_blank" href="https://testflight.apple.com/join/38YuPtRy">
	<picture>
	  <source srcset="/images/tintoy/mas-dark.svg" media="(prefers-color-scheme: light)"/>
	  <source srcset="/images/tintoy/mas-light.svg"  media="(prefers-color-scheme: dark)"/>
	  <img src="/images/tintoy/mas-dark.svg"/>
	</picture>
</a>
</div>


## Intro
Based upon [shadertoy.com](https://shadertoy.com), Tin Toy allows for the easy creation and experimentation of shaders using Apple Metal on macOS.

![Tin Toy](/images/blog/tintoy/tintoy-rain-vid.gif)


## Example Shaders


<ul class="shader-block">

{% include posts/shader-block.html name='Rain' link='/demos/tintoy/rain.metal' image='rain.png' vid='rain.mp4' %}
{% include posts/shader-block.html name='Plasma ball' link='/demos/tintoy/PlasmaBall.metal' image='plasma.png' vid='plasma.mp4' %}
{% include posts/shader-block.html name='Warp' link='/demos/tintoy/warp-vortex.metal' image='warp.png' vid='warp.mp4' %}
{% include posts/shader-block.html name='Zebra-valley' link='/demos/tintoy/zebra-valley-2b.metal' image='zebra.png' vid='zebra.mp4' %}
{% include posts/shader-block.html name='Ascii renderer' link='/demos/tintoy/ascii-renderer.metal' image='ascii.png' %}


</ul>