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
// use solana_sdk::address_lookup_table::program;
use solana_system_interface::instruction;

entrypoint!(process_instruction);

pub struct StackHeader {
    /// The index of the top item in the stack.
    top: u8,
}

impl StackHeader {
    /// The size of the stack header in bytes.
    const SIZE: usize = std::mem::size_of::<Self>();
    /// The index flag for an empty stack.
    const EMPTY: u8 = u8::MAX;
    /// The maximum index of the top item in the stack.
    const MAX_TOP: u8 = Self::EMPTY - 1;

    pub fn from_top_unchecked(top: u8) -> Self {
        Self { top }
    }

    pub fn write_to_account_data(&self, bytes: &mut [u8]) {
        bytes[0] = self.top;
    }

    pub fn read_from_account_data(bytes: &[u8]) -> StackHeader {
        Self { top: bytes[0] }
    }
}

impl Default for StackHeader {
    fn default() -> Self {
        Self { top: Self::EMPTY }
    }
}

pub struct StackItem {
    /// The value stored in the stack item.
    value: u64,
}

impl StackItem {
    /// The size of the stack item in bytes.
    const SIZE: usize = std::mem::size_of::<Self>();

    pub fn from_value(value: u64) -> Self {
        Self { value }
    }

    pub fn write_to_account_data_at_index(
        &self,
        bytes: &mut [u8],
        index: u8,
    ) -> Result<(), ProgramError> {
        // Calculate the byte offset for the stack item based on the index.
        let offset = StackHeader::SIZE + (index as usize * Self::SIZE);
        bytes[offset..offset + Self::SIZE].copy_from_slice(&self.value.to_le_bytes());
        Ok(())
    }

    pub fn read_from_account_data_at_index(bytes: &mut [u8], index: u8) -> Self {
        // Calculate the byte offset for the stack item based on the index.
        let offset = StackHeader::SIZE + (index as usize * Self::SIZE);
        let value_bytes = &bytes[offset..offset + Self::SIZE];
        let value = u64::from_le_bytes(value_bytes.try_into().unwrap());
        Self { value }
    }
}

#[derive(BorshSerialize, BorshDeserialize, Debug)]
pub struct CounterAccount {
    count: u64,
}

#[derive(BorshSerialize, BorshDeserialize, Debug)]
pub enum Instruction {
    Initialize { initial_value: u64 },
    Increment,
    InitializeStack,
    PushToStack { value: u64 },
    PopFromStack,
}

#[repr(u8)]
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum InstructionType {
    Initialize = 0,
    Increment = 1,
    InitializeStack = 2,
    PushToStack = 3,
    PopFromStack = 4,
}

impl From<InstructionType> for u8 {
    fn from(instruction_type: InstructionType) -> Self {
        instruction_type as u8
    }
}

impl TryFrom<u8> for InstructionType {
    type Error = ProgramError;

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(InstructionType::Initialize),
            1 => Ok(InstructionType::Increment),
            2 => Ok(InstructionType::InitializeStack),
            3 => Ok(InstructionType::PushToStack),
            4 => Ok(InstructionType::PopFromStack),
            _ => Err(ProgramError::InvalidInstructionData),
        }
    }
}

impl Instruction {
    pub fn unpack(input: &[u8]) -> Result<Self, ProgramError> {
        // Get the instruction variant from the first byte.
        let (&variant, rest) = input
            .split_first()
            .ok_or(ProgramError::InvalidInstructionData)?;

        // Match instruction type and parse the remaining bytes based on the variant.
        let instruction_type = InstructionType::try_from(variant)?;
        match instruction_type {
            InstructionType::Initialize => {
                // Parse the initial value for the counter from the remaining bytes.
                let initial_value = u64::from_le_bytes(
                    rest.try_into()
                        .map_err(|_| ProgramError::InvalidInstructionData)?,
                );
                Ok(Self::Initialize { initial_value })
            }
            InstructionType::Increment => Ok(Self::Increment),
            InstructionType::InitializeStack => Ok(Self::InitializeStack),
            InstructionType::PushToStack => {
                // Parse the value to push onto the stack from the remaining bytes.
                let value = u64::from_le_bytes(
                    rest.try_into()
                        .map_err(|_| ProgramError::InvalidInstructionData)?,
                );
                Ok(Self::PushToStack { value })
            }
            InstructionType::PopFromStack => Ok(Self::PopFromStack),
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
    let instruction = Instruction::unpack(instruction_data)?;
    match instruction {
        Instruction::Initialize { initial_value } => {
            process_initialize_counter(program_id, accounts, initial_value)?
        }
        Instruction::Increment => process_increment_counter(program_id, accounts)?,
        Instruction::InitializeStack => {
            process_init_stack(program_id, accounts)?;
        }
        Instruction::PushToStack { value } => {
            process_push(program_id, accounts, value)?;
        }
        Instruction::PopFromStack => {
            process_pop(program_id, accounts)?;
        }
    };
    Ok(())
}

fn process_init_stack(program_id: &Pubkey, accounts: &[AccountInfo]) -> ProgramResult {
    let accounts_iter = &mut accounts.iter();
    let stack_account = next_account_info(accounts_iter)?;
    let payer_account = next_account_info(accounts_iter)?;
    let system_program = next_account_info(accounts_iter)?;

    // Create a stack account.
    invoke(
        &instruction::create_account(
            payer_account.key,
            stack_account.key,
            Rent::get()?.minimum_balance(StackHeader::SIZE),
            StackHeader::SIZE as u64,
            program_id,
        ),
        &[
            payer_account.clone(),
            stack_account.clone(),
            system_program.clone(),
        ],
    )?;

    // Initialize the stack header with default values.
    StackHeader::default().write_to_account_data(&mut stack_account.data.borrow_mut());
    msg!("Stack initialized with default header.");
    Ok(())
}

fn process_push(program_id: &Pubkey, accounts: &[AccountInfo], value: u64) -> ProgramResult {
    let accounts_iter = &mut accounts.iter();
    let stack_account = next_account_info(accounts_iter)?;
    let payer_account = next_account_info(accounts_iter)?;
    let system_program = next_account_info(accounts_iter)?;

    // Verify account ownership.
    if stack_account.owner != program_id {
        return Err(ProgramError::IncorrectProgramId);
    }

    // Get the current length of the stack account data.
    let stack_account_data_length = stack_account.data_len();

    // Mutably borrow the account data, assert it is non-empty, and read the current top index.
    let mut stack_account_data = stack_account.data.borrow_mut();
    if stack_account_data.is_empty() {
        return Err(ProgramError::InvalidAccountData);
    }
    let mut top = StackHeader::read_from_account_data(&stack_account_data).top;

    // Error out if the stack is full.
    if top == StackHeader::MAX_TOP {
        return Err(ProgramError::InvalidAccountData);
    }

    // If stack is empty, set the top index to 0 with a wrapping add. Else increment top.
    top = top.wrapping_add(1);

    // Get the number of items currently allocated in the stack.
    let n_allocated = ((stack_account_data_length - StackHeader::SIZE) / StackItem::SIZE) as u8;

    // Allocate more space if necessary, depositing extra rent via payer account.
    if top + 1 > n_allocated {
        // Drop the account data borrow before resizing.
        drop(stack_account_data);

        stack_account
            .resize(stack_account_data_length + StackItem::SIZE)
            .map_err(|_| ProgramError::InvalidAccountData)?;

        invoke(
            &instruction::transfer(
                payer_account.key,
                stack_account.key,
                Rent::get()?.minimum_balance(StackItem::SIZE),
            ),
            &[
                payer_account.clone(),
                stack_account.clone(),
                system_program.clone(),
            ],
        )?;

        // Re-borrow after resize
        stack_account_data = stack_account.data.borrow_mut();
    }

    // Write the new value to the stack item at the top index.
    StackItem::from_value(value).write_to_account_data_at_index(&mut stack_account_data, top)?;

    // Write the updated stack header back to the account data.
    StackHeader::from_top_unchecked(top).write_to_account_data(&mut stack_account_data);

    msg!("Pushed value {} to stack at index {}", value, top);
    Ok(())
}

fn process_pop(program_id: &Pubkey, accounts: &[AccountInfo]) -> ProgramResult {
    let accounts_iter = &mut accounts.iter();
    let stack_account = next_account_info(accounts_iter)?;

    // Verify account ownership.
    if stack_account.owner != program_id {
        return Err(ProgramError::IncorrectProgramId);
    }

    // Mutably borrow the account data, assert it is non-empty, and read the current top index.
    let mut stack_account_data = stack_account.data.borrow_mut();
    if stack_account_data.is_empty() {
        return Err(ProgramError::InvalidAccountData);
    }
    let mut top = StackHeader::read_from_account_data(&stack_account_data).top;

    // Error out if the stack is empty.
    if top == StackHeader::EMPTY {
        return Err(ProgramError::InvalidAccountData);
    }

    // Read the value at the top index.
    let value = StackItem::read_from_account_data_at_index(&mut stack_account_data, top).value;

    msg!("Popped value {} from stack at index {top}", value);

    // If the stack is now empty, flag it accordingly using a wrapping subtract. Else decrement top.
    top = top.wrapping_sub(1);

    // Write the updated stack header back to the account data.
    StackHeader::from_top_unchecked(top).write_to_account_data(&mut stack_account_data);

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
    async fn test_counter() {
        let program_id = Pubkey::new_unique();
        let (banks_client, payer, recent_blockhash) =
            ProgramTest::new("prototype", program_id, processor!(process_instruction))
                .start()
                .await;

        // Create a new keypair to use as the address for the counter account.
        let counter_keypair = Keypair::new();
        let initial_value: u64 = 42;

        // Create initialize instruction.
        println!("Testing counter initialization...");
        let mut init_instruction_data = vec![InstructionType::Initialize.into()];
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
            &[InstructionType::Increment.into()],
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

    #[tokio::test]
    async fn test_stack() {
        let program_id = Pubkey::new_unique();
        let (banks_client, payer, recent_blockhash) =
            ProgramTest::new("prototype", program_id, processor!(process_instruction))
                .start()
                .await;

        // Create a new keypair to use as the address for the stack account.
        let keypair = Keypair::new();

        // Create initialize stack instruction.
        println!("Testing stack initialization...");
        let initialize_instruction = Instruction::new_with_bytes(
            program_id,
            &[InstructionType::InitializeStack.into()],
            vec![
                AccountMeta::new(keypair.pubkey(), true),
                AccountMeta::new(payer.pubkey(), true),
                AccountMeta::new_readonly(program::id(), false),
            ],
        );

        // Send transaction with initialize stack instruction.
        let mut transaction =
            Transaction::new_with_payer(&[initialize_instruction], Some(&payer.pubkey()));
        transaction.sign(&[&payer, &keypair], recent_blockhash);
        banks_client.process_transaction(transaction).await.unwrap();

        // Create push instruction.
        println!("Testing stack push...");
        let first_value: u64 = 123;
        let mut push_instruction_data = vec![InstructionType::PushToStack.into()];
        push_instruction_data.extend_from_slice(&first_value.to_le_bytes());
        let push_instruction = Instruction::new_with_bytes(
            program_id,
            &push_instruction_data,
            vec![
                AccountMeta::new(keypair.pubkey(), true),
                AccountMeta::new(payer.pubkey(), true),
                AccountMeta::new_readonly(program::id(), false),
            ],
        );

        // Send transaction with push instruction.
        let mut transaction =
            Transaction::new_with_payer(&[push_instruction], Some(&payer.pubkey()));
        transaction.sign(&[&payer, &keypair], recent_blockhash);
        banks_client.process_transaction(transaction).await.unwrap();

        // Resend the push instruction with a different value.
        println!("Testing stack push with different value...");
        let second_value: u64 = 456;
        let mut push_instruction_data = vec![InstructionType::PushToStack.into()];
        push_instruction_data.extend_from_slice(&second_value.to_le_bytes());
        let push_instruction = Instruction::new_with_bytes(
            program_id,
            &push_instruction_data,
            vec![
                AccountMeta::new(keypair.pubkey(), true),
                AccountMeta::new(payer.pubkey(), true),
                AccountMeta::new_readonly(program::id(), false),
            ],
        );

        // Send transaction with push instruction.
        let mut transaction =
            Transaction::new_with_payer(&[push_instruction], Some(&payer.pubkey()));
        transaction.sign(&[&payer, &keypair], recent_blockhash);
        banks_client.process_transaction(transaction).await.unwrap();
    }
}
