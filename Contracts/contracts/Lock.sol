// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDaoContract {
    function balanceOf(address account, uint256 tokenId) external view returns (uint256);
}

contract Lock {
    address public owner;
    uint256 nextProposal;
    IDaoContract daoContract;
    uint256 buffer;

    constructor(address _daoContractAddress){
        owner = msg.sender;
        nextProposal = 1;
        buffer = 60;
        daoContract = IDaoContract(_daoContractAddress);
    }

    function changeBuffer(uint256 _buffer) public{
        require(msg.sender == owner, "Only the owner can change the buffer");
        buffer = _buffer;
    }

    struct Proposal {
        uint256 id;
        uint256 votesUp;
        uint256 votesDown;
        address[] canVote;
        mapping(address => bool) voteStatus;
        bool countConducted;
        bool passed;
        uint256 completionTime;
    }

    mapping(uint256 => Proposal) public Proposals;

    event ProposalCreated(
        uint256 id,
        address proposer
    );

    event NewVote(
        uint256 votesUp,
        uint256 votesDown,
        address voter,
        uint256 proposal,
        bool votedFor
    );

    event ProposalCount(
        uint256 id,
        bool passed
    );

    function checkVoter(uint256 _id, address _voter) private view returns (bool) {
        for (uint256 i = 0; i < Proposals[_id].canVote.length; i++) {
            if (Proposals[_id].canVote[i] == _voter) {
                return true;
            }
        }
        return false;
    }

    function createProposal(address[] memory _canVote) public {
        Proposal storage newProposal = Proposals[nextProposal];
        newProposal.id = nextProposal;
        newProposal.canVote = _canVote;
        newProposal.completionTime = block.timestamp + 60;
        emit ProposalCreated(nextProposal, msg.sender);
        nextProposal++;
    }

    function voteOnProposal(uint256 _id, bool _vote) public {
        require(_id >= nextProposal, "Incorrect proposal ID");
        require(Proposals[_id].completionTime <= block.timestamp, "The voting has concluded");
        require(!Proposals[_id].countConducted, "Voting process has finished");
        require(checkVoter(_id, msg.sender), "You cannot vote on this proposal");
        require(!Proposals[_id].voteStatus[msg.sender], "You have already voted on this Proposal");

        Proposal storage p = Proposals[_id];

        if(_vote)
            p.votesUp++;
        else 
            p.votesDown++;
        p.voteStatus[msg.sender] = true;
    }

    function countVotes(uint256 _id) public {
        require(msg.sender == owner, "Only Owner Can Count Votes");
        require(Proposals[_id].completionTime <= block.timestamp, "The voting hasn't concluded yet!!");
        require(!Proposals[_id].countConducted, "Count already conducted");

        Proposal storage p = Proposals[_id];

        if (p.votesDown < p.votesUp) {
            p.passed = true;
        } else {
            p.passed = false;
        }

        p.countConducted = true;

        emit ProposalCount(_id, p.passed);
    }

    function passed(uint256 _id) public view returns (bool) {
        require(msg.sender == owner, "Only Owner Can Check Proposal Status");
        require(Proposals[_id].countConducted, "Count not completed yet");

        return Proposals[_id].passed;
    }

    function getProposalId() public view returns(uint256) {
        return nextProposal;
    }
}