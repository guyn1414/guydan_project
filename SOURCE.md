# Proposed Data Sources

## Proposal 1: Bitcoin Bid-Ask Spreads (Preferred)

### Research Question

How do Bitcoin bid-ask spreads change throughout the day and week, and how do they differ between Kraken and Bitstamp?

The bid-ask spread is the difference between the lowest selling price (ask) and the highest buying price (bid).

We want to check whether spreads are larger at certain hours or days, and whether the two exchanges show similar results.

### Source 1: Kraken

- **Description:** A cryptocurrency exchange that provides live order book data.
- **URL:** https://api.kraken.com/0/public/Depth?pair=XBTUSD&count=5
- **Data:** Bitcoin/USD bid and ask prices, order quantities, and timestamps.
- **Updates:** Continuously throughout the day.
- **Access:** Public API. No login or API key required.
- **Sample size:** Approximately 1–5 KB per request.
- **Example from our test (November 7, 2026):**
  - Best bid: $75,513.40
  - Best ask: $75,513.50
  - Spread: $0.10

### Source 2: Bitstamp

- **Description:** A cryptocurrency exchange that provides current market prices.
- **URL:** https://www.bitstamp.net/api/v2/ticker/btcusd/
- **Data:** Bitcoin/USD bid, ask, last traded price, trading volume, and timestamp.
- **Updates:** Continuously throughout the day.
- **Access:** Public API. No login or API key required.
- **Sample size:** Less than 1 KB per request.
- **Example from our test (November 7, 2026):**
  - Bid: $75,538.45
  - Ask: $75,538.46
  - Last price: $75,538.46

### Collection Plan

We plan to collect data from both exchanges every 15 minutes and save each sample with a UTC timestamp.

The total expected storage for the semester is well below 500 MB.

### Limitations

Prices can change very quickly, so the samples from the two exchanges may not represent exactly the same moment. Historical order book snapshots may also be unavailable, making regular collection important.

---

## Proposal 2: London Underground Disruptions and Bike Availability

### Research Question

Is there a relationship between disruptions on the London Underground and the number of rental bikes available at selected docking stations?

We want to see whether fewer bikes are available when more Underground lines experience delays or disruptions.

### Source 1: Transport for London - BikePoint

- **Description:** Live availability information for rental bikes at docking stations in London.
- **URL:** https://api.tfl.gov.uk/Occupancy/BikePoints/BikePoints_1,BikePoints_2
- **Data:** Station name, number of available bikes, standard bikes, electric bikes, and empty docks.
- **Updates:** Regularly throughout the day as station availability changes.
- **Access:** Public API. Our test worked without an API key. TfL also offers developer registration.
- **Sample size:** A few KB when requesting a small group of stations.
- **Example from our test (November 8, 2026):**
  - River Street: 2 available bikes, including 0 electric bikes.
  - Phillimore Gardens: 10 available bikes, including 2 electric bikes.

### Source 2: Transport for London - Tube Status

- **Description:** Current service status of London Underground lines.
- **URL:** https://api.tfl.gov.uk/line/mode/tube/status
- **Data:** Line names, service status, disruption severity, and explanations of delays.
- **Updates:** When service conditions or disruptions change.
- **Access:** Public API. Our test worked without an API key. TfL also offers developer registration.
- **Sample size:** Expected to be a few tens of KB per request.
- **Example from our test (November 8, 2026):**
  - Line: Bakerloo
  - Status: Severe Delays
  - Reported reason: Infrastructure damage and a points failure.

### Collection Plan

We plan to monitor approximately 15–20 selected bike stations and the status of Underground lines every 30 minutes.

We will save the relevant data with UTC timestamps and compare bike availability during normal service and during disruptions.

By limiting the number of stations and storing only relevant fields, we expect to remain below 500 MB for the semester.

### Limitations

Underground disruptions are not necessarily the reason for changes in bike availability. Other factors, such as weather, time of day, and weekends, may also affect the results.

This project will examine relationships in the collected data, not prove cause and effect.

---

## Ranking and Preferred Proposal

**1. Bitcoin Bid-Ask Spreads — Preferred**

We prefer this proposal because both APIs are simple to use, the data changes frequently, and the analysis is relatively straightforward.

**2. London Underground Disruptions and Bike Availability — Alternative**

This proposal is also interesting and uses live data, but comparing the two sources may require more work.

Both proposals use public APIs that we successfully tested from our Linux virtual machine on November 7–8, 2026.

Our final choice will depend on the lecturer's approval.
