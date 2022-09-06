const assert = require('assert')
const { expect } = require('chai')
const { log } = require('console')
const console = require('console')
const { ethers } = require('hardhat')

describe(' contract: UserRegister', function () {
  let UserStorage
  let userstorage

  before(async function () {
    UserStorage = await ethers.getContractFactory('UserRegister')
    userstorage = await UserStorage.deploy()
    await userstorage.deployed()
    ;[owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners()
  })


  describe('register function testing ', function () {
 
    it('only owner: should create profession', async function () {

let create =await userstorage.connect(owner).createProfession(["electrician","plumber","escrowAgent","inspector"])
let list = await userstorage.connect(owner).showProfession();
console.log(list);

     
    })

})
})