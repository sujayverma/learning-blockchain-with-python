// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

// This acts like classes in Solidity
contract SimpleStorage {
    // By default this variable has value = 0.
    uint256 public favoriteNumber;
    address public account2 = 0x9a2C3A404B6e10d477d310854d20bCd9970acAC7;

    // This kind of user defined data type in solidity. Somewhat kind of list or dictionary in python. Or even an Array in different way.
    struct People {
        uint256 favoriteNumber;
        string name;
    }
    // Using People data type to define a variable.
    // People public person = People({favoriteNumber:10, name: "Sujay"});

    // Array data type. Variable name people use of People Struct.
    People[] public people;
    // Map data type used for mapping values for arrays.
    mapping(string => uint256) public nameToFavoriteNumber;

    function store(uint256 _favoriteNumber) public {
        favoriteNumber = _favoriteNumber;
    }

    // This is view function.It doesn't make state changes. No transaction takes place in view functions. View functions and variables has blue button.
    function retrive() public view returns (uint256) {
        return favoriteNumber;
    }

    // memory keyword used for runtime memory for storing string object.
    function addPerson(uint256 _favoriteNumber, string memory _name) public {
        people.push(People(_favoriteNumber, _name));
        nameToFavoriteNumber[_name] = _favoriteNumber;
    }

    // function getPerson() public view returns (People[] memory) {
    //     return people;
    // }

    // function multiple() public pure returns (uint256 favoriteNumber) {
    //      favoriteNumber * favoriteNumber;
    // }
}
