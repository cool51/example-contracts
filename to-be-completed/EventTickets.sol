pragma solidity ^0.5.0;

    /*
        The EventTickets contract keeps track of the details and ticket sales of one event.
     */

contract EventTickets {

    /*
        Create a public state variable called owner.
        Use the appropriate keyword to create an associated getter function.

       -- Use the appropriate keyword to allow ether transfers.
     */
     address payable public  owner ;





   function getOwner() public view returns(address) {
        return owner;
    }
    

    uint   TICKET_PRICE = 100 wei;

    /*
        Create a struct called "Event".
        The struct has 6 fields: description, website (URL), totalTickets, sales, buyers, and isOpen.
        Choose the appropriate variable type for each field.
        The "buyers" field should keep track of addresses and how many tickets each buyer purchases.
    */
struct Buyers {
mapping (address=>uint) noOfTicket;
    string descriptin;

}
struct Event{
    string description;
    string websiteURL;
    uint256 totalTickets;
    uint256 sales;
    
    Buyers buyers;



    bool isOpen;
}
   Event events;

    /*
        Define 3 logging events.
        LogBuyTickets should provide information about the purchaser and the number of tickets purchased.
        LogGetRefund should provide information about the refund requester and the number of tickets refunded.
        LogEndSale should provide infromation about the contract owner and the balance transferred to them.
    */
    
    	event LogBuyTickets(address purchaser,uint noOfTicket);
        event LogGetRefund(address refunfRequester,uint noOfTicket);
        event LogEndSale(address contractOwner,uint256 balanceTransferred);

    /*
        Create a modifier that throws an error if the msg.sender is not the owner.
    */
    
    modifier onlyOwner{
        require (owner==msg.sender,"Error, Caller must be an Owner");
        _;
    }

modifier isOpen{
    require (events.isOpen == true,"Event is not available at the moment");
    _;
}

    /*
        Define a constructor.
        The constructor takes 3 arguments, the description, the URL and the number of tickets for sale.
        Set the owner to the creator of the contract.
        Set the appropriate myEvent details.
    */


constructor(string memory _description,string  memory _websiteURL,uint  _totalTickets) public{
    owner=msg.sender;
    events.description=_description;
    events.websiteURL=_websiteURL;
    events.totalTickets=_totalTickets;

}

    /*
        Define a function called readEvent() that returns the event details.
        This function does not modify state, add the appropriate keyword.
        The returned details should be called description, website, uint totalTickets, uint sales, bool isOpen in that order.
    */
    function readEvent()
        public view 
        returns(string memory description, string memory websiteURL, uint totalTickets, uint sales, bool isOpen)
    {
return (events.description,events.websiteURL,events.totalTickets,events.sales,events.isOpen);
    }

    /*
        Define a function called getBuyerTicketCount().
        This function takes 1 argument, an address and
        returns the number of tickets that address has purchased.
    */
    function getBuyerTicketCount(address  _buyerAddress) public view returns(uint ){
    return events.buyers.noOfTicket[_buyerAddress];
}

    /*
        Define a function called buyTickets().
        This function allows someone to purchase tickets for the event.
        This function takes one argument, the number of tickets to be purchased.
        This function can accept Ether.
        Be sure to check:
            - That the event isOpen
            - That the transaction value is sufficient for the number of tickets purchased
            - That there are enough tickets in stock
        Then:
            - add the appropriate number of tickets to the purchasers count
            - account for the purchase in the remaining number of available tickets
            - refund any surplus value sent with the transaction
            - emit the appropriate event
    */

function buyTickets(uint _noOfTicket) payable public isOpen{
require(msg.value>=TICKET_PRICE* _noOfTicket,"Insufficiet amount");
require(events.totalTickets>=_noOfTicket,"Sorry not enough tickets available");

events.buyers.noOfTicket[msg.sender]+=_noOfTicket;
events.sales+=_noOfTicket;
events.totalTickets-=_noOfTicket;

uint  remainingMoney=msg.value-(TICKET_PRICE*_noOfTicket);

msg.sender.transfer(remainingMoney);
emit LogBuyTickets(msg.sender,_noOfTicket);
}

    /*
        Define a function called getRefund().
        This function allows someone to get a refund for tickets for the account they purchased from.
        TODO:
            - Check that the requester has purchased tickets.
            - Make sure the refunded tickets go back into the pool of avialable tickets.
            - Transfer the appropriate amount to the refund requester.
            - Emit the appropriate event.
    */

function getRefund(uint _noOfTickets) public{
    require(events.buyers.noOfTicket[msg.sender]>=_noOfTickets,"You havent purchased any tickets");
    events.totalTickets+=_noOfTickets;
    events.sales-=_noOfTickets;
    events.buyers.noOfTicket[msg.sender]-=_noOfTickets;
    msg.sender.transfer(_noOfTickets*TICKET_PRICE);
    emit LogGetRefund(msg.sender,_noOfTickets);


}

    /*
        Define a function called endSale().
        This function will close the ticket sales.
        This function can only be called by the contract owner.
        TODO:
            - close the event
            - transfer the contract balance to the owner
            - emit the appropriate event
    */

    function endSale()public onlyOwner{
        uint total=events.sales*TICKET_PRICE;
        owner.transfer(total);
        events.isOpen=false;
        emit LogEndSale(owner,total);
    }
}