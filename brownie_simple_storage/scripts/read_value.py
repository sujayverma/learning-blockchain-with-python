from brownie import SimpleStorage, accounts, config


def read_contract():
    # print(SimpleStorage)
    print(SimpleStorage[-1])
    # This will get the latest deployed contract address.
    simple_storage = SimpleStorage[-1]
    print(simple_storage.retrive())
    # for i in SimpleStorage:
    #     print(i)


def main():
    read_contract()
