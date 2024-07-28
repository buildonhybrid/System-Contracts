## Hybots Staking Smart Contract

## Project Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

## Docs

[Git Source](https://github.com/buildonhybrid/System-Contracts/blob/ecc0b91b2acdac9dddf1d2205743220548909118/src/HybotsStaking.sol)

**Inherits:**
Ownable, IERC721Receiver


## State Variables
### hybotsCollection
address of Hybots nft collection.


```solidity
IERC721 public hybotsCollection;
```


### numberOfLockedTokens
number of total locked hybots nfts.


```solidity
uint32 public numberOfLockedTokens;
```


### nftOwnerByTokenId
collection of tokenIds staked by users.


```solidity
mapping(uint256 tokenId => address owner) public nftOwnerByTokenId;
```


### stakedTokensByOwner
collection of nfts staked by user.


```solidity
mapping(address owner => EnumerableSet.UintSet ids) internal stakedTokensByOwner;
```


## Functions
### constructor


```solidity
constructor(IERC721 hybotsCollection_, address initialOwner) Ownable(initialOwner);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`hybotsCollection_`|`IERC721`|address of the hybots nft collection.|
|`initialOwner`|`address`|address of the contractOwner.|


### stake

main function for stake nft by user.


```solidity
function stake(uint256 tokenId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|id of the nft which will be staked.|


### unstake

function for unstake nft by user.


```solidity
function unstake(uint256 tokenId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|id of the nft which will be unstaked.|


### withdrawETH

withdraw native coin and transfer it to owner.


```solidity
function withdrawETH() external onlyOwner;
```

### withdrawToken

withdraw tokens and transfer it to owner.


```solidity
function withdrawToken(IERC20 token, uint256 amount) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`IERC20`|address of the token which will be withdrawn.|
|`amount`|`uint256`|amount of token which will be withdrawn in wei.|


### getAllStakedTokensByOwner

returns all ids of staked nfts by given user.


```solidity
function getAllStakedTokensByOwner(address owner_) public view returns (uint256[] memory ids);
```

### onERC721Received


```solidity
function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4);
```

## Events
### Staked
emits when user staken nft.


```solidity
event Staked(address owner, uint256 tokenId);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner`|`address`|address of user which staked nft.|
|`tokenId`|`uint256`|id of the staked nft.|

### Unstaked
emits when user unstake his nft.


```solidity
event Unstaked(address owner, uint256 tokenId);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner`|`address`|address of user which staked nft.|
|`tokenId`|`uint256`|id of the staked nft.|

### ETHWithdrawn
emits when owner withdrawn native coin from contract.


```solidity
event ETHWithdrawn(address to, uint256 amount);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|address of the eth receiver, it is always `owner`.|
|`amount`|`uint256`|amount of withdraw eth in wei.|

### TokenWithdrawn
emits when owner erc20 tokens from contract.


```solidity
event TokenWithdrawn(IERC20 token, address to, uint256 amount);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`IERC20`|address of the erc20 token which was withdrawn.|
|`to`|`address`|address of the eth receiver, it is always `owner`.|
|`amount`|`uint256`|amount of withdraw token in wei.|

## Errors
### UnaceptableValue

```solidity
error UnaceptableValue();
```

### NotOwnerOfStakedToken

```solidity
error NotOwnerOfStakedToken(uint256 tokenId);
```


