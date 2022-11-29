from brownie import FundMe, accounts, network, config, MockV3Aggregator
from scripts.helper_script import get_account, deploy_mock, LOCAL_BLOCKCHAIN_ENVIRONMENT


def deploy_fund_me():
    account = get_account()
    # fund_me = FundMe.deploy({"from": account})
    # This will help to publish the contract in human readable form and make it more interactive.
    # Will now need to pass a address to deploy for contract constructor function.
    # if we are on a presistent network like goerli, use the associated address.
    # otherwise, deploy mocks.
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENT:
        price_feeds_address = config['networks'][network.show_active(
        )]['eth_usd_price_feed']
    else:
        deploy_mock()
        price_feeds_address = MockV3Aggregator[-1].address
    fund_me = FundMe.deploy(price_feeds_address, {
                            "from": account}, publish_source=config['networks'][network.show_active()].get('verify'))
    print(f'Contract Deployed to {fund_me.address}')
    return fund_me


def main():
    deploy_fund_me()
