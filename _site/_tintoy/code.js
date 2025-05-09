

window.onload = function() {
  const videos = document.querySelectorAll(".video-preview")

  videos.forEach(video => {
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

}