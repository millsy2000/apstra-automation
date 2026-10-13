#!/usr/bin/env python3

import json
import os
import subprocess
import sys
import requests

APSTRA_URL = os.environ.get("APSTRA_URL")
APSTRA_USERNAME = os.environ.get("APSTRA_USERNAME")
APSTRA_PASSWORD = os.environ.get("APSTRA_PASSWORD")

VERIFY_SSL = False


def fail(message):
    print(f"\nERROR: {message}\n")
    sys.exit(1)


def get_blueprint_id():

    result = subprocess.run(
        ["terraform", "output", "-json"],
        capture_output=True,
        text=True,
        check=True
    )

    outputs = json.loads(result.stdout)

    return outputs["blueprint_id"]["value"]


def login():

    response = requests.post(
        f"{APSTRA_URL}/api/aaa/login",
        json={
            "username": APSTRA_USERNAME,
            "password": APSTRA_PASSWORD
        },
        verify=VERIFY_SSL,
        timeout=30,
    )

    response.raise_for_status()

    token = response.json().get("token")

    if not token:
        fail("Authentication token not returned")

    return token


def get_build_errors(token, blueprint_id):

    headers = {
        "AUTHTOKEN": token
    }

    response = requests.get(
        f"{APSTRA_URL}/api/blueprints/{blueprint_id}/errors",
        headers=headers,
        verify=VERIFY_SSL,
        timeout=30
    )

    response.raise_for_status()

    return response.json()


def validate_build_errors(errors_response):

    errors_count = errors_response.get(
        "errors_count",
        0
    )

    warnings_count = errors_response.get(
        "warnings_count",
        0
    )

    print(
        f"Build Errors: {errors_count}"
    )

    print(
        f"Build Warnings: {warnings_count}"
    )

    if errors_count == 0:

        print(
            "\nNo blueprint build errors detected.\n"
        )

        return

    print(
        f"\nFound {errors_count} build errors\n"
    )

    nodes = errors_response.get(
        "nodes",
        {}
    )

    for node_name, node_errors in nodes.items():

        print(
            f"\nNode: {node_name}"
        )

        print("-" * 80)

        for error in node_errors:

            print(
                f"Severity     : {error.get('severity')}"
            )

            print(
                f"Category     : {error.get('display_category')}"
            )

            print(
                f"Type         : {error.get('error_type')}"
            )

            print(
                f"Entity Type  : {error.get('entity_type')}"
            )

            print(
                f"Message      : {error.get('message')}"
            )

            print()

            resolutions = error.get(
                "resolutions",
                []
            )

            if resolutions:

                print(
                    "Suggested Resolutions:"
                )

                for resolution in resolutions:

                    print(
                        f"  - {resolution.get('hint')}"
                    )

            print()

    sys.exit(1)


def main():

    if not APSTRA_URL:
        fail("TF_VAR_apstra_url not set")

    if not APSTRA_USERNAME:
        fail("TF_VAR_apstra_username not set")

    if not APSTRA_PASSWORD:
        fail("TF_VAR_apstra_password not set")

    blueprint_id = get_blueprint_id()

    print(
        f"Blueprint ID: {blueprint_id}"
    )

    token = login()

    build_errors = get_build_errors(
        token,
        blueprint_id
    )

    validate_build_errors(
        build_errors
    )


if __name__ == "__main__":

    main()