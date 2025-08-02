use super::Market;
use macros::*;
use solana_program::{program::invoke, pubkey::Pubkey};
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

    // Serialize the market data into the account.
    Market::init_account(accounts.market, args)?;

    Ok(())
}
