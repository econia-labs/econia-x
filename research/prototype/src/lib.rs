use solana_program::{program_error::ProgramError, pubkey::Pubkey};

pub struct Market {
    pub base_mint: Pubkey,
    pub quote_mint: Pubkey,
}

pub enum Instruction {
    LaunchMarket {
        base_mint: Pubkey,
        quote_mint: Pubkey,
    },
}

impl Instruction {
    /// Instruction type for launching a market.
    pub const LAUNCH_MARKET_TYPE: u8 = 0;
    /// Size of the instruction data for launching a market, excluding the instruction type byte.
    pub const LAUNCH_MARKET_SIZE: usize = 2 * size_of::<Pubkey>();

    pub fn unpack(input: &[u8]) -> Result<Self, ProgramError> {
        let (&instruction_type, rest) = input
            .split_first()
            .ok_or(ProgramError::InvalidInstructionData)?;
        match instruction_type {
            Self::LAUNCH_MARKET_TYPE => {
                // Verify correct bytes length then deserialize via pointer casting.
                if rest.len() != Self::LAUNCH_MARKET_SIZE {
                    return Err(ProgramError::InvalidInstructionData);
                };
                Ok(unsafe {
                    Instruction::LaunchMarket {
                        base_mint: Pubkey::from(
                            *(rest[0..size_of::<Pubkey>()].as_ptr()
                                as *const [u8; size_of::<Pubkey>()]),
                        ),
                        quote_mint: Pubkey::from(
                            *(rest[size_of::<Pubkey>()..Self::LAUNCH_MARKET_SIZE].as_ptr()
                                as *const [u8; size_of::<Pubkey>()]),
                        ),
                    }
                })
            }
            _ => Err(ProgramError::InvalidInstructionData),
        }
    }
}
