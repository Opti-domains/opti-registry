// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/lib/DNSEncoder.sol";

contract DNSEncoderTest is Test {
    function testValidLabel() public {
        assertTrue(DNSEncoder.isValidLabel(bytes("test")));
        assertTrue(DNSEncoder.isValidLabel(bytes("test123")));
        assertTrue(DNSEncoder.isValidLabel(bytes("test-123")));
    }

    function testInvalidLabel() public {
        assertFalse(DNSEncoder.isValidLabel(bytes("")));
        assertFalse(DNSEncoder.isValidLabel(bytes("test!")));
        assertFalse(DNSEncoder.isValidLabel(bytes("test.")));
        assertFalse(DNSEncoder.isValidLabel(new bytes(64))); // Too long
    }

    function testValidDomain() public {
        bytes memory encoded = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(3)), "eth", bytes1(uint8(0)));
        assertTrue(DNSEncoder.isValidDomain(encoded));
    }

    function testInvalidDomain() public {
        bytes memory noTerminator = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(3)), "eth");
        assertFalse(DNSEncoder.isValidDomain(noTerminator));

        bytes memory invalidChar = abi.encodePacked(bytes1(uint8(4)), "test!", bytes1(uint8(0)));
        assertFalse(DNSEncoder.isValidDomain(invalidChar));
    }

    function testConcatenateName() public {
        bytes memory label = bytes("test");
        bytes memory name = abi.encodePacked(bytes1(uint8(3)), "eth", bytes1(uint8(0)));

        bytes memory expected = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(3)), "eth", bytes1(uint8(0)));
        bytes memory result = DNSEncoder.concatenateName(label, name);

        assertEq0(result, expected);
    }

    function testEncodeName() public {
        string[] memory labels = new string[](3);
        labels[0] = "com";
        labels[1] = "example";
        labels[2] = "test";

        bytes memory expected = abi.encodePacked(
            bytes1(uint8(4)), "test", bytes1(uint8(7)), "example", bytes1(uint8(3)), "com", bytes1(uint8(0))
        );

        bytes memory result = DNSEncoder.encodeName(labels);
        assertEq0(result, expected);
    }

    function testDecodeName() public {
        bytes memory encoded = abi.encodePacked(
            bytes1(uint8(4)), "test", bytes1(uint8(7)), "example", bytes1(uint8(3)), "com", bytes1(uint8(0))
        );

        string[] memory labels = DNSEncoder.decodeName(encoded);

        assertEq(labels.length, 3);
        assertEq(labels[0], "test");
        assertEq(labels[1], "example");
        assertEq(labels[2], "com");
    }

    function testReverseDnsEncoded() public {
        bytes memory original = abi.encodePacked(
            bytes1(uint8(3)), "com", bytes1(uint8(7)), "example", bytes1(uint8(4)), "test", bytes1(uint8(0))
        );

        bytes memory expected = abi.encodePacked(
            bytes1(uint8(4)), "test", bytes1(uint8(7)), "example", bytes1(uint8(3)), "com", bytes1(uint8(0))
        );

        bytes memory reversed = DNSEncoder.reverseDnsEncoded(original);
        assertEq0(reversed, expected);
    }

    function testDnsEncodedNamehash() public {
        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(0)));

        bytes32 namehash1 = DNSEncoder.dnsEncodedNamehash(dnsEncoded);
        assertEq(namehash1, keccak256(abi.encodePacked(bytes32(0), keccak256(bytes("test")))));

        bytes32 namehash2 = DNSEncoder.dnsEncodedNamehash(hex"0b6f707469646f6d61696e730365746800");
        assertEq(namehash2, 0x1dabf510ed6940730bc64780f29034ef80f9b15ccf4a267701a74efc4e789f46);

        bytes32 namehash3 = DNSEncoder.dnsEncodedNamehash(
            hex"016101620163016401650166016701680169016a016b016c016d016e016f0170017101720173017401750176017701780179017a0b6f707469646f6d61696e730365746800"
        );
        assertEq(namehash3, 0x9bf3be41b05876aca7fdd3f6a521543ba6ef525606c25065fc66f1df6042516f);
    }
}
