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
    /// Derive the market address from the base and quote mint addresses.
    fn address(&self, program_id: &Pubkey) -> Pubkey {
        let (address, _bump_seed) = Pubkey::find_program_address(
            &[&self.base_mint.to_bytes(), &self.quote_mint.to_bytes()],
            program_id,
        );
        address
    }

    fn from(instruction: launch::Instruction) -> Self {
        Self {
            base_mint: instruction.base_mint,
            quote_mint: instruction.quote_mint,
        }
    }

    /// Write the market data straight to the account, overwriting any existing data.
    fn write_to_account_unsafe(&self, account: &AccountInfo) -> ProgramResult {
        let account_bytes_ptr = account.data.borrow_mut().as_mut_ptr() as *mut Market;
        unsafe { std::ptr::write(account_bytes_ptr, *self) };
        Ok(())
    }
}

pub(super) fn launch<'info>(
    program_id: &Pubkey,
    accounts: &'info [AccountInfo<'info>],
    instruction_parameter_bytes: &[u8],
) -> ProgramResult {
    // Parse the accounts and instruction parameters, and get the derived market account address.
    let accounts = launch::Accounts::try_from(accounts)?;
    let market = Market::from(launch::Instruction::try_from(instruction_parameter_bytes)?);
    let market_address = market.address(program_id);

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
    market.write_to_account_unsafe(accounts.market)?;

    Ok(())
}
