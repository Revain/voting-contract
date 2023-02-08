// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts@4.7.1/token/ERC20/ERC20.sol";

contract StubERC20 is ERC20 {
    constructor() ERC20("Stub", "STB") {
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}
