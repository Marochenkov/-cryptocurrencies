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
})