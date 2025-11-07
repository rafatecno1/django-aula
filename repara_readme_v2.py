#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Repara fitxers Markdown mal codificats (double-encoded UTF-8, Latin-1, Windows-1252)
com els que mostren caràcters 'M-CM-' o símbols estranys.
"""

import codecs
from pathlib import Path

INPUT = "README_UTF8_FIX.md"       # Fitxer original
OUTPUT = "README_UTF8_CLEAN.md"  # Fitxer reparat

# Llegeix bytes sense tocar-los
raw = Path(INPUT).read_bytes()

# Prova 1: intentar "doble decodificació" (UTF-8 → Latin1 → UTF-8)
try:
    step1 = raw.decode("utf-8", errors="ignore")
    repaired = step1.encode("latin1", errors="ignore").decode("utf-8", errors="ignore")
except Exception:
    # Prova alternativa
    repaired = raw.decode("latin1", errors="ignore")

# Neteja restes de caràcters invisibles i substitueix possibles símbols estranys
repaired = repaired.replace("Â", "")  # resta d'espais no trencables
repaired = repaired.replace("Ã§", "ç").replace("Ã©", "é").replace("Ã¨", "è").replace("Ã¡", "á")
repaired = repaired.replace("Ã", "à").replace("â€‹", "")  # zero-width
repaired = repaired.replace("M-CM-", "").replace("M-BM-", "")

# Desa el resultat final com UTF-8 net
Path(OUTPUT).write_text(repaired, encoding="utf-8")

print(f"✅ Fitxer net desat com: {OUTPUT}")
