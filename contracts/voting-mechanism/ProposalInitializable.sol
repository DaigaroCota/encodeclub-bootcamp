// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract ProposalInitializable is Initializable {

  event Registered(address indexed user);
  event VoteCasted(address indexed user);

  struct VoterState {
    uint64 registeredTimestamp;
    uint64 castedVoteTimestamp;
    uint64 vote;
  }

  struct PhaseBlockTimes {
    uint64 proposalLaunchBlock;
    uint64 registrationBlockDeadline;
    uint64 voteCastingBlockDeadline;
    uint64 executionBlockDelay;
  }

  struct VoteCount {
    uint64 inFavor;
    uint64 against;
  }
  
  uint public porposalID;

  PhaseBlockTimes public phaseTimes;

  mapping(address => VoterState) public voterRegistry;

  uint public registeredVoters;
  uint public castedVoters;

  VoteCount private _voteResults;

  bytes public signedPayloadToExecute;
  address public target;
  bool public proposalExecuted;

  function initialize (
    uint _proposalID,
    bytes memory _signedPayloadToExecute,
    address _target,
    uint64 _registrationBlockDeadline,
    uint64 _voteCastingBlockDeadline,
    uint64 _executionBlockDelay
  ) public initializer() {
    porposalID = _proposalID;
    signedPayloadToExecute = _signedPayloadToExecute;
    target = _target;
    phaseTimes.proposalLaunchBlock = uint64(block.number);
    phaseTimes.registrationBlockDeadline = _registrationBlockDeadline;
    phaseTimes.voteCastingBlockDeadline = _voteCastingBlockDeadline;
    phaseTimes.executionBlockDelay = _executionBlockDelay;
  }

  function register() public {
    require(block.number <= phaseTimes.registrationBlockDeadline, "No more registrations!");
    VoterState memory userVoteState = VoterState({
      registeredTimestamp: uint64(block.timestamp),
      castedVoteTimestamp: 0,
      vote: 0
    });
    voterRegistry[msg.sender] = userVoteState;
    registeredVoters++;
    emit Registered(msg.sender);
  }

  function castVote(bool vote) public { 
    require(
      block.number > phaseTimes.registrationBlockDeadline &&
      block.number <= phaseTimes.voteCastingBlockDeadline,
      "Not phase to vote!"
    );
    VoterState memory userVoteState = voterRegistry[msg.sender];
    require(_isRegistered(userVoteState), "Not registered!");
    require(!_hasVoted(userVoteState), "Vote already casted!");
    
    userVoteState.castedVoteTimestamp = uint64(block.timestamp);

    uint64 numVote = vote == true ? 1 : 0;
    userVoteState.vote = numVote;

    voterRegistry[msg.sender] = userVoteState;

    castedVoters++;

    if(vote) {
      _voteResults.inFavor++;
    } else {
      _voteResults.against++;
    }
    emit VoteCasted(msg.sender);
  }

  function executeProposal() payable public {
    require(_votePhaseComplete(), "No ready to execute!");
    require(_isMajorityInFavor(), "Proposal is not approved!");
    require(!proposalExecuted, "Proposal Already Executed");
    (bool success,) = target.call{value: msg.value}(signedPayloadToExecute);
    require(success, "Call Failed!");
    proposalExecuted = true;
  }

  function getVoteResults() public view returns(VoteCount memory) {
    return _voteResults;
  }

  function _isRegistered(VoterState memory userVoteState) private pure returns(bool) {
    if (userVoteState.registeredTimestamp != 0) {
      return true;
    } else {
      return false;
    }
  }

  function _hasVoted(VoterState memory userVoteState) private pure returns(bool) {
    if (userVoteState.castedVoteTimestamp != 0) {
      return true;
    } else {
      return false;
    }
  }

  function _votePhaseComplete() private view returns(bool) {
    uint executionStartBlock = phaseTimes.voteCastingBlockDeadline + phaseTimes.executionBlockDelay;
    if (block.number >= executionStartBlock) {
      return true;
    } else {
      return false;
    }
  }

  function _isMajorityInFavor() private view returns(bool) {
    if (_voteResults.inFavor > _voteResults.against ) {
      return true;
    } else {
      return false;
    }
  }

}