# Replication Package for: *Problem Set 1 - Computational Methods in Economics*

**Authors:**  
Fred Milhome, Sao Paulo School of Economics - FGV, fred.milhome@fgv.br

---

## 1. Overview

This repository contains the analysis code and instructions to obtain the data necessary to replicate the results in the report named:

> *FredMilhome_pset1_CME*  
> Fred Milhome

The replication package reproduces **all tables, figures, and numbers** in the report.

---

## 2. Repository Structure

```text
.
├── data/
│   ├── raw/                          # Placeholder for original raw data
│   │   ├── Mega-Sena.xlsx/           # Results data (read about access below, not commited)
│   │   ├── Mega-Sena - example.xlsx/ # Results data structure example
│   │   └── ticket_price_history.csv
│   └── processed/                    # Placeholder for cleaned and analysis-ready data
├── code/
│   ├── data_treatment.py/            # Parses the raw data and uses it to build additional series
│   └── analysis.py                   # Code to answer parts a and e
├── output/
│   ├── tables/
│   └── figures/
├── .venv/                            # Python environment files (not committed)
├── requirements.txt                  # Pinned Python dependencies
├── LICENSE                           # License file       
└── README.md
```

## 3. Computational Environment

The analysis was conducted using Python version 3.13.5 (June 11, 2025) on a Windows 11 Pro 25H2 system. All the required Python packages and their versions are listed in the requirements.txt file located in the main directory.

## 4. Data access
Past results data for this exercise can be obtained at 
https://loterias.caixa.gov.br/Paginas/Mega-Sena.aspx, where a button named 
"Download de resultados" allows you to download it. A snapshot of the page is found in
https://web.archive.org/web/20260102020959/https://loterias.caixa.gov.br/Paginas/Mega-Sena.aspx, 
where we can see such source existed by January 14th, 2026.

Data for historical lottery ticket prices can be found in https://graficos.poder360.com.br/PEXGE/1/.
An archived version of this is found in https://web.archive.org/web/20250707005543/https://graficos.poder360.com.br/PEXGE/1/.
Before the last announcement date available, the ticket price was R$ 2. This information is used to fill the ticket_price_history.csv.

## 5. Reproducing results

After opening the project folder in VSCode, run the following in the terminal to build and activate a virtual environment and install dependencies.
```text
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

After downloading the results data and ensuring the spreadsheet has the same structure as in the example in `data/raw`, the results in the report can be reproduced running `data_treatment.py`, then `analysis.py` afterwards in the `code` folder. This will populate the `output` folder with the results.