const { expectThrow, increaseTime, latestTime, toWei, fromWei } = require('./helpers')

const EnsSubdomainFactory = artifacts.require('EnsSubdomainFactory')
const VoluntaryTaxFactory = artifacts.require('VoluntaryTaxFactory')
const MockEnsRegistry = artifacts.require('MockEnsRegistry')
const MockEnsResolver = artifacts.require('MockEnsResolver')

contract('VoluntaryTaxFactory', async function(accounts) {

    const creator = accounts[0]
    const alice = accounts[1];
    const bob = accounts[2];
    const charlie = accounts[3];

    const estoniaTreasury = accounts[9];

    let EnsSubdomainFactoryInstance;

    beforeEach(async function() {
        let MockEnsRegistryInstance = await MockEnsRegistry.new({ from: creator });
        let MockEnsResolverInstance = await MockEnsResolver.new({ from: creator });
        EnsSubdomainFactoryInstance = await EnsSubdomainFactory.new(MockEnsRegistryInstance.address, MockEnsResolverInstance.address, { from: creator } );
    })

    it('VoluntaryTaxFactory can be instantiated', async () => {

        let voluntaryTaxFactoryInstance  = await VoluntaryTaxFactory.new(EnsSubdomainFactoryInstance.address, { from: creator } );

        let deployed = await voluntaryTaxFactoryInstance.deployNew(10000, alice, estoniaTreasury, "estoniadao", "hacker");

        console.log(deployed);

    });

  })