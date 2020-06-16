pragma solidity ^0.4.24;

contract Lottery{
    address[] public players; // dynamic array with players address
    address public manager; // contract manager
    
    constructor() public{
        manager = msg.sender;
    }
    
    // This is a fallback payable function will be automatically called when someone sends ether to our contract address
    function() payable public{
        players.push(msg.sender); // add address of the account that sends ether to the players array 
        //(iss contract account me jo b paisa bhej rha h uska address)
    }
    function get_balance() public view returns(uint){
        return address(this).balance; // return contract balance
    } 
    
    
}
