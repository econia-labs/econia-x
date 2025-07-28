use solana_program::{
    account_info::AccountInfo, entrypoint::ProgramResult, program_error::ProgramError,
    pubkey::Pubkey,
};
mod launch;

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
}

pub(super) fn launch(
    program_id: &Pubkey,
    _accounts: &[AccountInfo],
    instruction_parameter_bytes: &[u8],
) -> ProgramResult {
    let market = Market::from(launch::Instruction::unpack(instruction_parameter_bytes)?);
    let market_address = market.address(program_id);
    Ok(())
}
