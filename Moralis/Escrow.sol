// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.6.0 <0.9.0;

contract Escrow {

    //Variables
    enum State { NOT_INITIATED, AWAITING_PAYMENT, AWAYTING_DELEVERY, COMPLETE}

    State public currState;

    bool public isBuyerIn;
    bool public isSellerIn;

    uint public price;

    address public buyer;
    address payable public seller;

    //Modifiers
    modifier onlyBuyer() {
        require(msg.sender ==  buyer, "Only buyer can call this function");
        _;
    }

    modifier escrowNotStarted() {
        require(currState == State.NOT_INITIATED);
        _;
    }
    
    //function
    constructor(address _buyer, address payable _seller, uint _price){
        buyer = _buyer;
        seller = _seller;
        price = _price * (1 ether);
    }

    function initContract() escrowNotStarted public {
        if (msg.sender == buyer) {
            isBuyerIn = true;
        }
        if (msg.sender == seller) {
            isSellerIn = true;
        }
        if (isBuyerIn && isSellerIn) {
            currState = State.AWAITING_PAYMENT;
        }
    }

    function deposit() onlyBuyer public payable {
        require(currState == State.AWAITING_PAYMENT, "Already Paid");
        require(msg.value == price, "Wrong deposit amount");
        currState = State.AWAYTING_DELEVERY;

    }

    function confirmDelivery() onlyBuyer public payable {
        require(currState == State.AWAYTING_DELEVERY, "Cannot confirm delivery");
        seller.transfer(price);
        currState = State.COMPLETE;
    }
    function withdraw() onlyBuyer public payable {
        require(currState == State.AWAYTING_DELEVERY, "Cannot withdraw at the stage");
        payable(msg.sender).transfer(price);
        currState = State.COMPLETE;
    }
}
