const { expectThrow, increaseTime, latestTime, toWei, fromWei } = require('./helpers')

const EnsSubdomainFactory = artifacts.require('EnsSubdomainFactory')
const VoluntaryTaxFactory = artifacts.require('VoluntaryTaxFactory')
const MockEnsRegistry = artifacts.require('MockEnsRegistry')
const MockEnsResolver = artifacts.require('MockEnsResolver')

contract('VoluntaryTaxFactory', async function(accounts) {

    const creator = accounts[0]
    const employer = accounts[1];
    const guy2 = accounts[2];
    const guy3 = accounts[3];

    let EnsSubdomainFactoryInstance;

    beforeEach(async function() {
        EnsSubdomainFactoryInstance = await EnsSubdomainFactory.new("PNK for testing", "PNKT", 18, { from: creator } ); 
        // DAI = await ERC20.new("DAI for testing", "DAIT", 18, { from: creator } ); 

        // await PNK.mint(employer, toWei("1000000"), { from: creator })
        // await DAI.mint(employer, toWei("1000"), { from: creator })
    })

    it('EnsSubdomainFactory can be instantiated', async () => {

        // let hourlyRate = await HourlyRate.new(PNK.address, toWei("10000"), DAI.address, toWei("50"), { from: creator } );

        // hourlyRate.approvePNK(200000, { from: employer });
        // hourlyRate.approveDAI(10000, { from: employer });
        // hourlyRate.mintPNKDAI(20, { from: employer });

        // console.log("hourlyRate.PNKDAI: \n-----------------")
        // console.log(hourlyRate.PNKDAI);
        // console.log(hourlyRate.PNKDAI.address);
        // console.log("-----------------")

        // let employerPNKDAI = await hourlyRate.PNKDAI.balance(employer);
        // console.log(employerPNKDAI);
        // assert.equal(employerPNKDAI, toWei("20"), "Employer shouold have 20 tokens of PNKDAI");

    });

  })