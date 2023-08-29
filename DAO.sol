// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAOMembership {
    address[] MembersAccepted;

    struct ApplicationStatus {
        uint256 noOfApprovals;
        uint256 noOfDisApprovals;
        bool isApplicationActive;
        bool isMemberOfDao;
        bool isApplicationActiveForDisApproval;
        uint256 noOfRemoval;
        bool left;
    }
    mapping(address=>mapping(address=>bool)) hasVoted;

    mapping(address => ApplicationStatus) Applicants;

    constructor(){
        MembersAccepted.push(msg.sender);
        Applicants[msg.sender].isApplicationActive = false;
        Applicants[msg.sender].isMemberOfDao = true;
    }

    //To apply for membership of DAO
    function applyForEntry() public {
        require(MembersAccepted.length>0);
        require(!Applicants[msg.sender].isMemberOfDao);
        require(!Applicants[msg.sender].isApplicationActive);
        require(!Applicants[msg.sender].left);
        Applicants[msg.sender].noOfApprovals = 0;
        Applicants[msg.sender].isApplicationActive = true;
    }
    
    //To approve the applicant for membership of DAO
    function approveEntry(address _applicant) public {
        require(Applicants[msg.sender].isMemberOfDao);
        require(Applicants[_applicant].isApplicationActive);
        require(!hasVoted[_applicant][msg.sender]);
        Applicants[_applicant].noOfApprovals += 1;
        hasVoted[_applicant][msg.sender]=true;
        if(Applicants[_applicant].noOfApprovals*100>=MembersAccepted.length*30){
            Applicants[_applicant].isApplicationActive = false;
            Applicants[_applicant].isMemberOfDao = true;
            MembersAccepted.push(_applicant);
        }
    }

    //To disapprove the applicant for membership of DAO
    function disapproveEntry(address _applicant) public{
        require(Applicants[msg.sender].isMemberOfDao);
        require(Applicants[_applicant].isApplicationActive);
        require(!hasVoted[_applicant][msg.sender]);
        Applicants[_applicant].noOfDisApprovals = Applicants[_applicant].noOfDisApprovals + 1;
        hasVoted[_applicant][msg.sender]=true;
        if(Applicants[_applicant].noOfDisApprovals*100>=MembersAccepted.length*70){
            Applicants[_applicant].isApplicationActive = false;
            Applicants[_applicant].left = true;
        }
    }

    //To remove a member from DAO
    function removeMember(address _memberToRemove) public {
        require(Applicants[msg.sender].isMemberOfDao);
        require(Applicants[_memberToRemove].isMemberOfDao);
        require(msg.sender!=_memberToRemove);
        require(!Applicants[msg.sender].left);
        Applicants[_memberToRemove].noOfRemoval += 1;
        if(Applicants[_memberToRemove].noOfRemoval*100>=(MembersAccepted.length-1)*70){
            for(uint i=0;i<MembersAccepted.length;i++){
                if(MembersAccepted[i] == _memberToRemove){
                    MembersAccepted[i] = MembersAccepted[MembersAccepted.length-1];
                    Applicants[_memberToRemove].isMemberOfDao = false;
                    Applicants[_memberToRemove].left = true;
                    MembersAccepted.pop();
                }
            }
        }
    }

    //To leave DAO
    function leave() public {
        require(Applicants[msg.sender].isMemberOfDao);
        Applicants[msg.sender].left = true;
        for(uint i=0;i<MembersAccepted.length;i++){
            if(MembersAccepted[i] == msg.sender){
                MembersAccepted[i] = MembersAccepted[MembersAccepted.length-1];
                Applicants[msg.sender].isMemberOfDao = false;
                MembersAccepted.pop();
            }
        }
    }

    //To check membership of DAO
    function isMember(address _user) public view returns (bool) {
        require(Applicants[msg.sender].isMemberOfDao);
        return Applicants[_user].isMemberOfDao;
    }

    //To check total number of members of the DAO
    function totalMembers() public view returns (uint256) {
        require(Applicants[msg.sender].isMemberOfDao);
        return MembersAccepted.length;
    }
}