####You have been asked to add delayed transfer functionality, such that the token is
####transfered at a specified time upto 24hrs in the future
1. Is it possible to implement in a contract?  
No, all transaction in the EVM, need to be initiated by an Externally Owned Account and are executed at call time.  
There can be the possibility to delay execution, however, an additional call will be required.  
2. If so, describe how you would do this, you don't need to code the solution.
As indicated in the previous answer, this could be achieved by splitting the transfer into two calls. One to initiate the transfer and the second one to execute it. Where execution can only be done, after 24h have passed. You could also set this as a keeper task in a protocol that supports keeper tasks.  
