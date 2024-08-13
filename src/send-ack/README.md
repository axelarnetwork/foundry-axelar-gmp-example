# Send ack Example

Send a 2-way message from the source chain to the destination chain, and an "executed" acknowledgment is sent back to the source chain.

> Make sure you follow the command above to set up your local `.env` and start the local chains in a different terminal.

To execute the example, use the following command:

```
make local-chain-execute FROM={srcChain} TO={destChain} SCRIPT={script} VALUE={gasValue} MESSAGE={message}
```

## Parameters

- `srcChain`: The blockchain network from which the message will be relayed. Acceptable values include "Moonbeam", "Avalanche", "Fantom", "Ethereum", and "Polygon".

- `destChain`: The blockchain network to which the message will be relayed. Acceptable values include "Moonbeam", "Avalanche", "Fantom", "Ethereum", and "Polygon".

- `script`: The contract to execute on the blockchain network.

- `gasValue`: The gas amount to pay for cross-chain interactions.

- `message`: The message to be relayed between the chains.

## Example

This example sends "Hello" from Fantom and gets an acknowledgment message "World" from Polygon.

```
make local-chain-execute FROM=Fantom TO=Polygon SCRIPT=SendAck VALUE=1 MESSAGE="Hello"
```

**The output will be**:

```
Using local private key for transactions...
SRC_RPC_URL: http://localhost:8548
DEST_RPC_URL: http://localhost:8549
Reading initial state from destination network (POLYGON)...
Message: ""
Executing sendMessage for SendAck...

blockHash               0xa9a084b37455507d18227019ee0b161acd910689f390aa025a603a9ccb7ff393
blockNumber             29
contractAddress
cumulativeGasUsed       60507
effectiveGasPrice       3030987695
gasUsed                 60507
logs                    [{...}]
logsBloom               0x
status                  1
transactionHash         0x274ddcc2f306a9e3a9ec0c82cfc210e94d360d91d32eccceebfe93075aecb1db
transactionIndex        0
type                    2
Transaction sent successfully.
Reading final state from destination network (POLYGON)...

Message: "World"
Operation completed successfully!
```
