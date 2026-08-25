// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VotingSystem {

    address public admin;
    bool public electionStarted;
    bool public electionEnded;

    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }

    struct Voter {
        bool registered;
        bool hasVoted;
    }

    mapping(uint256 => Candidate) public candidates;
    mapping(address => Voter) public voters;

    uint256 public candidateCount;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    function addCandidate(string memory _name) public onlyAdmin {
        require(!electionStarted, "Election already started");
        require(bytes(_name).length > 0, "Candidate name required");

        candidateCount++;

        candidates[candidateCount] = Candidate(
            candidateCount,
            _name,
            0
        );
    }

    function registerVoter(address _voter) public onlyAdmin {
        require(!electionStarted, "Election already started");
        require(_voter != address(0), "Invalid voter address");
        require(!voters[_voter].registered, "Voter already registered");

        voters[_voter] = Voter(true, false);
    }

    function startElection() public onlyAdmin {
        require(!electionStarted, "Election already started");
        require(candidateCount > 0, "Add candidates first");

        electionStarted = true;
    }

    function vote(uint256 _candidateId) public {
        require(electionStarted, "Election has not started");
        require(!electionEnded, "Election has ended");
        require(voters[msg.sender].registered, "You are not a registered voter");
        require(!voters[msg.sender].hasVoted, "You have already voted");
        require(
            _candidateId > 0 && _candidateId <= candidateCount,
            "Invalid candidate"
        );

        voters[msg.sender].hasVoted = true;
        candidates[_candidateId].voteCount++;
    }

    function endElection() public onlyAdmin {
        require(electionStarted, "Election has not started");
        require(!electionEnded, "Election already ended");

        electionEnded = true;
    }

    function getCandidate(uint256 _candidateId)
        public
        view
        returns (
            uint256 id,
            string memory name,
            uint256 voteCount
        )
    {
        require(
            _candidateId > 0 && _candidateId <= candidateCount,
            "Invalid candidate"
        );

        Candidate memory candidate = candidates[_candidateId];

        return (
            candidate.id,
            candidate.name,
            candidate.voteCount
        );
    }
}