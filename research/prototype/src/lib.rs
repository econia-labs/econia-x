// cspell:word borsh
// cspell:word cfgs
// cspell:word sysvar

#![allow(unexpected_cfgs)]

use borsh::{BorshDeserialize, BorshSerialize};
use solana_program::{
    account_info::{next_account_info, AccountInfo},
    entrypoint,
    entrypoint::ProgramResult,
    msg,
    program::invoke,
    program_error::ProgramError,
    pubkey::Pubkey,
    sysvar::{rent::Rent, Sysvar},
};
use solana_system_interface::instruction;

entrypoint!(process_instruction);

#[derive(BorshSerialize, BorshDeserialize, Debug)]
pub struct CounterAccount {
    count: u64,
}

#[derive(BorshSerialize, BorshDeserialize, Debug)]
pub enum CounterInstruction {
    Initialize { initial_value: u64 },
    Increment,
}

pub const INITIALIZE_COUNTER_INSTRUCTION: u8 = 0;
pub const INCREMENT_COUNTER_INSTRUCTION: u8 = 1;

impl CounterInstruction {

    pub fn unpack(input: &[u8]) -> Result<Self, ProgramError> {
        // Get the instruction variant from the first byte.
        let (&variant, rest) = input
            .split_first()
            .ok_or(ProgramError::InvalidInstructionData)?;

        // Match instruction type and parse the remaining bytes based on the variant.
        match variant {
            INITIALIZE_COUNTER_INSTRUCTION => {
                // Parse the initial value for the counter from the remaining bytes.
                let initial_value = u64::from_le_bytes(
                    rest.try_into()
                        .map_err(|_| ProgramError::InvalidInstructionData)?,
                );
                Ok(Self::Initialize { initial_value })
            }
            INCREMENT_COUNTER_INSTRUCTION => Ok(Self::Increment),
            _ => Err(ProgramError::InvalidInstructionData),
        }
    }
}

pub type ProcessInstruction =
    fn(program_id: &Pubkey, accounts: &[AccountInfo], instruction_data: &[u8]) -> ProgramResult;

pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let instruction = CounterInstruction::unpack(instruction_data)?;
    match instruction {
        CounterInstruction::Initialize { initial_value } => {
            process_initialize_counter(program_id, accounts, initial_value)?
        }
        CounterInstruction::Increment => process_increment_counter(program_id, accounts)?,
    };
    Ok(())
}

fn process_increment_counter(program_id: &Pubkey, accounts: &[AccountInfo]) -> ProgramResult {
    let accounts_iter = &mut accounts.iter();
    let counter_account = next_account_info(accounts_iter)?;

    // Verify account ownership.
    if counter_account.owner != program_id {
        return Err(ProgramError::IncorrectProgramId);
    }

    // Borrow the account data, increment the counter, and serialize it back.
    let mut data = counter_account.data.borrow_mut();
    let mut counter_data: CounterAccount = CounterAccount::try_from_slice(&data)?;
    counter_data.count = counter_data
        .count
        .checked_add(1)
        .ok_or(ProgramError::InvalidAccountData)?;
    counter_data.serialize(&mut &mut data[..])?;
    msg!("Counter incremented to: {}", counter_data.count);
    Ok(())
}

fn process_initialize_counter(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    initial_value: u64,
) -> ProgramResult {
    let accounts_iter = &mut accounts.iter();
    let counter_account = next_account_info(accounts_iter)?;
    let payer_account = next_account_info(accounts_iter)?;
    let system_program = next_account_info(accounts_iter)?;

    // Calculate minimum balance for rent exemption.
    let rent = Rent::get()?;
    let account_space = 8; // Size in bytes to store a u64.
    let required_lamports = rent.minimum_balance(account_space);

    // Create a counter account.
    invoke(
        &instruction::create_account(
            payer_account.key,
            counter_account.key,
            required_lamports,
            account_space as u64,
            program_id,
        ),
        &[
            payer_account.clone(),
            counter_account.clone(),
            system_program.clone(),
        ],
    )?;

    // Initialize the counter account with the initial value.
    let mut account_data = &mut counter_account.data.borrow_mut()[..];
    let counter_data = CounterAccount {
        count: initial_value,
    };
    counter_data.serialize(&mut account_data)?;
    msg!("Counter initialized with value: {}", initial_value);
    Ok(())
}

#[cfg(test)]
mod test {
    use super::*;
    use solana_program_test::*;
    use solana_sdk::{
        instruction::{AccountMeta, Instruction},
        signature::{Keypair, Signer},
        transaction::Transaction,
    };
    use solana_system_interface::program;

    #[tokio::test]
    async fn test_prototype() {
        let program_id = Pubkey::new_unique();
        let (banks_client, payer, recent_blockhash) = ProgramTest::new(
            "prototype",
            program_id,
            processor!(process_instruction),
        )
        .start()
        .await;

        // Create a new keypair to use as the address for the counter account.
        let counter_keypair = Keypair::new();
        let initial_value: u64 = 42;

        // Create initialize instruction.
        println!("Testing counter initialization...");
        let mut init_instruction_data = vec![INITIALIZE_COUNTER_INSTRUCTION];
        init_instruction_data.extend_from_slice(&initial_value.to_le_bytes());
        let initialize_instruction = Instruction::new_with_bytes(
            program_id,
            &init_instruction_data,
            vec![
                AccountMeta::new(counter_keypair.pubkey(), true),
                AccountMeta::new(payer.pubkey(), true),
                AccountMeta::new_readonly(program::id(), false),
            ],
        );

        // Send transaction with initialize instruction.
        let mut transaction =
            Transaction::new_with_payer(&[initialize_instruction], Some(&payer.pubkey()));
        transaction.sign(&[&payer, &counter_keypair], recent_blockhash);
        banks_client.process_transaction(transaction).await.unwrap();

        // Check account data.
        let account = banks_client
            .get_account(counter_keypair.pubkey())
            .await
            .expect("Failed to get counter account");
        if let Some(account_data) = account {
            let counter: CounterAccount = CounterAccount::try_from_slice(&account_data.data)
                .expect("Failed to deserialize counter data");
            assert_eq!(counter.count, 42);
            println!(
                "✅ Counter initialized successfully with value: {}",
                counter.count
            );
        }

        // Create increment instruction.
        println!("Testing counter increment...");
        let increment_instruction = Instruction::new_with_bytes(
            program_id,
            &[INCREMENT_COUNTER_INSTRUCTION],
            vec![AccountMeta::new(counter_keypair.pubkey(), true)],
        );

        // Send transaction with increment instruction.
        let mut transaction =
            Transaction::new_with_payer(&[increment_instruction], Some(&payer.pubkey()));
        transaction.sign(&[&payer, &counter_keypair], recent_blockhash);
        banks_client.process_transaction(transaction).await.unwrap();

        // Check account data.
        let account = banks_client
            .get_account(counter_keypair.pubkey())
            .await
            .expect("Failed to get counter account");
        if let Some(account_data) = account {
            let counter: CounterAccount = CounterAccount::try_from_slice(&account_data.data)
                .expect("Failed to deserialize counter data");
            assert_eq!(counter.count, 43);
            println!("✅ Counter incremented successfully to: {}", counter.count);
        }
    }
}