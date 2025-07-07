---
layout: tintoy
navbar: false
title: Tin Toy
js: /_tintoy/code.js
imagebase: "/images/blog/tintoy/"
---

<div class="heading-section" markdown="1">
<canvas id="myCanvas" width="300" height="300"></canvas>
# Tin Toy
## Metal shaders made easy


<div class="dual-column">

<a class="column-left" target="_blank" href="https://apps.apple.com/us/app/tin-toy/id6737349612">
	<picture>
	  <source srcset="/images/tintoy/mas-dark.svg" media="(prefers-color-scheme: light)"/>
	  <source srcset="/images/tintoy/mas-light.svg"  media="(prefers-color-scheme: dark)"/>
	  <img src="/images/tintoy/mas-dark.svg" alt="Download on the Mac App Store"/>
	</picture>
</a>


<a class="column-right" target="_blank" href="https://testflight.apple.com/join/38YuPtRy">
	<picture>
	  <source srcset="/images/tintoy/app-store-dark.svg" media="(prefers-color-scheme: light)"/>
	  <source srcset="/images/tintoy/app-store-light.svg"  media="(prefers-color-scheme: dark)"/>
	  <img src="/images/tintoy/app-store-dark.svg" alt="Download on the App Store"/>
	</picture>
</a>

</div>

![Tin Toy](/images/blog/tintoy/All-devices-A.png)

</div>



Based upon [shadertoy.com](https://shadertoy.com), Tin Toy allows for the easy creation and experimentation of shaders using Apple Metal on macOS.


{% include app-feature-section.html 
    reverse   = false
	title     = "Edit & debug your shaders in real-time"
	content   = "Edit your shaders and recompile manually or automatically. View errors and apply suggested fixes easily"
	image     = "images/projects/editor.png" 
	image_alt = "A screenshot of the Tin Toy app, on macOS, showing the editor with errors and a suggestion for automatically fixing a common issue"
%}


{% include app-feature-section.html 
    reverse   = true
	title     = "Easily use custom textures in your shaders"
	content   = "Use custom images, videos, and the device's camera as a texture input"
	image     = "images/projects/custom-textures.png" 
	image_alt = "A screenshot of the Tin Toy app, on macOS, showing a popover where custom textures can be selected; in this case a Rick Astley music video"
%}

{% include app-feature-section.html 
    reverse   = false
	title     = "Easily understand your shaders"
	content   = "Select which stage of the render to view, or all at once to see exactly what is happening"
	image     = "images/projects/shader-selection.png" 
	image_alt = "A screenshot of the Tin Toy app, on macOS, set to show the outputs of the all buffer stages at once and with the menu to select the current view open and showing all options; in this case the main buffer, all 4 intermediate buffers, and the mixed option which is selected"
%}

{% include app-feature-section.html 
    reverse   = true
	title     = "Capture frames for analysis in Xcode"
	content   = "You can capture a GPU trace for a frame to analysis using XCode's Metal debugger to understand exactly what your shaders are doing"
	image     = "images/projects/xcode-capture.png" 
	image_alt = "A screenshot of an Xcode window showing the debugging of a Metal frame captured from the Tin Toy app"
%}

{% include app-feature-section.html 
    reverse   = false
	title     = "Screenshot frames or record to video"
	content   = "Capture your shaders as images or video for use elsewhere"
	image     = "images/projects/recording.png" 
	image_alt = "A screenshot of the Quicktime app showing a video recording of a shader captured from the Tin Toy app"
%}
