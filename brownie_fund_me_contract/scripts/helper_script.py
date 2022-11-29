from brownie import network, accounts, config, MockV3Aggregator
from web3 import Web3

FORKED_MAINNET_ENVIRONMENT = ['mainnet-fork', 'mainnet-fork-dev2']
LOCAL_BLOCKCHAIN_ENVIRONMENT = ['development', 'ganache-local']
DECIMALS = 8
STARTING_PRICE = 200000000


def get_account():
    if (network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENT or network.show_active() in FORKED_MAINNET_ENVIRONMENT):
        return accounts[0]
    else:
        return accounts.add(config['wallets']['from_key'])


def deploy_mock():
    print(f'The Network is {network.show_active()}')
    print('Deploying Mocks...')
    if len(MockV3Aggregator) <= 0:
        MockV3Aggregator.deploy(
            DECIMALS, Web3.toWei(STARTING_PRICE, 'ether'), {"from": get_account()})
    print("Mock Deployed")
