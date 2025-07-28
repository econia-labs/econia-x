use solana_program::{program_error::ProgramError, pubkey::Pubkey};
use std::mem::size_of;

pub(super) struct Instruction {
    pub(super) base_mint: Pubkey,
    pub(super) quote_mint: Pubkey,
}

#[repr(usize)]
enum Accounts {
    Market,
    Payer,
    SystemProgram,
}

impl Instruction {
    pub(super) fn unpack(bytes: &[u8]) -> Result<Self, ProgramError> {
        if bytes.len() != std::mem::size_of::<Self>() {
            return Err(ProgramError::InvalidInstructionData);
        }
        let base_bytes_ptr = bytes.as_ptr() as *const [u8; size_of::<Pubkey>()];
        unsafe {
            // Since the number of bytes in the instruction data bytes has already been verified,
            // raw pointer arithmetic and dereferencing is safe here.
            let quote_bytes_ptr = base_bytes_ptr.add(size_of::<Pubkey>());
            Ok({
                Self {
                    base_mint: Pubkey::from(*base_bytes_ptr),
                    quote_mint: Pubkey::from(*quote_bytes_ptr),
                }
            })
        }
    }
}
