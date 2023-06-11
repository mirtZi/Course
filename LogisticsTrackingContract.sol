// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract LogisticsTrackingContract {
    struct Shipment {
        address sender;
        address receiver;
        string origin;
        string destination;
        string currentLocation;
        string status;
    }
    mapping(uint256 => Shipment) private shipments;

    uint256 private shipmentCount;

    event ShipmentCreated(
        uint256 shipmentId,
        address sender,
        address receiver,
        string origin,
        string destination
    );

    event ShipmentUpdated(
        uint256 shipmentId,
        string currentLocation,
        string status
    );

    function createShipment(
        address _receiver,
        string memory _origin,
        string memory _destination
    ) public {
        shipmentCount++;
        shipments[shipmentCount] = Shipment(
            msg.sender,
            _receiver,
            _origin,
            _destination,
            _origin,
            "In transit"
        );

        emit ShipmentCreated(
            shipmentCount,
            msg.sender,
            _receiver,
            _origin,
            _destination
        );
    }

    function updateShipment(
        uint256 _shipmentId,
        string memory _currentLocation,
        string memory _status
    ) public {
        require(
            _shipmentId > 0 && _shipmentId <= shipmentCount,
            "Invalid shipment ID"
        );
        require(msg.sender == shipments[_shipmentId].sender, "Unauthorized");

        shipments[_shipmentId].currentLocation = _currentLocation;
        shipments[_shipmentId].status = _status;

        emit ShipmentUpdated(_shipmentId, _currentLocation, _status);
    }

    function confirmReceipt(uint256 _shipmentId) public {
        require(
            _shipmentId > 0 && _shipmentId <= shipmentCount,
            "Invalid shipment ID"
        );
        require(msg.sender == shipments[_shipmentId].receiver, "Unauthorized");
        Shipment storage shipment = shipments[_shipmentId];

        // Update the shipment current location to destination
        shipments[_shipmentId].currentLocation = shipments[_shipmentId]
            .destination;
        // Update the shipment status to completed
        shipment.status = "Completed";
    }

    function getShipmentInfo(
        uint256 _shipmentId
    ) public view returns (Shipment memory) {
        require(
            _shipmentId > 0 && _shipmentId <= shipmentCount,
            "Invalid shipment ID"
        );
        require(
            msg.sender == shipments[_shipmentId].receiver ||
                msg.sender == shipments[_shipmentId].sender,
            "Unauthorized"
        );
        return shipments[_shipmentId];
    }

    function getSendShipmentCount(
        address _account
    ) public view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 1; i <= shipmentCount; i++) {
            if (shipments[i].sender == _account) {
                count++;
            }
        }
        return count;
    }

    function getSendShipmentIds(
        address _account
    ) public view returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](shipmentCount); // Subtract 1 from shipmentCount to exclude ID 0
        uint256 index = 0;
        for (uint256 i = 1; i <= shipmentCount; i++) {
            if (i != 0 && shipments[i].sender == _account) {
                // Exclude ID 0
                ids[index] = i;
                index++;
            }
        }
        return ids;
    }

    function getReceivedShipmentCount(
        address _account
    ) public view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 1; i <= shipmentCount; i++) {
            if (shipments[i].receiver == _account) {
                count++;
            }
        }
        return count;
    }

    function getReceivedShipmentIds(
        address _account
    ) public view returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](shipmentCount); // Subtract 1 from shipmentCount to exclude ID 0
        uint256 index = 0;
        for (uint256 i = 1; i <= shipmentCount; i++) {
            if (i != 0 && shipments[i].receiver == _account) {
                // Exclude ID 0
                ids[index] = i;
                index++;
            }
        }
        return ids;
    }
}
