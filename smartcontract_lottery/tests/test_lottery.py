from brownie import Lottery, accounts, config, network
from web3 import Web3
# 0.039
# 390000000000000000


def test_get_entry_fees():
    account = accounts[0]
    lottery = Lottery.deploy(
        config['networks'][network.show_active()]['eth_usd_price_feed'], {'from': account})
    # print(lottery.getEntranceFee())
    assert lottery.getEntranceFee() > Web3.toWei(0.038, "ether")
    assert lottery.getEntranceFee() < Web3.toWei(0.040, "ether")
