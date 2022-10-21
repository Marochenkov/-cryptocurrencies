const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Ballot", function () {
    let owner
    let acc1
    let acc2
    let acc3
    let acc4
    let acc5
    let ballot

    this.beforeEach(async function() {
        [owner, acc1, acc2, acc3, acc4, acc5] = await ethers.getSigners()
        const Ballot = await ethers.getContractFactory("Ballot", owner)
        ballot = await Ballot.deploy()
        await ballot.deployed()
    })

    it("test voting is finished error", async function() {
        await ballot.createVoting(0, 1, 0, [])
        try {
            await ballot.voteFor(0)
        } catch(err) {
            expect(err)
        }
    })

    it("test initial balance", async function () {
        expect(await ballot.balance()).to.eq(0)
    });

    it("test balance after one vote", async function() {
        await ballot.createVoting(1, 1, 0, [acc1.getAddress()])
        await ballot.connect(acc2).voteFor(0, { value: 1})
        expect(await ballot.balance()).to.eq(1)
        
    })
})