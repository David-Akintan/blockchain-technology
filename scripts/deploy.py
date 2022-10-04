from brownie import accounts, config, FundMe, network, MockV3Aggregator
from web3 import Web3
from scripts.helpful_scripts import (
    get_account,
    deploy_mocks,
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
)


def deploy_fund_me():
    # Connect to development server
    account = get_account()

    # Deploy FundMe contract while passing the
    # contract address of priceFeed into FundMe contract
    # if on a persistent network like rinkeby, use associated address.
    # otherwise, deploy mocks
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_price_feed"
        ]
    else:
        deploy_mocks()
        price_feed_address = MockV3Aggregator[-1].address

    fundMe = FundMe.deploy(
        price_feed_address,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify"),
    )
    print(f"Contract deployed to {fundMe.address}")
    return fundMe


def main():
    deploy_fund_me()
