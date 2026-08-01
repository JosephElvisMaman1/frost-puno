"""Informe tecnico final del curso (8 puntos), en Word.

Estructura alineada a los criterios de evaluacion:
  1 pt  Herramientas, plataformas y aplicaciones
  1 pt  Organizacion del codigo fuente
  1 pt  Consideraciones de despliegue inicial
  2 pt  Flujos de mantenimiento e integracion continua
  3 pt  Video grabado de la exposicion

Sin cursivas, sin guiones largos, tono formal.
"""

from pathlib import Path

from docx import Document
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from docx.shared import Inches, Pt, RGBColor

ROOT = Path(r"D:\Dev\02_UNIVERSIDAD\FrostPuno\.claude\worktrees\flutter-frost-prediction-puno-d1a1d7")
IMG = ROOT / "docs" / "presentacion" / "img"
OUT = ROOT / "docs" / "Informe_Tecnico_FrostPuno.docx"

VIDEO_URL = "https://drive.google.com/drive/folders/1nxD0mXwB2P-LHh588sDdEh17SuBmWok7?usp=sharing"
REPO_URL = "https://github.com/JosephElvisMaman1/frost-puno"
APP_URL = "https://frost-puno.vercel.app"
API_URL = "https://frost-puno.onrender.com"

doc = Document()
style = doc.styles["Normal"]
style.font.name = "Arial"
style.font.size = Pt(11)
style.paragraph_format.space_after = Pt(8)

BLACK = RGBColor(0, 0, 0)

# Los estilos de titulo de Word son azules por defecto. Se fuerzan a negro para
# que el documento completo quede en un solo color.
for style_name, size in [("Title", 22), ("Heading 1", 15), ("Heading 2", 12.5),
                         ("Heading 3", 11.5)]:
    try:
        st = doc.styles[style_name]
    except KeyError:
        continue
    st.font.color.rgb = BLACK
    st.font.name = "Arial"
    st.font.size = Pt(size)
    st.font.bold = True
    rpr = st.element.get_or_add_rPr()
    for tag in ("w:color",):
        for node in rpr.findall(qn(tag)):
            rpr.remove(node)
    color = rpr.makeelement(qn("w:color"), {qn("w:val"): "000000"})
    rpr.append(color)

fig_counter = {"n": 0}
tab_counter = {"n": 0}


def h(text, level=1):
    par = doc.add_heading(text, level=level)
    for run in par.runs:
        run.font.color.rgb = BLACK
        run.font.name = "Arial"
    par.paragraph_format.space_before = Pt(14)
    par.paragraph_format.space_after = Pt(6)
    return par


def p(text, bold=False, size=None, center=False, space_after=8):
    par = doc.add_paragraph()
    par.paragraph_format.space_after = Pt(space_after)
    if not center:
        par.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    else:
        par.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = par.add_run(text)
    run.bold = bold
    if size:
        run.font.size = Pt(size)
    return par


def bullet(text, bold_prefix=None):
    par = doc.add_paragraph(style="List Bullet")
    par.paragraph_format.space_after = Pt(4)
    if bold_prefix:
        r = par.add_run(bold_prefix)
        r.bold = True
    par.add_run(text)
    return par


def numbered(text):
    par = doc.add_paragraph(style="List Number")
    par.paragraph_format.space_after = Pt(4)
    par.add_run(text)
    return par


def code(text):
    par = doc.add_paragraph()
    par.paragraph_format.left_indent = Inches(0.3)
    par.paragraph_format.space_after = Pt(8)
    run = par.add_run(text)
    run.font.name = "Consolas"
    run.font.size = Pt(9)
    return par


def table(headers, rows, caption=None, widths=None):
    if caption:
        tab_counter["n"] += 1
        cap = doc.add_paragraph()
        cap.paragraph_format.space_after = Pt(4)
        r = cap.add_run(f"Tabla {tab_counter['n']}. {caption}")
        r.bold = True
        r.font.size = Pt(9)

    t = doc.add_table(rows=1, cols=len(headers))
    t.style = "Table Grid"
    t.alignment = WD_TABLE_ALIGNMENT.CENTER
    for i, head in enumerate(headers):
        cell = t.rows[0].cells[i]
        cell.text = ""
        run = cell.paragraphs[0].add_run(head)
        run.bold = True
        run.font.size = Pt(10)
    for row in rows:
        cells = t.add_row().cells
        for i, value in enumerate(row):
            cells[i].text = ""
            run = cells[i].paragraphs[0].add_run(str(value))
            run.font.size = Pt(10)
    if widths:
        for row in t.rows:
            for i, width in enumerate(widths):
                row.cells[i].width = Inches(width)
    doc.add_paragraph().paragraph_format.space_after = Pt(6)
    return t


def img(name, caption, width=5.5):
    path = IMG / name
    if not path.exists():
        return
    fig_counter["n"] += 1
    doc.add_picture(str(path), width=Inches(width))
    doc.paragraphs[-1].alignment = WD_ALIGN_PARAGRAPH.CENTER
    cap = doc.add_paragraph()
    cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
    cap.paragraph_format.space_after = Pt(12)
    run = cap.add_run(f"Figura {fig_counter['n']}. {caption}")
    run.bold = True
    run.font.size = Pt(9)


# =========================================================== PORTADA
for _ in range(3):
    doc.add_paragraph()

p("UNIVERSIDAD NACIONAL DEL ALTIPLANO - PUNO", bold=True, size=14, center=True, space_after=4)
p("FACULTAD DE INGENIERIA MECANICA ELECTRICA, ELECTRONICA Y SISTEMAS", size=12, center=True, space_after=4)
p("ESCUELA PROFESIONAL DE INGENIERIA DE SISTEMAS", size=12, center=True, space_after=24)

if (IMG / "escudo_una.png").exists():
    doc.add_picture(str(IMG / "escudo_una.png"), width=Inches(1.7))
    doc.paragraphs[-1].alignment = WD_ALIGN_PARAGRAPH.CENTER

doc.add_paragraph()
p("INFORME TECNICO", bold=True, size=20, center=True, space_after=8)
p("FrostPuno: sistema de prediccion de heladas y apoyo a la produccion de chuno "
  "en el altiplano de Puno mediante aprendizaje no supervisado",
  bold=True, size=13, center=True, space_after=6)
p("Aplicacion desplegada en produccion con procesos automatizados de mantenimiento "
  "e integracion continua", size=11, center=True, space_after=28)

_cover = doc.add_table(rows=0, cols=2)
_cover.style = "Table Grid"
_cover.alignment = WD_TABLE_ALIGNMENT.CENTER
for label, value in [
    ("Curso", "Aprendizaje de Maquina"),
    ("Carrera", "Ingenieria de Sistemas, noveno ciclo"),
    ("Proyecto", "Segunda Unidad"),
    ("Docente", "Ing. Fernandez Chambi, Mayenka"),
    ("Integrantes",
     "Mamani Mendoza, Joseph Elvis\n"
     "Lipe Machaca, Juan Artemio\n"
     "Ticona Erquinigo, Jhoel Yovani\n"
     "Tapara Ccahuana, Paul Renmis"),
    ("Lugar y fecha", "Puno, Peru - 2026"),
]:
    cells = _cover.add_row().cells
    run_label = cells[0].paragraphs[0].add_run(label)
    run_label.bold = True
    run_label.font.size = Pt(10)
    cells[1].paragraphs[0].add_run(value).font.size = Pt(10)
    cells[0].width = Inches(1.6)
    cells[1].width = Inches(4.4)

doc.add_page_break()

# =========================================================== INDICE
h("Indice general", 1)
_toc = [
    ("Enlaces del producto y del entregable", 4),
    ("1. Introduccion", 6),
    ("2. Herramientas, plataformas y aplicaciones necesarias", 7),
    ("3. Organizacion del codigo fuente", 9),
    ("4. Consideraciones de despliegue inicial", 11),
    ("5. Flujos de mantenimiento e integracion continua", 14),
    ("6. Componente inteligente del sistema", 18),
    ("7. Funcionamiento de la aplicacion", 20),
    ("8. Limitaciones", 23),
    ("9. Conclusiones", 23),
    ("10. Video de la exposicion", 24),
    ("Anexo. Comandos de verificacion", 24),
]
_toc_table = doc.add_table(rows=0, cols=2)
_toc_table.alignment = WD_TABLE_ALIGNMENT.CENTER
for titulo, pagina in _toc:
    cells = _toc_table.add_row().cells
    cells[0].paragraphs[0].add_run(titulo).font.size = Pt(11)
    par_num = cells[1].paragraphs[0]
    par_num.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    par_num.add_run(str(pagina)).font.size = Pt(11)
    cells[0].width = Inches(5.4)
    cells[1].width = Inches(0.7)
    for cell in cells:
        cell.paragraphs[0].paragraph_format.space_after = Pt(2)

doc.add_paragraph()
h("Indice de figuras", 1)
_figs = [
    "Figura 1. Verificacion de integridad del APK Android mediante Play Protect.",
    "Figura 2. Documentacion interactiva de la interfaz de programacion.",
    "Figura 3. Respuesta del punto de acceso de verificacion de salud.",
    "Figura 4. Ejecuciones de los flujos de integracion continua.",
    "Figura 5. Detalle de las ejecuciones de los flujos de trabajo.",
    "Figura 6. Pantalla de zonas de riesgo con las metricas del modelo.",
    "Figura 7. Pantalla principal con la alerta del dia.",
    "Figura 8. Modulo estacional de chuno.",
    "Figura 9. Pantalla de ajustes con umbral y perfil de usuario.",
]
for texto in _figs:
    par = doc.add_paragraph()
    par.paragraph_format.space_after = Pt(3)
    par.add_run(texto).font.size = Pt(11)

doc.add_page_break()

# =========================================================== ENLACES
h("Enlaces del producto y del entregable", 1)
p("El sistema descrito en este informe se encuentra operativo. Los siguientes enlaces "
  "permiten verificar cada componente de forma directa.")

table(
    ["Recurso", "Enlace"],
    [
        ["Video de la exposicion", VIDEO_URL],
        ["Repositorio de codigo fuente (GitHub)", REPO_URL],
        ["Aplicacion web (Flutter en Vercel)", APP_URL],
        ["API de produccion (FastAPI en Render)", API_URL],
        ["Documentacion interactiva de la API", f"{API_URL}/docs"],
        ["Aplicacion Android (APK release)", f"{REPO_URL}  (build: app-release.apk, 47.3 MB)"],
    ],
    caption="Enlaces de verificacion del producto entregado.",
    widths=[2.3, 3.9],
)

p("El archivo APK se genera desde el repositorio con el siguiente comando y queda "
  "disponible en la ruta indicada:")
code("flutter build apk --release --dart-define=API_BASE_URL=https://frost-puno.onrender.com\n"
     "Salida: app_flutter/build/app/outputs/flutter-apk/app-release.apk")

img("apk_play_protect.png",
    "Verificacion de integridad del APK Android mediante Play Protect: sin virus "
    "detectados y aplicacion legitima.", 4.3)

doc.add_page_break()

# =========================================================== 1. INTRODUCCION
h("1. Introduccion", 1)
p("FrostPuno es una aplicacion con elementos inteligentes orientada a la prediccion del "
  "riesgo de heladas en el altiplano de la region Puno. Por encima de los 3 800 metros "
  "sobre el nivel del mar, las heladas afectan los cultivos y provocan mortalidad "
  "neonatal en crias de alpaca y ovino. Esas mismas heladas constituyen el insumo del "
  "chuno, la papa deshidratada mediante congelamiento nocturno y secado diurno que forma "
  "parte de la seguridad alimentaria regional.")
p("La logica de negocio del sistema no se resuelve con reglas fijas: se operativiza a "
  "traves de las predicciones de un modelo de aprendizaje no supervisado, concretamente "
  "un modelo de agrupamiento K-Means que descubre los regimenes climaticos de los "
  "distritos y los asocia a niveles de riesgo.")
p("Este documento esta dirigido a un equipo de tecnologias de la informacion que reciba "
  "el sistema para su mantenimiento e integracion. Por ello describe las herramientas "
  "necesarias, la organizacion del codigo, las consideraciones de despliegue inicial y "
  "los flujos automatizados que mantienen operativo tanto el software como el modelo.")

h("1.1 Objetivo del sistema", 2)
bullet("Emitir una alerta diaria de riesgo de helada con umbral configurable por el usuario.")
bullet("Diferenciar el riesgo para ganado del riesgo para cultivos.")
bullet("Identificar ventanas optimas para la elaboracion de chuno durante la temporada.")
bullet("Agrupar los distritos de Puno por nivel de riesgo mediante aprendizaje no supervisado.")
bullet("Detectar eventos climaticos inusuales respecto de la climatologia reciente.")

h("1.2 Trazabilidad academica", 2)
p("El proyecto se inicio con un clasificador supervisado basado en RandomForest evaluado "
  "con la metrica f1 macro. Conforme al enunciado de la segunda unidad, se migro a "
  "aprendizaje no supervisado. Los scripts del modelo anterior se conservan en el "
  "repositorio como referencia documentada, fuera de la ruta productiva, de modo que la "
  "evolucion del proyecto sea auditable.")

doc.add_page_break()

# =========================================================== 2. HERRAMIENTAS (1 pt)
h("2. Herramientas, plataformas y aplicaciones necesarias", 1)
p("Esta seccion detalla el software y los servicios requeridos para desplegar, mantener "
  "e integrar el sistema. Todas las plataformas empleadas cuentan con un plan gratuito "
  "suficiente para el alcance academico del proyecto.")

h("2.1 Entorno de desarrollo", 2)
table(
    ["Herramienta", "Version", "Funcion en el proyecto"],
    [
        ["Python", "3.11", "Pipeline de aprendizaje automatico y servicio backend"],
        ["scikit-learn", "1.5 o superior", "Implementacion de K-Means, escalado y metricas"],
        ["pandas", "2.2 o superior", "Construccion y validacion del conjunto de datos"],
        ["joblib", "1.4 o superior", "Serializacion del modelo entrenado"],
        ["FastAPI", "0.115 o superior", "Servicio web que expone el modelo"],
        ["Uvicorn", "0.32 o superior", "Servidor ASGI de ejecucion del backend"],
        ["Pydantic", "2.9 o superior", "Validacion de esquemas de entrada y salida"],
        ["httpx", "0.27 o superior", "Cliente HTTP hacia el proveedor de clima"],
        ["Flutter", "3.x", "Cliente web y aplicacion Android"],
        ["Git", "2.x", "Control de versiones"],
    ],
    caption="Herramientas de desarrollo y sus versiones.",
    widths=[1.6, 1.5, 3.1],
)

h("2.2 Plataformas de despliegue y operacion", 2)
table(
    ["Plataforma", "Plan", "Responsabilidad"],
    [
        ["Render", "Free", "Alojamiento del backend FastAPI y del modelo en memoria"],
        ["Vercel", "Hobby", "Alojamiento del cliente Flutter Web mediante red de distribucion"],
        ["Supabase", "Free", "Base de datos PostgreSQL gestionada para el historial"],
        ["GitHub", "Publico", "Repositorio de codigo y ejecucion de la integracion continua"],
        ["GitHub Actions", "Incluido", "Automatizacion de pruebas, entrenamiento y control de calidad"],
        ["Open-Meteo", "API abierta", "Fuente climatica historica, de pronostico y de archivo"],
    ],
    caption="Plataformas de despliegue, mantenimiento e integracion continua.",
    widths=[1.5, 1.1, 3.6],
)

h("2.3 Dependencias de la aplicacion movil", 2)
bullet("geolocator: obtencion de coordenadas por sistema de posicionamiento global.")
bullet("permission_handler: gestion de permisos de ubicacion y notificaciones en Android.")
bullet("fl_chart: graficos de temperatura y humedad en la pantalla de clima historico.")
bullet("shared_preferences: persistencia local de umbral de alerta, perfil e idioma.")
bullet("flutter_local_notifications: notificaciones nativas de alerta de helada en Android.")
bullet("flutter_localizations: soporte de los idiomas espanol e ingles en la interfaz.")

h("2.4 Requisitos minimos para el mantenimiento", 2)
p("Un equipo que reciba el sistema requiere unicamente: Python 3.11, Flutter, Git, una "
  "cuenta de GitHub con permisos sobre el repositorio y acceso a los paneles de Render, "
  "Vercel y Supabase. No se necesita infraestructura propia ni licencias de pago.")

doc.add_page_break()

# =========================================================== 3. ORGANIZACION (1 pt)
h("3. Organizacion del codigo fuente", 1)
p("El repositorio se organiza en tres subsistemas independientes mas los datos "
  "compartidos y la definicion de la automatizacion. Cada subsistema puede evolucionar "
  "por separado porque la comunicacion entre ellos ocurre a traves de contratos "
  "explicitos.")

h("3.1 Estructura de directorios", 2)
code("ml_pipeline/            Pipeline de aprendizaje automatico\n"
     "  config.py             Fuente unica de rutas, caracteristicas y constantes\n"
     "  data_ingestion/       Ingesta de clima y ubicaciones\n"
     "  features/             Construccion del conjunto de datos\n"
     "  clustering/           Entrenamiento K-Means y reentrenamiento adaptativo\n"
     "  registry/             Modelo serializado, metadatos y control de calidad\n"
     "  evaluation/           Perfiles de agrupamiento y reportes\n"
     "  tests/                Pruebas de mantenimiento e integracion continua\n"
     "\n"
     "backend_fastapi/        Servicio web que expone el modelo\n"
     "  app/api/routes/       Capa HTTP\n"
     "  app/services/         Logica de negocio\n"
     "  app/repositories/     Persistencia\n"
     "  app/schemas/          Contratos de datos con Pydantic\n"
     "  app/core/             Configuracion y excepciones\n"
     "  tests/                Pruebas del servicio\n"
     "\n"
     "app_flutter/            Cliente web y Android\n"
     "  lib/core/             Cliente HTTP, tema, preferencias e idiomas\n"
     "  lib/features/         Una carpeta por funcionalidad\n"
     "  lib/shared/widgets/   Componentes reutilizables\n"
     "\n"
     "data/                   Conjuntos de datos versionados\n"
     ".github/workflows/      Cinco flujos de integracion continua\n"
     "docs/                   Documentacion tecnica y evidencias")

h("3.2 Principios de organizacion aplicados", 2)
bullet("La configuracion esta centralizada. El archivo ml_pipeline/config.py concentra "
       "rutas, listas de caracteristicas y constantes; el backend hace lo propio en "
       "app/core/config.py y el cliente recibe su configuracion por parametro de "
       "compilacion. No existen rutas escritas dentro de la logica.",
       bold_prefix="Configuracion centralizada. ")
bullet("El backend separa la capa HTTP de la logica y de la persistencia. Cada ruta "
       "delega en un servicio y este en un repositorio, de modo que la fuente de datos "
       "puede cambiar sin modificar los controladores.",
       bold_prefix="Separacion por capas. ")
bullet("El cliente Flutter agrupa el codigo por funcionalidad y no por tipo de archivo. "
       "Cada carpeta bajo lib/features contiene sus pantallas, modelos y servicios.",
       bold_prefix="Organizacion por funcionalidad. ")
bullet("La lista de caracteristicas declarada en los metadatos del modelo define el "
       "contrato entre el pipeline y el servicio de inferencia. El backend construye el "
       "vector de entrada siguiendo ese orden, por lo que un reentrenamiento no obliga a "
       "modificar el codigo del servidor.",
       bold_prefix="Contrato explicito entre modelo y servicio. ")
bullet("Los errores internos se transforman en respuestas estables de la interfaz de "
       "programacion. No se exponen detalles de implementacion del modelo al cliente.",
       bold_prefix="Gestion de errores en el borde. ")

h("3.3 Convenciones de trabajo", 2)
p("El desarrollo se realiza en ramas y la integracion a la rama principal se efectua "
  "mediante solicitudes de incorporacion, lo que permite que los flujos de verificacion "
  "se ejecuten antes de que un cambio llegue a produccion. Los conjuntos de datos estan "
  "versionados y su modificacion exige aprobar el flujo de validacion de datos.")

img("swagger_api.png",
    "Documentacion interactiva de la interfaz de programacion generada automaticamente "
    "por FastAPI y disponible en produccion.", 5.4)

doc.add_page_break()

# =========================================================== 4. DESPLIEGUE (1 pt)
h("4. Consideraciones de despliegue inicial", 1)
p("El sistema se distribuye en cuatro componentes alojados en plataformas distintas. "
  "Esta seccion documenta la configuracion necesaria y las precauciones detectadas "
  "durante la puesta en produccion.")

h("4.1 Arquitectura de despliegue", 2)
table(
    ["Componente", "Plataforma", "Direccion"],
    [
        ["Cliente Flutter Web", "Vercel", APP_URL],
        ["Servicio FastAPI", "Render", API_URL],
        ["Base de datos PostgreSQL", "Supabase", "Instancia gestionada del proyecto"],
        ["Aplicacion Android", "Distribucion directa", "app-release.apk"],
    ],
    caption="Distribucion de los componentes en produccion.",
    widths=[1.9, 1.5, 2.8],
)

h("4.2 Configuracion del servicio backend", 2)
p("El despliegue del backend esta declarado como infraestructura como codigo en el "
  "archivo render.yaml, de modo que la configuracion es reproducible y queda versionada "
  "junto al codigo.")
code("runtime: python 3.11\n"
     "buildCommand: pip install -r backend_fastapi/requirements.txt\n"
     "startCommand: uvicorn app.main:app --host 0.0.0.0 --port $PORT --app-dir backend_fastapi\n"
     "healthCheckPath: /health\n"
     "autoDeploy: true")

p("Las variables de entorno requeridas por el servicio son las siguientes:")
table(
    ["Variable", "Proposito"],
    [
        ["MODEL_PATH", "Ruta del modelo de agrupamiento serializado"],
        ["MODEL_METADATA_PATH", "Ruta de los metadatos con caracteristicas y metricas"],
        ["DISTRICT_CLUSTERS_PATH", "Ruta de la agrupacion de distritos por nivel de riesgo"],
        ["CORS_ORIGINS", "Origenes autorizados para el consumo desde el cliente"],
        ["ENABLE_SUPABASE", "Activa o desactiva la persistencia en base de datos"],
        ["SUPABASE_URL", "Direccion del proyecto de base de datos"],
        ["SUPABASE_SERVICE_ROLE_KEY", "Credencial de servicio, declarada como no sincronizable"],
    ],
    caption="Variables de entorno del servicio backend.",
    widths=[2.4, 3.8],
)

h("4.3 Consideracion critica detectada en produccion", 2)
p("Durante la migracion del modelo supervisado al modelo de agrupamiento se produjo una "
  "situacion que conviene documentar para el equipo que reciba el sistema. Tras "
  "incorporar los cambios a la rama principal, la plataforma redesplego el servicio "
  "correctamente, pero la interfaz de programacion continuo respondiendo con el modelo "
  "anterior.")
p("La causa fue que las variables de entorno definidas manualmente en el panel de "
  "administracion tienen prioridad sobre las declaradas en el archivo de configuracion. "
  "Las rutas del modelo anterior permanecian fijadas en el panel, por lo que el archivo "
  "versionado no surtia efecto. La verificacion recomendada despues de cada cambio de "
  "modelo consiste en consultar el punto de acceso de informacion del modelo y confirmar "
  "que el nombre y la version corresponden al artefacto esperado.")

h("4.4 Configuracion del cliente", 2)
p("La direccion del servicio no esta escrita en el codigo del cliente. Se inyecta en "
  "tiempo de compilacion, de manera que el mismo codigo fuente sirve para el entorno "
  "local, para la version web y para la aplicacion Android.")
code("flutter build web --release --dart-define=API_BASE_URL=https://frost-puno.onrender.com\n"
     "flutter build apk --release --dart-define=API_BASE_URL=https://frost-puno.onrender.com\n"
     "flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000")

h("4.5 Secuencia de puesta en marcha", 2)
numbered("Entrenar el modelo y publicar los artefactos en el registro de modelos.")
numbered("Desplegar el servicio backend y verificar los puntos de acceso de salud e "
         "informacion del modelo.")
numbered("Desplegar el cliente web indicando la direccion del servicio.")
numbered("Compilar la aplicacion Android apuntando al mismo servicio.")
numbered("Activar la persistencia en base de datos de forma opcional. Con la persistencia "
         "desactivada el sistema opera con un repositorio en memoria, que es la "
         "configuracion utilizada por las pruebas automatizadas.")

h("4.6 Consideraciones de seguridad", 2)
bullet("La credencial de servicio de la base de datos existe unicamente en el panel del "
       "backend y esta marcada como no sincronizable, por lo que nunca se incorpora al "
       "repositorio.")
bullet("El cliente recibe exclusivamente la direccion publica del servicio y en ningun "
       "caso credenciales de base de datos.")
bullet("El servicio valida el rango de coordenadas correspondiente a la region de Puno "
       "antes de procesar cualquier consulta.")

h("4.7 Limitaciones del entorno gratuito", 2)
bullet("El plan gratuito del servicio backend suspende la instancia tras un periodo de "
       "inactividad, por lo que la primera peticion puede demorar mientras el servicio "
       "se reactiva.")
bullet("La aplicacion Android no esta firmada para distribucion en tiendas, se entrega "
       "como archivo de instalacion directa.")

img("health_check.png",
    "Respuesta del punto de acceso de verificacion de salud del servicio desplegado.", 5.2)

doc.add_page_break()

# =========================================================== 5. MANTENIMIENTO E IC (2 pt)
h("5. Flujos de mantenimiento e integracion continua", 1)
p("El sistema incorpora un componente inteligente, por lo que el mantenimiento no se "
  "limita al codigo: tambien comprende el reentrenamiento del modelo, el registro de "
  "versiones, el almacenamiento de caracteristicas y el control de calidad previo a la "
  "promocion de un modelo nuevo. Todos estos procesos estan automatizados.")

h("5.1 Flujos de integracion continua", 2)
p("Se implementaron cinco flujos independientes que se ejecutan de forma simultanea en "
  "entornos separados ante cada incorporacion de cambios al repositorio.")

table(
    ["Flujo", "Disparo", "Funcion"],
    [
        ["ml-training.yml", "Manual y programado",
         "Ingesta de clima, construccion de caracteristicas, entrenamiento y publicacion de artefactos"],
        ["model-quality-gate.yml", "Cada cambio",
         "Verifica la calidad del modelo y ejecuta las pruebas de mantenimiento"],
        ["backend-tests.yml", "Cada cambio",
         "Ejecuta las doce pruebas del servicio sin base de datos externa"],
        ["data-validation.yml", "Cada cambio",
         "Valida la estructura de los conjuntos de datos y la agrupacion de distritos"],
        ["flutter-build.yml", "Cada cambio",
         "Analiza, prueba y compila la version web del cliente"],
    ],
    caption="Flujos de integracion continua implementados.",
    widths=[1.6, 1.3, 3.3],
)

img("actions_verde.png",
    "Ejecuciones de los flujos de integracion continua en estado satisfactorio.", 5.6)

img("actions_detalle.png",
    "Detalle de las ejecuciones: cada incorporacion de cambios dispara los flujos "
    "de forma simultanea.", 5.6)

h("5.2 Mantenimiento del modelo", 2)
p("El modelo se reentrena de forma automatica sin intervencion humana. El flujo de "
  "entrenamiento cuenta con una programacion semanal mediante expresion de tiempo, de "
  "manera que el sistema incorpora datos climaticos recientes de forma periodica.")

p("Reentrenamiento adaptativo.", bold=True)
p("El procedimiento de reentrenamiento no se limita a repetir el entrenamiento con los "
  "mismos parametros. Si la calidad de agrupamiento obtenida no alcanza el objetivo "
  "definido, el procedimiento amplia la ventana de datos historicos, de catorce a "
  "veintinueve y luego a cuarenta y cuatro dias, y repite el entrenamiento. Cada "
  "ejecucion queda registrada en un historial que incluye la fecha, la cantidad de dias "
  "de datos empleados, el tamano del conjunto resultante, la metrica obtenida y los "
  "hiperparametros seleccionados. Ese historial constituye la evidencia de que el modelo "
  "mejora conforme dispone de mas informacion.")

p("Registro de modelos.", bold=True)
p("Cada entrenamiento serializa el modelo junto con un archivo de metadatos que contiene "
  "la lista de caracteristicas, las metricas obtenidas, los hiperparametros explorados y "
  "los elegidos, el tamano del conjunto de datos, la version y las limitaciones "
  "declaradas. El servicio backend carga exactamente ese artefacto, lo que garantiza la "
  "correspondencia entre lo entrenado y lo servido.")

p("Almacenamiento de caracteristicas.", bold=True)
p("El conjunto de caracteristicas se encuentra versionado dentro del repositorio y se "
  "valida en cada integracion. Cumple la funcion de almacen de caracteristicas del "
  "proyecto, de modo que cualquier reentrenamiento parte de una base reproducible.")

h("5.3 Control de calidad como barrera", 2)
p("El reentrenamiento automatico presenta un riesgo: un modelo nuevo podria resultar "
  "inferior al que se encuentra en produccion. Para evitarlo se implemento un control de "
  "calidad que verifica la metrica de agrupamiento antes de permitir la promocion. Si el "
  "valor obtenido se encuentra por debajo del umbral establecido de 0.35, el proceso "
  "finaliza con codigo de error y la integracion se detiene.")

code("python -m ml_pipeline.registry.check_cluster_quality --min-silhouette 0.35\n"
     "Resultado: QUALITY GATE PASSED (silhouette 0.419)")

h("5.4 Pruebas de funcionamiento del mantenimiento", 2)
p("La existencia de los flujos no demuestra por si sola que el mantenimiento opere de "
  "forma correcta. Por ese motivo se implementaron seis pruebas automatizadas que se "
  "ejecutan dentro de la integracion continua y verifican el comportamiento del ciclo "
  "completo.")

table(
    ["Prueba", "Comportamiento verificado"],
    [
        ["Artefactos del registro",
         "El reentrenamiento genera el modelo, los metadatos y la agrupacion de distritos"],
        ["Carga e inferencia",
         "El artefacto serializado se carga y produce predicciones, manteniendo el contrato con el servicio"],
        ["Cobertura territorial",
         "Los trece distritos quedan asignados a un nivel de riesgo valido"],
        ["Hiperparametros documentados",
         "Los metadatos registran la busqueda realizada y la configuracion elegida corresponde a la mejor evaluada"],
        ["Aprobacion del control de calidad",
         "El control aprueba el modelo vigente en produccion"],
        ["Bloqueo de modelo degradado",
         "El control rechaza un modelo con metrica insuficiente y finaliza con codigo de error"],
    ],
    caption="Pruebas automatizadas del mantenimiento y la integracion continua.",
    widths=[1.9, 4.3],
)

p("La ultima prueba resulta particularmente relevante porque verifica el funcionamiento "
  "de la propia barrera de seguridad: construye deliberadamente un conjunto de metadatos "
  "con una metrica insuficiente y comprueba que el control lo rechaza.")

code("python -m pytest ml_pipeline/tests/test_maintenance_ci.py -v\n"
     "Resultado: 6 passed")

h("5.5 Evidencias de funcionamiento", 2)
table(
    ["Verificacion", "Resultado"],
    [
        ["Pruebas del servicio backend", "12 pruebas satisfactorias"],
        ["Pruebas de mantenimiento e integracion continua", "6 pruebas satisfactorias"],
        ["Control de calidad del modelo", "Aprobado, metrica 0.419 frente a un minimo de 0.35"],
        ["Analisis estatico y pruebas del cliente", "Sin observaciones"],
        ["Compilacion de la version web", "Satisfactoria"],
        ["Compilacion de la aplicacion Android", "Satisfactoria, 47.3 MB"],
        ["Modelo servido en produccion", "KMeans, version v1.0.0-clustering"],
    ],
    caption="Resumen de las verificaciones realizadas sobre el sistema.",
    widths=[3.2, 3.0],
)

doc.add_page_break()

# =========================================================== 6. MODELO
h("6. Componente inteligente del sistema", 1)
p("Aunque la evaluacion de este informe se centra en el despliegue y la automatizacion, "
  "se incluye una descripcion del modelo para que el equipo de mantenimiento comprenda "
  "que se esta operando.")

h("6.1 Conjunto de datos y caracteristicas", 2)
p("La fuente climatica es Open-Meteo, de la que se obtienen series horarias para trece "
  "distritos de la region, lo que produce un conjunto de 4 368 registros. La informacion "
  "territorial procede de una semilla compatible con el Instituto Nacional de Estadistica "
  "e Informatica. El Servicio Nacional de Meteorologia e Hidrologia se declara como "
  "fuente oficial prioritaria en el sistema, si bien no expone una interfaz publica "
  "estable, por lo que Open-Meteo constituye la fuente operativa.")

p("El modelo utiliza cuatro caracteristicas: altitud estimada, temperatura, punto de "
  "rocio y humedad relativa. La seleccion se realizo mediante un experimento de "
  "subconjuntos que evidencio que la precipitacion, la velocidad del viento, la "
  "nubosidad y la temperatura aparente introducian ruido y reducian la separacion entre "
  "grupos. Al retirarlas, la metrica de agrupamiento aumento de 0.286 a 0.419.")

h("6.2 Entrenamiento e hiperparametros", 2)
p("El algoritmo es K-Means, incorporado en una secuencia de procesamiento que aplica "
  "previamente un escalado estandar, necesario porque las variables presentan magnitudes "
  "muy distintas. La seleccion de hiperparametros se realiza mediante una busqueda "
  "exhaustiva de veinticuatro combinaciones que maximiza la metrica de agrupamiento.")

table(
    ["Hiperparametro", "Valores evaluados", "Valor seleccionado"],
    [
        ["Numero de grupos", "3, 4, 5, 6, 7, 8", "3"],
        ["Metodo de inicializacion", "k-means++, aleatorio", "aleatorio"],
        ["Numero de inicializaciones", "10, 25", "10"],
        ["Escalado", "Estandarizacion", "Aplicado"],
        ["Semilla de aleatoriedad", "Fija", "42"],
    ],
    caption="Busqueda de hiperparametros y configuracion seleccionada.",
    widths=[2.1, 2.2, 1.9],
)

h("6.3 Evaluacion", 2)
p("Al tratarse de aprendizaje no supervisado no se dispone de etiquetas de referencia, "
  "por lo que no procede el uso de exactitud ni de f1. La evaluacion mide la calidad de "
  "la estructura descubierta mediante el coeficiente de silueta, que alcanza un valor de "
  "0.419, y el indice de Davies-Bouldin, que alcanza un valor de 0.813.")

p("El resultado admite interpretacion geografica. El distrito de Macusani, situado a "
  "4 315 metros, queda clasificado en riesgo alto, mientras que Sandia, ubicado en valle "
  "a 2 170 metros, queda en riesgo bajo. Esta correspondencia con la geografia regional "
  "no fue programada: emerge del agrupamiento.")

img("zonas_kmeans.png",
    "Pantalla de zonas de riesgo con las metricas del modelo en produccion y la "
    "clasificacion de distritos por nivel.", 2.6)

doc.add_page_break()

# =========================================================== 7. FUNCIONAMIENTO
h("7. Funcionamiento de la aplicacion", 1)
p("La aplicacion se encuentra disponible como version web y como aplicacion Android. "
  "Incorpora seleccion de idioma entre espanol e ingles, de modo que la totalidad de la "
  "interfaz, incluidas las alertas y los niveles de riesgo, puede presentarse en ingles.")

h("7.1 Funcionalidades principales", 2)
bullet("Alerta diaria de helada con umbral de temperatura configurable por el usuario.")
bullet("Aviso diferenciado de riesgo para el ganado, orientado a la proteccion de crias.")
bullet("Deteccion de eventos inusuales por comparacion con la climatologia reciente.")
bullet("Agrupacion de distritos por nivel de riesgo obtenida del modelo.")
bullet("Modulo estacional de chuno con evaluacion de ventanas de congelamiento y secado.")
bullet("Historico climatico de los ultimos treinta dias con representacion grafica.")
bullet("Perfil de usuario que prioriza las alertas mostradas segun la actividad.")

img("home_claro.png", "Pantalla principal con la alerta del dia y el riesgo actual.", 2.6)
img("chuno.png", "Modulo estacional de chuno con la evaluacion del pronostico diario.", 2.6)
img("ajustes.png",
    "Pantalla de ajustes: activacion de alertas, umbral de temperatura configurable "
    "y seleccion de perfil de usuario.", 2.6)

doc.add_page_break()

# =========================================================== 8. LIMITACIONES
h("8. Limitaciones", 1)
p("Se declaran de forma explicita las limitaciones del sistema, dado que su conocimiento "
  "resulta necesario para cualquier equipo que asuma el mantenimiento.")

bullet("Los niveles de riesgo se derivan del perfil termico de cada grupo y no de un "
       "registro oficial de heladas observadas, dado que no existe un conjunto etiquetado "
       "disponible para estos distritos.")
bullet("El Servicio Nacional de Meteorologia e Hidrologia no expone una interfaz publica "
       "estable, por lo que la fuente operativa efectiva es Open-Meteo.")
bullet("La semilla territorial constituye una version reducida y debe sustituirse por la "
       "exportacion oficial completa para un uso productivo.")
bullet("Los umbrales aplicados al chuno y al ganado corresponden a un diseno documentado "
       "con fuentes, sin constituir cifras oficiales.")
bullet("La deteccion de eventos inusuales emplea climatologia reciente de treinta dias y "
       "no una serie multianual.")
bullet("El plan gratuito de la plataforma de alojamiento introduce una demora en la "
       "primera peticion tras un periodo de inactividad.")

p("Ninguna de estas limitaciones afecta la validez de la arquitectura de despliegue ni "
  "de los procesos de mantenimiento e integracion continua descritos en este informe.")

# =========================================================== 9. CONCLUSIONES
h("9. Conclusiones", 1)
p("El sistema cumple con los objetivos planteados para la segunda unidad. Se desarrollo "
  "una aplicacion con elementos inteligentes basada en aprendizaje no supervisado, se "
  "desplego en produccion y se automatizaron sus procesos de mantenimiento e integracion "
  "continua.")

numbered("El componente inteligente corresponde a un modelo de agrupamiento K-Means con "
         "hiperparametros optimizados mediante busqueda exhaustiva, evaluado con metricas "
         "propias del aprendizaje no supervisado.")
numbered("La aplicacion se encuentra operativa y accesible como version web, como "
         "interfaz de programacion y como aplicacion Android.")
numbered("El mantenimiento del modelo esta automatizado mediante reentrenamiento "
         "programado con ampliacion adaptativa de la ventana de datos, registro de "
         "versiones y almacenamiento de caracteristicas.")
numbered("La integracion continua comprende cinco flujos y un control de calidad que "
         "impide la promocion de modelos degradados.")
numbered("El funcionamiento del mantenimiento se verifica mediante pruebas automatizadas, "
         "una de las cuales comprueba que el control de calidad rechaza efectivamente un "
         "modelo insuficiente.")

# =========================================================== 10. VIDEO
h("10. Video de la exposicion", 1)
p("La exposicion tecnica del producto se encuentra grabada y disponible en el siguiente "
  "enlace, con una duracion que se ajusta al maximo de doce minutos establecido.")

table(
    ["Recurso", "Enlace"],
    [["Video de la exposicion", VIDEO_URL]],
    widths=[1.6, 4.6],
)

p("La grabacion comprende la presentacion del problema y la arquitectura, la descripcion "
  "del conjunto de datos, la explicacion del entrenamiento del modelo y de los "
  "hiperparametros optimizados, la demostracion del funcionamiento de la aplicacion en "
  "ingles, el despliegue en produccion y los flujos de mantenimiento e integracion "
  "continua con sus pruebas de funcionamiento.")

h("Anexo. Comandos de verificacion", 1)
p("Los siguientes comandos permiten reproducir las verificaciones descritas en este "
  "informe a partir del repositorio.")
code("# Entrenamiento del modelo\n"
     "python -m ml_pipeline.clustering.train_clusters\n\n"
     "# Control de calidad del modelo\n"
     "python -m ml_pipeline.registry.check_cluster_quality --min-silhouette 0.35\n\n"
     "# Pruebas de mantenimiento e integracion continua\n"
     "python -m pytest ml_pipeline/tests/test_maintenance_ci.py -v\n\n"
     "# Reentrenamiento adaptativo\n"
     "python -m ml_pipeline.clustering.adaptive_retrain --target 0.45 --max-iters 3\n\n"
     "# Pruebas del servicio backend\n"
     "pytest backend_fastapi/tests -q\n\n"
     "# Verificacion del cliente\n"
     "flutter analyze && flutter test && flutter build web --release")

doc.save(str(OUT))
print("SAVED", OUT, OUT.stat().st_size, "bytes")
