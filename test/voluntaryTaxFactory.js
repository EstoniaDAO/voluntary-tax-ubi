const { expectThrow, increaseTime, latestTime, toWei, fromWei } = require('./helpers')

const EnsSubdomainFactory = artifacts.require('EnsSubdomainFactory')
const VoluntaryTaxFactory = artifacts.require('VoluntaryTaxFactory')
const MockEnsRegistry = artifacts.require('MockEnsRegistry')
const MockEnsResolver = artifacts.require('MockEnsResolver')

contract('VoluntaryTaxFactory', async function(accounts) {

    const creator = accounts[0]
    const beneficiary = accounts[1];
    const beneficiary2 = accounts[2];
    const alice = accounts[3];

    const estoniaTreasury = accounts[9];

    let EnsSubdomainFactoryInstance;

    beforeEach(async function() {
        let MockEnsRegistryInstance = await MockEnsRegistry.new({ from: creator });
        let MockEnsResolverInstance = await MockEnsResolver.new({ from: creator });
        EnsSubdomainFactoryInstance = await EnsSubdomainFactory.new(MockEnsRegistryInstance.address, MockEnsResolverInstance.address, { from: creator } );
    })

    it('VoluntaryTaxFactory can be instantiated', async () => {

        let voluntaryTaxFactoryInstance  = await VoluntaryTaxFactory.new(EnsSubdomainFactoryInstance.address, { from: creator } );

        await voluntaryTaxFactoryInstance.deployNew(10000, beneficiary, estoniaTreasury, "estoniadao", "hacker");

        // THINK / TODO / FIXME: I have no idea how to retrieve the address better
        var howMany = await voluntaryTaxFactoryInstance.getCount.call(estoniaTreasury);
        var result = await voluntaryTaxFactoryInstance.voluntaryTaxDeployments.call(estoniaTreasury, howMany-1)

        console.log(howMany);
        console.log(result);

        await web3.eth.sendTransaction({from: alice, to: result.deployed, value: toWei("1")});
        var beneficiaryETH =  await web3.eth.getBalance(beneficiary);
        var estoniaTreasuryETH = await web3.eth.getBalance(estoniaTreasury);

        assert.equal(beneficiaryETH, toWei("100.99"), "Beneficiary should get 99%")
        assert.equal(estoniaTreasuryETH, toWei("100.01"), "Estonia DAO should get 1%")

        // ••••••••••••• SECOND VOLUNTARY TAX GUY •••••••••••••••

        await voluntaryTaxFactoryInstance.deployNew(20000, beneficiary2, estoniaTreasury, "estoniadao", "hacker2");

        var howMany = await voluntaryTaxFactoryInstance.getCount.call(estoniaTreasury);
        var result = await voluntaryTaxFactoryInstance.voluntaryTaxDeployments.call(estoniaTreasury, howMany-1)

        console.log(howMany);
        console.log(result);

        await web3.eth.sendTransaction({from: alice, to: result.deployed, value: toWei("1")});
        var beneficiaryETH =  await web3.eth.getBalance(beneficiary2);
        var estoniaTreasuryETH = await web3.eth.getBalance(estoniaTreasury);

        assert.equal(beneficiaryETH, toWei("100.98"), "Beneficiary2 should get 98% (of the second transaction)")
        assert.equal(estoniaTreasuryETH, toWei("100.03"), "Estonia DAO should get 2% (of the second transaction)")
    });

    it('Cannot do more than once', async () => {
        let voluntaryTaxFactoryInstance  = await VoluntaryTaxFactory.new(EnsSubdomainFactoryInstance.address, { from: creator } );

        await voluntaryTaxFactoryInstance.deployNew(10000, beneficiary, estoniaTreasury, "estoniadao", "hacker");

        let treasury = await voluntaryTaxFactoryInstance.guys.call(beneficiary);

        console.log(treasury);


        // await expectThrow( voluntaryTaxFactoryInstance.deployNew(10000, beneficiary, estoniaTreasury, "estoniadao", "hacker2") )
    });

  })