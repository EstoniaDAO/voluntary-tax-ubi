pragma solidity >=0.4.24;

import './SafeMath.sol';

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IEnsSubdomainFactory {
    function newSubdomain(string calldata _subdomain, string calldata _domain, address _owner, address _target) external;
}

contract VoluntaryTax {

    using SafeMath for uint256;
    // Double check the address: https://gitcoin.co/grants/659/estonia-dao-aragon-integration
    address payable public EstoniaTreasury = 0x614962025820c57D6AF5acff56B5879237dAf559;
    uint public ppm;
    uint public divisor = 1000000; // 1 million
    address payable public beneficiary;
    address public owner;

    constructor(uint _ppm, address payable _beneficiary) public {
        owner = msg.sender;
        require(_ppm <= divisor, "the voluntary tax cannot be greater than 100%");
        ppm = _ppm;
        beneficiary = _beneficiary;
    }

    function() external payable {
        EstoniaTreasury.transfer(msg.value.mul(ppm).div(divisor));
        beneficiary.transfer(msg.value.mul(divisor-ppm).div(divisor));
    }

    // It may happen that someone sends ERC20 - returning to the guy who deployed the contract
    function returnERC20(address ERC20address) external {
        IERC20 token = IERC20(ERC20address);
        uint balance = token.balanceOf(address(this));
        token.transfer(owner, balance);
    }
}

contract VoluntaryTaxFactory {
    address public EnsSubdomainFactoryAddress = 0xfbbfFCeFCFC92093840AE72932c30231b96F2f93;
    IEnsSubdomainFactory public EnsSubdomainFactory;

    constructor() public {
        EnsSubdomainFactory = IEnsSubdomainFactory(EnsSubdomainFactoryAddress);
    }

    function deployNew(uint ppm, address payable beneficiary, string memory subdomain) public {
        VoluntaryTax deployed = new VoluntaryTax(ppm, beneficiary);
        EnsSubdomainFactory.newSubdomain(subdomain, "estoniaropsten", msg.sender, address(deployed));
    }
}