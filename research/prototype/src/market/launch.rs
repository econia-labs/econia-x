use crate::InstructionParameters;
use macros::InstructionAccounts;
use solana_program::{account_info::AccountInfo, pubkey::Pubkey};

#[InstructionAccounts]
pub struct Accounts<'info> {
    pub market: &'info AccountInfo<'info>,
    pub payer: &'info AccountInfo<'info>,
    pub system_program: &'info AccountInfo<'info>,
}

#[repr(C)]
pub struct Parameters {
    pub(super) base_mint: Pubkey,
    pub(super) quote_mint: Pubkey,
}
impl InstructionParameters for Parameters {}
