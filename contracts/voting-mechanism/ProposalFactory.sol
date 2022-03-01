// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./Proposal.sol";

contract ProposalFactory {

  mapping (uint => address) public deployedProposals;

  uint[] private _listedProposals;

  function createProposal(
    bytes memory _signedPayloadToExecute,
    address _target,
    uint64 _registrationBlockDeadline,
    uint64 _voteCastingBlockDeadline,
    uint64 _executionBlockDelay
  ) public {

    // TODO checks on inputs.

    uint proposalID = uint256(keccak256(abi.encode(
      _signedPayloadToExecute,
      _target,
      _registrationBlockDeadline,
      _voteCastingBlockDeadline,
      _executionBlockDelay
    )));

    Proposal aNewProposal = new Proposal(
      proposalID,
      _signedPayloadToExecute,
      _target,
      _registrationBlockDeadline,
      _voteCastingBlockDeadline,
      _executionBlockDelay
    );

    deployedProposals[proposalID] = address(aNewProposal);
    _listedProposals.push(proposalID);
  }

  function getListedProposals() public view returns(uint[] memory) {
    return _listedProposals;
  }
}