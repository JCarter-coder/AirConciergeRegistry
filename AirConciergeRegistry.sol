// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// Contract definition
contract AirConciergeRegistry {
    address public owner;
    uint256 applicationFee;

    constructor(uint256 _applicationFee) {
        owner = msg.sender;
        applicationFee = _applicationFee;
    }

    // Structure to represent a pilot candidate
    struct Candidate {
        string pilotName;
        address pilotAddr;
        uint256 appliedDate;
    }

    // Structure to represent an accepted pilot
    struct Pilot {
        string pilotName;
        address payable pilotAddr;
        uint256 acceptedDate;
        bool isArchived;
    }

    // State variables
    Candidate[] candidates;
    mapping(address => Pilot) public pilots; // accepted pilots


    // For event emitter
    event Action(string action, string name, uint256 time);

    // Modifier to restrict access to owner-only functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

    function pilot_Application(string memory _name) public payable {
        require(msg.value == applicationFee, "Transaction failed. Application fee is incorrect.");
        uint256 currentTime = block.timestamp;
        candidates.push(Candidate({
                pilotName: _name,
                pilotAddr: msg.sender,
                appliedDate: currentTime
            })
        );
        emit Action("Applied", _name, currentTime);
    }

    function owner_seeNextCandidate() external view onlyOwner returns(string memory, address){
        require(candidates.length > 0, "The Candidates array is empty.");
        Candidate memory candidate = candidates[candidates.length - 1];
        return (
            candidate.pilotName,
            candidate.pilotAddr
        );
    }

    // A helper function to compare string response values
    function compareStrings(string memory a, string memory b) internal pure returns(bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function owner_acceptNextCandidate(string memory _Y_or_N) external onlyOwner {
        require(candidates.length > 0, "Candidates array is empty.");
        require(
            compareStrings(_Y_or_N, "Y") || 
            compareStrings(_Y_or_N, "N"),
            "Invalid input. Please enter Y or N."
        );
        Candidate memory candidate = candidates[candidates.length - 1];
        uint256 currentTime = block.timestamp;
        pilots[candidate.pilotAddr] = Pilot({
            pilotName: candidate.pilotName,
            pilotAddr: payable(candidate.pilotAddr),
            acceptedDate: currentTime,
            isArchived: false
        });
        if (compareStrings(_Y_or_N, "Y")) {
            
            emit Action("Pilot Accepted", candidate.pilotName, currentTime);
            candidates.pop();
        } else {
            emit Action("Rejected", candidate.pilotName, currentTime);
            candidates.pop();
        }
    }

    function owner_archivePilot(address _address) external onlyOwner {
        pilots[_address].isArchived = false;
        emit Action("Pilot Archived", pilots[_address].pilotName, block.timestamp);
    }
}
