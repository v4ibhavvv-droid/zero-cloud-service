<div align="center">

# 🌩️ Zero Cloud Service

### Your personal AWS + Azure + GCP — running 100% on your own laptop, for ₹0

**9 open-source emulators · 1 docker-compose file · 14 containers · 6 GUIs · 188+ services**

[![Platform](https://img.shields.io/badge/platform-macOS%20Apple%20Silicon-black?logo=apple)](https://www.apple.com/mac/)
[![Docker](https://img.shields.io/badge/docker-compose%20v2-2496ED?logo=docker&logoColor=white)](https://docs.docker.com/compose/)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Verification](https://img.shields.io/badge/verified-17%2F17%20checks-success)](verification.md)
[![Cloud Bill](https://img.shields.io/badge/monthly%20cost-%240-brightgreen)](#-why-this-exists)

*No cloud account. No credit card. No free-tier limits. No data leaving your machine.*

</div>

---

## 🎯 Why this exists

Real cloud = billing anxiety, region latency, free-tier expiry emails, and "why is my demo app ₹2,400 this month?".

**Zero Cloud Service** flips that: a full multi-cloud lab that boots with **one double-click**, behaves like real AWS / Azure / GCP APIs, and never leaves `localhost`. Learn cloud, prototype apps, run CI tests, break things on purpose — then `STOP`, and your RAM comes back.

| | Real cloud | Zero Cloud Service |
|---|---|---|
| Cost | 💸 pay per request | ₹0, forever |
| Account | card + KYC | none |
| Latency | 50–300 ms | ~2 ms (loopback) |
| Data privacy | leaves your machine | never leaves |
| "Can I delete prod?" | 😰 | go ahead, it's your lab |

---

## 🧩 What's inside — 9 projects, 1 stack

| # | Upstream project | Role in the stack | License |
|---|---|---|---|
| 1 | [floci-io/floci](https://github.com/floci-io/floci) | **AWS engine** — 128 services (S3, Lambda with *real* Docker containers, DynamoDB, RDS, EKS, Cognito…) | MIT |
| 2 | [aws/aws-emulator](https://github.com/aws/aws-emulator) | **AWS official emulator** from AWS — high-fidelity ground truth, HTTPS + auth | CC0-1.0 |
| 3 | [floci-io/floci-az](https://github.com/floci-io/floci-az) | **Azure engine** — 32 services (Cosmos DB, Key Vault, Functions, VMs…) | MIT |
| 4 | [Azure/Azurite](https://github.com/Azure/Azurite) | **Azure official storage emulator** — Blob / Queue / Table | MIT |
| 5 | [floci-io/floci-gcp](https://github.com/floci-io/floci-gcp) | **GCP engine** — 28 services (GCS, Pub/Sub, BigQuery, Cloud Run…) | MIT |
| 6 | [fsouza/fake-gcs-server](https://github.com/fsouza/fake-gcs-server) | GCS-standard emulator (Google JSON + XML APIs) | BSD-2 |
| 7 | [omab/cloudbox](https://github.com/omab/cloudbox) | "LocalStack for GCP" — BigQuery, Spanner, Tasks, Scheduler, KMS, Secrets, Logging + admin UI | MIT |
| 8 | [floci-io/floci-ui](https://github.com/floci-io/floci-ui) | **Unified web console** for all three clouds | — |
| 9 | [drehelis/gcp-emulator-ui](https://github.com/drehelis/gcp-emulator-ui) | GCP data browser — Firestore query builder, Pub/Sub explorer, bucket drag & drop | — |

Everything runs from **prebuilt images** (or one tiny official Dockerfile). This repo ships **zero third-party source code** — `docker-compose.yml` + scripts + docs is all you need. Each upstream project stays in its own repo; see [Credits](#-credits--licenses).

---

## 🚀 Quick start

### One-click (macOS)

```text
1. Clone this repo
2. Double-click  START-ZeroCloud.command   → ~2 min later, browser opens the dashboard
3. Done. Use it. ( STOP-ZeroCloud.command  when you're finished — data survives )
```

> First launch on macOS may need: right-click the file → **Open → Open** (Gatekeeper). Once is enough.

### Terminal

```bash
docker compose up -d          # boot everything
open http://localhost:3010    # dashboard with every link
docker compose stop           # stop (data persists in ./data/)
```

What START does under the hood (so your laptop never chokes):
1. Starts Docker Desktop if it's asleep
2. Pulls missing images (first run only)
3. **Staged 3-wave boot** — heavy Java emulators start separately, so 8 GB laptops don't OOM
4. Waits for all **13 service endpoints** (HTTPS-aware probes)
5. **Targeted auto-repair** — if one service sulks, only *that* container restarts
6. Runs a full health check → opens the dashboard

---

## 🖥️ The GUIs

| URL | What you get |
|---|---|
| **`localhost:4510`** | ⭐ **Unified console** — browse/create/delete resources across AWS + Azure + GCP in one app |
| `localhost:4500` | floci's built-in AWS web console (auto-spawned) |
| `localhost:9090` | GCP browser — Firestore query builder, Pub/Sub topic explorer, bucket file manager |
| `localhost:8888` | Cloudbox admin — BigQuery datasets, Spanner, Tasks, KMS, Secrets |
| `localhost:4566/_floci/ui` | floci's AWS service console |
| `localhost:3010` | Landing page — dashboard of dashboards |

---

## 🗺️ Full port map

| Port | Service | API |
|---|---|---|
| `3010` | landing | dashboard |
| `4443` | fake-gcs | GCS JSON/XML |
| `4500` | floci-aws-ui | AWS console (auto) |
| `4510` | floci-ui | unified console |
| `4566` | floci | AWS (S3/EC2/Lambda/DynamoDB/…) |
| `6379-99 / 7001-19 / 9200-09` | floci proxies | ElastiCache / RDS / OpenSearch |
| `4577` | floci-az | Azure ARM-style |
| `4588` | floci-gcp | GCP |
| `8085 / 8086 / 8087` | gcloud emulators | Pub/Sub gRPC · Firestore · Datastore mode |
| `8888` | cloudbox | admin UI (`/health`) |
| `9090` | gcp-ui | GCP browser |
| `9297` | aws-emulator | AWS official (HTTPS + auth) |
| `10000 / 10001 / 10002` | azurite | Blob / Queue / Table |
| `18443 / 18080 / 18085 / 18086` | cloudbox | its own GCS / Firestore / Pub/Sub (host-remapped to avoid conflicts) |
| `8090 8123 9050 9010 9020 8091 8092` | cloudbox | Secrets · Tasks · BigQuery · Spanner · Logging · Scheduler · KMS |

---

## 🔌 Point your tools at it

<details open>
<summary><b>AWS CLI / SDK / Terraform</b> (floci :4566)</summary>

```bash
export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test

aws s3 mb s3://demo
aws s3 ls
terraform plan   # works with the standard AWS provider via AWS_ENDPOINT_URL
```
</details>

<details>
<summary><b>AWS official emulator</b> (:9297, HTTPS + auth)</summary>

```bash
# credentials + CA cert are generated at: ./data/aws-emulator/9297/
source <(cat ./data/aws-emulator/9297/emulator_credentials | sed 's/^/export /')
export AWS_ENDPOINT_URL=https://localhost:9297
export AWS_CA_BUNDLE="$PWD/data/aws-emulator/9297/ca.pem"
aws s3 ls
```
</details>

<details>
<summary><b>Azure SDK / Storage Explorer</b></summary>

```bash
export AZURE_STORAGE_CONNECTION_STRING="UseDevelopmentStorage=true"
```
Azure Storage Explorer → *Add account → Use a local emulator*, or paste:
```text
DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://127.0.0.1:10000/devstoreaccount1;QueueEndpoint=http://127.0.0.1:10001/devstoreaccount1;TableEndpoint=http://127.0.0.1:10002/devstoreaccount1;
```
</details>

<details>
<summary><b>Google Cloud SDK</b></summary>

```bash
export STORAGE_EMULATOR_HOST=http://localhost:4443/storage/v1
export PUBSUB_EMULATOR_HOST=localhost:8085
export FIRESTORE_EMULATOR_HOST=localhost:8086
# Node SDK: pin @google-cloud/storage@7 and pass a dummy service-account JSON
# (a ready-made one is in samples/gcp-dummy-service-account.json)
```
</details>

Working SDK proof-scripts live in [`samples/`](samples/) — `azure-verify.js`, `gcs-verify.js`, `firestore-verify.js`, `pubsub-verify.js`. Each one creates → reads → lists → deletes real data through the official SDKs.

---

## 🔬 Verified, not vibes

Every service in this stack passed a **functional test through its official SDK/CLI** — full log in [`verification.md`](verification.md):

| Proof | Result |
|---|---|
| `aws s3 mb/ls` inside floci *and* against Amazon's own emulator | ✅ buckets created & listed |
| Azure SDK: container → blob upload → read-back → list | ✅ |
| GCS SDK: bucket → object → download → list | ✅ |
| Firestore SDK: create / read / query / delete | ✅ |
| Pub/Sub SDK: topic → subscription → publish → **message received** | ✅ |
| Cloudbox: bucket + topic + Secrets API | ✅ |
| 13/13 endpoints + staged boot + auto-repair + one-click files | ✅ |

17/17 checks. Re-run anytime: `make health` (or double-click **STATUS**).

---

## 🛠️ Make targets

```bash
make up        # start everything
make stop      # stop (data safe)
make health    # probe all 15 endpoints
make status    # container table
make logs      # follow logs
make aws       # AWS stack only
make azure     # Azure stack only
make gcp       # GCP stack only
make reset     # ⚠️ wipe ./data — fresh cloud
```

---

## 🧠 How it's put together

```
┌──────────────────────────── YOUR MAC ────────────────────────────┐
│                                                                  │
│   Browser ──► landing :3010 ──► links to every GUI               │
│      │                                                           │
│      ├──► floci-ui :4510 ─────► AWS + Azure + GCP consoles       │
│      ├──► gcp-ui :9090 ───────► Pub/Sub / Firestore / GCS        │
│      └──► cloudbox :8888 ─────► BigQuery / Tasks / KMS admin     │
│                                                                  │
│   AWS plane    : floci :4566      + aws-emulator :9297 (HTTPS)   │
│   Azure plane  : floci-az :4577   + Azurite :10000–10002         │
│   GCP plane    : floci-gcp :4588  + fake-gcs :4443               │
│                  + gcloud emu :8085/86/87 + cloudbox :8888…      │
│                                                                  │
│   Persistence : ./data/ (bind mounts) — stop/start keeps state   │
└──────────────────────────────────────────────────────────────────┘
```

- **Staged boot** — 3 waves (engines → heavy emulators → UIs) so an 8 GB laptop boots all 14 containers without the Docker daemon choking.
- **Data survives** — floci runs in `persistent` mode, floci-az/gcp in `hybrid` (5 s flush), storage engines write to `./data/`. `STOP` keeps everything; `make reset` is the only nuke.
- **HTTPS where the real APIs are** — aws-emulator serves TLS with a generated CA in `./data/aws-emulator/9297/`.
- **Conflict-free ports** — cloudbox's internal GCS/Pub/Sub/Firestore are host-remapped to `18xxx` so the official emulators keep their canonical ports.

---

## 🩺 Troubleshooting

| Symptom | Fix |
|---|---|
| START says Docker not ready in 2 min | Open Docker Desktop manually, wait for the whale, re-run START |
| First run takes 5–10 min | Images are being pulled (~2 GB total). One-time. |
| `aws-emulator` build is slow | It downloads the official ~160 MB RPM from AWS at build. One-time. |
| Port already allocated | Another app owns it — change the left side of the mapping in `docker-compose.yml` |
| `:4500` console missing right after start | floci spawns it ~1–2 min after boot. START waits for it; refresh the page. |
| Wants a fresh cloud | `make reset` (wipes `./data/`) |
| 8 GB Mac, memory pressure | `make aws` / `make azure` / `make gcp` run one cloud at a time |

---

## ❓ FAQ

**Is this real cloud?**
No — it's a local emulation of the public APIs. Real AWS/Azure/GCP own their services; this just speaks their protocols locally so you can develop and test without them.

**Can I use it in CI?**
Yes — that's a sweet spot. `docker compose up -d && make health && <your test suite>` with the SDK env vars above.

**Will my code deploy to real cloud later?**
Yes — that's the point of API-fidelity. Point the same SDK/Terraform code at real endpoints by removing the env vars.

**Why HTTPS + credentials for aws-emulator?**
Amazon's own emulator enforces TLS and request signing like the real service — higher fidelity, slight setup cost. It's worth it.

---

## 🗺️ Roadmap

- [ ] `zcs doctor` — deeper diagnostics
- [ ] Per-cloud compose profiles toggle
- [ ] Linux + Windows (WSL2) starters
- [ ] Sample Terraform + CDK project wired to the lab
- [ ] GitHub Actions example running tests against the stack

---

## 📜 Credits & licenses

This is **orchestration glue**, not a fork: every engine/UI belongs to its authors and ships from their own images/repos.

- [floci-io/floci](https://github.com/floci-io/floci) · [floci-io/floci-az](https://github.com/floci-io/floci-az) · [floci-io/floci-gcp](https://github.com/floci-io/floci-gcp) · [floci-io/floci-ui](https://github.com/floci-io/floci-ui) — MIT
- [aws/aws-emulator](https://github.com/aws/aws-emulator) — CC0-1.0
- [Azure/Azurite](https://github.com/Azure/Azurite) — MIT
- [fsouza/fake-gcs-server](https://github.com/fsouza/fake-gcs-server) — BSD-2-Clause
- [drehelis/gcp-emulator-ui](https://github.com/drehelis/gcp-emulator-ui) · [omab/cloudbox](https://github.com/omab/cloudbox)

Orchestration in this repo (compose file, one-click scripts, health checks, docs, samples): **MIT** — see [LICENSE](LICENSE).

*Not affiliated with, endorsed by, or sponsored by Amazon Web Services, Microsoft Azure, or Google Cloud. All product names are trademarks of their respective owners.*

<div align="center">

**⭐ If this saved you a cloud bill, star it — someone else is getting those emails too.**

</div>
