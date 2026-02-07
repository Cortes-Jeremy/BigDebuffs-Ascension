#target photoshop

app.preferences.rulerUnits = Units.PIXELS;

// =========================
// DOCUMENT
// =========================
if (app.documents.length === 0) {
    var doc = app.documents.add(1024, 1024, 72, "SquareCooldownAtlas", NewDocumentMode.RGB, DocumentFill.TRANSPARENT);
} else {
    var doc = app.activeDocument;
}

// =========================
// CONFIG
// =========================
var cells = 20;
var cellSize = doc.width / cells;
var frames = 400;

var startAngle = 90; // 0=right, 90=down, 180=left, 270=up

var fillOpacity = 100;
var strokeOpacity = 0;
var strokeWidth = 1;

// Colors
var black = new SolidColor();
black.rgb.red = black.rgb.green = black.rgb.blue = 255;

// =========================
// MATH UTILS
// =========================
function degToRad(d) {
    return d * Math.PI / 180;
}

// Intersection rayon ↔ carré
function raySquareIntersection(cx, cy, dx, dy, left, right, top, bottom) {
    var tMin = Infinity;

    if (dx !== 0) {
        var tx1 = (left - cx) / dx;
        var tx2 = (right - cx) / dx;
        if (tx1 > 0) tMin = Math.min(tMin, tx1);
        if (tx2 > 0) tMin = Math.min(tMin, tx2);
    }

    if (dy !== 0) {
        var ty1 = (top - cy) / dy;
        var ty2 = (bottom - cy) / dy;
        if (ty1 > 0) tMin = Math.min(tMin, ty1);
        if (ty2 > 0) tMin = Math.min(tMin, ty2);
    }

    return [cx + dx * tMin, cy + dy * tMin];
}

// =========================
// OPTIMIZED GENERATION
// =========================

// Création de deux calques uniques
var fillLayer = doc.artLayers.add();
fillLayer.opacity = fillOpacity;
fillLayer.name = "CooldownFill";

var strokeLayer = doc.artLayers.add();
strokeLayer.opacity = strokeOpacity;
strokeLayer.name = "CooldownStroke";

for (var i = 0; i < frames; i++) {

    var row = Math.floor(i / cells);
    var col = i % cells;

    var x0 = col * cellSize;
    var y0 = row * cellSize;

    var cx = x0 + cellSize / 2;
    var cy = y0 + cellSize / 2;

    var left = x0;
    var right = x0 + cellSize;
    var top = y0;
    var bottom = y0 + cellSize;

    var percent = (i + 1) / frames;
    var maxAngle = percent * 360;

    var steps = 200;
    var points = [[cx, cy]];

    for (var s = 0; s <= steps; s++) {
        var angle = degToRad(startAngle + maxAngle * (s / steps));
        var dx = Math.cos(angle);
        var dy = Math.sin(angle);

        var p = raySquareIntersection(cx, cy, dx, dy, left, right, top, bottom);
        points.push(p);
    }

    if (points.length < 3) continue;

    // Créer la sélection
    doc.selection.select(points);

    // Remplir sur le calque unique
    doc.activeLayer = fillLayer;
    doc.selection.fill(black);

    // Tracer sur le calque unique
    doc.activeLayer = strokeLayer;
    doc.selection.stroke(black, strokeWidth, StrokeLocation.INSIDE);

    // Deselect
    doc.selection.deselect();
}
