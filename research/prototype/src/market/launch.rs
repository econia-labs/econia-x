use crate::{
    market::Market,
    price::{PRICE_INFINITY, PRICE_ZERO},
    sector::NIL,
};
use macros::{svm_assert, InstructionAccounts, InstructionArguments, InstructionProcessor};
use solana_program::{
    program::invoke,
    program_error::ProgramError::{
        AccountAlreadyInitialized, InvalidAccountOwner, InvalidArgument,
    },
    pubkey::Pubkey,
};
use solana_system_interface::instruction;

#[InstructionAccounts]
pub struct Accounts {
    pub market: Pubkey,
    pub payer: Pubkey,
    pub system_program: Pubkey,
}

#[InstructionArguments]
pub struct Arguments {
    pub base_mint: Pubkey,
    pub quote_mint: Pubkey,
}

#[InstructionProcessor]
pub(crate) fn process() {
    // Derive the market account address, and ensure that it matches the passed market account.
    let market_address =
        Market::address_from_pubkeys(&args.base_mint, &args.quote_mint, program_id);
    svm_assert!(*accounts.market.key == market_address, InvalidArgument);

    // Ensure that the passed market account is empty and is owned by the system program.
    svm_assert!(accounts.market.data_is_empty(), AccountAlreadyInitialized);
    svm_assert!(
        accounts.market.owner == accounts.system_program.key,
        InvalidAccountOwner
    );

    // Create an account at the derived market address.
    invoke(
        &instruction::create_account(
            accounts.payer.key,
            accounts.market.key,
            Market::RENT_EXEMPT_BALANCE,
            size_of::<Market>() as u64,
            program_id,
        ),
        &[
            accounts.payer.clone(),
            accounts.market.clone(),
            accounts.system_program.clone(),
        ],
    )?;

    // Get a mutable pointer to the market account data, and cast it into a mutable pointer to a
    // `Market`. Then cast the pointer into a mutable reference to `Market`. This is safe since the
    // account is empty and its size is checked during account creation.
    let market_ptr = accounts.market.data.borrow_mut().as_mut_ptr() as *mut Market;
    let market_mut: &mut Market = unsafe { &mut *market_ptr };

    // Zero-copy initialize the base and quote mints from the instruction arguments.
    market_mut.base_mint = args.base_mint;
    market_mut.quote_mint = args.quote_mint;

    // Initialize the rest of the market fields to their default values.
    market_mut.fee_rate = 0;
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
