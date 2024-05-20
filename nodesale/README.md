# Nodesale
## Usage

### Build

```shell
$ forge build
```

### Run Static Analyzer
```shell
$ slither . --config-file slither.config.json 
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Cast

```shell
$ cast <subcommand>
```


# Protocol Documentation
## Functions
### buy

Main function for buy nodes in public sale.


```solidity
function buy(uint8 nodeType, uint256 amount, ReferralCode memory referralCode) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`nodeType`|`uint8`|Number of the node type.|
|`amount`|`uint256`|Amount of nodes to be bought in one time.|
|`referralCode`|`ReferralCode`|Referral code which has all attributes for setup discounts.|


### withdraw

Withdraw collected wrapped ether by owner.


```solidity
function withdraw(address to) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address which will receive collected tokens.|


### pause

*To pause the presale*


```solidity
function pause() external;
```

### unpause

*To unpause the presale*


```solidity
function unpause() external;
```

## Events
### SaleTimeUpdated
Emits when timestamp of start and end of the sale are updated.


```solidity
event SaleTimeUpdated(uint256 indexed _start, uint256 indexed _end);
```

### Bought
Emits when someone bought nodes.


```solidity
event Bought(address indexed user, ReferralCode referralCode, uint256 indexed nodesBought, uint256 amountPaid);
```

### Withdrawn
Emits when owner withdraw collected tokens.


```solidity
event Withdrawn(address to, uint256 value);
```

## Errors
### InvalidTimestamp

```solidity
error InvalidTimestamp();
```

### MaximumLimitReached

```solidity
error MaximumLimitReached();
```

### InvalidAmountToBuy

```solidity
error InvalidAmountToBuy();
```

### UnacceptableValue

```solidity
error UnacceptableValue();
```

### ExceedsMaxAllowedNodesPerUser

```solidity
error ExceedsMaxAllowedNodesPerUser();
```

## Structs
### ReferralCode

```solidity
struct ReferralCode {
    address ownerOfReferralCode;
    bool isWithReferralCode;
    uint16 ownerPercentNumerator;
    uint16 ownerPercentDenominator;
    uint16 discountNumerator;
    uint16 discountDenominator;
    bytes signature;
}
```

