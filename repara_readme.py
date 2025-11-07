#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Repara codificacions malmeses en fitxers Markdown (README.md)
causades per conversions errònies entre ANSI, Latin-1 i UTF-8.
"""

import re
from pathlib import Path

# --- Configuració ---
INPUT = "README.md"       # Nom del fitxer d'entrada
OUTPUT = "README_UTF8_FIX.md"  # Nom del fitxer corregit

# --- Lectura tolerant ---
raw = Path(INPUT).read_bytes()
decoded = None

for enc in ["utf-8", "latin1", "cp1252"]:
    try:
        decoded = raw.decode(enc)
        break
    except Exception:
        continue

if decoded is None:
    raise ValueError("No s'ha pogut llegir el fitxer amb cap codificació coneguda.")

# --- Neteja de caràcters estranys i seqüències corruptes ---
# Elimina restes com M-CM-, M-BM-, etc.
decoded = re.sub(r"M-[\w\^\-@;:/]+", "", decoded)
decoded = decoded.replace("??", "")  # Elimina els interrogants substitutius

# --- Correccions habituals d'accents catalans/castellans ---
# (Només corregeix si la paraula exacta és detectable)
replacements = {
    "Instal lacio": "Instal·lació",
    "Instal lació": "Instal·lació",
    "Metode": "Mètode",
    "metode": "mètode",
    "Caracteristiques": "Característiques",
    "Administracio": "Administració",
    "administracio": "administració",
    "demostracio": "demostració",
    "carrega": "càrrega",
    "Contribucio": "Contribució",
    "contribucio": "contribució",
    "Guia": "Guia",
    "guia": "guia",
}

for k, v in replacements.items():
    decoded = re.sub(rf"\b{k}\b", v, decoded)

# --- Desa com a UTF-8 net ---
Path(OUTPUT).write_text(decoded, encoding="utf-8")
print(f"✅ Fitxer reparat desat com: {OUTPUT}")
