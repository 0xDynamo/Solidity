How to code a Multi Signature Wallet in solidity

First, let's begin by defining what exactly a multi sig wallet is. 
A multi sig wallet stands for multi signature wallet in which multiple addresses can verify, confirm or revoke a transaction made on a wallet that is shared by multiple owners. A majority of verifiers has to be achieved for a transaction to be confirmed and executed.



**1. Events**

- event Deposit()
- event SubmitTransaction()
- event ExecuteTransaction()
- event Approve()
- event RevokeConfirmation()

**2. State Variables**
- store some owners in an array of addresses called owners
- only owners should be allowed to execute functions in this contract
- We define a mapping of addresses that will return a boolean if isOwner
- Once a transaction is submited to the contract, other owners will have to approve that the transaction should go through. The number of approvals needed before the transaction can be accepted will be stored in a uint.

- We will declare a struct that will store the Transaction
	- the address the transaction should go to
	- the value that should be sent
	- some data
	- a boolean indicating whether the Transaction has been executed or not
	- Number of confirmations this transaction has received
	
- We also store the struct of Transaction into an array of transactions
- Each transaction can be exececuted if the number of approvals is greater or equal to the required Confirmations. We will store the approval of each transaction by each owner  into a public nested mapping called approved. From uint(index of the transaction) to another mapping of address (address of the owner) to boolean (indicates whether the transaction is approved by the owner or not)

**3. Constructor**
- For the input of the constructor we put in two inputs. The Addresses of the owners from memory and the required number of Confirmations for the contract.
-  Validate _owner is not empty
-  Validate _required is greater than 0
-  Validate _required is less than or equal to the number of _owners
-  Set the state variables owners from the input _owners.
	- Each owner should not be the zero address
	- Validate owners are unique using the isOwner mapping
-  Set the state variable required from the input.

**4. Fallback**
- msg.sender
- msg.value
- current amount of ether in the contract (address(this).balance)
- emit the Deposit event (see below) with

**5. Submit Transaction**
- Create an onlyOwner modifier that checks that the message sender is included in isOwner.
- Inside submitTransaction, create a new Transaction struct from the inputs and append it to the transactions array
	- executed should be initialized to false
	- numConfirmations should be initialized to 0
- Emit the SubmitTransaction event 
	- txIndex should be the index of the newly created transaction

**6. Approve Transaction**
- Complete the modifier txExists
	- it should require that the transaction at txIndex exists by checking _txIndex is bigger 
- Complete the modifier notExecuted
	- it should require that the transaction at txIndex is not yet executed
- Complete the modifier notConfirmed
	- it should require that the transaction at txIndex is not yet confirmed by msg.sender
- Confirm the transaction
	- Check that the _txId of the msg.sender in the nested mapping approved is equal to true.
	- We need to get the data stored in the Transaction struct as a variable transaction and update it.
	- increment numConfirmation by 1
	- emit ConfirmTransaction event for the transaction being confirmed

**1. Helper Functions**
- GetApprovalCount
Before an owner can execute a function we need to make sure that the number of approvals is high enough. So we should define a function that counts the number of approvals. This function can be private.
	- For each owner, we check whether approved is true or not.
	- if we initialise count within the return variable count, then we do not need to write return count; because it is implicitly returned  from returns.
- Getbalance 
- GetTransaction
	

**8.Execute Function**
- it should only be able to execute if the txId exists and hasn't been executed yet 
- check that the count of Approvals that we defined in the helper function is greater than or equal to the required number of approvals.
- We need to get the data stored in the Transaction struct as a variable transaction and update it.
- set executed to true
- execute the transaction using the low level call method 
- require that the transaction executed successfully
- emit ExecuteTransaction

**9.Revoke**
Let's say that an owner approves a transaction, but before the transaction is executed, he changes his mind and wants to undo the approval.
- Add appropriate modifiers
	- only owner should be able to call this function
	- transaction at _txIndex must exist
	- transaction at _txIndex must be executed
- Revoke the confirmation
	- We need to get the data stored in the Transaction struct as a variable transaction and update it.
	- require that msg.sender has approved the transaction
	- set approved to false for msg.sender
	- decrement the number of  confirmations that  the transaction has.
	- emit RevokeConfirmation

