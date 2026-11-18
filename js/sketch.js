var displayWidth = document.documentElement.clientWidth;
var displayHeight = window.innerHeight;

document.addEventListener("DOMContentLoaded", function () {
  // register before processing's DOMContentLoaded initializer loads the sketchz
  // attach displayDensity library to the sketch for handling high-DPI displayz
  Processing.registerLibrary("displayDensity", {
    attach: function (sketch) {
      sketch.externals.sketch.onLoad = function () {
        var canvas = sketch.externals.canvas;
        var context = canvas.getContext("2d");
        var setTransform = context.setTransform.bind(context);
        var size = sketch.size;
        var density = 1;

        // processing resets the transform for backgrounds and resetMatrix()
        context.setTransform = function (a, b, c, d, e, f) {
          setTransform(a * density, b * density, c * density,
            d * density, e * density, f * density);
        };

        function resize(width, height) {
          density = window.devicePixelRatio || 1;
          sketch.size = size;
          sketch.size(Math.round(width * density), Math.round(height * density));
          size = sketch.size;
          sketch.size = resize;
          sketch.width = width;
          sketch.height = height;
          canvas.style.width = width + "px";
          canvas.style.height = height + "px";
          sketch.resetMatrix();
        }

        sketch.size = resize;
      };
    }
  });

  document.querySelectorAll("canvas[data-processing-sources]").forEach(function (canvas) {
    var startTouch = null;
    var direction = null;
    var dragging = false;

    function mouse(type, touch) {
      canvas.dispatchEvent(new MouseEvent(type, {
        bubbles: true,
        cancelable: true,
        clientX: touch.clientX,
        clientY: touch.clientY,
        button: 0,
        buttons: type === "mouseup" ? 0 : 1,
        view: window
      }));
    }

    function press(touch) {
      mouse("mousemove", touch);
      mouse("mousedown", touch);
    }

    function reset() {
      if (dragging) mouse("mouseup", startTouch);
      startTouch = null;
      direction = null;
      dragging = false;
    }

    // keep processing's touch adapter from cancelling page scrolling.
    canvas.addEventListener("touchstart", function (event) {
      event.stopImmediatePropagation();
      reset();
      if (event.touches.length === 1) startTouch = event.touches[0];
    }, { capture: true, passive: true });

    canvas.addEventListener("touchmove", function (event) {
      event.stopImmediatePropagation();
      if (event.touches.length !== 1) {
        reset();
        return;
      }
      if (!startTouch) return;
      var touch = event.touches[0];
      if (!direction) {
        var dx = Math.abs(touch.clientX - startTouch.clientX);
        var dy = Math.abs(touch.clientY - startTouch.clientY);
        if (Math.max(dx, dy) < 8) return;
        direction = dx > dy ? "horizontal" : "vertical";
      }
      if (direction === "vertical") return;
      if (event.cancelable) event.preventDefault();
      if (!dragging) {
        press(startTouch);
        dragging = true;
      }
      mouse("mousemove", touch);
    }, { capture: true, passive: false });

    canvas.addEventListener("touchend", function (event) {
      event.stopImmediatePropagation();
      if (!startTouch) return;
      if (direction !== "vertical") {
        // suppress the browser's duplicate mouse events after a handled touch.
        if (event.cancelable) event.preventDefault();
        if (!dragging) press(startTouch);
        mouse("mouseup", event.changedTouches[0]);
        dragging = false;
      }
      reset();
    }, { capture: true, passive: false });

    canvas.addEventListener("touchcancel", function (event) {
      event.stopImmediatePropagation();
      reset();
    }, { capture: true, passive: true });
  });
});

window.addEventListener("resize", function () {
  displayWidth = document.documentElement.clientWidth;
  displayHeight = window.innerHeight;

  if (!window.Processing) return;

  document.querySelectorAll("canvas[data-processing-sources]").forEach(function (canvas) {
    var sketch = Processing.getInstanceById(canvas.id);
    if (sketch) sketch.size(displayWidth, displayHeight);
  });
});
