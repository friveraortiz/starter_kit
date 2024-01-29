pragma solidity ^0.5.0;

contract Marketplace {
   string public name;
   
   /* We will declare a variable as unsigned integer.
     An unsigned integer in Solidity is a data type that represents a number greater than or equal to zero.
   */ 
   uint public productCount = 0;
   
   /* We will create a mapping for the Product.
      A mapping in Solidity works like associative arrays, or hash tables, with key value-pairs. 
      Mappings have unique keys that return unique values. 
      In our case, we will use an id as a key, and the value will be a Product struct. 
      This will essentially allow us to look up a product by id, like a database.
   */
   mapping(uint => Product) public products;
   
   
   /* We will create an struct.
      An struct in Solidity allows you to create your own data structures, with any arbitrary attributes. 
      The Product struct stores all the attributes of a product that we'll need, like id, name, price, owner, and purchased.
   */
   struct Product {
      uint id;
	  string name;
	  uint price;
	  address payable owner;
	  bool purchased;
   }
   
   /* We will create an event.
     An event in Solidity works like a Listener in Java.
     An event allows external subscribers to listen to an action.
     In this case, the ProductCreated event will allow us to verify that a product was created on the blockchain.
   */
   event ProductCreated(
      uint id,
	  string name,
	  uint price,
	  address payable owner,
	  bool purchased
   );
   
   event ProductPurchased(
      uint id,
	  string name,
	  uint price,
	  address payable owner,
	  bool purchased
   );   
   
   constructor() public {
      name = "Dapp University Marketplace";
   }
   
   function createProduct(string memory _name, uint _price) public {
      // Require a valid name
	  require(bytes(_name).length > 0);
	  // Require a valid price
	  require(_price > 0);
      // Increment product count
      productCount ++;
	  // Create the product
	  products[productCount] = Product(productCount, _name, _price, msg.sender, false);
	  // Trigger an event
      emit ProductCreated(productCount, _name, _price, msg.sender, false);
   }
   
   /* We are going to create a function that allows us to buy a product and 
     sends Ether, and weis to the seller
     To do this, when we create the function purchaseProduct we add a modifier : payable 
     We also add this modifier payer in all the places that use the variable _seller
   */
   function purchaseProduct(uint _id) public payable {
       // Fetch the product
       Product memory _product = products[_id];
	   
       // Fetch the owner
	   address payable _seller = _product.owner;
	   
	   // Make sure the product has a valid id
       require(_product.id > 0 && _product.id <= productCount);
	   
	   // Require that there is enough Ether in the transaction
       require(msg.value >= _product.price);
	   
       // Require that the product has not been purchased already
       require(!_product.purchased);
	   
	   // Require that the buyer is not the seller
       require(_seller != msg.sender);
	   
	   // Transfer ownership to the buyer
       _product.owner = msg.sender;
	   
	   // Mark as purchased
       _product.purchased = true;
	   
	   // Update the product
       products[_id] = _product;
	   
	   // Pay the seller by sending them Ether
       address(_seller).transfer(msg.value);
	   
       // Trigger an event
       emit ProductPurchased(productCount, _product.name, _product.price, msg.sender, true);	 	   
   }
}