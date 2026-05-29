# External data

`inei_puno_districts.csv` is an MVP seed file for the first FrostPuno ML pipeline.

Important notes:

- It is designed to match the district-level structure expected from INEI/EstaDist exports.
- It is not a full automated extraction from INEI.
- The `source_note` column must remain visible because population values are an initial curated seed for demonstration and must be replaced by official INEI CPV 2017/EstaDist exports before production use.
- Climate data must not be sourced from INEI; the MVP uses Open-Meteo, and SENAMHI is reserved for official validation in phase 2.
