// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmountFunded;

    // array of address that fund the contract.
    address[] public funders;
    // address of the contract creator
    address public owner;
    // priceFeed
    AggregatorV3Interface public priceFeed;

    // this is always initiated at contract deployment
    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    /**
     * @dev Funds the contract with ETH
     *
     * This function keeps track of address that funds
     * the contract and amount funded.
     *
     * Requirements:
     * - ETH Deposited > minimum threshold
     **/
    function fund() public payable {
        // $50 threshold
        uint256 minimumUSD = 50 * 10**8;
        require(
            getEthDepositedInUSD(msg.value) >= minimumUSD,
            "Gas Insufficient"
        );
        // maps funder address to value funded
        addressToAmountFunded[msg.sender] += msg.value;
        // adds funder's address to array
        funders.push(msg.sender);
    }

    /**
     * @dev Returns the price feed version
     *
     *
     **/
    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    /**
     * @dev Returns the latest USD value of ETH
     *
     * This function uses the AggregatorV3Interface of Chainlink
     * to fetch the current price of ETH stored on a contract.
     *
     *
     **/
    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();

        return uint256(answer * (10**8));
    }

    /**
     * @dev Returns the USD value of ETH deposited
     *
     * getPrice() function is called for current
     * price of ETH.
     *
     **/
    function getEthDepositedInUSD(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethDepositedInUSD = (ethPrice * ethAmount);

        return ethDepositedInUSD;
    }

    /**
     * @dev Returns the USD value of ETH deposited
     *
     * getPrice() function is called for current
     * price of ETH.
     *
     **/
    function getEntranceFee() public view returns (uint256) {
        uint256 minimumUSD = 50 * 10**8;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**8;
        return (minimumUSD * precision) / price;
    }

    /**
     * @dev Withdraws funds from the contract.
     *
     * This function uses a modifier to check the
     * the address of the sender equals that of the contract owner.
     *
     *
     * Requirements:
     * - Withdrawal address should be the owner of contract.
     **/
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdrawAmountFunded() public payable onlyOwner {
        // withdraw funds to contract owner address.
        msg.sender.transfer(address(this).balance);
        // Loop through the addresses in the array, setting the value to 0
        for (
            uint256 fundersIndex = 0;
            fundersIndex < funders.length;
            fundersIndex++
        ) {
            address funder = funders[fundersIndex];
            addressToAmountFunded[funder] = 0;
        }
        // reset the array
        funders = new address[](0);
    }
}
