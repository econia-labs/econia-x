use super::Market;
use macros::{InstructionAccounts, InstructionParameters, InstructionProcessor};
use solana_program::{program::invoke, program_error::ProgramError, pubkey::Pubkey};
use solana_system_interface::instruction;

#[InstructionAccounts]
pub struct Accounts {
    pub market: Pubkey,
    pub payer: Pubkey,
    pub system_program: Pubkey,
}

#[InstructionParameters]
pub struct Parameters {
    pub base_mint: Pubkey,
    pub quote_mint: Pubkey,
}

#[InstructionProcessor]
pub(crate) fn process() {
    // Derive the market account address.
    let market_address =
        Market::address_from_pubkeys(&parameters.base_mint, &parameters.quote_mint, program_id);

    // Verify that the passed market account address matches the derived market account address.
    if accounts.market.key != &market_address {
        return Err(ProgramError::InvalidAccountData);
    };

    // Ensure that the market account does not already exist.
    if !accounts.market.data_is_empty() || accounts.market.owner != accounts.system_program.key {
        return Err(ProgramError::AccountAlreadyInitialized);
    };

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
    Market::init_account(accounts.market, parameters)?;

    Ok(())
}
