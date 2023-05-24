//SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.4;

contract Optimism_ENS_Resolver  {

struct CoinAddr {address addr;}
    mapping(bytes32 => mapping(uint256 => mapping(address => CoinAddr))) public coinAddrOf;

struct content {bytes content;}
    mapping(bytes32 => mapping(address => content)) public contentOf;

struct _text {string text;}
    mapping(bytes32 => mapping(string => mapping(address => _text))) public textOf;

function addressToBytes(address a) internal pure virtual returns(bytes memory b) {
        b = new bytes(20);
        assembly {
            mstore(add(b, 32), mul(a, exp(256, 12)))
        }
    }

function setAddr(
        bytes32 node,
        address a
    ) external {
        setAddr(node,60,a);
    }

function setAddr(
        bytes32 node,
        uint256 coinType,
        address a
    ) public {
        coinAddrOf[node][coinType][msg.sender].addr = a;
    }

function setContenthash(
        bytes32 node,
        bytes calldata hash
    ) external {
        contentOf[node][msg.sender].content = hash;
    }

function setText(
        bytes32 node,
        string calldata key,
        string calldata value
    ) external {
        textOf[node][key][msg.sender].text = value;
    }

function addr(
        bytes32 node,
        address owner
    ) public view returns(address) {
        return coinAddrOf[node][60][owner].addr;
    }

function addr(
        bytes32 node,
        uint256 coinType,
        address owner
    ) public view returns(bytes memory) {
        return addressToBytes(coinAddrOf[node][coinType][owner].addr);
    }

function contenthash(
        bytes32 node,
        address owner
    ) public view returns(bytes memory) {
        return contentOf[node][owner].content;
    }

function text(
        bytes32 node,
        string memory key,
        address owner
    ) public view returns(string memory) {
        return textOf[node][key][owner].text;
    }

function decodeData(bytes memory callData) public pure returns(uint256 functionName, bytes32 node, string memory key, uint256 coinType) {
        bytes4 functionSelector;
        assembly {
            functionSelector:= mload(add(callData, 0x20))
    }
        bytes memory callDataWithoutSelector = new bytes(callData.length - 4);
        for (uint256 i = 0; i < callData.length - 4; i++) {
            callDataWithoutSelector[i] = callData[i + 4];
    }
        if (functionSelector == bytes4(keccak256("addr(bytes32)"))) {
            functionName = 1;
            (node) = abi.decode(callDataWithoutSelector, (bytes32));
    } 
        if (functionSelector == bytes4(keccak256("addr(bytes32,uint256)"))) {
            functionName = 2;
            (node, coinType) = abi.decode(callDataWithoutSelector, (bytes32, uint256));
    } 
        if (functionSelector == bytes4(keccak256("contenthash(bytes32)"))) {
            functionName = 3;
            (node) = abi.decode(callDataWithoutSelector, (bytes32));
    } 
        if (functionSelector == bytes4(keccak256("text(bytes32,string)"))) {
            functionName = 4;
            (node, key) = abi.decode(callDataWithoutSelector, (bytes32, string));
    }}

function resolve(bytes calldata callData) public view returns(bytes memory) {
        (bytes memory name, bytes memory data, address owner) = abi.decode(callData, (bytes, bytes, address));
        (uint256 functionName, bytes32 node, string memory key, uint256 coinType) = decodeData(data);


        if (functionName == 1) {
                return abi.encode(addr(node, owner));
    } 
        if (functionName == 2) {
                return abi.encode(addr(node, coinType, owner));
    } 
        if (functionName == 3) {
                return abi.encode(contenthash(node,owner));
    }
        if (functionName == 4) {
                return abi.encode(text(node, key, owner));
    }
        return abi.encode(0x00);
    
    }

}
