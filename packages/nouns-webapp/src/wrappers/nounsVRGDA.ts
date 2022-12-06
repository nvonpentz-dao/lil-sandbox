import {
  ChainId,
  useBlockNumber,
  useContractCall,
  useContractCalls,
  useContractFunction,
  useEthers,
} from '@usedapp/core';
import { BigNumber as EthersBN, utils } from 'ethers';
import { NounsAuctionHouseABI } from '@lilnounsdao/sdk';
import config, { CHAIN_ID } from '../config';
import BigNumber from 'bignumber.js';
import { BigNumber as bNum } from '@ethersproject/bignumber';
import { findAuction, isNounderNoun, isNounsDAONoun } from '../utils/nounderNoun';
import { useAppSelector } from '../hooks';
import { AuctionState } from '../state/slices/auction';
import VRGDA_ABI from '../abi/LilVRGDA/LilVRGDA.json';

//* vrgda version of ./nounsAuctions.ts

//fethcing abi from within webapp for fast testing
export const VRGDA_ContractGenesisBlock = 10000000;
const VRGDA_Address = '0x...';
const VRGDA_FromBlock = CHAIN_ID === ChainId.Mainnet ? VRGDA_ContractGenesisBlock : 0;
const VRGDA_Abi = new utils.Interface(VRGDA_ABI);


// some functions (like auction) might been to called through auction house proxy
export const AuctionHouseProxy_ContractGenesisBlock = 10000000;
const AuctionHouseProxyAddress = '0x';
const AuctionHouse_FromBlock = CHAIN_ID === ChainId.Mainnet ? AuctionHouseProxy_ContractGenesisBlock : 0;
const AuctionHouse_Abi = new utils.Interface(VRGDA_ABI);


export enum VRGDAContractFunction {
  auction = 'auction', 
  startTime = 'startTime', 
  updateInterval = 'updateInterval', 
  minBidIncrementPercentage = 'minBidIncrementPercentage', 
  nounsToken = 'nounsToken', 
  settleAuction = 'settleAuction',
  getCurrentVRGDAPrice = 'getCurrentVRGDAPrice',
  fetchNextNoun = 'fetchNextNoun',
}

export interface VRGDA {
  amount: EthersBN;
  buyer: string;
  priceIntervalEndTime: EthersBN;
  priceIntervalStartTime: EthersBN;
  nounId: EthersBN;
  settled: boolean;
}

//get buy now price
//buy now
//get interval time
