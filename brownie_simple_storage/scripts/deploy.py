from brownie import accounts, config, SimpleStorage, network
import os


def deploy_simple_storage():
    # account = accounts[0]  # This is Ganache account
    # print(account)
    # account = accounts.load("metamask")  # This is testnet Account on Gorli network.
    # print(account)
    # This will get private key from .env
    # account = accounts.add(os.getenv("PRIVATE_KEY"))
    # print(account)
    # This will get the private key from .env file via brownie-config.yml.
    # account = accounts.add(config['wallets']['from_key'])
    # print(account)
    # In brownie you can directly import the contract after compiling it.
    account = get_account()
    simple_storage = SimpleStorage.deploy({"from": account})
    stored_value = simple_storage.retrive()
    print(stored_value)
    transaction = simple_storage.store(15, {"from": account})
    transaction.wait(1)
    updated_stored_value = simple_storage.retrive()
    print(updated_stored_value)


def get_account():
    if (network.show_active() == "development"):
        return accounts[0]
    else:
        return accounts.add(config['wallets']['from_key'])


def main():
    deploy_simple_storage()
