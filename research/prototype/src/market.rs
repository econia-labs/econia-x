use solana_program::{account_info::AccountInfo, entrypoint::ProgramResult, pubkey::Pubkey};
pub struct Market {
    pub base_mint: Pubkey,
    pub quote_mint: Pubkey,
}

pub struct LaunchParameters {
    pub base_mint: Pubkey,
    pub quote_mint: Pubkey,
}

pub(crate) fn launch(
    _program_id: &Pubkey,
    _accounts: &[AccountInfo],
    _instruction_parameter_bytes: &[u8],
) -> ProgramResult {
    Ok(())
}
