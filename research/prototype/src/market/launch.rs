use macros::{InstructionAccounts, InstructionParameters};
use solana_program::pubkey::Pubkey;

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
