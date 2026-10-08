#!/usr/bin/env python3

import json
import os
import subprocess
import sys
import requests

APSTRA_URL = os.environ.get("APSTRA_URL")
APSTRA_USERNAME = os.environ.get("APSTRA_USER")
APSTRA_PASSWORD = os.environ.get("APSTRA_PASS")

VERIFY_SSL = False


def fail(message):
    print(f"ERROR: {message}")
    sys.exit(1)


def get_blueprint_id():
    try:
        result = subprocess.run(
            ["terraform", "output", "-json"],
            capture_output=True,
            text=True,
            check=True,
        )

        outputs = json.loads(result.stdout)

        return outputs["blueprint_id"]["value"]

    except Exception as exc:
        fail(f"Unable to retrieve blueprint_id output: {exc}")


def login():
    response = requests.post(
        f"{APSTRA_URL}/api/aaa/login",
        json={
            "username": APSTRA_USERNAME,
            "password": APSTRA_PASSWORD,
        },
        verify=VERIFY_SSL,
        timeout=30,
    )
    response.raise_for_status()
    token = response.json().get("token")
    if not token:
        fail("Authentication succeeded but no token returned")
    return token


def get_anomalies(token, blueprint_id):
    headers = {
        "AUTHTOKEN": token
    }
    response = requests.get(
        f"{APSTRA_URL}/api/blueprints/{blueprint_id}/anomalies",
        headers=headers,
        verify=VERIFY_SSL,
        timeout=30,
    )
    response.raise_for_status()
    return response.json()


def validate_anomalies(anomalies):
    critical = []
    for anomaly in anomalies:
        severity = anomaly.get("severity", "").lower()
        if severity in ["critical", "error"]:
            critical.append(anomaly)
    if critical:
        print("\nCritical anomalies found:\n")
        for item in critical:
            print(
                f"- {item.get('severity')}: "
                f"{item.get('description')}"
            )
        sys.exit(1)
    print("No critical anomalies detected")

def validate_anomalies_new(anomalies_response):
    anomalies = anomalies_response.get("items", [])
    critical = [
        a for a in anomalies
        if a.get("severity", "").lower() == "critical"
    ]
    if critical:
        print(
            f"\nFound {len(critical)} critical anomaly(s)\n"
        )
        for anomaly in critical:
            print("=" * 60)
            print(
                f"Type: {anomaly.get('anomaly_type')}"
            )
            print(
                f"Node: {anomaly.get('anomalous_node_id')}"
            )
            print(
                f"Expected: {anomaly.get('expected')}"
            )
            print(
                f"Actual: {anomaly.get('actual')}"
            )
        sys.exit(1)
    print("No critical anomalies detected")

def main():

    if not APSTRA_URL:
        fail("TF_VAR_apstra_url not set")

    if not APSTRA_USERNAME:
        fail("TF_VAR_apstra_username not set")

    if not APSTRA_PASSWORD:
        fail("TF_VAR_apstra_password not set")

    blueprint_id = get_blueprint_id()

    print(f"Blueprint ID: {blueprint_id}")

    token = login()

    anomalies = get_anomalies(
        token,
        blueprint_id,
    )

    validate_anomalies_new(anomalies)

    print("Blueprint validation passed")


if __name__ == "__main__":
    main()
