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

pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let (&instruction_type_byte, instruction_parameter_bytes) = instruction_data
        .split_first()
        .ok_or(ProgramError::InvalidInstructionData)?;
    match instruction_type_byte {
        val if val == InstructionType::LaunchMarket as u8 => {
            market::launch(program_id, accounts, instruction_parameter_bytes)?;
        }
        _ => return Err(ProgramError::InvalidInstructionData),
    }
    Ok(())
}
