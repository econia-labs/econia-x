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
    // Derive the market account address.
    let market_address =
        Market::address_from_pubkeys(&args.base_mint, &args.quote_mint, program_id);

    // Ensure that the passed market account matches the derived address, is empty, and is owned by
    // the system program.
    svm_assert!(*accounts.market.key == market_address, InvalidArgument);
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

    // Write the market data straight to the account using zero-copy. This is safe since the account
    // is empty its size is checked during account creation.
    unsafe {
        std::ptr::write(
            accounts.market.data.borrow_mut().as_mut_ptr() as *mut Market,
            Market {
                base_mint: args.base_mint,
                quote_mint: args.quote_mint,
                fee_rate: 0,
                base_locked: 0,
                quote_locked: 0,
                best_ask: PRICE_INFINITY,
                best_bid: PRICE_ZERO,
                seats_root: NIL,
                asks_root: NIL,
                bids_root: NIL,
                stack_top: NIL,
            },
        );
    }

    Ok(())
}
