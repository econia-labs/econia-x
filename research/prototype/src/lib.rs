// cspell:word cfgs
#![allow(unexpected_cfgs)]

use solana_program::{
    account_info::AccountInfo, entrypoint, entrypoint::ProgramResult, program_error::ProgramError,
    pubkey::Pubkey,
};
mod market;

entrypoint!(process_instruction);

enum InstructionType {
    LaunchMarket = 0,
}

impl TryFrom<&u8> for InstructionType {
    type Error = ProgramError;

    fn try_from(value: &u8) -> Result<Self, Self::Error> {
        match value {
            val if *val == InstructionType::LaunchMarket as u8 => Ok(InstructionType::LaunchMarket),
            _ => Err(ProgramError::InvalidInstructionData),
        }
    }
}

pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let (&instruction_type_byte, parameter_bytes) = instruction_data
        .split_first()
        .ok_or(ProgramError::InvalidInstructionData)?;
    let instruction_type = InstructionType::try_from(&instruction_type_byte)?;
    match instruction_type {
        InstructionType::LaunchMarket => market::launch(program_id, accounts, parameter_bytes)?,
    }
    Ok(())
}
