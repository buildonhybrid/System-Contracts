// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;



interface InterfaceValidator {
    enum Status {
        // validator not exist, default status
        NotExist,
        // validator created
        Created,
        // anyone has staked for the validator
        Staked,
        // validator's staked coins < MinimalStakingCoin
        Unstaked,
        // validator is jailed by system(validator have to repropose)
        Jailed
    }
    struct Description {
        string moniker;
        string identity;
        string website;
        string email;
        string details;
    }
    function getTopValidators() external view returns(address[] memory);
    function getValidatorInfo(address val)external view returns(address payable, Status, uint256, uint256, uint256, address[] memory);
    function getValidatorDescription(address val) external view returns ( string memory,string memory,string memory,string memory,string memory);
    function totalStake() external view returns(uint256);
    function getStakingInfo(address staker, address validator) external view returns(uint256, uint256, uint256);
    function viewStakeReward(address _staker, address _validator) external view returns(uint256);
    function MinimalStakingCoin() external view returns(uint256);
    function isTopValidator(address who) external view returns (bool);
    function StakingLockPeriod() external view returns(uint64);
    function UnstakeLockPeriod() external view returns(uint64);
    function WithdrawProfitPeriod() external view returns(uint64);


    //write functions
    function createOrEditValidator(
        address payable feeAddr,
        string calldata moniker,
        string calldata identity,
        string calldata website,
        string calldata email,
        string calldata details
    ) external payable  returns (bool);

    function unstake(address validator)
        external
        returns (bool);

    function withdrawProfits(address validator) external returns (bool);
}


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ValidatorHelper is Ownable {

    InterfaceValidator public valContract = InterfaceValidator(0x000000000000000000000000000000000000f000);
    uint256 public minimumValidatorStaking = 32 * 1e18;   
   
    //events
    event Stake(address validator, uint256 amount, uint256 timestamp);
    event Unstake(address validator, uint256 timestamp);
    event WithdrawProfit(address validator, uint256 amount, uint256 timestamp);

    receive() external payable {
       
    }


    function createOrEditValidator(
        address payable feeAddr,
        string calldata moniker,
        string calldata identity,
        string calldata website,
        string calldata email,
        string calldata details
    ) external payable  returns (bool) {

       

        require(msg.value >= minimumValidatorStaking, "Please stake minimum validator staking" );

        valContract.createOrEditValidator{value: msg.value}(feeAddr, moniker, identity, website, email, details);

        emit Stake(msg.sender, msg.value, block.timestamp);

        return true;
    }


    function unstake(address validator)
        external
        returns (bool)
    {        
        valContract.unstake(validator);

        emit Unstake(msg.sender, block.timestamp);
        return true;
    }

    function withdrawStakingReward(address validator) external {
        require(validator == tx.origin, "caller should be real validator");    

        
	valContract.withdrawProfits(validator);       
      
    }

    function viewValidatorRewards(address validator) public view returns(uint256){

        (, InterfaceValidator.Status validatorStatus, , uint256 rewardAmount , ,  ) = valContract.getValidatorInfo(validator);


        // if validator is jailed, non-exist, or created, then he will not get any rewards
        if(validatorStatus == InterfaceValidator.Status.Jailed || validatorStatus == InterfaceValidator.Status.NotExist || validatorStatus == InterfaceValidator.Status.Created ){
            return 0;
        }
	rewardAmount += valContract.viewStakeReward(validator,validator);     

       // return hbincoming;
    }

   
    /**
        admin functions
    */
    function rescueCoins() external onlyOwner{        
        payable(msg.sender).transfer(address(this).balance);
    }
    function changeMinimumValidatorStaking(uint256 amount) external onlyOwner{
        minimumValidatorStaking = amount;
    }

    /**
        View functions
    */

    function getAllValidatorInfo() external view returns (uint256 totalValidatorCount,uint256 totalStakedCoins,address[] memory,InterfaceValidator.Status[] memory,uint256[] memory,string[] memory,string[] memory)
    {
        address[] memory highestValidatorsSet = valContract.getTopValidators();

        uint256 totalValidators = highestValidatorsSet.length;
	uint256 totalunstaked ;
        InterfaceValidator.Status[] memory statusArray = new InterfaceValidator.Status[](totalValidators);
        uint256[] memory coinsArray = new uint256[](totalValidators);
        string[] memory identityArray = new string[](totalValidators);
        string[] memory websiteArray = new string[](totalValidators);

        for(uint8 i=0; i < totalValidators; i++){
            (, InterfaceValidator.Status status, uint256 coins, , , ) = valContract.getValidatorInfo(highestValidatorsSet[i]);
	if(coins>0){
            (, string memory identity, string memory website, ,) = valContract.getValidatorDescription(highestValidatorsSet[i]);

            statusArray[i] = status;
            coinsArray[i] = coins;
            identityArray[i] = identity;
            websiteArray[i] = website;
 	}

        else

        {
            totalunstaked += 1;

	}

        }
        return(totalValidators - totalunstaked , valContract.totalStake(), highestValidatorsSet, statusArray, coinsArray, identityArray, websiteArray);


    }


    function validatorSpecificInfo1(address validatorAddress, address user) external view returns(string memory identityName, string memory website, string memory otherDetails, uint256 withdrawableRewards, uint256 stakedCoins, uint256 waitingBlocksForUnstake ){

        (, string memory identity, string memory websiteLocal, ,string memory details) = valContract.getValidatorDescription(validatorAddress);
	

        uint256 unstakeBlock;

        (stakedCoins, unstakeBlock, ) = valContract.getStakingInfo(validatorAddress,validatorAddress);

        if(unstakeBlock!=0){
            waitingBlocksForUnstake = stakedCoins;
            stakedCoins = 0;
        }

        return(identity, websiteLocal, details, viewValidatorRewards(validatorAddress), stakedCoins, waitingBlocksForUnstake) ;
    }


    function validatorSpecificInfo2(address validatorAddress, address user) external view returns(uint256 totalStakedCoins, InterfaceValidator.Status status, uint256 selfStakedCoins, uint256 masterVoters, uint256 stakers, address){
        address[] memory stakersArray;
        (, status, totalStakedCoins, , , stakersArray)  = valContract.getValidatorInfo(validatorAddress);

        (selfStakedCoins, , ) = valContract.getStakingInfo(validatorAddress,validatorAddress);

        return (totalStakedCoins, status, selfStakedCoins, 0, stakersArray.length, user);
    }
    

    function waitingWithdrawProfit(address user, address validatorAddress) external view returns(uint256){
        // no waiting to withdraw profit.
        // this is kept for backward UI compatibility

       return 0;
    }

    function waitingUnstaking(address user, address validator) external view returns(uint256){

        //this function is kept as it is for the UI compatibility
        //no waiting for unstaking
        return 0;
    }

    function waitingWithdrawStaking(address user, address validatorAddress) public view returns(uint256){

        //validator and delegators will have waiting

        (, uint256 unstakeBlock, ) = valContract.getStakingInfo(user,validatorAddress);

        if(unstakeBlock==0){
            return 0;
        }

        if(unstakeBlock + valContract.StakingLockPeriod() > block.number){
            return 2 * ((unstakeBlock + valContract.StakingLockPeriod()) - block.number);
        }

       return 0;

    }

    function minimumStakingAmount() external view returns(uint256){
        return valContract.MinimalStakingCoin();
    }

    function stakingValidations(address user, address validatorAddress) external view returns(uint256 minimumStakingAmt, uint256 stakingWaiting){
        return (valContract.MinimalStakingCoin(), waitingWithdrawStaking(user, validatorAddress));
    }

    function checkValidator(address user) external view returns(bool){
        //this function is for UI compatibility
        return true;
    }
} 
