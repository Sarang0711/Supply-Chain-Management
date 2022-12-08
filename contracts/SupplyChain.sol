//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract SupplyChain {
    uint256 public product_id = 0;
    uint256 public participant_id = 0;
    uint256 public owner_id = 0;

    struct product {
        string modelNumber;
        string partNumber;
        string serialNumber;
        uint32 cost;
        address productOwner;
        uint32 mfgTimeStamp;
    }

    mapping (uint256 => product) public products;

    struct participant {
        string username;
        string password;
        string participantType;
        address participantAddress;
    }

    mapping (uint256 => participant) public participants;

    struct ownership {
        uint256 productId;
        uint256 ownerId;
        uint32 txnTimeStamp;
        address ownerAddress;
    }

    mapping (uint256 => ownership) public ownerships;
    mapping (uint256 => uint256[]) public productTrack;

    event TransferOwnership(uint256 productId);

    function addParticipant(string memory _uname,
                            string memory _pass, 
                            string memory _pType,
                            address _pAddress) public returns (uint256) {

            uint256 userId = participant_id++;
            participants[userId].username = _uname;
            participants[userId].password = _pass;
            participants[userId].participantType = _pType;
            participants[userId].participantAddress = _pAddress;

            return userId;
    }

    function getParticipant(uint256 _participantId) public view returns (string memory, address, string memory) {
        return (participants[_participantId].username,
                participants[_participantId].participantAddress,
                participants[_participantId].participantType);
    }

    modifier onlyOwner(uint256 _productId) {
        require(msg.sender == products[_productId].productOwner, "");
        _;
    }

    function addProduct(uint256 _ownerId,
                        string memory _mNumber,
                        string memory _pNumber, 
                        string memory _sNumber,
                        uint32 _cost
                        ) public returns (uint256) {

            if(keccak256(abi.encodePacked(participants[_ownerId].participantType)) == 
            keccak256("Manufacturer")) {
                uint256 prodId = product_id++;
                products[prodId].modelNumber = _mNumber;
                products[prodId].partNumber = _pNumber;
                products[prodId].serialNumber = _sNumber;
                products[prodId].cost = _cost;
                products[prodId].productOwner = participants[_ownerId].participantAddress;
                products[prodId].mfgTimeStamp = uint32(block.timestamp);
                return prodId;
            }
            return 0;
    }  

    function getProduct(uint256 _productId) public view returns (string memory, string memory,
                 string memory, uint32, address, uint32) {

            return ( products[_productId].modelNumber,
                    products[_productId].partNumber,
                    products[_productId].serialNumber,
                    products[_productId].cost,
                    products[_productId].productOwner,
                    products[_productId].mfgTimeStamp);
    }

    function newOwner(uint256 _userId1, uint256 _userId2, uint256 _productId)
        public onlyOwner(_productId) returns (bool) {
            participant memory p1 = participants[_userId1];
            participant memory p2 = participants[_userId2];
            uint256 ownershipId = owner_id++;

            if(keccak256(abi.encode(p1.participantType)) == keccak256("Manufacturer") 
                && keccak256(abi.encode(p2.participantType)) == keccak256("Supplier")) {
                    ownerships[ownershipId].productId = _productId;
                    ownerships[ownershipId].ownerAddress = p2.participantAddress;
                    ownerships[ownershipId].ownerId = _userId2;
                    ownerships[ownershipId].txnTimeStamp = uint32(block.timestamp);
                    products[_productId].productOwner = p2.participantAddress;
                    productTrack[_productId].push(ownershipId);
                    emit TransferOwnership(_productId);

                    return (true);
                }
            else if(keccak256(abi.encode(p1.participantType)) == keccak256("Supplier")
                && keccak256(abi.encode(p2.participantType)) == keccak256("Supplier")) {
                    ownerships[ownershipId].productId = _productId;
                    ownerships[ownershipId].ownerAddress = p2.participantAddress;
                    ownerships[ownershipId].ownerId = _userId2;
                    ownerships[ownershipId].txnTimeStamp = uint32(block.timestamp);
                    products[_productId].productOwner = p2.participantAddress;
                    productTrack[_productId].push(ownershipId);
                    emit TransferOwnership(_productId);
                    return (true);
                } 
            else if(keccak256(abi.encode(p1.participantType)) == keccak256("Supplier")
                && keccak256(abi.encode(p2.participantType)) == keccak256("Consumer")) {
                    ownerships[ownershipId].productId = _productId;
                    ownerships[ownershipId].ownerAddress = p2.participantAddress;
                    ownerships[ownershipId].ownerId = _userId2;
                    ownerships[ownershipId].txnTimeStamp = uint32(block.timestamp);
                    products[_productId].productOwner = p2.participantAddress;
                    productTrack[_productId].push(ownershipId);
                    emit TransferOwnership(_productId);
                    return (true);
                }
            return false;
    }

    function getProverance (uint256 _productId) external view returns (uint256[] memory) {
        return productTrack[_productId];
    }

    function getOwnership (uint256 _regId) external view returns (uint256, uint256, address, uint32) {
        ownership memory r = ownerships[_regId];

        return (r.ownerId, r.productId, r.ownerAddress, r.txnTimeStamp);
    }

    function AuthenticateParticipant (uint256 _uId,
                                    string memory _uname,
                                    string memory _pass,
                                    string memory _utype ) public view returns (bool) {

            if(keccak256(abi.encodePacked(participants[_uId].participantType)) == 
                keccak256(abi.encodePacked(_utype))) {
                    if(keccak256(abi.encodePacked(participants[_uId].username)) == 
                        keccak256(abi.encodePacked(_uname))) {
                            if(keccak256(abi.encodePacked(participants[_uId].password)) == 
                                keccak256(abi.encodePacked(_pass))) {
                                    return true;
                                }
                        }
                }    
                return false;              

    }

    
}