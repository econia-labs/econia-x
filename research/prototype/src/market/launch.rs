use solana_program::{account_info::AccountInfo, program_error::ProgramError, pubkey::Pubkey};
use std::mem::size_of;
use strum::EnumCount;
use strum_macros::EnumCount;

#[derive(EnumCount)]
#[repr(usize)]
pub(super) enum AccountIndices {
    Market,
    Payer,
    SystemProgram,
}

pub(super) struct Accounts<'info> {
    pub(super) market: &'info AccountInfo<'info>,
    pub(super) payer: &'info AccountInfo<'info>,
    pub(super) system_program: &'info AccountInfo<'info>,
}

impl<'info> TryFrom<&'info [AccountInfo<'info>]> for Accounts<'info> {
    type Error = ProgramError;

    fn try_from(accounts: &'info [AccountInfo<'info>]) -> Result<Self, Self::Error> {
        if accounts.len() < AccountIndices::COUNT {
            return Err(ProgramError::NotEnoughAccountKeys);
        }
        Ok(Self {
            market: &accounts[AccountIndices::Market as usize],
            payer: &accounts[AccountIndices::Payer as usize],
            system_program: &accounts[AccountIndices::SystemProgram as usize],
        })
    }
}

#[repr(C)]
pub(super) struct Instruction {
    pub(super) base_mint: Pubkey,
    pub(super) quote_mint: Pubkey,
}

impl TryFrom<&[u8]> for Instruction {
    type Error = ProgramError;

    fn try_from(instruction_parameter_bytes: &[u8]) -> Result<Self, ProgramError> {
        if instruction_parameter_bytes.len() != std::mem::size_of::<Self>() {
            return Err(ProgramError::InvalidInstructionData);
        }
        let base_bytes_ptr =
            instruction_parameter_bytes.as_ptr() as *const [u8; size_of::<Pubkey>()];
        unsafe {
            // Since the number of bytes in the instruction data bytes has already been verified,
            // raw pointer arithmetic and dereferencing is safe here.
            let quote_bytes_ptr = base_bytes_ptr.add(1);
            Ok({
                Self {
                    base_mint: Pubkey::from(*base_bytes_ptr),
                    quote_mint: Pubkey::from(*quote_bytes_ptr),
                }
            })
        }
    }
}
