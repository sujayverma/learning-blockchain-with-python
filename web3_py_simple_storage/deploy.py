# from pathlib import Path
# path3 = Path()
# for file in path3.glob("*"):
#     print(file)
import json
from solcx import compile_standard, install_solc
from web3 import Web3
import os
from dotenv import load_dotenv
install_solc("0.8.0")
with open("./web3_py_simple_storage/SimpleStorage.sol", "r") as file:
    simple_storage_file = file.read()
# print(simple_storage_file)

compile_sol = compile_standard(
    {
        "language": "Solidity",
        "sources": {"SimpleStorage.sol": {"content": simple_storage_file}},
        "settings": {
            "outputSelection": {
                "*": {"*": ["abi", "metadata", "evm.bytecode", "evm.sourceMap"]}
            }
        },
    },
    solc_version="0.8.0",
)

with open("./web3_py_simple_storage/compiled_code.json", "w") as file:
    json.dump(compile_sol, file)

# get bytecode.
bytecode = compile_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["evm"]["bytecode"]["object"]

# get abi.
abi = compile_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["abi"]

# print(abi)
# print(compile_sol)
# exit()
# For connecting to Ganache.
w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))
chain_id = 1337
my_address = "0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1"
load_dotenv()
private_key = os.getenv("PRIVATE_KEY")

# Create the Contract in python.
SimpleStorage = w3.eth.contract(abi=abi, bytecode=bytecode)
# Get latest transaction.
nonce = w3.eth.getTransactionCount(my_address)
# 1. Build Transaction.
# 2. Sign Transaction.
# 3. Send Transaction.
transaction = SimpleStorage.constructor().build_transaction(
    {"gasPrice": w3.eth.gas_price, "chainId": chain_id, "from": my_address, "nonce": nonce})
signed_txn = w3.eth.account.sign_transaction(
    transaction, private_key=private_key)
# print(signed_txn)

# Send this signed tranaction.
tx_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
# Working With Contract.
# We need Contract Address.
# And Contract ABI
# Interacting with contract.
simple_storage = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)
# Now to interact we normally use 2 functions.
# 1) Call -> Simulate making the call and getting a return value. This is usaully used for view functions.
# 2) Transact -> Actually make a state change. This is usaully used for making state changes like storing a values.
print(simple_storage.functions.retrive().call())

store_transaction = simple_storage.functions.store(10).buildTransaction({
    "gasPrice": w3.eth.gas_price, "chainId": chain_id, "from": my_address, "nonce": nonce + 1
})
signed_store_tx = w3.eth.account.sign_transaction(
    store_transaction, private_key=private_key)
store_txn_hash = w3.eth.send_raw_transaction(signed_store_tx.rawTransaction)
store_txn_receipt = w3.eth.wait_for_transaction_receipt(store_txn_hash)
print(simple_storage.functions.retrive().call())
