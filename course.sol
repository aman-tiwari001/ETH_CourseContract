// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

contract Course {
    uint public fee;
    address public owner;
    event CoursePurchased(address user, string email, uint amount);

    struct User {
        address user;
        string email;
        uint amount;
    }

    User[] public subscribers;
    mapping(address => bool) public hasAccess;

    constructor(uint256 _fee) {
        owner = msg.sender;
        fee = _fee;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function changeCourseFee(uint _fee) external onlyOwner {
        fee = _fee;
    }

    function checkCourseAccess(address _user) public view returns(bool) {
        return hasAccess[_user];
    }

    function buyCourse(string memory email) payable external {
        require(!checkCourseAccess(msg.sender), "Course already purchased");
        require(msg.value >= fee, "ETH amount should be equal to course fee");
        
        // Store subscriber information
        subscribers.push(User(msg.sender, email, msg.value));
        hasAccess[msg.sender] = true;
        
        emit CoursePurchased(msg.sender, email, msg.value);
        
        // Refund excess Ether
        if (msg.value > fee) {
            payable(msg.sender).transfer(msg.value - fee);
        }
    }

    function withdrawMoney() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function getAllSubscribers() external view returns(User[] memory) {
        return subscribers;
    }
}
