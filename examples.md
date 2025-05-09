---
layout: tintoy
navbar: false
title: Tin Toy
js: /_tintoy/code.js
imagebase: "/images/blog/tintoy/"
---


## Some example shaders
I have converted a few interesting shaders written for shadertoy.com to metal so that they will run within Tin Toy. The attributions of the original creators is included in the tops of the files and I would like to thank them for creating and sharing such interesting work on shadertoy.com; they all given me much inspiration and have taught me a lot.


<ul class="shader-block">

{% include posts/shader-block.html name='Rain' link='/demos/tintoy/rain.metal' image='rain.png' gif='rain.gif' %}
{% include posts/shader-block.html name='Plasma ball' link='/demos/tintoy/PlasmaBall.metal' image='plasma.png' gif='plasma.gif' %}
{% include posts/shader-block.html name='Warp' link='/demos/tintoy/warp-vortex.metal' image='warp.png' gif='warp.gif' %}
{% include posts/shader-block.html name='Zebra-valley' link='/demos/tintoy/zebra-valley-2b.metal' image='zebra.png' gif='zebra.gif' %}
{% include posts/shader-block.html name='Ascii renderer' link='/demos/tintoy/ascii-renderer.metal' image='ascii.png' %}


</ul>