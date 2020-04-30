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
    // 0x614962025820c57D6AF5acff56B5879237dAf559
    address payable public DAOPoolUBI;
    uint public ppm; // parts per million
    uint public divisor = 1000000; // 1 million
    address payable public beneficiary;

    constructor(uint _ppm, address payable _beneficiary, address payable _DAOPoolUBI) public {
        require(_ppm <= divisor, "the voluntary tax cannot be greater than 100%");
        ppm = _ppm;
        beneficiary = _beneficiary;
        DAOPoolUBI = _DAOPoolUBI;
    }

    function() external payable {
        DAOPoolUBI.transfer(msg.value.mul(ppm).div(divisor));
        beneficiary.transfer(msg.value.mul(divisor-ppm).div(divisor));
    }

    // It may happen that someone sends ERC20 - returning to the guy who deployed the contract
    function returnERC20(address ERC20address) external {
        IERC20 token = IERC20(ERC20address);
        uint balance = token.balanceOf(address(this));
        token.transfer(beneficiary, balance);
    }
}

contract VoluntaryTaxFactory {
    IEnsSubdomainFactory public EnsSubdomainFactory;

    constructor(address EnsSubdomainFactoryAddress) public {
        EnsSubdomainFactory = IEnsSubdomainFactory(EnsSubdomainFactoryAddress);
    }

    mapping(address => Deployment[]) public voluntaryTaxDeployments;

    function getCount(address treasury) public view returns(uint count) {
        Deployment[] memory deployments = voluntaryTaxDeployments[treasury];
        return deployments.length;
    }

    struct Deployment {
        address deployer;
        address beneficiary;
        address deployed;
        string subdomain;
        string domain;
        uint256 ppm;
    }

    function deployNew(uint ppm, address payable beneficiary, address payable DAOPoolUBI, string memory domain, string memory subdomain) public {
        VoluntaryTax deployed = new VoluntaryTax(ppm, beneficiary, DAOPoolUBI);
        EnsSubdomainFactory.newSubdomain(subdomain, domain, msg.sender, address(deployed));

        Deployment memory deployment = Deployment({deployer:msg.sender, beneficiary:beneficiary, deployed: address(deployed), subdomain:subdomain, domain:domain, ppm: ppm });
        voluntaryTaxDeployments[DAOPoolUBI].push(deployment);
    }
}