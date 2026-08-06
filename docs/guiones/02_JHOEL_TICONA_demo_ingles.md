# Guion — JHOEL YOVANI TICONA ERQUINIGO
## Rol: Demostración de la aplicación **EN INGLÉS**

**Tiempo: ~2.5 min** — Vale **3 puntos** directos de la rúbrica
("Funcionamiento de la aplicación en inglés"). Tu parte se narra **en inglés**.

**Repositorio:** https://github.com/JosephElvisMaman1/frost-puno
**App:** https://frost-puno.vercel.app · **API:** https://frost-puno.onrender.com/docs

---

## ANTES DE EMPEZAR (importante)

1. Abre la app **unos minutos antes** (Render Free se duerme y la primera carga tarda ~30 s).
2. **Cambia la app a inglés:** Inicio → ícono ⚙ (arriba a la derecha) → **Language → English**.
   Toda la interfaz queda en inglés: pestañas, alertas, niveles de riesgo.
3. Ten estas pestañas listas: la app y `/docs`.

> Consejo: no improvises el inglés. Lee estas líneas tal cual, despacio. Están escritas para
> sonar naturales dichas en voz alta.

---

## 1. Switching to English (10 s)

> "Thank you, Juan. Let me show the application working. First, I switch the interface
> language: in Settings, I select **English** — the whole app is now in English."

## 2. Home and the daily alert (45 s)

> "This is FrostPuno. The chip at the top shows the system is active, which means the machine
> learning model is loaded and serving predictions.
>
> The first card is **today's frost alert**. The backend reads the forecast and compares the
> minimum temperature against the user's own threshold. When a strong frost is expected, the
> banner turns amber and says: *'Strong frost risk today. Shelter livestock and protect
> crops.'* On Android, the same message arrives as a native notification.
>
> Below it there is a dedicated **livestock card**. Frost in the altiplano kills newborn
> alpacas and sheep, so herders get their own actionable message, separate from crops.
>
> And when today's minimum is far below the recent average, an **unusual risk card** appears,
> telling the user this frost is abnormal for this time of year."

## 3. Settings — alarms and profile (25 s)

> "In Settings the user is in control. They can turn frost alarms on or off, and drag the
> slider to choose their own alert threshold — for example, *warn me if the low drops below
> minus six degrees*.
>
> They can also pick a profile: **farmer, herder, or chuño maker**. The profile decides which
> alerts appear first on the home screen."

## 4. Zones — the model in action (30 s)

*Pestaña **Zones**.*

> "This is where the machine learning becomes visible. We use **K-Means**, an unsupervised
> clustering algorithm, to group Puno's districts by their thermal regime.
>
> The header shows the model quality: **three clusters** and a **silhouette score of zero
> point four two**.
>
> **Macusani**, at four thousand three hundred metres, is high risk. **Sandia**, in a warmer
> valley, is low risk. That ranking comes from the clustering itself — not from hand-written
> rules."

## 5. Chuño — the seasonal module (30 s)

*Pestaña **Chuño**.*

> "Chuño is a traditional freeze-dried potato, made only in the cold dry season.
>
> This module evaluates the daily forecast against the traditional criteria: nights at or
> below **minus five degrees**, clear skies, dry air, and no rain. It flags an **optimal
> window** when at least three consecutive days meet all conditions.
>
> Outside the May-to-August season, the module reports that we are **off season**, so the app
> never gives misleading advice."

## 6. Weather history (20 s)

*Pestaña **Weather**.*

> "Here we plot the last **thirty days** of minimum and maximum temperature, plus relative
> humidity, from the Open-Meteo Archive API. The charts adapt to light and dark mode."

## 7. The API behind it (20 s)

*Abre https://frost-puno.onrender.com/docs y ejecuta `GET /ml/model-info`.*

> "Everything is served by a **FastAPI** backend on Render. Calling **model-info** returns the
> model actually in production: **K-Means**, version one point zero, with its silhouette score
> and number of clusters — so the app and the report always reflect the real deployed model.
>
> I hand over to Paul for the deployment and continuous integration."

---

## Vocabulario clave (por si te trabas)

| Español | Inglés |
|---|---|
| helada | frost |
| ganado / crías | livestock / newborns |
| cultivos | crops |
| umbral | threshold |
| pronóstico | forecast |
| agrupamiento | clustering |
| no supervisado | unsupervised |
| ventana óptima | optimal window |
| nubosidad | cloud cover |
| aprendizaje automático | machine learning |

## Preguntas probables (puedes responder en español si preguntan en español)

**"¿La app está traducida completa o solo la demo?"**
> "Está implementada la internacionalización real: hay una tabla de textos español/inglés y
> el idioma se guarda en las preferencias del usuario. La API responde en español y el cliente
> rotula según campos estructurados como el nivel de severidad."

**"¿Funciona igual en el APK de Android?"**
> "Sí, es el mismo código. En Android además se activan las notificaciones nativas, que en la
> versión web se muestran como aviso dentro de la aplicación."
