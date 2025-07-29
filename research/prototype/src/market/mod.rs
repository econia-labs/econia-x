use solana_program::{
    account_info::AccountInfo,
    entrypoint::ProgramResult,
    program::invoke,
    program_error::ProgramError,
    pubkey::Pubkey,
    sysvar::{rent::Rent, Sysvar},
};
use solana_system_interface::instruction;
use std::mem::size_of;
mod launch;

#[derive(Clone, Copy)]
#[repr(C)]
struct Market {
    base_mint: Pubkey,
    quote_mint: Pubkey,
}

impl Market {
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
        let market_ptr = account.data.borrow_mut().as_mut_ptr() as *mut Market;
        // Safe since account data size is checked during account creation.
        let market_mut = unsafe { &mut *market_ptr };
        market_mut.base_mint = parameters_ref.base_mint;
        market_mut.quote_mint = parameters_ref.quote_mint;
        Ok(())
    }
}

pub(super) fn launch<'info>(
    program_id: &Pubkey,
    accounts: &'info [AccountInfo<'info>],
    instruction_parameter_bytes: &[u8],
) -> ProgramResult {
    // Parse the instruction accounts and parameters, then derive the market account address.
    let accounts = launch::Accounts::try_from(accounts)?;
    let parameters = <&launch::Parameters>::try_from(instruction_parameter_bytes)?;
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

    // Calculate rent for the market account, then create it at the derived address.
    invoke(
        &instruction::create_account(
            accounts.payer.key,
            accounts.market.key,
            Rent::get()?.minimum_balance(size_of::<Market>()),
            size_of::<Market>() as u64,
            program_id,
        ),
        &[
            accounts.payer.clone(),
            accounts.market.clone(),
            accounts.system_program.clone(),
        ],
    )?;

    // Serialize the market data into the account (safe since size checked upon account creation).
    Market::init_account(accounts.market, parameters)?;

    Ok(())
}
