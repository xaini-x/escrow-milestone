//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./BaseContract.sol";
import "./IContractManager.sol";
import "./IBlockCities.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


/** @title Blockcities token(ERC 20, Burnable and Ownable) contract. */
contract BlockCitiesAssets is Ownable, BaseContract {
    uint256 private _rate;
    uint256 private _investLimit = 50000;
    uint256 private _buyLimit = 50000;
    uint256 private tokensPerEther = 100;
    string private _BlockCities;

    mapping(address => uint256) private securityTokens;
    
    event InvestEvent(
        address indexed _investor,
        string _assetDetails,
        uint256 _amount,
        string _duration,
        string _roi,
        uint256 _timestamp
    );
    event ReserveEvent(
        address indexed _depositor,
        string _assetDetails,
        uint256 _amount,
        uint256 _timestamp
    );
    event BuyEvent(
        uint256 initailAssetTokenAmount,
        uint256 totalChargesInTokens,
        address assetOwnerAddress
       
    );
    event BuyBlockcities(
        address indexed from,
        address indexed receipent,
        uint256 amount
    );
    
    function getTokenPerEther() public view returns (uint256) {
        return tokensPerEther;
    }

    function setTokenPerEther(uint256 _totalTokensPerEther) public onlyOwner {
        tokensPerEther = _totalTokensPerEther;
    }

    function getSecurityTokens() public view returns(uint256) {
        return securityTokens[msg.sender];
    }


    /** @dev func setRate() : Only Onwer (intially the one who deployed the contract)
     * @param rate :  ROI (rate of return on investments) upon the investment..
     */

    function setRate(uint256 rate) public onlyOwner {
        _rate = rate;
    }

    /** @dev func getRate().
     * @return ROI (rate of return on investments) upon the investment.
     */

    function getRate() public view returns (uint256) {
        return (_rate);
    }

    /** @dev func setRate() : Only Onwer (intially the one who deployed the contract)
     * @param investlimit :  ROI (rate of return on investments) upon the investment..
     */

    function setInvestLimit(uint256 investlimit) public onlyOwner {
        _investLimit = investlimit;
    }

    /** @dev func getRate().
     * @return ROI (rate of return on investments) upon the investment.
     */

    function getInvestLimit() public view returns (uint256) {
        return (_investLimit);
    }

    /** @dev func setRate() : Only Onwer (intially the one who deployed the contract)
     * @param buylimit :  ROI (rate of return on investments) upon the investment..
     */

    function setBuyLimit(uint256 buylimit) public onlyOwner {
        _buyLimit = buylimit;
    }

    /** @dev func getRate().

      * @return ROI (rate of return on investments) upon the investment.
      */

    function getBuyLimit() public view returns (uint256) {
        return (_buyLimit);
    }

    /** @dev func getSecurityToken().
     * @param investorAddress : ethereum address of the user's whose security tokens are required.
     * @return securityTokens : Total Amount of security token on provided address.
     */

    function getSecurityToken(address investorAddress)
        public
        view
        returns (uint256)
    {
        return (securityTokens[investorAddress]);
    }

    // just for testing
    function getDecimal() public returns(uint8) {
        IContractManager manager = IContractManager(
            managerAddress
        );
        console.log("_blockCities :", _BlockCities);
        address blockcitiesAddress = manager.getAddress(_BlockCities);
        console.log("blockCitiesAddress :", blockcitiesAddress);
        
        IBlockCities BLKCT = IBlockCities(blockcitiesAddress);
        uint8 decimals = BLKCT.decimals();
        return decimals;
    }

    /** @dev func buyBlockcities().
     * @param _amount : Total number of blockcities tokens (decimals) to be transfer to sender's address.
     */

    function buyBlockcities(address recipient, uint256 _amount) public onlyOwner {
        IContractManager manager = IContractManager(
            managerAddress
        );
        address blockcitiesAddress = manager.getAddress(_BlockCities);
        IBlockCities BLKCT = IBlockCities(blockcitiesAddress);
        BLKCT.transferPrice(owner(), recipient, _amount);
        emit BuyBlockcities(owner(), recipient, _amount);
    }

    /** @dev func invest()
     * @param _amount      : Total number of blockcities tokens (decimals) required to invest in asset.
     * @param _assetowner  : Assest Owner's ethereum address.
     * @param _duration    : Duration (time period) to which investment is done.
     * @param _roi         : Rate of return on investment.
     * @param _assetDetails : Additional Details(type, characterstics etc.) of the assest.
     */

    function invest(
        uint256 _amount,
        address _assetowner,
        string memory _duration,
        string memory _roi,
        string memory _assetDetails
    ) public {
        IContractManager manager = IContractManager(
            managerAddress
        );
        address getsAddress = manager.getAddress(_BlockCities);
        IBlockCities BLKCT = IBlockCities(getsAddress);
        require(_amount >= _investLimit, "Not enough balance");
        require(BLKCT.balanceOf(_msgSender()) >= _amount, "Not enough balance");
        BLKCT.transferPrice(_msgSender(), _assetowner, _amount);
        securityTokens[_msgSender()] = securityTokens[_msgSender()] + _amount;
        emit InvestEvent(
            _msgSender(),
            _assetDetails,
            _amount,
            _duration,
            _roi,
            block.timestamp
        );
    }

    /** @dev func reserve()
     * @param _amount      : Total number of blockcities tokens (decimals) required to reserve in asset.
     * @param _receiver    : Assest Owner's ethereum address.
     * @param _assetDetails : Additional Details(type, characterstics etc.) of the assest.
     */

    function reserve(
        uint256 _amount,
        address _receiver,
        string memory _assetDetails
    ) public {
        IContractManager manager = IContractManager(
            managerAddress
        );
        address getsAddress = manager.getAddress(_BlockCities);
        IBlockCities BLKCT = IBlockCities(getsAddress);
        require(BLKCT.balanceOf(_msgSender()) >= _amount, "Not enough balance");
        BLKCT.transferPrice(_msgSender(), _receiver, _amount);
        emit ReserveEvent(
            _msgSender(),
            _assetDetails,
            _amount,
            block.timestamp
        );
    }

    /** @dev func claimReturns()
     * @param _amount        : Total number of blockcities tokens (decimals) included interest earned on investment.
     * @param _assetowner    : Assest Owner's ethereum address.
     * @param _investor      : Investor's (one who invested in assest) ethreum address.
     * @param _initialAmount : Total number of blockcities tokens (decimals) submitted at the investment (Intial Amount(excluding interest)).
     */

    function claimReturns(
        uint256 _amount,
        address _assetowner,
        address _investor,
        uint256 _initialAmount
    ) public {
        IContractManager manager = IContractManager(
            managerAddress
        );
        address getsAddress = manager.getAddress(_BlockCities);
        IBlockCities BLKCT = IBlockCities(getsAddress);
        require(BLKCT.balanceOf(_assetowner) >= _amount, "Not enough balance");
        BLKCT.transferPrice(_assetowner, _investor, _amount);
        securityTokens[_investor] = securityTokens[_investor] - _initialAmount;
    }

    //** @dev func buyAsset()
    // * @param initailAssetTokenAmount : Total number of blockcities tokens (decimals) required to invest in asset.
    // * @param assetOwnerAddress : Assest Owner's ethereum address.
    // * @param feeTokenAmount : Fees charged by buyer is transffered to admin account.
    // * @param taxTokenAmount : Tax charged by buyer is transferred  to admin account.
    // * @param assetTitle : Title of the assest.
    // * @param unitNumber : alphaNumeric value of the asset
    // */
    
      function buyAsset(
        uint256 initialAssetTokenAmount,
        uint256 totalChargesInTokens,
        address assetOwnerAddress
      
    ) external{
        IContractManager manager = IContractManager(
            managerAddress
        );
        address getsAddress = manager.getAddress(_BlockCities);
        IBlockCities BLKCT = IBlockCities(getsAddress);
         require(
            BLKCT.balanceOf(msg.sender) >= 0,
             "ERROR : Not enough token to buy asset"
        );
        BLKCT.transferPrice(msg.sender, assetOwnerAddress, initialAssetTokenAmount);
        BLKCT.transferPrice(msg.sender, owner(), totalChargesInTokens);
        emit BuyEvent(initialAssetTokenAmount,totalChargesInTokens, assetOwnerAddress);
    }

    
    function setBlockCities(string memory _blockCitiesAddress) public onlyOwner {
        _BlockCities = _blockCitiesAddress;
    }

    
    function getBlockCities() public view returns(string memory) {
        return _BlockCities;
    }
}