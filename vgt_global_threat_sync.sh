#!/bin/bash
# VISIONGAIATECHNOLOGY OMEGA PROTOCOL
# Modul: GLOBAL_THREAT_SYNC (Daily Threat Intelligence)
# Status: DIAMANT VGT SUPREME
# Architektur: Atomarer Swap, Zero-Downtime, O(1) Suchkomplexität
#
# Cronjob Setup (Täglich um 04:00 Uhr):
# 0 4 * * * /root/vgt_global_threat_sync.sh > /dev/null 2>&1

# 1. System-Voraussetzungen
if [[ $EUID -ne 0 ]]; then 
   echo "[FEHLER] VGT_SEC_VIOLATION: Root-Privilegien erforderlich."
   exit 1
fi

for tool in curl ipset iptables awk grep; do
    if ! command -v $tool &> /dev/null; then
        echo "[FEHLER] $tool fehlt."
        exit 1
    fi
done

echo "[VGT] Starte globale Threat-Intelligence Synchronisation..."

# 2. VGT Konfiguration
IPSET_LIVE="VGT_GLOBAL_THREAT"
IPSET_TMP="VGT_GLOBAL_THREAT_TMP"
RULES_FILE="/etc/iptables/rules.v4"
T_BATCH=$(mktemp)

# 3. Hochwertige Threat-Feeds (Platin-Auswahl + Erweiterung)
FEEDS=(
    "https://feodotracker.abuse.ch/downloads/ipblocklist.txt"
    "https://www.spamhaus.org/drop/drop.txt"
    "https://www.spamhaus.org/drop/edrop.txt"
    "https://cinsscore.com/list/ci-badguys.txt"
    "https://www.blocklist.de/downloads/export-ips_all.txt"
    "https://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt"
)

# 4. Atomare Vorbereitung (Shadow Set)
ipset create $IPSET_TMP hash:net -exist
ipset flush $IPSET_TMP

# 5. Daten-Extraktion & Aggregation
IPV4_REGEX='([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]{1,2})?'

for feed in "${FEEDS[@]}"; do
    echo "[VGT] Ingesting Feed: $feed"
    curl -s --connect-timeout 10 "$feed" | \
    grep -Eo "$IPV4_REGEX" | \
    awk -v set="$IPSET_TMP" '{print "add " set " " $1 " -exist"}' >> "$T_BATCH"
done

# Zähle die extrahierten Bedrohungen
L_COUNT=$(wc -l < "$T_BATCH")
if [ "$L_COUNT" -lt 5000 ]; then
    echo "[KRITISCH] Feed-Integrität kompromittiert (nur $L_COUNT IPs). Abbruch."
    ipset destroy $IPSET_TMP
    rm -f "$T_BATCH"
    exit 1
fi

echo "[VGT] $L_COUNT Bedrohungs-Vektoren identifiziert. Injektiere in Shadow-Memory..."
ipset restore < "$T_BATCH"
rm -f "$T_BATCH"

# 6. ATOMARER SWAP
ipset create $IPSET_LIVE hash:net -exist
echo "[VGT] Führe atomaren State-Swap durch..."
ipset swap $IPSET_TMP $IPSET_LIVE
ipset destroy $IPSET_TMP

# 7. IPTables Link Härtung
iptables -C INPUT -m set --match-set $IPSET_LIVE src -j DROP 2>/dev/null
if [ $? -ne 0 ]; then
    echo "[VGT] Etabliere IPTables-Link (Position 1)..."
    iptables -I INPUT 1 -m set --match-set $IPSET_LIVE src -j DROP
fi

# 8. System-Persistenz
if [ -d /etc/iptables ]; then
    iptables-save > $RULES_FILE
    echo "[VGT] Matrix in rules.v4 gebrannt."
fi

echo "[VGT] SYNCHRONISATION ABGESCHLOSSEN. Status: DIAMANT."
