### Imagine you have been given the Contract.sol (in folder) to audit with the following note from the team:  

```
DogCoinGame is a game where players are added to the contract via the addPlayer function,  
they need to send 1 ETH to play.
Once 200 players have entered, the UI will be notified by the startPayout event, and will  
pick 100 winners which will be added to the winners array, the UI will then call the payout  
function to pay each of the winners.
The remaining balance will be kept as profit for the developers.'  
```

### Write out the main points that you would include in an audit.

0. Game description is lacking definition or intent.
1. The `startPayout()` event does not have parameters.
2. The function `addPlayer(address payable _player)` can be called by anyone. The function should check that call is done by msg.sender.
3. The function `addWinner(address payable _winner)` can be called by anyone. The function should restrict access. 
4. The point above needs to highlight that such mechanism put a highlevel of trust on the holder of the restricted access.
5. the function `payWinners(uint _amount)` should be marked as internal. 
