# 🛡️ SecureEdgeBotDefender

A fully automated bot mitigation and edge security infrastructure pipeline built using **AWS Lambda@Edge**, **CloudFront**, **WAFv2**, **Terraform**, and **GitHub Actions**.

This solution defends globally-distributed applications from malicious bots by identifying suspicious patterns at the edge, enforcing Web Application Firewall (WAF) rules, and visualizing attack data in CloudWatch — all deployed without any local execution.

---

## ⚙️ Architecture Overview

┌───────────────┐ │ End User │ └──────┬────────┘ │ ▼ ┌────────────────────┐ │ CloudFront CDN │◄────── Global Edge Network │ + WAFv2 Rules │ │ + Lambda@Edge Hook │ └──────┬─────────────┘ │ ▼ ┌────────────────────────────┐ │ Lambda@Edge Fingerprinter │ │ - Detects headless bots │ │ - Parses missing headers │ │ - Flags suspicious traffic│ └──────┬─────────────────────┘ │ injects ▼ ┌────────────────────────────┐ │ WAF Custom Rules │ │ - x-suspicious-bot check │ │ - Geo blocking │ │ - Rate limiting │ └────────────────────────────┘ │ ▼ ┌────────────────────┐ │ S3 Static Origin │ └────────────────────┘

---

## 🔐 Key Features

- **Lambda@Edge bot fingerprinting**
  - Flags requests missing `Accept-Language` or using suspicious `User-Agent`
  - Adds `x-suspicious-bot: true` header to malicious traffic
- **WAFv2 enforcement**
  - Custom rule blocks traffic based on bot fingerprint
  - Rate-limiting login endpoints
  - Geo-blocking high-risk countries
- **CloudWatch logging + insights**
  - Logs all request evaluations (BLOCK/ALLOW)
  - Dashboard tracks top reasons, bot trends, and decisions
- **CI/CD with GitHub Actions**
  - Automated linting, validation, and Terraform deployment
  - Manual approval gate before production apply
- **No local execution required**
  - All infrastructure is deployed and managed in GitHub Actions

---

## 🧱 Technologies Used

| Tech           | Purpose                               |
|----------------|----------------------------------------|
| **Terraform**  | Infrastructure as Code (WAF, Lambda, S3, CloudFront) |
| **GitHub Actions** | Automated pipeline with approval flow |
| **AWS Lambda@Edge** | Inspect and classify HTTP requests |
| **AWS WAFv2**  | Block suspicious bots at the edge     |
| **AWS CloudFront** | Global content delivery & entry point |
| **AWS CloudWatch** | Logging and dashboarding           |

---

## 📊 CloudWatch Dashboard (Live Data)

The dashboard tracks:

- 📈 **Blocked bot activity over time**
- 🔎 **Top reasons requests were flagged**
- ⚖️ **Allow vs Block breakdown**

> Example Log Entry:
> ```
> [BLOCK] Bot-like request flagged: ["Missing Accept-Language header", "Headless browser detected"]
> ```

---

## 🧪 How It Works

1. **User Request** hits CloudFront
2. **Lambda@Edge** inspects headers and behavior
3. If suspicious, it adds a custom header
4. **AWS WAFv2** checks for the fingerprint
5. If flagged, the request is blocked immediately — before it hits the origin
6. Decision is logged to **CloudWatch** in near real-time

---

## 🚀 Deployment Pipeline

All infra is deployed via GitHub Actions using the following steps:

1. `terraform fmt`, `validate`, and `lint`
2. `terraform plan` runs on PR or push
3. **Manual approval gate**
4. `terraform apply` executed via CI/CD
5. Lambda artifact (`bot_fingerprint.py`) is zipped and deployed
6. All logs flow into CloudWatch

---

## 📦 Project Structure

├── terraform/ │ ├── lambda.tf │ ├── waf.tf │ ├── cloudfront.tf ├── lambda/ │ ├── bot_fingerprint.py ├── .github/workflows/ │ ├── deploy.yml ├── README.md

---

## 🧠 Next Enhancements (Future Work)

- CAPTCHA challenge for repeat offenders
- Bot behavior fingerprinting via device/browser entropy
- Integration with third-party analytics or SIEM
- Alerting and auto-remediation for traffic anomalies

---

## 💬 Summary

This project demonstrates how to detect and block bot traffic at the edge using modern AWS services, zero local execution, and observability through real-time dashboards. It is fully modular, automated, and production-ready.


