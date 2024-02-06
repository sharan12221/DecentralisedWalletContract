const {ethers} = require('ethers');
const fs = require('fs');
const { serialize } = require('v8');

const abiJson = fs.readFileSync('./abi.json', 'utf8');
const abi = JSON.parse(abiJson);

const Erc20Abi = fs.readFileSync('./tokenAbi.json', 'utf8');
const erc20Abi = JSON.parse(Erc20Abi);

const privateKey = '';///////////private Key 

const contractAddress = '0x7066A9e09Cd2E794290d7a6b996a37cE8ba5dAFE';
const tokenAddress = '0x825f444532a019C563dD33802fc11B5092f2e218';
const provider =new ethers.providers.JsonRpcProvider('https://goerli.infura.io/v3/59eb174a56444d4295c9addb3d68e733');
const signer =new ethers.Wallet(privateKey, provider);

const contract = new ethers.Contract(contractAddress, abi, signer);
const tokenContract = new ethers.Contract(tokenAddress, erc20Abi, signer);

async function getData(){
    const bal =await contract.functions.balanceOfToken(contractAddress);
    console.log("Token Balance of Address",contractAddress,":",ethers.utils.formatEther(bal.toString(),18));
}


async function approve(address,amount){
    const approve = await tokenContract.functions.approve(address, amount,{
        gasLimit : 4000000,
    })
    await approve.wait();
    console.log("approve hash: ",approve.hash);
}


async function deposit(amount){
    const deposit = await contract.functions.deposit(amount,{
        gasLimit : 1200000,
    })
    await deposit.wait();
    console.log("deposit Hash: ",deposit.hash);
}


async function setRefundDeadline(timeinSecond){
    const setRefundDeadline = await contract.functions.setRefundDeadline(timeinSecond,{
        gasLimit : 300000,
    })

    await setRefundDeadline.wait();
    console.log("timeOutLimit: ", setRefundDeadline.hash);

    const getTimeLimit =await contract.functions.refundDeadline();
    console.log("TimeLimit set to: ",getTimeLimit.toString())
}

async function requestRefund(){
    const requestRefund = await contract.functions.requestRefund({
        gasLimit : 12000000,
    })
    await requestRefund.wait();
    console.log("deposit Hash: ",requestRefund.hash);
}


async function claimTokens(amount){
    const claimTokens = await contract.functions.claimTokens(amount,{
        gasLimit : 12000000,
    })
    await claimTokens.wait();
    console.log("deposit Hash: ",claimTokens.hash);
}


getData();
approve(contractAddress, 100);
// deposit(100);
// setRefundDeadline(7112323232132321);
// requestRefund()
// claimTokens(100) 
