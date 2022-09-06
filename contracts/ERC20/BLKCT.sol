// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;
import "./IBLKCT.sol";
import "../security/ReentrancyGuard.sol";

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
contract BaseContract is Ownable {
    address internal managerAddress;

    function setManagerAddress(address _managerAddress) public onlyOwner {
        managerAddress = _managerAddress;
    }

    function getManagerAddress() public view returns (address) {
        return managerAddress;
    }
}
interface IContractManager {
    function setAddress(string calldata _name, address _address) external;

    function getAddress(string calldata _name) external view returns (address);

    function deleteAddress(string calldata _name) external;
}


/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


contract BlockCities is ERC20, BaseContract {
    // Name : Blockcities
    // Symbol : BLKCT
    // Decimals : 2
    uint8 public _decimals;
    string private _BlockCitiesAssets;

    event ReferalBonus(address indexed recipient, uint256 amount);

    constructor(uint256 _totalSupply) ERC20("Blockcities", "BLKCT") {
        _decimals = 2;
        _totalSupply = _totalSupply * (10**2);
        _mint(msg.sender, _totalSupply);
        // _approve(address(this), msg.sender, _totalSupply);
    }

    function transferPrice( 
        address from,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        IContractManager manager = IContractManager(managerAddress);
        address blockcitieAssetsAddress = manager.getAddress(
            _BlockCitiesAssets
        );
        require(
            msg.sender == blockcitieAssetsAddress,
            "Can be invoked by only blockcities asset contract"
        );
        _transfer(from, recipient, amount);
        return true;
    }

     function transfertoken( 
        address from,
        address recipient,
        uint256 amount
    ) public returns (bool) {
      
        _transfer(from, recipient, amount);
        return true;
    }
    


    // function referalBonus(address recipient, uint256 amount) public {
    //     transferFrom(address(this), recipient, amount);
    //     emit ReferalBonus(recipient, amount);
    // }

    function transferOwnership(address newOwner) public override onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function decimals() public view virtual override returns (uint8) {
        return 2;
    }

    function setBlockCitiesAssets(string memory _assetAddress)
        public
        onlyOwner
    {
        _BlockCitiesAssets = _assetAddress;
    }

    function getBlockCitiesAssets() public view returns (string memory) {
        return _BlockCitiesAssets;
    }
}


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
        // console.log("_blockCities :", _BlockCities);
        address blockcitiesAddress = manager.getAddress(_BlockCities);
        // console.log("blockCitiesAddress :", blockcitiesAddress);
        
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