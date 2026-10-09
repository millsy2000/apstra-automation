#!/usr/bin/env python3

import ipaddress
import re
import sys
import yaml
import os


POLICY_FILE = "policies/network-standards.yaml"
TENANTS_FILE = os.environ.get("TENANTS_PATH")


def fail(errors):

    print("\nVALIDATION FAILED\n")

    for error in errors:
        print(f"ERROR: {error}")

    sys.exit(1)


def load_policy():

    with open(POLICY_FILE, "r") as fh:
        return yaml.safe_load(fh)

def load_tenants():

    with open(TENANTS_FILE, "r") as fh:
        return yaml.safe_load(fh)


def validate_vlan(network, policy):

    vlan = network["app_vlan"]

    minimum = policy["vlan"]["minimum"]
    maximum = policy["vlan"]["maximum"]

    if vlan < minimum or vlan > maximum:
        return (
            f"VLAN {vlan} outside "
            f"permitted range {minimum}-{maximum}"
        )

    return None


def validate_vni(network, policy):

    vni = network["app_vni"]

    minimum = policy["vni"]["minimum"]
    maximum = policy["vni"]["maximum"]

    if vni < minimum or vni > maximum:
        return (
            f"VNI {vni} outside "
            f"permitted range {minimum}-{maximum}"
        )

    return None


def validate_network_name(network, policy):

    regex = policy["network_name"]["regex"]

    if not re.match(regex, network["name"]):
        return (
            f"Network name "
            f"'{network['name']}' "
            f"fails naming standard"
        )

    return None


def validate_tenant_name(tenant, policy):

    regex = policy["tenant_name"]["regex"]

    if not re.match(regex, tenant["tenant_name"]):

        return (
            f"Tenant name "
            f"'{tenant['tenant_name']}' "
            f"fails naming standard"
        )

    return None


def validate_subnet(network, policy):

    subnet = ipaddress.ip_network(
        network["subnet"],
        strict=False
    )

    allowed = policy["subnet"]["allowed_prefixes"]

    if subnet.prefixlen not in allowed:

        return (
            f"Subnet {network['subnet']} "
            f"is not permitted"
        )

    return None


def validate_gateway(network):

    subnet = ipaddress.ip_network(
        network["subnet"],
        strict=False
    )

    gateway = ipaddress.ip_address(
        network["virtual_gateway"]
    )

    if gateway not in subnet:
        return (
            f"Gateway {gateway} "
            f"not within subnet "
            f"{subnet}"
        )

    return None


def validate_duplicates(tenants):

    errors = []

    vlans = {}
    vnis = {}

    for tenant in tenants:

        for network in tenant["networks"]:

            vlan = network["app_vlan"]

            if vlan in vlans:

                errors.append(
                    f"Duplicate VLAN "
                    f"{vlan} used by "
                    f"{vlans[vlan]} and "
                    f"{tenant['tenant_name']}"
                )

            else:
                vlans[vlan] = tenant["tenant_name"]

            vni = network["app_vni"]

            if vni in vnis:

                errors.append(
                    f"Duplicate VNI "
                    f"{vni} used by "
                    f"{vnis[vni]} and "
                    f"{tenant['tenant_name']}"
                )

            else:
                vnis[vni] = tenant["tenant_name"]

    return errors


def main():

    policy = load_policy()
    TENANTS = load_tenants()['tenants']

    errors = []

    for tenant in TENANTS:

        result = validate_tenant_name(
            tenant,
            policy
        )

        if result:
            errors.append(result)

        for network in tenant["networks"]:

            checks = [

                validate_vlan(
                    network,
                    policy
                ),

                validate_vni(
                    network,
                    policy
                ),

                validate_network_name(
                    network,
                    policy
                ),

                validate_subnet(
                    network,
                    policy
                ),

                validate_gateway(
                    network
                )

            ]

            errors.extend(
                [
                    check
                    for check in checks
                    if check
                ]
            )

    errors.extend(
        validate_duplicates(
            TENANTS
        )
    )

    if errors:
        fail(errors)

    print(
        "\nNetwork Standards Validation Passed\n"
    )


if __name__ == "__main__":
    main()