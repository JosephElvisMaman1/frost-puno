# Entrega del semillero

| Archivo | Contenido |
|---|---|
| `paper_frostpuno.pdf` | Paper en formato IEEE (5 paginas) |
| `codigo_fuente.pdf` | Codigo fuente del proyecto (89 paginas, 105 archivos) |
| `paper_frostpuno.tex` | Fuente LaTeX del paper |
| `build_codigo_pdf.py` | Generador del PDF de codigo a partir del repositorio |
| `fig/` | Figuras del paper |

## Regenerar

```bash
# Paper (dos pasadas para las referencias cruzadas)
cd docs/paper && pdflatex paper_frostpuno.tex && pdflatex paper_frostpuno.tex

# Codigo fuente (requiere XeLaTeX por los simbolos fuera de Latin-1)
python docs/paper/build_codigo_pdf.py
cd docs/paper && xelatex codigo_fuente.tex
```

El codigo fuente completo y su historial estan en
https://github.com/JosephElvisMaman1/frost-puno
