pragma solidity ^0.4.24;

contract Auction{
    address public owner;
    //IPFS: Inter platenary file system foe saving large amount of data
    //IPFS is cost effective and scable off chain decentralized soln for saving data
    
    uint public startBlock;
    uint public endBlock;
    string public ipfsHash;
    
    enum State{Started, Running, Ended, Cancelled}
    State public actionState;
    
    uint public HigestBidingBid;
    address public highestBider;
    
    uint bidIncrement;
    
    mapping(address=>uint) public bids;
    
    constructor(uint _startBlock, uint _endBlock, string _ipfsHash, uint _bidIncrement) public{
        owner = msg.sender;
        actionState = State.Running;
        
        startBlock = block.number;
        endBlock = startBlock  + 40320; // 40320 is 60*60*24*7 
        ipfsHash = "";
        
        bidIncrement = 10;
        /*
        startBlock = _startBlock;
        endBlock = _endBlock;
        ipfsHash = _ipfsHash;
        
        bidIncrement = _bidIncrement; */
    }
    
    modifier notOwner(){
        require(msg.sender != owner);
        _;
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
        
    modifier afterStart(){
        require(block.number >= startBlock);
        _;
    }
    
    modifier beforeEnd(){
        require(block.number <= endBlock);
        _;
    }
    
    function min(uint a, uint b) pure internal returns(uint){ // pure mtlb ki jb blockchain ko touch ni karta H. 
        if (a<=b){
            return a;
        }else{
            return b;
        }
    }
    
    function cancelAuction() public onlyOwner{
        actionState =  State.Cancelled;
    }
    
    
    function placeBid() public payable notOwner afterStart beforeEnd returns(bool){
        require(actionState == State.Running);
        //require(msg.value > 0.001 ether);
        
        uint currentBid = bids[msg.sender] + msg.value;
        
        require(currentBid > HigestBidingBid);
        
        bids[msg.sender] = currentBid;
        
        if(currentBid <= bids[highestBider]){
            HigestBidingBid = min(currentBid + bidIncrement, bids[highestBider]);
        }else{
            HigestBidingBid = min(currentBid, bidIncrement+ bids[highestBider]);
            highestBider = msg.sender;
        }
        
        return true;
        
    }
    
    
    function finalizeAuction() public{
        require(actionState == State.Cancelled || block.number > endBlock);
        require(msg.sender == owner || bids[msg.sender] > 0);
        
        address recipient;
        uint value;
        
        if(actionState == State.Cancelled){
            recipient = msg.sender;
            value =  bids[msg.sender];
        }else{ //ended not canceled
            if(msg.sender == owner){
                recipient = owner;
                value = HigestBidingBid;
            }else{
                if(msg.sender == highestBider){
                    recipient =  highestBider;
                    value = bids[highestBider] - HigestBidingBid;
                }else{// this is neigther the owner nor the highest bidder
                recipient = msg.sender;
                value = bids[msg.sender];
                    
                }
            }
        
    }
    
    recipient.transfer(value);
    
    
}
}
