"""Extrae las capturas de la app desde el informe PDF del equipo.

Las capturas de `docs/capturas/` son previas a la migración a K-Means. El PDF
`Semillero info-1.pdf` contiene capturas actuales (la de "Zonas" ya muestra
silhouette 0.419 y KMeans), que son las que usan las diapositivas.

Uso:
    python docs/presentacion/extract_pdf_images.py [ruta_al_pdf]
"""

from __future__ import annotations

import sys
from pathlib import Path

import fitz  # PyMuPDF
from PIL import Image

DEFAULT_PDF = Path(r"C:\Users\ASUS\Downloads\Semillero\Semillero info-1.pdf")
OUT_DIR = Path(__file__).resolve().parent / "img"

# page: número de página (1-indexado) -> nombre de salida.
# Se renderiza la página completa y luego se recortan los márgenes en blanco,
# que es más robusto que extraer los objetos incrustados (algunos vienen
# fragmentados o con máscara aparte).
# Estrategia de recorte por figura:
#   "dense"  -> captura de fondo oscuro: se aisla por densidad de pixeles.
#   "blocks" -> contenido claro (escudo, UI blanca): se aisla por bloques de tinta.
FIGURES: dict[int, tuple[str, str]] = {
    1: ("escudo_una.png", "blocks"),         # escudo de la universidad (portada)
    8: ("actions_verde.png", "blocks"),      # GitHub Actions con workflows en verde
    14: ("apk_play_protect.png", "dense"),   # Play Protect: APK legitimo, 47.3 MB
    20: ("home_oscuro.png", "dense"),        # Inicio (tema oscuro), riesgo y 5 pestañas
    21: ("home_claro.png", "blocks"),        # Inicio (tema claro), alerta y 5 pestañas
    22: ("ajustes.png", "dense"),            # Ajustes: umbral y perfiles
    23: ("zonas_kmeans.png", "dense"),       # ⭐ Zonas: 3 clusters, 0.419, KMeans
    25: ("zonas_sandia.png", "dense"),       # Sandia riesgo BAJO
    26: ("chuno.png", "dense"),              # Modulo chuño "En temporada"
    28: ("clima_historico.png", "dense"),    # Graficos de clima historico
}

DPI = 200
# Recorte del pie de figura (las paginas traen texto de "Figura N" abajo).
# Se resuelve recortando bordes casi blancos y luego el bloque de texto inferior.
WHITE_TOLERANCE = 246


def crop_borders(image: Image.Image) -> Image.Image:
    """Recorta los margenes blancos alrededor del contenido."""
    grayscale = image.convert("L")
    mask = grayscale.point(lambda px: 255 if px < WHITE_TOLERANCE else 0)
    bbox = mask.getbbox()
    return image.crop(bbox) if bbox else image


# Los bloques separados por menos de este porcentaje del alto se consideran el
# mismo elemento (evita partir una captura de tema claro por sus espacios internos).
MERGE_GAP_RATIO = 0.025


DENSITY_THRESHOLD = 0.25


def keep_densest_block(image: Image.Image) -> Image.Image:
    """Aisla la captura de fondo oscuro: filas donde la mayoria de pixeles tienen tinta."""
    grayscale = image.convert("L")
    width, height = grayscale.size
    step = max(1, width // 300)
    columns = range(0, width, step)

    dense_rows = [
        (sum(1 for x in columns if grayscale.getpixel((x, y)) < WHITE_TOLERANCE) / len(columns))
        >= DENSITY_THRESHOLD
        for y in range(height)
    ]

    best, start = None, None
    for y, is_dense in enumerate([*dense_rows, False]):
        if is_dense and start is None:
            start = y
        elif not is_dense and start is not None:
            if best is None or (y - start) > (best[1] - best[0]):
                best = (start, y)
            start = None

    return image if best is None else image.crop((0, best[0], width, best[1]))


def keep_largest_block(image: Image.Image) -> Image.Image:
    """Se queda con el bloque de contenido mas alto, descartando el pie de figura.

    Agrupa las filas con tinta en bloques, fusiona los separados por huecos
    pequeños y devuelve el bloque mas alto. Funciona igual con capturas de tema
    oscuro (un bloque solido) que de tema claro o el escudo (varios sub-bloques
    juntos), porque el pie de figura queda separado por un hueco mayor.
    """
    grayscale = image.convert("L")
    width, height = grayscale.size
    step = max(1, width // 300)

    rows_with_ink = [
        any(grayscale.getpixel((x, y)) < WHITE_TOLERANCE for x in range(0, width, step))
        for y in range(height)
    ]

    blocks: list[list[int]] = []
    start = None
    for y, has_ink in enumerate([*rows_with_ink, False]):
        if has_ink and start is None:
            start = y
        elif not has_ink and start is not None:
            blocks.append([start, y])
            start = None

    if not blocks:
        return image

    merge_gap = height * MERGE_GAP_RATIO
    merged = [blocks[0]]
    for block_start, block_end in blocks[1:]:
        if block_start - merged[-1][1] <= merge_gap:
            merged[-1][1] = block_end
        else:
            merged.append([block_start, block_end])

    top, bottom = max(merged, key=lambda block: block[1] - block[0])
    return image.crop((0, top, width, bottom))


def main() -> int:
    pdf_path = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_PDF
    if not pdf_path.exists():
        print(f"No se encontro el PDF: {pdf_path}")
        return 1

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    document = fitz.open(pdf_path)
    zoom = DPI / 72

    for page_number, (filename, mode) in FIGURES.items():
        page = document[page_number - 1]
        pixmap = page.get_pixmap(matrix=fitz.Matrix(zoom, zoom))
        image = Image.frombytes("RGB", (pixmap.width, pixmap.height), pixmap.samples)

        image = crop_borders(image)
        image = keep_densest_block(image) if mode == "dense" else keep_largest_block(image)
        image = crop_borders(image)

        destination = OUT_DIR / filename
        image.save(destination, optimize=True)
        print(f"pag {page_number:>2} -> {filename:<24} {image.size}")

        # La captura completa de GitHub Actions es ilegible proyectada: se guarda
        # ademas un detalle con las primeras corridas, que si se lee desde el fondo.
        if filename == "actions_verde.png":
            width, height = image.size
            # Solo 3 corridas: proyectadas se leen; la vista completa no.
            detail = image.crop(
                (int(width * 0.245), int(height * 0.335), width, int(height * 0.565))
            )
            detail_path = OUT_DIR / "actions_detalle.png"
            detail.save(detail_path, optimize=True)
            print(f"{'':>7} -> {'actions_detalle.png':<24} {detail.size}")

    document.close()
    print(f"\nListo. {len(FIGURES)} imagenes en {OUT_DIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
