use crate::InstructionParameters;
use macros::InstructionAccounts;
use solana_program::{account_info::AccountInfo, pubkey::Pubkey};

#[InstructionAccounts]
pub struct Accounts {
    pub market: Pubkey,
    pub payer: Pubkey,
    pub system_program: Pubkey,
}

#[repr(C)]
pub struct Parameters {
    pub(super) base_mint: Pubkey,
    pub(super) quote_mint: Pubkey,
}
impl InstructionParameters for Parameters {}
