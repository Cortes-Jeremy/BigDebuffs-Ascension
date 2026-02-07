#target photoshop

app.preferences.rulerUnits = Units.PIXELS;

// =========================
// CREER LE DOCUMENT SI INEXISTANT
// =========================
if (app.documents.length == 0) {
    var docWidth = 1024;
    var docHeight = 1024;
    var doc = app.documents.add(docWidth, docHeight, 72, "CooldownAtlas", NewDocumentMode.RGB, DocumentFill.TRANSPARENT);
} else {
    var doc = app.activeDocument;
}

// =========================
// CONFIGURATION
// =========================

var fillOpacity = 100;   // 0-100%
var strokeOpacity = 0; // 0-100%
var strokeWidth = 1;    // px

// Angle de départ du cooldown
var startAngle = 90;

//
var cells = 20;
var cellSize = doc.width / cells;  // 51.2 px
var frames = cells * cells;       // 400 frames

// Couleur principale du cooldown
var fillColor = new SolidColor();
fillColor.rgb.red = 255;
fillColor.rgb.green = 255;
fillColor.rgb.blue = 255;

// Couleur bordure
var strokeColor = new SolidColor();
strokeColor.rgb.red = 255;
strokeColor.rgb.green = 255;
strokeColor.rgb.blue = 255;

// =========================
// UTILS
// =========================
function degToRad(deg) {
    return deg * Math.PI / 180;
}

// =========================
// GENERATION DES FRAMES
// =========================
for (var i = 0; i < frames; i++) {
    var row = Math.floor(i / cells);
    var col = i % cells;
    var xOffset = col * cellSize;
    var yOffset = row * cellSize;

    // -------------------------
    // Calque remplissage
    // -------------------------
    var fillLayer = doc.artLayers.add();
    fillLayer.name = "FrameFill_" + (i+1);
    fillLayer.kind = LayerKind.NORMAL;
    fillLayer.opacity = fillOpacity;

    var cx = xOffset + cellSize/2;
    var cy = yOffset + cellSize/2;
    var radius = cellSize/2;

    var angleDeg = ((i+1) / frames) * 360;
    var points = 200;
    var pathPoints = [];
    pathPoints.push([cx, cy]);

    for (var j = 0; j <= points; j++) {
        var a = degToRad(startAngle + (angleDeg / points) * j);
        var px = cx + radius * Math.cos(a);
        var py = cy + radius * Math.sin(a);
        pathPoints.push([px, py]);
    }
    pathPoints.push([cx, cy]);

    doc.selection.select(pathPoints);
    doc.selection.fill(fillColor);
    doc.selection.deselect();

    // -------------------------
    // Calque bordure
    // -------------------------
    var strokeLayer = doc.artLayers.add();
    strokeLayer.name = "FrameBorder_" + (i+1);
    strokeLayer.kind = LayerKind.NORMAL;
    strokeLayer.opacity = strokeOpacity;

    doc.selection.select(pathPoints);
    doc.selection.stroke(strokeColor, strokeWidth, StrokeLocation.INSIDE);
    doc.selection.deselect();
}
