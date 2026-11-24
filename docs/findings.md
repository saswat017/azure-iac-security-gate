# Findings: Checkov results for the insecure Azure baseline

The insecure baseline produced **21 failed checks** (12 passed). The pipeline blocks the merge on the
12 critical and high checks below; the rest are reported without blocking.
Severity labels are my own risk assessment, not Checkov's.

## Blocking findings (critical and high)

| Check ID | Resource | What it detected | Risk | Fix applied |
|---|---|---|---|---|
| CKV_AZURE_10 | NSG | SSH (22) open to `*` | Internet-wide brute-force and credential-stuffing attempts against the VM | Source limited to the VNet range (10.0.0.0/16) |
| CKV_AZURE_9 | NSG | RDP (3389) open to `*` | RDP is a common ransomware entry point | RDP rule removed (Linux VM does not need it) |
| CKV_AZURE_59, CKV_AZURE_190, CKV2_AZURE_47 | Storage account | Public blob access allowed | Anyone can read blobs without logging in, so data leaks | `allow_nested_items_to_be_public = false`, public network access off |
| CKV_AZURE_34 | Blob container | Access level `blob` (public) | Container contents readable by anonymous users | `container_access_type = "private"` |
| CKV_AZURE_3 | Storage account | HTTP allowed | Traffic can be intercepted or modified in transit | `enable_https_traffic_only = true` |
| CKV_AZURE_44 | Storage account | TLS 1.0 | Known-weak protocol, vulnerable to downgrade attacks | `min_tls_version = "TLS1_2"` |
| CKV_AZURE_1, CKV_AZURE_149, CKV_AZURE_178 | Linux VM | Password authentication | Passwords can be guessed or leaked; keys are far harder to attack | Password auth disabled, SSH key required |
| CKV_AZURE_119 | Network interface | Public IP attached | VM directly reachable from the internet | Public IP removed |

## Attack scenario (chained)

An attacker scans the internet and finds the VM's public IP with SSH open to everyone. They brute-force
the password login and get a shell. Meanwhile the storage container is public, so they can also download
its contents with no credentials at all. Each misconfiguration is bad alone; together they give
full access from outside.

## Non-blocking findings (reported only)

CKV2_AZURE_40 (shared key auth), CKV2_AZURE_33 (no private endpoint), CKV2_AZURE_41 (no SAS expiry),
CKV2_AZURE_38 (no soft delete), CKV2_AZURE_1 (no customer-managed key), CKV_AZURE_206 (no geo-replication),
CKV_AZURE_33 and CKV2_AZURE_21 (storage logging), CKV_AZURE_50 (VM extensions).
These are hardening items; I deferred them to keep the gate focused on high-impact risks.

## Known limitations

- Static scan of code only; it does not inspect live Azure resources.
- `enable_https_traffic_only` is deprecated in azurerm v4; this project pins v3.