// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDaoContract {
    function balanceOf(address account, uint256 tokenId) external view returns (uint256);
}

contract Lock {

    address public owner;
    uint256 nextProposal;
    IDaoContract daoContract;

    constructor(address _daoContractAddress){
        owner = msg.sender;
        nextProposal = 1;
        daoContract = IDaoContract(_daoContractAddress);
    }

    struct Proposal {
        uint256 id;
        uint256 votesUp;
        uint256 votesDown;
        address[] canVote;
        mapping(address => bool) voteStatus;
        bool countConducted;
        bool passed;
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

    function checkVoteEligibility(uint256 _id, address _voter) private view returns (bool) {
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

        emit ProposalCreated(nextProposal, msg.sender);
        nextProposal++;
    }

    function voteOnProposal(uint256 _id, bool _vote) public {
        require(checkVoteEligibility(_id, msg.sender), "You can not vote on this Proposal");
        require(!Proposals[_id].voteStatus[msg.sender], "You have already voted on this Proposal");

        Proposal storage p = Proposals[_id];

        if(_vote) {
            p.votesUp++;
        } else {
            p.votesDown++;
        }

        p.voteStatus[msg.sender] = true;

        emit NewVote(p.votesUp, p.votesDown, msg.sender, _id, _vote);
    }

    function countVotes(uint256 _id) public {
        require(msg.sender == owner, "Only Owner Can Count Votes");
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