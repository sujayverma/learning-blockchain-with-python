# from pathlib import Path
# path3 = Path()
# for file in path3.glob("*"):
#     print(file)
from solcx import compile_standard, install_solc
with open("./web3_py_simple_storage/SimpleStorage.sol", "r") as file:
    simple_storage_file = file.read()

install_solc("0.6.0")
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
    solc_version="0.6.0",
)

print(compile_sol)
