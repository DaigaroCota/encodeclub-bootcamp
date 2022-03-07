// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ProposalInitializable.sol";

contract ProposalCloneFactory is Ownable {
    mapping(uint256 => address) public deployedProposals;

    address public proposalImplementation;

    uint256[] private _listedProposals;

    function createProposalClone(
        bytes memory _signedPayloadToExecute,
        address _target,
        uint64 _registrationBlockDeadline,
        uint64 _voteCastingBlockDeadline,
        uint64 _executionBlockDelay
    ) public {
        // TODO checks on inputs.

        require(
            proposalImplementation != address(0),
            "Set proposal implementation contract to clone!"
        );

        uint256 proposalID = uint256(
            keccak256(
                abi.encode(
                    _signedPayloadToExecute,
                    _target,
                    _registrationBlockDeadline,
                    _voteCastingBlockDeadline,
                    _executionBlockDelay
                )
            )
        );

        address newProxyClone = Clones.clone(proposalImplementation);

        ProposalInitializable iProposal = ProposalInitializable(newProxyClone);

        iProposal.initialize(
            proposalID,
            _signedPayloadToExecute,
            _target,
            _registrationBlockDeadline,
            _voteCastingBlockDeadline,
            _executionBlockDelay
        );

        _listedProposals.push(proposalID);

        deployedProposals[proposalID] = newProxyClone;
    }

    function setProposalImplementation(address newImplAddr) external onlyOwner {
        proposalImplementation = newImplAddr;
    }

    function getListedProposals() public view returns (uint256[] memory) {
        return _listedProposals;
    }
}
