from brownie import (
    network,
    accounts,
    config,
    Schedule
)
import time


LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["hardhat", "development", "ganache"]

def get_account(index=None, id=None):
    """
    Ключ можно настроить в brownie-config.yaml
    """
    if index:
        return accounts[index]
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        return accounts[0]
    if id:
        return accounts.load(id)
    return accounts.add(config["wallets"]["from_key"])


def deploy_contract(quiet=False):
    if not quiet:
        print(f"The active network is {network.show_active()}")
    account = get_account()
    if not quiet:
        print("Account received.")
    schedule_contract = Schedule.deploy({"from": account}, publish_source=False)
    if not quiet:
        print(f"Contract deployed to {schedule_contract.address}")
