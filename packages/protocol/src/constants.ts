import { utils } from 'ethers';

// Time
export const ONE_HOUR_IN_SECONDS = 60 * 60;
export const ONE_DAY_IN_SECONDS = ONE_HOUR_IN_SECONDS * 24;
export const ONE_YEAR_IN_SECONDS = ONE_DAY_IN_SECONDS * 365.25;

// Percentages
// BPS
export const ONE_PERCENT_IN_BPS = 100;
export const FIVE_PERCENT_IN_BPS = ONE_PERCENT_IN_BPS * 5;
export const TEN_PERCENT_IN_BPS = ONE_PERCENT_IN_BPS * 10;
export const ONE_HUNDRED_PERCENT_IN_BPS = 10000;
// WEI
export const ONE_HUNDRED_PERCENT_IN_WEI = utils.parseEther('1');
export const TEN_PERCENT_IN_WEI = ONE_HUNDRED_PERCENT_IN_WEI.div(10);
export const FIVE_PERCENT_IN_WEI = ONE_HUNDRED_PERCENT_IN_WEI.div(20);
export const ONE_PERCENT_IN_WEI = ONE_HUNDRED_PERCENT_IN_WEI.div(100);
export const ONE_ONE_HUNDREDTH_PERCENT_IN_WEI = ONE_HUNDRED_PERCENT_IN_WEI.div(10000);

export const SHARES_UNIT = utils.parseEther('1');
