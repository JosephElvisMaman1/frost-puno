"""Genera el PDF con el codigo fuente del proyecto para la entrega del semillero.

Recorre los archivos versionados del repositorio, agrupados por subsistema, y
produce un documento LaTeX con numeracion de lineas e indice por archivo.

Uso:
    python docs/paper/build_codigo_pdf.py
"""

from __future__ import annotations

import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT_TEX = Path(__file__).resolve().parent / "codigo_fuente.tex"

# Orden de presentacion por subsistema. Solo codigo propio del proyecto.
SECCIONES: list[tuple[str, list[str]]] = [
    ("Pipeline de aprendizaje automatico", ["ml_pipeline/"]),
    ("Servicio backend", ["backend_fastapi/"]),
    ("Cliente Flutter", ["app_flutter/lib/"]),
    ("Integracion continua", [".github/workflows/"]),
    ("Configuracion de despliegue", ["render.yaml", "supabase/"]),
]

EXTENSIONES = {".py", ".dart", ".yml", ".yaml", ".sql"}

LENGUAJE = {
    ".py": "Python",
    ".dart": "Java",   # resaltado aproximado, Dart no viene en listings
    ".yml": "bash",
    ".yaml": "bash",
    ".sql": "SQL",
}

PREAMBULO = r"""\documentclass[10pt,a4paper]{article}
% Se compila con XeLaTeX: el codigo fuente contiene simbolos fuera de Latin-1.
\usepackage[spanish,es-noquoting]{babel}
\usepackage{fontspec}
\setmonofont{Consolas}[Scale=MatchLowercase]
\usepackage[margin=2cm]{geometry}
\usepackage{listings}
\usepackage{xcolor}
\usepackage{fancyhdr}
\usepackage{hyperref}
\hypersetup{colorlinks=false, pdfborder={0 0 0}}

\pagestyle{fancy}
\fancyhf{}
\fancyhead[L]{\small FrostPuno. Codigo fuente}
\fancyhead[R]{\small Semillero de investigacion}
\fancyfoot[C]{\thepage}
\renewcommand{\headrulewidth}{0.4pt}

\lstset{
  basicstyle=\ttfamily\tiny,
  breaklines=true,
  breakatwhitespace=false,
  columns=fullflexible,
  numbers=left,
  numberstyle=\tiny\color{gray},
  numbersep=6pt,
  showstringspaces=false,
  tabsize=4,
  frame=leftline,
  framesep=6pt,
  xleftmargin=18pt,
  keywordstyle=\bfseries,
  commentstyle=\itshape\color{gray},
  extendedchars=true,
}

\title{\vspace{-1.5cm}\textbf{FrostPuno}\\[0.3cm]
\large Codigo fuente de la aplicacion\\[0.2cm]
\normalsize Sistema distribuido de prediccion de heladas para el altiplano de Puno}
\author{Mamani Mendoza, Joseph Elvis \and Lipe Machaca, Juan Artemio \and
Ticona Erquinigo, Jhoel Yovani \and Tapara Ccahuana, Paul Renmis}
\date{Universidad Nacional del Altiplano, Puno\\
Escuela Profesional de Ingenieria de Sistemas\\[0.3cm]
Repositorio: \url{https://github.com/JosephElvisMaman1/frost-puno}}

\begin{document}
\maketitle
\thispagestyle{fancy}

\noindent Este documento reune el codigo fuente de la aplicacion FrostPuno,
organizado por subsistema. El repositorio publico contiene la version completa
y su historial de cambios.

\vspace{0.3cm}
\tableofcontents
\newpage
"""


def archivos_versionados() -> list[str]:
    salida = subprocess.run(
        ["git", "ls-files"], cwd=ROOT, capture_output=True, text=True, check=True
    )
    return salida.stdout.splitlines()


def escapar(texto: str) -> str:
    """Sustituye caracteres que listings no puede representar."""
    return texto.replace("\t", "    ").replace("\r\n", "\n")


def main() -> int:
    todos = archivos_versionados()
    partes = [PREAMBULO]
    total_archivos = 0
    total_lineas = 0

    for titulo, prefijos in SECCIONES:
        seleccion = sorted(
            ruta
            for ruta in todos
            if any(ruta.startswith(pref) for pref in prefijos)
            and Path(ruta).suffix in EXTENSIONES
        )
        if not seleccion:
            continue

        partes.append(f"\\section{{{titulo}}}\n")
        for ruta in seleccion:
            archivo = ROOT / ruta
            try:
                contenido = archivo.read_text(encoding="utf-8")
            except (UnicodeDecodeError, OSError):
                continue
            if not contenido.strip():
                continue

            lenguaje = LENGUAJE.get(Path(ruta).suffix, "")
            seguro = ruta.replace("_", r"\_")
            total_archivos += 1
            total_lineas += contenido.count("\n") + 1

            partes.append(f"\\subsection*{{{seguro}}}\n")
            partes.append(f"\\addcontentsline{{toc}}{{subsection}}{{{seguro}}}\n")
            partes.append(
                f"\\begin{{lstlisting}}[language={lenguaje}]\n"
                if lenguaje
                else "\\begin{lstlisting}\n"
            )
            partes.append(escapar(contenido))
            if not contenido.endswith("\n"):
                partes.append("\n")
            partes.append("\\end{lstlisting}\n\n")

    partes.append("\\end{document}\n")
    OUT_TEX.write_text("".join(partes), encoding="utf-8")
    print(f"Generado {OUT_TEX.name}: {total_archivos} archivos, {total_lineas} lineas")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
