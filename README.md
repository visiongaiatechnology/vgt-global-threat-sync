# 🌐 VGT Global Threat Sync — Daily Threat Intelligence Engine

[![License](https://img.shields.io/badge/License-AGPLv3-green?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Linux-FCC624?style=for-the-badge&logo=linux)](https://kernel.org)
[![Kernel](https://img.shields.io/badge/Layer-Kernel_Level-red?style=for-the-badge)](#)
[![Status](https://img.shields.io/badge/Status-DIAMANT-purple?style=for-the-badge)](#)
[![Feeds](https://img.shields.io/badge/Threat_Feeds-6_Sources-orange?style=for-the-badge)](#)
[![Cron](https://img.shields.io/badge/Sync-Daily_04:00-blue?style=for-the-badge)](#)
[![VGT](https://img.shields.io/badge/VGT-VisionGaia_Technology-red?style=for-the-badge)](https://visiongaiatechnology.de)
[![Donate](https://img.shields.io/badge/Donate-PayPal-00457C?style=for-the-badge&logo=paypal)](https://www.paypal.com/paypalme/dergoldenelotus)

> *"Don't wait for the attack. Block the attacker before they arrive."*

**VGT Global Threat Sync** is a zero-downtime, atomic threat intelligence synchronization engine for Linux servers. It pulls live data from 6 authoritative threat feeds daily, aggregates tens of thousands of malicious IPs and subnets, and injects them directly into the kernel via `ipset` — using an atomic swap mechanism that guarantees zero protection gap during updates.

No downtime. No race conditions. No gaps. Pure kernel-level prevention.

---

## 🔗 VGT Linux Defense Ecosystem

Three tools. One philosophy. Complete coverage.

| Tool | Type | Purpose |
|---|---|---|
| 🌐 **VGT Global Threat Sync** | **Preventive** | Blocks known attackers before they arrive |
| ⚔️ **[VGT Auto-Punisher](https://github.com/visiongaiatechnology/vgt-auto-punisher)** | **Reactive** | Bans attackers the moment they hit your server |
| 🔥 **[VGT Windows Firewall Burner](https://github.com/visiongaiatechnology/vgt-windows-burner)** | **Windows** | 280,000+ APT IPs burned into Windows Firewall |

> **The complete stack:** Threat Sync blocks the known threats. Auto-Punisher eliminates the unknown ones in real-time.

---

## 🚨 The Problem — Reactive Security Is Not Enough

Tools like Fail2Ban and Auto-Punisher are reactive — they ban after the first attack. Known botnet infrastructure, APT C2 servers, and repeat offenders can still land that first hit.

| Reactive Only | Reactive + Global Threat Sync |
|---|---|
| ❌ Known botnet hits you first | ✅ Known botnet blocked before first packet |
| ❌ Repeat offenders retry daily | ✅ Already banned from previous sync |
| ❌ No intelligence about known bad actors | ✅ 6 authoritative feeds, updated daily |
| ❌ Manual blocklist management | ✅ Fully automated, zero-downtime updates |
| ❌ Update gaps expose the server | ✅ Atomic swap — no protection gap ever |

---

## 🛡️ Threat Intelligence Sources — Platin Selection

```
Feodo Tracker (abuse.ch)    →  Botnet C2 servers (Emotet, TrickBot, etc.)
Spamhaus DROP               →  "Don't Route Or Peer" — worst of the internet
Spamhaus EDROP              →  Extended DROP list — hijacked netblocks
CINS Score (cinsscore.com)  →  Continuous threat scoring feed
Blocklist.de                →  Attack IPs reported by intrusion sensors worldwide
Emerging Threats (Proofpoint) →  Commercial-grade threat intelligence, free feed
```

Combined: **Tens of thousands of IPs and subnets** updated daily from authoritative sources.

---

## ⚡ The Atomic Swap Architecture

This is what makes VGT Global Threat Sync different from a simple cron script:

```
Standard approach (with downtime gap):
    Flush live set → [UNPROTECTED GAP] → Load new IPs → Protected again

VGT Atomic Swap (zero-downtime):
    Load new IPs into SHADOW set (server stays protected by LIVE set)
        ↓
    ipset swap SHADOW LIVE  ← atomic kernel operation, nanoseconds
        ↓
    Destroy old SHADOW set
    Server never had a gap. Ever.
```

```bash
# The magic line:
ipset swap $IPSET_TMP $IPSET_LIVE
```

One command. Atomic. Zero-downtime. The kernel swaps both sets simultaneously.

---

## 🔒 Feed Integrity Validation

Before any swap occurs, the script validates feed integrity:

```bash
if [ "$L_COUNT" -lt 5000 ]; then
    echo "[KRITISCH] Feed-Integrität kompromittiert. Abbruch."
    exit 1
fi
```

If a feed is down, returns garbage, or is compromised — the sync aborts. Your existing protection stays intact. No silent failures.

---

## 📊 Live Output

```
[VGT] Starte globale Threat-Intelligence Synchronisation...
[VGT] Ingesting Feed: feodotracker.abuse.ch...
[VGT] Ingesting Feed: spamhaus DROP...
[VGT] Ingesting Feed: spamhaus EDROP...
[VGT] Ingesting Feed: cinsscore.com...
[VGT] Ingesting Feed: blocklist.de...
[VGT] Ingesting Feed: emergingthreats...
[VGT] 47,832 Bedrohungs-Vektoren identifiziert. Injektiere in Shadow-Memory...
[VGT] Führe atomaren State-Swap durch...
[VGT] Matrix in rules.v4 gebrannt.
[VGT] SYNCHRONISATION ABGESCHLOSSEN. Status: DIAMANT.
```

---

## 🚀 Installation

### Requirements
- Linux (Debian / Ubuntu / CentOS)
- Root access
- `curl`, `ipset`, `iptables`, `awk`, `grep`

### Setup

```bash
# Clone the repository
git clone https://github.com/visiongaiatechnology/vgt-global-threat-sync.git
cd vgt-global-threat-sync

# Make executable
chmod +x vgt_global_threat_sync.sh

# Run first sync manually
sudo ./vgt_global_threat_sync.sh
```

### Automate with Cron (Recommended)

```bash
# Edit crontab
sudo crontab -e

# Add this line — runs daily at 04:00
0 4 * * * /root/vgt_global_threat_sync.sh > /dev/null 2>&1
```

Daily sync at 04:00 — fresh threat intelligence every morning before business hours.

---

## 🔍 Managing the Blocklist

```bash
# Count currently blocked IPs
ipset list VGT_GLOBAL_THREAT | grep -c "^[0-9]"

# View all blocked ranges
ipset list VGT_GLOBAL_THREAT

# Emergency flush (removes all threat sync blocks)
ipset flush VGT_GLOBAL_THREAT

# Manual sync trigger
sudo ./vgt_global_threat_sync.sh
```

---

## 🏗️ Combining With Auto-Punisher

The complete Linux defense stack:

```
04:00 daily  →  Threat Sync updates known bad actors (preventive)
24/7         →  Auto-Punisher terminates unknown attackers in real-time (reactive)

Result: Known threats never reach you. Unknown threats get one shot — then permanent ban.
```

```bash
# Run both as systemd services for complete coverage
systemctl enable vgt-punisher
systemctl start vgt-punisher
# + cron for threat sync
```

---

## 📦 System Specs

```
ARCHITECTURE      Atomic Shadow-Swap (Zero-Downtime Updates)
THREAT_FEEDS      6 authoritative sources
SYNC_SCHEDULE     Daily via cron (recommended: 04:00)
BAN_MECHANISM     ipset hash:net (O(1) lookup complexity)
INTEGRITY_CHECK   Aborts if feed returns < 5,000 IPs
PERSISTENCE       iptables-save → /etc/iptables/rules.v4
OVERHEAD          ~0% CPU after sync (kernel-level O(1) lookups)
DEPENDENCIES      curl, ipset, iptables, awk, grep
```

---

## ⚠️ Important Notes

- **Run as root** — kernel-level operations require root privileges
- **First run takes ~30 seconds** — feed downloads + injection
- **Subsequent runs are fast** — atomic swap is near-instant
- **Feed integrity check** — sync aborts if feeds look compromised
- **Combine with Auto-Punisher** — for reactive coverage of unknown threats

---

## 🤝 Contributing

Pull requests are welcome. Additional feed suggestions especially appreciated.

Licensed under **AGPLv3** — *"For Humans, not for SaaS Corporations."*

---

## ☕ Support the Project

VGT Global Threat Sync is free. If it keeps your server clean:

[![Donate via PayPal](https://img.shields.io/badge/Donate-PayPal-00457C?style=for-the-badge&logo=paypal)](https://www.paypal.com/paypalme/dergoldenelotus)

---

## 🏢 Built by VisionGaia Technology

[![VGT](https://img.shields.io/badge/VGT-VisionGaia_Technology-red?style=for-the-badge)](https://visiongaiatechnology.de)

VisionGaia Technology builds enterprise-grade security and AI tooling — engineered to the DIAMANT VGT SUPREME standard.

> *"Reactive security is brave. Preventive security is smart. Use both."*

---

*Version 1.0.0 (DIAMANT SUPREME) — VGT Global Threat Sync // Atomic Threat Intelligence Engine*
