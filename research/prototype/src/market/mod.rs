use crate::{
    fee::FeeRate,
    price::{Price, PRICE_INFINITY, PRICE_ZERO},
    sector::{SectorIndex, NIL},
};
use macros::instruction;

use solana_program::{account_info::AccountInfo, entrypoint::ProgramResult, pubkey::Pubkey, rent};
use std::mem::size_of;

instruction!(launch);

#[cfg(test)]
mod tests;

#[repr(C)]
struct Market {
    base_mint: Pubkey,
    quote_mint: Pubkey,
    fee_rate: FeeRate,
    /// Base subunits locked in the market, cumulative across all seats.
    base_locked: u64,
    /// Quote subunits locked in the market, cumulative across all seats.
    quote_locked: u64,
    /// Lowest ask price, `PRICE_INFINITY` if no asks.
    best_ask: Price,
    /// Highest bid price, `PRICE_ZERO` if no bids.
    best_bid: Price,
    /// `SectorIndex` of market seats tree root, `NIL` if no seats.
    seats_root: SectorIndex,
    /// `SectorIndex` of asks tree root, `NIL` if no asks.
    asks_root: SectorIndex,
    /// `SectorIndex` of bids tree root, `NIL` if no bids.
    bids_root: SectorIndex,
    /// `SectorIndex` of `StackNode` at top of unallocated sector node stack, `NIL` if all allocated
    /// sectors are in use.
    stack_top: SectorIndex,
}

impl Market {
    /// The rent exempt balance for a market account, calculated at compile time via official rent
    /// logic.
    const RENT_EXEMPT_BALANCE: u64 = (((rent::ACCOUNT_STORAGE_OVERHEAD
        + (size_of::<Market>() as u64))
        * rent::DEFAULT_LAMPORTS_PER_BYTE_YEAR) as f64
        * rent::DEFAULT_EXEMPTION_THRESHOLD) as u64;

    /// Derive the market account address from the base and quote mint pubkeys.
    fn address_from_pubkeys(
        base_mint: &Pubkey,
        quote_mint: &Pubkey,
        program_id: &Pubkey,
    ) -> Pubkey {
        let (address, _bump_seed) = Pubkey::find_program_address(
            &[&base_mint.to_bytes(), &quote_mint.to_bytes()],
            program_id,
        );
        address
    }

    /// Write market data straight to a freshly-initialized account.
    fn init_account(account: &AccountInfo, parameters_ref: &launch::Parameters) -> ProgramResult {
        // Get a mutable pointer to the account data and cast it to a mutable pointer to a market.
        let market_ptr = account.data.borrow_mut().as_mut_ptr() as *mut Market;

        // Cast the mutable pointer to a mutable reference. This is safe since account data size is
        // checked during account creation.
        let market_mut = unsafe { &mut *market_ptr };

        // Write the base and quote mint pubkeys straight to the market account without intermediate
        // copies against the instruction parameters reference.
        market_mut.base_mint = parameters_ref.base_mint;
        market_mut.quote_mint = parameters_ref.quote_mint;

        // Initialize other fields to default values.
        market_mut.base_locked = 0;
        market_mut.quote_locked = 0;
        market_mut.best_ask = PRICE_INFINITY;
        market_mut.best_bid = PRICE_ZERO;
        market_mut.seats_root = NIL;
        market_mut.asks_root = NIL;
        market_mut.bids_root = NIL;
        market_mut.stack_top = NIL;
        Ok(())
    }
}
