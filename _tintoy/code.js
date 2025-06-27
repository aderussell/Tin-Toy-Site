

window.onload = function() {
  const videos = document.querySelectorAll(".video-preview")

  videos.forEach(video => {
    video.pause()

    video.addEventListener("mouseover", function () {
      this.play()
    })
    
    video.addEventListener("mouseout", function () {
      this.pause()
    })
    
    video.addEventListener("touchstart", function () {
      this.play()
    })
    
    video.addEventListener("touchend", function () {
      this.pause()
    })
  })



    // Get the canvas
    const canvas = document.getElementById("myCanvas");
    const gl = canvas.getContext("webgl2");

    // Only continue if WebGL is available
    if (!gl) {
        const img = document.createElement('img');
        img.src = '/images/projects/tintoy-icon.png';
        canvas.parentNode.replaceChild(img, canvas);
        return;
    }

    const ratio = window.devicePixelRatio;
    var width = canvas.width;
    var height = canvas.width;
    canvas.width = width * ratio;
    canvas.height = height * ratio;
    canvas.style.width = width + "px";
    canvas.style.height = height + "px";

    // Initialize the GL context
    
    var shaderProgram = setup(gl, canvas);

    function render(time) {
  
      var timeLocation = gl.getUniformLocation(shaderProgram, "iTime");
      gl.uniform1f(timeLocation, time / 1000.0);

      gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);

      window.requestAnimationFrame(render);
    }

    window.requestAnimationFrame(render);
}