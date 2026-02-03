# Revenue Leakage Prioritization for an Online Grocery Business

## Overview
This project is a **decision-focused analytics case study** built to answer a single business question:

**Which operational failure is causing the largest preventable net revenue loss, and should be fixed first?**

Rather than optimizing isolated metrics, the project integrates transactional, inventory, delivery, marketing, and customer feedback data to **prioritize action under constraints**.

---

## Decision Framing
The analysis evaluates three competing sources of revenue leakage:

1. **Delivery & fulfillment delays (operations)**
2. **Inventory instability (stock stress)**
3. **Marketing inefficiency**

All scenarios are evaluated against:
- **Primary metric:** Net Revenue  
- **Trade-offs:** Inventory risk, operational risk  
- **Guardrail:** Service quality (long-tail delivery delays)

---

## Data & Pipeline
- Raw datasets ingested into PostgreSQL without modification
- Explicit **raw → staging → baseline → analysis** pipeline
- Real-world data quality issues handled in staging (invalid dates, malformed numerics, header rows ingested as data)

Key layers:
- `sql/staging/` – typed, validated staging tables  
- `sql/baselines/` – weekly baseline metrics  
- `sql/analysis/` – revenue leakage and risk quantification  

---

## Baseline Findings (Summary)
- Weekly net revenue is consistently material, indicating healthy demand
- **45–77% of revenue** is associated with late deliveries
- p95 delivery delays reveal a long-tail operational reliability problem
- Customer sentiment is already under pressure (avg ratings ~3.3–3.5)

---

## Analysis & Results
- **Operations leakage:** dominant in every observed week  
- **Inventory risk exposure:** ~12% on average (max ~25%)  
- Inventory issues are real but consistently secondary to delivery failures

The magnitude gap between operational leakage and inventory risk is large and persistent.

![Revenue leakage comparison](assets/screenshots/revenue_leakage_comparison.png)


---

## Final Recommendation
**Prioritize delivery and fulfillment operations first.**

Inventory stabilization should follow as a secondary initiative.  
Marketing efficiency improvements should be deferred until execution reliability improves.

This ordering maximizes near-term revenue protection while respecting service quality constraints.

---

## Documentation
- `docs/project_objective.md` – problem framing and scope  
- `docs/staging_layer.md` – data preparation and design choices  
- `docs/baseline_findings.md` – current-state performance summary  
- `docs/decision_memo.md` – final prioritization decision  

---

## Status
Project complete.  
Focus: decision quality, not model complexity.

