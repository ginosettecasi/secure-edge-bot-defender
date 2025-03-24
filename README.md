# 🛡️ SecureEdgeBotDefender

A fully automated bot mitigation and edge security pipeline using **AWS Lambda@Edge**, **CloudFront**, **WAFv2**, **Terraform**, and **GitHub Actions**.

---

## 🔧 Tech Stack

- **Terraform**: Infrastructure as Code for secure, repeatable deployments
- **AWS Lambda@Edge**: Real-time request inspection & fingerprinting
- **AWS WAFv2**: Layer 7 firewall to block bots using custom logic
- **CloudFront**: Global CDN for edge-level enforcement
- **GitHub Actions**: Full CI/CD pipeline with validation and manual approvals
- **CloudWatch**: Logging, queries, and dashboards for traffic intelligence

---

## 🧠 Features

- Detects and blocks bots using headless browsers or missing headers
- Adds `x-suspicious-bot: true` header to flagged requests
- WAF rules enforce blocking before origin is hit
- Geo-blocking for unserved regions
- Rate-limiting for login abuse
- Centralized logging to CloudWatch with real-time insights
- Fully automated via GitHub Actions — no local setup required

---

## 📊 Dashboard Preview

<p align="center">
  <img src="assets/dashboard-preview.png" alt="CloudWatch Dashboard" width="700"/>
</p>

---

## 🚀 How It Works

1. Traffic hits **CloudFront**, the first edge defense
2. A **Lambda@Edge function** inspects headers and behavior
3. If suspicious, it injects a `x-suspicious-bot: true` header
4. **AWS WAFv2** blocks requests based on that header
5. All activity (BLOCK/ALLOW) is streamed into **CloudWatch Logs**
6. A **CloudWatch Dashboard** displays top threats, trends, and totals

---

## 🛠️ Setup & Deployment

Everything is deployed from GitHub Actions:

- ✅ Terraform formatting & validation
- ✅ Python linting
- ✅ Security scanning
- ✅ Terraform plan → manual approval → apply
- ✅ No local execution required

> Deployments are versioned and gated with CI for maximum control.

---

## 📂 Project Structure

. ├── terraform/ │ ├── lambda.tf │ ├── waf.tf │ ├── cloudfront.tf ├── lambda/ │ ├── bot_fingerprint.py │ └── test.html ├── .github/ │ └── workflows/ │ └── deploy.yml ├── assets/ │ └── dashboard-preview.png └── README.md

---

## 🧠 Next Steps (Optional Enhancements)

- 🧬 CAPTCHA challenge for repeat offenders
- 🔁 Replay-based detection (behavioral rate patterns)
- 🔔 CloudWatch alarms for bot traffic surges
- ☁️ CloudFront logging to S3 for compliance
- 📦 Package as a Terraform module for reuse

---

## 🧾 Summary

This repo delivers a complete edge-layer security and bot defense system using modern AWS-native tooling and DevSecOps pipelines. Designed for scale, observability, and automation — it protects applications from abuse before threats ever reach your infrastructure.
