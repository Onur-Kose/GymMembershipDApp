// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract GymMembership {

    struct Fee {
        uint dailyFee;
        uint weeklyFee;
        uint monthlyFee;
        uint quarterlyFee;
        uint semiAnnualFee;
        uint annualFee;
    }

    struct Location {
        string latitude;
        string longitude;
    }

    struct Gym {
        string name;
        Fee fees;
        uint totalUsers;
        uint totalRating;
        uint reviewCount;
        uint balance;
        Location location;
        address[] memberAddresses;
        mapping(address => uint) activeMembers;
    }

    struct Member {
        string name;
        uint age;
        uint weight;
        uint height;
        uint exerciseCount;
        uint visitCount;
        bool isManual;
        mapping(uint => Exercise) exercises;
        mapping(uint => Visit) visits;
        mapping(address => uint) gymSubscriptions;
    }

    struct Exercise {
        string machine;
        uint weightLifted;
        uint timestamp;
    }

    struct Visit {
        string gymName;
        uint timestamp;
    }

    struct GymDetails {
        string name;
        uint dailyFee;
        uint weeklyFee;
        uint monthlyFee;
        uint quarterlyFee;
        uint semiAnnualFee;
        uint annualFee;
        string latitude;
        string longitude;
    }

    mapping(address => Member) public members;
    mapping(address => bool) public isMember;
    mapping(address => Gym) public gyms;
    mapping(address => bool) public isGym;
    address[] public memberAddresses;
    address[] public gymAddresses;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyMember() {
        require(isMember[msg.sender], "Only members can call this function");
        _;
    }

    modifier onlyGym() {
        require(isGym[msg.sender], "Only gyms can call this function");
        _;
    }

    function registerMember(string memory _name, uint _age, uint _weight, uint _height) public {
        require(!isMember[msg.sender], "Already a member");
        require(!isGym[msg.sender], "Address is registered as a gym");
        Member storage newMember = members[msg.sender];
        newMember.name = _name;
        newMember.age = _age;
        newMember.weight = _weight;
        newMember.height = _height;
        newMember.exerciseCount = 0;
        newMember.visitCount = 0;
        newMember.isManual = false;
        isMember[msg.sender] = true;
        memberAddresses.push(msg.sender);
    }

    function setGymDetails(Gym storage gym, GymDetails memory details) internal {
        gym.name = details.name;
        gym.fees.dailyFee = details.dailyFee;
        gym.fees.weeklyFee = details.weeklyFee;
        gym.fees.monthlyFee = details.monthlyFee;
        gym.fees.quarterlyFee = details.quarterlyFee;
        gym.fees.semiAnnualFee = details.semiAnnualFee;
        gym.fees.annualFee = details.annualFee;
        gym.totalUsers = 0;
        gym.totalRating = 0;
        gym.reviewCount = 0;
        gym.balance = 0;
        gym.location.latitude = details.latitude;
        gym.location.longitude = details.longitude;
    }

    function registerGym(
        string memory name,
        uint dailyFee,
        uint weeklyFee,
        uint monthlyFee,
        uint quarterlyFee,
        uint semiAnnualFee,
        uint annualFee,
        string memory latitude,
        string memory longitude
    ) public {
        require(!isGym[msg.sender], "Already a gym");
        require(!isMember[msg.sender], "Address is registered as a member");
        GymDetails memory details = GymDetails(name, dailyFee, weeklyFee, monthlyFee, quarterlyFee, semiAnnualFee, annualFee, latitude, longitude);
        Gym storage newGym = gyms[msg.sender];
        setGymDetails(newGym, details);
        isGym[msg.sender] = true;
        gymAddresses.push(msg.sender);
    }

    function determineFee(Gym storage gym, uint duration) internal view returns (uint) {
        if (duration == 1) {
            return gym.fees.dailyFee;
        } else if (duration == 7) {
            return gym.fees.weeklyFee;
        } else if (duration == 30) {
            return gym.fees.monthlyFee;
        } else if (duration == 90) {
            return gym.fees.quarterlyFee;
        } else if (duration == 180) {
            return gym.fees.semiAnnualFee;
        } else if (duration == 365) {
            return gym.fees.annualFee;
        } else {
            revert("Invalid duration");
        }
    }

    function subscribeGym(address gymAddress, uint duration) public payable onlyMember {
        require(isGym[gymAddress], "Invalid gym");
        Gym storage gym = gyms[gymAddress];
        uint fee = determineFee(gym, duration);

        require(msg.value == fee, "Incorrect fee");

        gym.totalUsers++;
        gym.balance += msg.value;
        uint endDate = block.timestamp + (duration * 1 days);
        members[msg.sender].gymSubscriptions[gymAddress] = endDate;
        gym.memberAddresses.push(msg.sender);
        gym.activeMembers[msg.sender] = endDate;
    }

    function addExercise(string memory _machine, uint _weightLifted) public onlyMember {
        Member storage member = members[msg.sender];
        member.exercises[member.exerciseCount] = Exercise(_machine, _weightLifted, block.timestamp);
        member.exerciseCount++;
    }

    function addVisit(address _gym) public onlyMember {
        require(isGym[_gym], "Invalid gym");
        require(members[msg.sender].gymSubscriptions[_gym] > block.timestamp, "Subscription expired");

        Member storage member = members[msg.sender];
        Gym storage gym = gyms[_gym];

        member.visits[member.visitCount] = Visit(gym.name, block.timestamp);
        member.visitCount++;

        payable(_gym).transfer(gym.fees.dailyFee);
    }

    function rateGym(address _gym, uint _rating) public onlyMember {
        require(isGym[_gym], "Invalid gym");
        require(_rating >= 1 && _rating <= 5, "Invalid rating");
        Gym storage gym = gyms[_gym];
        gym.totalRating += _rating;
        gym.reviewCount++;
    }

    function calculateGymFee(address _gym) public view onlyOwner returns (uint) {
        require(isGym[_gym], "Invalid gym");
        Gym storage gym = gyms[_gym];
        if (gym.reviewCount == 0) {
            return gym.totalUsers * 1;
        }
        uint averageRating = gym.totalRating / gym.reviewCount;
        return gym.totalUsers * averageRating;
    }

    function withdrawEarnings() public onlyGym {
        Gym storage gym = gyms[msg.sender];
        uint amount = gym.balance;
        require(amount > 0, "No earnings to withdraw");
        gym.balance = 0;
        payable(msg.sender).transfer(amount);
    }

    function manualAddMember(address _member, string memory _name, uint _age, uint _weight, uint _height) public onlyGym {
        require(!isMember[_member], "Already a member");
        Member storage newMember = members[_member];
        newMember.name = _name;
        newMember.age = _age;
        newMember.weight = _weight;
        newMember.height = _height;
        newMember.exerciseCount = 0;
        newMember.visitCount = 0;
        newMember.isManual = true;
        isMember[_member] = true;
        memberAddresses.push(_member);
        gyms[msg.sender].memberAddresses.push(_member);
        gyms[msg.sender].activeMembers[_member] = block.timestamp + 365 days; // Default subscription end date for manually added members
    }

    function getMemberInfo(address _member) public view onlyMember returns (string memory, uint, uint, uint, bool) {
        require(isMember[_member], "Not a member");
        Member storage member = members[_member];
        return (member.name, member.age, member.weight, member.height, member.isManual);
    }

    function getExercise(address _member, uint _index) public view onlyMember returns (string memory, uint, uint) {
        require(isMember[_member], "Not a member");
        Member storage member = members[_member];
        Exercise storage exercise = member.exercises[_index];
        return (exercise.machine, exercise.weightLifted, exercise.timestamp);
    }

    function getVisit(address _member, uint _index) public view onlyMember returns (string memory, uint) {
        require(isMember[_member], "Not a member");
        Member storage member = members[_member];
        Visit storage visit = member.visits[_index];
        return (visit.gymName, visit.timestamp);
    }

    function getActiveMembers() public view onlyGym returns (string[] memory, uint[] memory) {
        Gym storage gym = gyms[msg.sender];
        uint memberCount = gym.memberAddresses.length;
        string[] memory memberNames = new string[](memberCount);
        uint[] memory endDates = new uint[](memberCount);
        
        for (uint i = 0; i < memberCount; i++) {
            address memberAddress = gym.memberAddresses[i];
            Member storage member = members[memberAddress];
            if (gym.activeMembers[memberAddress] > block.timestamp) {
                memberNames[i] = member.name;
                endDates[i] = gym.activeMembers[memberAddress];
            }
        }
        
        return (memberNames, endDates);
    }
    
    function getAllGyms() public view onlyOwner returns (address[] memory) {
        return gymAddresses;
    }
    
    function getAllMembers() public view onlyOwner returns (address[] memory) {
        return memberAddresses;
    }

    function getMemberSubscriptions(address _member) public view onlyOwner returns (address[] memory, uint[] memory) {
        Member storage member = members[_member];
        uint subscriptionCount = 0;
        for (uint i = 0; i < gymAddresses.length; i++) {
            if (member.gymSubscriptions[gymAddresses[i]] > block.timestamp) {
                subscriptionCount++;
            }
        }
        
        address[] memory gymAddressesActive = new address[](subscriptionCount);
        uint[] memory subscriptionEndDates = new uint[](subscriptionCount);
        uint index = 0;
        
        for (uint i = 0; i < gymAddresses.length; i++) {
            if (member.gymSubscriptions[gymAddresses[i]] > block.timestamp) {
                gymAddressesActive[index] = gymAddresses[i];
                subscriptionEndDates[index] = member.gymSubscriptions[gymAddresses[i]];
                index++;
            }
        }
        
        return (gymAddressesActive, subscriptionEndDates);
    }
}
