from brownie import FundMe
from scripts.helpful_scripts import get_account


def fund():
    fund_me = FundMe[-1]
    account = get_account()
    entrance_fee = fund_me.getEntranceFee()
    print(f"Current entry fee is {entrance_fee}")
    print("Funding contract...")
    fund_me.fund({"from": account, "value": entrance_fee})


def withdraw():
    fund_me = FundMe[-1]
    account = get_account()
    print(f"Withdrawing from contract...")
    fund_me.withdrawAmountFunded({"from": account})


def main():
    fund()
    withdraw()
