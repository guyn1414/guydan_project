# Data Source

## Research Question

After accounting for weather, road traffic and time of day, are disruptions on the London Underground still associated with changes in the number of rental bikes available at selected docking stations? Which stations are affected most, and how quickly does bike availability return to normal after a disruption ends?

---

## 1. Approved Data Sources

| Name | URL | Data format | Key / username required | License | Sampling frequency |
|---|---|---|---|---|---|
| TfL BikePoint Occupancy | https://api.tfl.gov.uk/Occupancy/BikePoints/BikePoints_1,BikePoints_2 | JSON | No (optional free registration raises the rate limit) | TfL Open Data, free to use with the attribution "Powered by TfL Open Data" | Every 30 minutes |
| TfL Tube Status | https://api.tfl.gov.uk/line/mode/tube/status | JSON | No (optional free registration raises the rate limit) | TfL Open Data, free to use with the attribution "Powered by TfL Open Data" | Every 30 minutes |
| Open-Meteo Weather | https://api.open-meteo.com/v1/forecast?latitude=51.51&longitude=-0.13&current=temperature_2m,precipitation,wind_speed_10m | JSON | No | Data under CC BY 4.0; free API for non-commercial use (up to 10,000 calls per day) | Every 30 minutes |
| TfL Road Status | https://api.tfl.gov.uk/Road/all/Status | JSON | No (optional free registration raises the rate limit) | TfL Open Data, free to use with the attribution "Powered by TfL Open Data" | Every 30 minutes |

Each sample calls all four sources at the same moment and saves the four responses together in one JSON file:
`raw/YYYY-mm-dd/HHMM.json` (UTC time), with the top-level keys `bikes`, `tube`, `weather` and `roads`.

We collect data from 2 docking stations:

| Station ID | Station name |
|---|---|
| BikePoints_1 | River Street, Clerkenwell |
| BikePoints_2 | Phillimore Gardens |

---

## 2. What Is Collected

- **Bikes:** for each selected docking station, the number of available bikes (standard and electric), empty docks and total docks.
- **Tube:** the current service status of each of the 11 Underground lines (for example "Good Service", "Minor Delays", "Severe Delays").
- **Weather:** current temperature, precipitation and wind speed in central London. Open-Meteo updates these values every 15 minutes.
- **Roads:** the current traffic status of 24 major road corridors in London (for example "Good" or "Serious").

The sources have different structures: one record per station, one per line, one per road, and a single weather record. The schema below combines them into one row per bike station per sample, so every row contains the station's availability together with the conditions at that moment.

---

## 3. Schema (dataset.csv)

One row per docking station per sample.

| Column | Content | Units / format |
|---|---|---|
| `sample_time_utc` | Time the sample was taken, from the file path | ISO 8601, UTC (e.g. 2026-11-17T16:01) |
| `station_id` | Docking station identifier | Text (e.g. BikePoints_1) |
| `station_name` | Docking station name | Text |
| `bikes_available` | Total available bikes | Count |
| `standard_bikes` | Available standard bikes | Count |
| `ebikes` | Available electric bikes | Count |
| `empty_docks` | Empty docks | Count |
| `total_docks` | Total docks at the station | Count |
| `temperature_c` | Air temperature at 2 m | °C |
| `precipitation_mm` | Precipitation in the preceding interval | mm |
| `wind_speed_kmh` | Wind speed at 10 m | km/h |
| `weather_time_utc` | Time the weather values refer to | ISO 8601, UTC |
| `tube_lines_not_good` | Number of Underground lines whose status is not "Good Service" | Count (0–11) |
| `tube_bakerloo_status` … `tube_waterloo_city_status` | Status of each line (11 columns, one per line) | Text (e.g. "Good Service"). If a line reports several statuses, they are joined with " \| " |
| `roads_not_good` | Number of road corridors whose status is not "Good" | Count (0–24) |

The 11 line columns are: `tube_bakerloo_status`, `tube_central_status`, `tube_circle_status`, `tube_district_status`, `tube_hammersmith_city_status`, `tube_jubilee_status`, `tube_metropolitan_status`, `tube_northern_status`, `tube_piccadilly_status`, `tube_victoria_status`, `tube_waterloo_city_status`.

---

## 4. Reasons for the Chosen Columns

**Kept:**
- The bike counts are the main variable we want to explain. Standard and electric bikes are kept separately because they may react differently, for example in bad weather.
- `total_docks` lets us compare stations of different sizes as a percentage of capacity.
- A separate status column for each Tube line lets us link a disruption on a specific line to the bike stations near that line. `tube_lines_not_good` gives a quick overall measure of the network's condition.
- Temperature, precipitation and wind are the weather factors most likely to affect cycling. `weather_time_utc` shows which time the values describe, since Open-Meteo updates only every 15 minutes.
- `roads_not_good` summarises road traffic in a single number. A separate column for each of the 24 corridors would add many columns with little benefit for our question.

**Not kept:**
- Technical fields with no analytical value: `$type`, `created`, `modified`, `serviceTypes`, `crowding`, `routeSections`, `url`, `generationtime_ms`.
- Fields that are identical in every sample: `modeName`, `latitude`, `longitude`, `elevation`, `timezone`, `timezone_abbreviation`, `utc_offset_seconds`, `current_units`, `interval`.
- Road geometry (`bounds`, `envelope`) and the road aggregation dates (`statusAggregationStartDate`, `statusAggregationEndDate`).
- Free-text disruption explanations and `validityPeriods`. They are useful for reading but hard to analyse as numbers. They remain available in the raw files if we need them later.

---

## 5. Field Name Translation

| Source | Source field | Schema column |
|---|---|---|
| File path | `raw/YYYY-mm-dd/HHMM.json` | `sample_time_utc` |
| BikePoint | `id` | `station_id` |
| BikePoint | `name` | `station_name` |
| BikePoint | `bikesCount` | `bikes_available` |
| BikePoint | `standardBikesCount` | `standard_bikes` |
| BikePoint | `eBikesCount` | `ebikes` |
| BikePoint | `emptyDocks` | `empty_docks` |
| BikePoint | `totalDocks` | `total_docks` |
| Open-Meteo | `current.temperature_2m` | `temperature_c` |
| Open-Meteo | `current.precipitation` | `precipitation_mm` |
| Open-Meteo | `current.wind_speed_10m` | `wind_speed_kmh` |
| Open-Meteo | `current.time` | `weather_time_utc` |
| Tube Status | `lineStatuses[].statusSeverityDescription` of the line with `id` = X | `tube_X_status` (e.g. `id` = "bakerloo" → `tube_bakerloo_status`) |
| Tube Status | Count of lines where `lineStatuses[].statusSeverity` ≠ 10 | `tube_lines_not_good` |
| Road Status | Count of corridors where `statusSeverity` ≠ "Good" | `roads_not_good` |

---

## 6. Expected Size (one semester)

Assumptions: sampling every 30 minutes (48 samples per day) for about 100 days, which gives about 4,800 samples, with 2 docking stations.

- **raw folder:** each sample file is about 30–40 KB (most of it is the Tube and Road responses). 4,800 × ~35 KB ≈ **170 MB**.
- **dataset.csv:** 4,800 samples × 2 stations = 9,600 rows. At about 400 bytes per row (mostly the 11 Tube status columns) ≈ **4 MB**.

Both are well below the 500 MB limit.
