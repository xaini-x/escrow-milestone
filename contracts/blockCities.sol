// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./ERC1155/ERC1155.sol";
import "./ERC20/IBLKCT.sol";
import "./storage/userStorageInterface.sol";
import "./utils/EnumerableSet.sol";

contract BLOCKCITIES is ERC1155, Ownable {
    uint256 fees;
    //blockcities token address
    IBlockCities public BC_TOKEN;
    //user storage contract address
    UserStorageInterface public userContract;
    //escrow admin address store
    address public ercrowAdmin;
    uint256 id;
    mapping(uint256 => _milestone) milestone;
    mapping(uint256 => mapping(uint256 => uint256)) public totalRFPid;
    mapping(uint256 => uint256) public totalMilestone;
    mapping(uint256 => assetDetail) public detail;
    mapping(uint256 => buyerDetail) public _buyerDetail;
    mapping(uint256 => string) public idsQuantity;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    struct assetDetail {
        uint256 quantity;
        string uri;
        uint256 amount;
        // address buyer;
        address escrowAgent;
    }
    enum status {
        waitForApproval,
        start,
        pending,
        working,
        over,
        nowork
    }
    struct buyerDetail{
        address user ;
        uint Amount;
        bool selected;
    }
    status choice;
    status constant defaultChoice = status.nowork;

    struct _milestone {
        mapping(uint256 => mapping(uint256 => bool)) RFPDone;
        mapping(uint256 => bool) midDone;
        mapping(uint256 => mapping(uint256 => bool)) RFP_bidder_approve;
        mapping(uint256 => mapping(uint256 => uint256)) RFP_Amount;
        mapping(uint256 => mapping(uint256 => address)) RFPBidder;
    }

    modifier isOwner(uint256 tokenId) {
        require(ownerOf( tokenId) == msg.sender, " user not registered");
        _;
    }

     modifier isAdmin(address addr) {
        require(ercrowAdmin == msg.sender, " Error: Only admin ");
        _;
    }

    constructor(
        address tokenAddr,
        address UserContractAddr,
        address admin_
    ) ERC1155(" ") {
        userContract = UserStorageInterface(UserContractAddr);
        BC_TOKEN = IBlockCities(tokenAddr);
        ercrowAdmin = admin_;
    }

//create asset
//admin enter the detail and assign Asset to owner 
    function AssetOwner(
        address _user,
        uint256 _quantity,
        string memory _uri,
        uint256 _amount
    ) public isExist(_user) {
        require(ercrowAdmin == msg.sender, "only admin");
        uint256 _id;
        _id = id++;
        detail[_id].quantity = _quantity;
        detail[_id].uri = _uri;
        detail[_id].amount = _amount;
        _mint(_user, _id, _quantity, "");
    }

// selecting an escrow Agent for Asset to handle all transaction
    function escrowAgent(uint256 Assetid, address addrEscrow) public onlyOwner {
        detail[Assetid].escrowAgent = addrEscrow;
    }



// all all rfp done for milestone submission 
    function mid_Done(uint256 M_Id, uint256 assetID) public onlyOwner {
        milestone[assetID].midDone[M_Id] = true;
    }

// when RFP done
    function RFP_Done(
        uint256 rfp,
        uint256 M_Id,
        uint256 assetID
    ) public onlyOwner {
        milestone[assetID].RFPDone[M_Id][rfp] = true;
    }

//Milestone Creation 
// count of total milestone
    function totalmid(uint256 assetid) public {
        totalMilestone[assetid] += 1;
        totalRFPid[assetid][totalMilestone[assetid]] += 1;
    }

//RFP fees
// RFp fees set by admin 
// amount deduct when user create or change RFP
    function RFpfees(uint256 _fees) public onlyOwner {
        fees = _fees;
    }

//RFP Creation 
// count of total RFP on a milestone
    function totalrfp(uint256 assetid, uint256 mid) public {
        totalRFPid[assetid][mid] += 1;
        BC_TOKEN.transfertoken(msg.sender, owner(), fees);
    }

//BIdding Process
//bidder on frp will save and cant be change
//bid amount transfer from asset owner to smart contract

       function bidderSelect(
        address user,
        uint256 rfp,
        uint256 M_Id,
        uint256 assetID,
        uint256 amount,
        address bidder
    ) public {
        milestone[assetID].RFP_bidder_approve[M_Id][rfp] = true;
        milestone[assetID].RFP_Amount[M_Id][rfp] = amount;
        milestone[assetID].RFPBidder[M_Id][rfp] = bidder;

        // BC_TOKEN._approve(user, address(this), 10000000000);

        BC_TOKEN.transfertoken(
            msg.sender,
            address(this),
            milestone[assetID].RFP_Amount[M_Id][rfp]
        );
    }

    function RFPDone(
        uint256 rfp,
        uint256 M_Id,
        uint256 assetID
    ) public onlyOwner {
        require(
            milestone[assetID].RFPDone[M_Id][rfp] == true,
            " rfp not complete"
        );

        BC_TOKEN.transfertoken(
            address(this),
            milestone[assetID].RFPBidder[M_Id][rfp],
            milestone[assetID].RFP_Amount[M_Id][rfp]
        );
    }

    // after asset owner approving the buyer 
function buyer(uint _id , uint amount , address buyer) public{
   require(_buyerDetail[_id].buyer == address(0) ,"buyer already selected");
    _buyerDetail[_id].amount = amount;
    _buyerDetail[_id].buyer = buyer;
}

// owner of token id 
  function ownerOf(uint256 tokenId) public view virtual returns (address) {
        return
            _tokenOwners.get(
                tokenId,
                "ERC1155: owner query for nonexistent token"
            );
    }
}
