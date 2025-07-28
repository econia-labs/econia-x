// cspell:word cfgs
#![allow(unexpected_cfgs)]

use num_enum::TryFromPrimitive;
use solana_program::{
    account_info::AccountInfo, entrypoint, entrypoint::ProgramResult, program_error::ProgramError,
    pubkey::Pubkey,
};
mod market;

entrypoint!(process_instruction);

#[derive(TryFromPrimitive)]
#[repr(u8)]
enum InstructionType {
    LaunchMarket,
}

pub fn process_instruction<'info>(
    program_id: &Pubkey,
    accounts: &'info [AccountInfo<'info>],
    instruction_data: &[u8],
) -> ProgramResult {
    let (&instruction_type_byte, parameters) = instruction_data
        .split_first()
        .ok_or(ProgramError::InvalidInstructionData)?;
    let instruction_type = InstructionType::try_from(instruction_type_byte)
        .map_err(|_| ProgramError::InvalidInstructionData)?;
    match instruction_type {
        InstructionType::LaunchMarket => market::launch(program_id, accounts, parameters)?,
    }
    Ok(())
}
