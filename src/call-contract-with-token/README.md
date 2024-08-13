# Call Contract with Token Example

This example allows you to send aUSDC from a source chain to a destination chain and distribute it equally among specified accounts.

> Make sure you follow the command above to set up your local `.env` and start the local chains in different terminal.

To execute the example, use the following command:

```
make local-chain-execute FROM={srcChain} TO={destChain} SCRIPT={script} VALUE={gasValue} AMOUNT={amount} DEST_ADDRESSES={destinationAddresses}
```

#### Parameters

`srcChain`: The blockchain network from which the message will be relayed. Acceptable values include "Moonbeam", "Avalanche", "Fantom", "Ethereum", and "Polygon".

`destChain`: The blockchain network to which the message will be relayed. Acceptable values include "Moonbeam", "Avalanche", "Fantom", "Ethereum", and "Polygon".

`script`: The contract to execute on the blockchain network.

`gasValue`: The gas amount to pay for cross-chain interactions.

`amount`: The amount of aUSDC to be transferred and distributed among the specified accounts.

`destinationAddresses`: The addresses to receive aUSDC.

#### Example

This example sends specified aUSDC amount from Fantom to Polygon.

```
make local-chain-execute FROM=Fantom TO=Polygon SCRIPT=DistributionExecutable VALUE=1 AMOUNT=10 DEST_ADDRESSES='["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"]'
```

**The output will be**:

```
Using local private key for transactions...
SRC_RPC_URL: http://localhost:8548
DEST_RPC_URL: http://localhost:8549
Checking initial aUSDC balance for the account making the request...
USDC Address: 0x6f3b8e61DD1aD2d28229Ba4190554263D365D632
SRC Address: 0xe6b98F104c1BEf218F3893ADab4160Dc73Eb8367
Requesting account's address: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
Initial balance: 0
Approving USDC spend...

blockHash               0x0310a1ef6bdea1d8f3ac8060b8348c566ffcc3125bbfd42828a412e029df60c1
blockNumber             53
contractAddress
cumulativeGasUsed       46253
effectiveGasPrice       3001437507
gasUsed                 46253
logs                    [{...}]
logsBloom               0x8
root
status                  1
transactionHash         0xc40cc2469a063d87bbecadd168735e5d30771f6897d4393232e41461f1da679f
transactionIndex        0
type                    2
Approval successful.
Checking USDC allowance...

10000000 [1e7]
Executing sendToMany for DistributionExecutable...

blockHash               0x479c04b1330b8f0953eae85b48d5169f363460e00afb73c2690dbedfba234f32
blockNumber             54
contractAddress
cumulativeGasUsed       124709
effectiveGasPrice       3001258373
gasUsed                 124709
logs                    [{...}]
logsBloom               0x8
status                  1
transactionHash         0x2ef519f9cfb0ef070d9bd2d55cd077d4795376311ea4506cc62709862b94df3a
transactionIndex        0
type                    2
Transaction sent successfully.
Checking final balance for the account making the request...
Checking final aUSDC balance for the account making the request...
10000000 [1e7]
Operation completed successfully!
```
