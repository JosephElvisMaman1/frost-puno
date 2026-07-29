# English Demo Script — FrostPuno

For the exam requirement **"Funcionamiento de la aplicación en inglés" (3 points)**.
Switch the app to English first: **Home → tune icon (⚙) → Language → English**. Every
screen below then renders in English.

- Live app: https://frost-puno.vercel.app
- API docs: https://frost-puno.onrender.com/docs

Target length: **2.5–3 minutes**. Speak slowly; the words below are meant to be read aloud.

---

## 0. Switch to English (10 s)

> "Before we start, let me switch the interface language. In Settings, I select English —
> the whole app, including alerts and risk labels, is now in English."

## 1. Home and the daily alert (40 s)

> "This is FrostPuno, a frost prediction app for the high-Andean communities of Puno, Peru.
> The chip at the top shows the system is active, meaning the machine learning model is
> loaded and serving.
>
> The first card is today's frost alert. The backend reads tomorrow's forecast and compares
> the minimum temperature against the user's own threshold. When a strong frost is expected,
> this banner turns amber and says: 'Strong frost risk today. Shelter livestock and protect
> crops.' On Android, the same message is pushed as a native notification.
>
> Below it there is a dedicated **livestock card**. Frost in the altiplano kills newborn
> alpacas and sheep, so herders get their own actionable message, separate from crops.
>
> And when today's minimum is far below the recent average, an **unusual risk card** appears,
> telling the user this frost is abnormal for this time of year."

## 2. Settings — alarms and profile (25 s)

> "In Settings the user is in control. They can turn frost alarms on or off, and drag the
> slider to choose their own alert threshold — for example, warn me if the low drops below
> minus six degrees. They can also pick a profile: farmer, herder, or chuño maker. The
> profile decides which alerts are shown first on the home screen."

## 3. Zones — the unsupervised model (35 s)

> "This is where the machine learning model becomes visible. We use **K-Means**, an
> unsupervised clustering algorithm. It groups Puno's districts by their thermal regime —
> no labels, no ground truth, just the structure in the data.
>
> The header shows the model quality: three clusters, and a silhouette score of zero point
> four two. Each district is then assigned to the dominant cluster and mapped to a risk
> level. Macusani, at four thousand three hundred metres, is high risk. Sandia, in a warmer
> valley, is low risk. That ranking comes purely from the clustering, not from hand-written
> rules."

## 4. Chuño — the seasonal module (30 s)

> "Chuño is a traditional freeze-dried potato, and it is made only in the cold dry season.
> This module evaluates the daily forecast against the traditional criteria: nights at or
> below minus five degrees, clear skies, dry air, and no rain.
>
> It flags an optimal window when at least three consecutive days meet all conditions, and
> it shows the current streak. Outside the May-to-August season, the module reports that we
> are off season, so the app never gives misleading advice."

## 5. Weather history (20 s)

> "Here we plot the last thirty days of minimum and maximum temperature, plus relative
> humidity, pulled from the Open-Meteo Archive API. The user can see the cold pattern
> visually and pull to refresh. The charts adapt to light and dark mode."

## 6. The API behind it (25 s)

Open https://frost-puno.onrender.com/docs

> "Everything is served by a FastAPI backend deployed on Render. Calling
> slash-m-l slash model-info returns the model actually in production: K-Means, version
> one point zero, with its silhouette score and the number of clusters — so the app and the
> report always show the real deployed model.
>
> The other endpoints are clusters, chuño window, weather history, and today's alert, which
> returns the frost, livestock and anomaly blocks you just saw in the interface."

## 7. Closing (15 s)

> "So, in summary: an unsupervised K-Means model in production, served by a FastAPI backend
> on Render, consumed by a Flutter app on the web and as a native Android APK, with
> automated retraining and a quality gate in continuous integration."

---

## Checklist before recording

- [ ] App switched to **English** in Settings.
- [ ] Backend awake (open `/health` first — Render free tier cold-starts).
- [ ] Tabs to visit in order: Home → Zones → Chuño → Weather → (Settings) → Swagger.
- [ ] Optional: show the Android APK on a phone for the same screens.
