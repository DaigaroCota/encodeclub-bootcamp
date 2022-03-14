// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract ExploringYul {

  function deposit() external payable returns (uint msgvalue) {
    assembly {
      msgvalue := callvalue()
    }
  }

  function saveInMemory(uint num_, uint index) external {
    assembly {
      sstore(index, num_)
    }
  }

  function viewNumberInSlot(uint index) external view returns(uint value) {
    assembly {
      value := sload(index)
    }
  }

}