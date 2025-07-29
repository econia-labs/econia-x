use solana_program::{account_info::AccountInfo, program_error::ProgramError, pubkey::Pubkey};
use std::mem::size_of;
use strum::EnumCount;
use strum_macros::EnumCount;

#[derive(EnumCount)]
#[repr(usize)]
enum AccountIndices {
    Market,
    Payer,
    SystemProgram,
}

pub struct Accounts<'info> {
    pub market: &'info AccountInfo<'info>,
    pub payer: &'info AccountInfo<'info>,
    pub system_program: &'info AccountInfo<'info>,
}

impl<'info> TryFrom<&'info [AccountInfo<'info>]> for Accounts<'info> {
    type Error = ProgramError;

    fn try_from(accounts: &'info [AccountInfo<'info>]) -> Result<Self, Self::Error> {
        if accounts.len() < AccountIndices::COUNT {
            return Err(ProgramError::NotEnoughAccountKeys);
        }
        Ok(Accounts {
            market: &accounts[AccountIndices::Market as usize],
            payer: &accounts[AccountIndices::Payer as usize],
            system_program: &accounts[AccountIndices::SystemProgram as usize],
        })
    }
}

#[repr(C)]
pub struct Parameters {
    pub(super) base_mint: Pubkey,
    pub(super) quote_mint: Pubkey,
}

impl TryFrom<&[u8]> for &Parameters {
    type Error = ProgramError;

    fn try_from(parameters_bytes: &[u8]) -> Result<Self, ProgramError> {
        if parameters_bytes.len() != size_of::<Self>() {
            return Err(ProgramError::InvalidInstructionData);
        }
        let parameters_ptr = parameters_bytes.as_ptr() as *const Parameters;
        unsafe {
            // Since the number of bytes in the instruction data bytes has already been verified,
            // raw pointer dereferencing is safe here.
            Ok(&*parameters_ptr)
        }
    }
}
