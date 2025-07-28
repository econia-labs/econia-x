use solana_program::{
    account_info::AccountInfo, entrypoint::ProgramResult, program_error::ProgramError,
    pubkey::Pubkey,
};
use std::mem::size_of;

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

    fn from(instruction: LaunchInstruction) -> Self {
        Self {
            base_mint: instruction.base_mint,
            quote_mint: instruction.quote_mint,
        }
    }
}

struct LaunchInstruction {
    base_mint: Pubkey,
    quote_mint: Pubkey,
}

impl LaunchInstruction {
    fn unpack(bytes: &[u8]) -> Result<Self, ProgramError> {
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

pub(crate) fn launch(
    program_id: &Pubkey,
    _accounts: &[AccountInfo],
    instruction_parameter_bytes: &[u8],
) -> ProgramResult {
    let market = Market::from(LaunchInstruction::unpack(instruction_parameter_bytes)?);
    Ok(())
}
