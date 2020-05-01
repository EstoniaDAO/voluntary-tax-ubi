
// File: contracts/SafeMath.sol

pragma solidity >=0.4.24;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts/VoluntaryTaxFactory.sol

pragma solidity >=0.4.24;


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

    mapping(address => Deployment[]) public voluntaryTaxDeployments; // Estonia treasury keeping track
    mapping(address => address) public guys; // I can totally imagine that someone has multiple, for now only one

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
        // require (guys[msg.sender] == address(0x0), "each address can have only one");
        guys[msg.sender] = DAOPoolUBI;

        VoluntaryTax deployed = new VoluntaryTax(ppm, beneficiary, DAOPoolUBI);
        EnsSubdomainFactory.newSubdomain(subdomain, domain, msg.sender, address(deployed));

        Deployment memory deployment = Deployment({deployer:msg.sender, beneficiary:beneficiary, deployed: address(deployed), subdomain:subdomain, domain:domain, ppm: ppm });
        voluntaryTaxDeployments[DAOPoolUBI].push(deployment);
    }
}
