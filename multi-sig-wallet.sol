//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Wallet{
    event Deposit(address indexed sender, uint amount, uint balance);
    event Submit(uint indexed txId);
    event Approve(address indexed owner, uint indexed txId); 
    event Revoke(address indexed owner, uint indexed txId); 
    event Execute(uint indexed txId);

    address[] public owners;     
    mapping(address => bool) public isOwner; 
    uint public required; 
    struct Transaction{ 
        address to; 
        uint value; 
        bytes data; 
        bool executed;
        uint numConfirmations;
    } 
    Transaction[] public transactions; 
    mapping(uint => mapping(address => bool)) public approved;


    constructor(address[] memory _owners, uint _required) payable { 
        require(_owners.length > 0, "owners required"); 
        require(_required > 0 &&  _required <=_owners.length, "Invalid required number of confirmations" 
        ); 
            for (uint i ; i < _owners.length ; i++) { 
                address owner = _owners[i]; 
                require(owner != address(0), "invalid owner"); 
                require(!isOwner[owner], "owner not unique"); 
                isOwner[owner] = true; 
                owners.push(owner); 
            } 
            required  = _required; 
        }
        receive() external payable { 
            emit Deposit(msg.sender, msg.value,(address(this).balance));
        }
        modifier onlyOwner() {
            require(isOwner[msg.sender], "not an owner");
            _;
        }
        function submit(address _to, uint _value, bytes calldata _data)
            external
            onlyOwner
        {
            transactions.push(Transaction({
                    to: _to,
                    value: _value,
                    data: _data,
                    executed: false,
                    numConfirmations: 0
            }));
            emit Submit(transactions.length - 1); 
        }

        modifier txExists(uint _txId) {
            require(_txId < transactions.length, "Tx does not exist");
            _;
        }
        modifier notApproved(uint _txId){
            require(!approved[_txId][msg.sender], "tx already approved");
            _;
        }
        modifier notExecuted(uint _txId){
            require(!transactions[_txId].executed, "tx already executed");
            _;
        }

        function approve(uint _txId)
            external
            onlyOwner
            txExists(_txId)
            notApproved(_txId) 
            notExecuted(_txId) 
            {
            Transaction storage transaction = transactions[_txId];
            approved[_txId][msg.sender] = true;
            transaction.numConfirmations += 1;
            emit Approve(msg.sender, _txId);
        }
        function _getApprovalCount(uint _txId) internal view returns(uint count){
            for(uint i; i < owners.length; i++){
                if(approved[_txId][owners[i]]) {
                    count += 1;
            }
        }
        }
        function execute(uint _txId) public
            onlyOwner
            txExists(_txId)
            notExecuted(_txId)
            {
            require(_getApprovalCount(_txId) >= required, "Not enough approvals");
            Transaction storage transaction = transactions[_txId];
            
            transaction.executed = true;
            
                (bool success, ) = transaction.to.call{value: transaction.value}(
                transaction.data
                );
                require(success, "txfailed");
                emit Execute(_txId);
            }
        function revoke(uint _txId) 
            external 
            onlyOwner 
            txExists( _txId) 
            notExecuted( _txId)
            {
                Transaction storage transaction = transactions[_txId];
                require(approved[_txId][msg.sender], "tx not approved");
                approved[_txId][msg.sender] = false;
                transaction.numConfirmations -= 1;
                emit Revoke(msg.sender, _txId);
                }
            
        function balance() external view returns (uint){
            uint bal = address(this).balance;
            return bal;
        }
        
        function getTransaction(uint _txIndex)
        public
        view
        returns (address to, uint value, bytes memory data, bool executed, uint numConfirmations)
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }
    }
