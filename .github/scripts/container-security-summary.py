#!/usr/bin/env python3
import json
from collections import Counter, defaultdict
from pathlib import Path

TRIVY_JSON = Path("trivy-report.json")
GRYPE_JSON = Path("grype-report.json")
OUTPUT = Path("security-summary.md")

SEVERITY_ORDER = ["CRITICAL", "HIGH", "MEDIUM", "LOW", "UNKNOWN", "NEGLIGIBLE"]


def normalize_severity(value):
    if not value:
        return "UNKNOWN"
    return str(value).upper()


def severity_badge(severity):
    labels = {
        "CRITICAL": "🔴 Critical",
        "HIGH": "🟠 High",
        "MEDIUM": "🟡 Medium",
        "LOW": "🔵 Low",
        "NEGLIGIBLE": "⚪ Negligible",
        "UNKNOWN": "⚫ Unknown",
    }
    return labels.get(severity, severity)


def load_json(path):
    if not path.exists():
        return {}
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def parse_trivy(data):
    findings = []

    for result in data.get("Results", []):
        target = result.get("Target", "unknown")
        for vuln in result.get("Vulnerabilities", []) or []:
            findings.append({
                "scanner": "Trivy",
                "target": target,
                "id": vuln.get("VulnerabilityID", "-"),
                "severity": normalize_severity(vuln.get("Severity")),
                "package": vuln.get("PkgName", "-"),
                "installed": vuln.get("InstalledVersion", "-"),
                "fixed": vuln.get("FixedVersion") or "-",
                "title": vuln.get("Title", ""),
                "fixable": bool(vuln.get("FixedVersion")),
            })

    return findings


def parse_grype(data):
    findings = []

    for match in data.get("matches", []):
        vuln = match.get("vulnerability", {})
        artifact = match.get("artifact", {})

        fixed_versions = vuln.get("fix", {}).get("versions") or []
        fixed = ", ".join(fixed_versions) if fixed_versions else "-"

        findings.append({
            "scanner": "Grype",
            "target": data.get("source", {}).get("target", {}).get("userInput", "simple-web:local"),
            "id": vuln.get("id", "-"),
            "severity": normalize_severity(vuln.get("severity")),
            "package": artifact.get("name", "-"),
            "installed": artifact.get("version", "-"),
            "fixed": fixed,
            "title": vuln.get("description", ""),
            "fixable": fixed != "-",
        })

    return findings


def count_by_severity(findings):
    counts = Counter(f["severity"] for f in findings)
    return counts


def format_counts(counts):
    parts = []
    for sev in ["CRITICAL", "HIGH", "MEDIUM", "LOW"]:
        count = counts.get(sev, 0)
        parts.append(f"{severity_badge(sev)}: **{count}**")
    return " · ".join(parts)


def write_scanner_section(lines, scanner_name, findings):
    counts = count_by_severity(findings)
    fixable = [f for f in findings if f["fixable"] and f["severity"] in ("CRITICAL", "HIGH")]

    lines.append(f"## {scanner_name}")
    lines.append("")
    lines.append(format_counts(counts))
    lines.append("")
    lines.append(f"**Total findings:** {len(findings)}")
    lines.append("")
    lines.append(f"**Fixable HIGH/CRITICAL findings:** {len(fixable)}")
    lines.append("")

    if not findings:
        lines.append("✅ No findings detected.")
        lines.append("")
        return

    grouped = defaultdict(list)
    for f in findings:
        grouped[f["severity"]].append(f)

    for sev in SEVERITY_ORDER:
        sev_findings = grouped.get(sev, [])
        if not sev_findings:
            continue

        lines.append(f"<details open>")
        lines.append(f"<summary><strong>{severity_badge(sev)} — {len(sev_findings)}</strong></summary>")
        lines.append("")
        lines.append("| CVE ID | Package | Installed | Fixed in | Fixable |")
        lines.append("|---|---|---:|---:|---|")

        for f in sev_findings[:50]:
            fixable_icon = "✅" if f["fixable"] else "—"
            lines.append(
                f"| `{f['id']}` | `{f['package']}` | `{f['installed']}` | `{f['fixed']}` | {fixable_icon} |"
            )

        if len(sev_findings) > 50:
            lines.append(f"| ... | ... | ... | ... | Showing first 50 of {len(sev_findings)} |")

        lines.append("")
        lines.append("</details>")
        lines.append("")


def main():
    trivy_data = load_json(TRIVY_JSON)
    grype_data = load_json(GRYPE_JSON)

    trivy_findings = parse_trivy(trivy_data)
    grype_findings = parse_grype(grype_data)

    all_fixable_high_critical = [
        f for f in trivy_findings + grype_findings
        if f["fixable"] and f["severity"] in ("CRITICAL", "HIGH")
    ]

    lines = []
    lines.append("# Container security scan summary")
    lines.append("")
    lines.append("| Scanner | Total | Critical | High | Medium | Fixable HIGH/CRITICAL |")
    lines.append("|---|---:|---:|---:|---:|---:|")

    for name, findings in [("Trivy", trivy_findings), ("Grype", grype_findings)]:
        counts = count_by_severity(findings)
        fixable_hc = [
            f for f in findings
            if f["fixable"] and f["severity"] in ("CRITICAL", "HIGH")
        ]
        lines.append(
            f"| {name} | {len(findings)} | {counts.get('CRITICAL', 0)} | {counts.get('HIGH', 0)} | {counts.get('MEDIUM', 0)} | {len(fixable_hc)} |"
        )

    lines.append("")
    if all_fixable_high_critical:
        lines.append("❌ **Policy result:** Failed. Fixable HIGH/CRITICAL vulnerabilities were found.")
    else:
        lines.append("✅ **Policy result:** Passed. No fixable HIGH/CRITICAL vulnerabilities were found.")

    lines.append("")
    write_scanner_section(lines, "Trivy", trivy_findings)
    write_scanner_section(lines, "Grype", grype_findings)

    OUTPUT.write_text("\n".join(lines), encoding="utf-8")


if __name__ == "__main__":
    main()