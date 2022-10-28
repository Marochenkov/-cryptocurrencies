// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

contract Ballot {
    address public owner;

    struct Candidate {
        address payable account;
        uint votesCount;
    }

    struct Voter {
        bool voted;
        uint voteIndex;
    }

    struct VoteInfo {
        uint daysLeft;
        uint paymentAmount;
        uint fee;
        Candidate[] candidates;
    }

    Candidate[] public candidates;

    mapping(address => Voter) public voters;

    uint votingFinishDate;
    uint paymentAmount;
    uint fee;

    constructor() {
        owner = msg.sender;
    }

    modifier OnlyOwner{
        require(msg.sender == owner, "Permission denied.");
        _;
    }

    modifier CheckFinishDate{
        require(block.timestamp >= votingFinishDate, "Voting is not finished.");
        _;
    }

    function createVoting(uint durationInDays, uint paymentAmount_, uint fee_, address[] memory candidates_) OnlyOwner public {
        require(fee_ <= paymentAmount_, "Fee must be less than X.");
        votingFinishDate = block.timestamp + (durationInDays * 1 days);
        paymentAmount = paymentAmount_;
        fee = fee_;

        for (uint i = 0; i < candidates_.length; i++) {
            candidates.push(
                Candidate({
                    account: payable(candidates_[i]), 
                    votesCount: 0
                })
            );
        }
    }

    function withdrawFees() OnlyOwner CheckFinishDate public {
        uint totalVotes = 0;
        
        for (uint i = 0; i < candidates.length; i++) {
            totalVotes += candidates[i].votesCount;
        }

        payable(owner).transfer(fee * totalVotes);
    }

    function finishVoting() OnlyOwner CheckFinishDate public {
        // count max amount of votes

        uint winningVotesCount = 0;
        uint totalVotes = 0;

        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].votesCount > winningVotesCount) {
                winningVotesCount = candidates[i].votesCount;
            } 
            totalVotes += candidates[i].votesCount;
        }

        // count amount of winners

        uint winnersCount = 0;

        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].votesCount == winningVotesCount) {
                winnersCount += 1;
            }
        }

        // transfer money to winners

        uint transferAmount = (paymentAmount - fee) * totalVotes / winnersCount;
        assert(transferAmount >= 0);


        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].votesCount == winningVotesCount) {
                candidates[i].account.transfer(transferAmount);
            }
        }
    }


    function voteFor(uint candidateIndex) public payable {
        require(block.timestamp < votingFinishDate, "Voting is finished.");
        require(!voters[msg.sender].voted, "Voter has already voted.");
        require(msg.value == paymentAmount, "Payment amount is wrong.");
        require(candidateIndex < candidates.length, "Candidates index out of range.");

        voters[msg.sender].voted = true;
        voters[msg.sender].voteIndex = candidateIndex;

        candidates[candidateIndex].votesCount += 1;
    }

    function getVoteInfo() public view returns (VoteInfo memory voteInfo) {
        voteInfo = VoteInfo({
            daysLeft: (votingFinishDate - block.timestamp) / 60 / 60 / 24,
            paymentAmount: paymentAmount,
            fee: fee,
            candidates: candidates
        });
    }

    function balance() view public returns (uint256) {
        return address(this).balance;
    }
}
