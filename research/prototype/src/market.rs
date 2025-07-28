use solana_program::{
    account_info::AccountInfo, entrypoint::ProgramResult, program_error::ProgramError,
    pubkey::Pubkey,
};
struct Market {
    base_mint: Pubkey,
    quote_mint: Pubkey,
}
use std::mem::size_of;

impl Market {
    /// Derive the market address from the base and quote mint addresses.
    pub fn address(&self, program_id: &Pubkey) -> Pubkey {
        let (address, _bump_seed) = Pubkey::find_program_address(
            &[&self.base_mint.to_bytes(), &self.quote_mint.to_bytes()],
            program_id,
        );
        address
    }
}

struct LaunchParameters {
    base_mint: Pubkey,
    quote_mint: Pubkey,
}

impl LaunchParameters {
    fn unpack(bytes: &[u8]) -> Result<Self, ProgramError> {
        if bytes.len() != std::mem::size_of::<Self>() {
            return Err(ProgramError::InvalidInstructionData);
        }
        let base_bytes_ptr = bytes.as_ptr() as *const [u8; size_of::<Pubkey>()];
        unsafe {
            // Since the number of bytes in the instruction data has already been verified, raw
            // pointer dereferencing is safe here.
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
    _program_id: &Pubkey,
    _accounts: &[AccountInfo],
    launch_parameter_bytes: &[u8],
) -> ProgramResult {
    let launch_parameters = LaunchParameters::unpack(launch_parameter_bytes)?;
    Ok(())
}
