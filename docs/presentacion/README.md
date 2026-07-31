# Diapositivas de la exposición

`FrostPuno_Joseph.pptx` — 7 diapositivas para la parte de Joseph (apertura y cierre).
Se acompaña de `FrostPuno_Joseph.pdf` como **respaldo** para la exposición presencial.

| # | Diapositiva | Momento |
|---|---|---|
| 1 | Portada | inicio |
| 2 | Una helada, dos caras (el problema) | apertura |
| 3 | En produccion, no una maqueta | apertura |
| 4 | Cuatro piezas conectadas (arquitectura) | apertura |
| 5 | Nadie escribio la regla (el modelo) | transición a Juan |
| 6 | Lo que el sistema todavia no hace | cierre |
| 7 | Lo que entregamos + Gracias | cierre |

Guion hablado: [`../guiones/00_JOSEPH_apertura_y_cierre.md`](../guiones/00_JOSEPH_apertura_y_cierre.md).

## Regenerar

```bash
python docs/presentacion/extract_pdf_images.py     # capturas -> img/
node   docs/presentacion/build_slides_joseph.js    # -> FrostPuno_Joseph.pptx
```

El script de extracción toma las capturas del informe en PDF del equipo (las de
`docs/capturas/` son previas a la migración a K-Means y mostrarían el modelo antiguo).
Si el PDF está en otra ruta: `python docs/presentacion/extract_pdf_images.py <ruta.pdf>`.

Para exportar el PDF de respaldo:

```bash
soffice --headless --convert-to pdf --outdir docs/presentacion docs/presentacion/FrostPuno_Joseph.pptx
```

## Notas de diseño

- Paleta tomada de la app (`app_flutter/lib/core/theme/app_colors.dart`): navy `0D1B2A`,
  hielo `E0FBFC`, ámbar `EE6C4D`, teal `1F6F78`.
- Estructura oscuro–claro–oscuro: portada y cierre en navy, contenido en claro.
- Franja lateral con el nombre de la sección como motivo repetido.
- Las rutas de las imágenes están en la constante `IMAGES` al inicio del script: para
  cambiar una captura basta con reemplazar el archivo en `img/` y regenerar.
