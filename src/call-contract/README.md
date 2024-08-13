# Call Contract Example

This example demonstrates how to relay a message from a source chain to a destination chain.

> Make sure you follow the command above to set up your local `.env` and start the local chains in a different terminal.

To execute the example, use the following command:

```
make local-chain-execute FROM={srcChain} TO={destChain} SCRIPT={script} VALUE={gasValue} MESSAGE={message}
```

## Parameters

`srcChain`: The blockchain network from which the message will be relayed. Acceptable values include "Moonbeam", "Avalanche", "Fantom", "Ethereum", and "Polygon".

`destChain`: The blockchain network to which the message will be relayed. Acceptable values include "Moonbeam", "Avalanche", "Fantom", "Ethereum", and "Polygon".

`script`: The contract to execute on the blockchain network.

`gasValue`: The gas amount to pay for cross-chain interactions.

`message`: The message to be relayed between the chains.

## Example

This example relays the message "Hello World" from Fantom to Polygon.

```
make local-chain-execute FROM=Fantom TO=Polygon SCRIPT=ExecutableSample VALUE=1 MESSAGE="Hello World"
```

**The output will be**:

```
Using local private key for transactions...
SRC_RPC_URL: http://localhost:8548
DEST_RPC_URL: http://localhost:8549
Reading initial state from destination network (POLYGON)...
Value: ""
Source Chain: "Fantom"
Executing setRemoteValue for ExecutableSample...

blockHash               0x716e05da395a0f0862fd4a42d339c495c78678bc7897440b5b6e7297e2f54f85
blockNumber             52
contractAddress
cumulativeGasUsed       60657
effectiveGasPrice       3001641916
gasUsed                 60657
logs                    [{...}]
logsBloom               0x0
status                  1
transactionHash         0x51cf7899a9832bd415b51f743e6a853d1ca817e497d66e2f51009d8f6efb6566
transactionIndex        0
type                    2
Transaction sent successfully.
Reading final state from destination network (POLYGON)...

Value: "Hello World"
Source Chain: "Fantom"
Operation completed successfully!
```
