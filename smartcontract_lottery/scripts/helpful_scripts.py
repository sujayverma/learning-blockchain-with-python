from brownie import accounts, network, config, MockV3Aggregator, Contract

FORKED_MAINNET_ENVIRONMENT = ['mainnet-fork', 'mainnet-fork-dev2']
LOCAL_BLOCKCHAIN_ENVIRONMENT = ['development', 'ganache-local']
DECIMALS = 8
INITIAL_VALUE = 200000000000


def get_account(index=None, id=None):
    if index:
        return accounts[index]
    if id:
        return accounts.load(id)

    if (network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENT or network.show_active() in FORKED_MAINNET_ENVIRONMENT):
        return accounts[0]
    else:
        return accounts.add(config['wallets']['from_key'])


contract_to_mock = {
    "eth_usd_price_feed": MockV3Aggregator
}


def get_contract(contract_name):

    # This function will grab the contract addresses from brownie config
    # if defined, otherwise, it will deploy a mock version of the contract, and return the mock contract.
    # Args: contract_name(string)
    # Returns: brownie.network.contract.ProjectContract: The most recently deployed version of this contract.
    # MockV3Aggregator.
    contract_type = contract_to_mock[contract_name]

    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENT:
        if len(contract_type) <= 0:
            deploy_mocks()
        contract = contract_type[-1]
    else:
        contract_address = config["networks"][network.show_active(
        )][contract_name]

        contract = Contract.from_abi(
            contract_type._name, contract_address, contract_type.abi)
    return contract


def deploy_mocks(decimals=DECIMALS, initial_value=INITIAL_VALUE):
    account = get_account()
    MockV3Aggregator.deploy(
        decimals, initial_value, {"from": account})

    print("Deployed")
