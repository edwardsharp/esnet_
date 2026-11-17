var displayWidth = document.documentElement.clientWidth;
var displayHeight = window.innerHeight;

window.addEventListener("resize", function () {
  displayWidth = document.documentElement.clientWidth;
  displayHeight = window.innerHeight;

  if (!window.Processing) return;

  document.querySelectorAll("canvas[data-processing-sources]").forEach(function (canvas) {
    var sketch = Processing.getInstanceById(canvas.id);
    if (sketch) sketch.size(displayWidth, displayHeight);
  });
});
