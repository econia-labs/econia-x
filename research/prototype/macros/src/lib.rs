use proc_macro::TokenStream;
use quote::quote;
use syn::{
    parse_macro_input, punctuated::Punctuated, token::Comma, Data, DeriveInput, Field, Fields,
};

/// Helper function to parse struct fields and validate struct name.
fn parse_struct_fields<'a>(
    input: &'a DeriveInput,
    expected_name: &'a str,
) -> &'a Punctuated<Field, Comma> {
    // Check struct name.
    if input.ident != expected_name {
        panic!("The struct must be named `{}`", expected_name);
    }

    // Parse and validate struct fields.
    match &input.data {
        Data::Struct(data_struct) => match &data_struct.fields {
            Fields::Named(fields) => &fields.named,
            _ => panic!("Only structs with named fields are supported"),
        },
        _ => panic!("Only structs are supported"),
    }
}

#[proc_macro_attribute]
#[allow(non_snake_case)]
pub fn InstructionAccounts(_args: TokenStream, input: TokenStream) -> TokenStream {
    // Parse the struct content.
    let input = parse_macro_input!(input as DeriveInput);
    let fields = parse_struct_fields(&input, "Accounts");
    let n_fields = fields.len();

    // Generate `AccountInfoRefs` struct fields.
    let account_infos_fields = fields.iter().map(|field| {
        let field_name = &field.ident;
        quote! {
            pub(super) #field_name: &'info solana_program::account_info::AccountInfo<'info>
        }
    });

    // Generate field assignment text for `TryFrom`: `first_field: &accounts[0] ... `.
    let field_assignments = fields.iter().enumerate().map(|(i, field)| {
        let field_name = &field.ident;
        quote! {
            #field_name: &accounts[#i]
        }
    });

    // Overwrite the input with macro-generated code, including a `TryFrom` parser.
    let expanded = quote! {
        // Keep the original Accounts struct.
        #[allow(dead_code)]
        #[derive(Debug, Clone)]
        #input

        // Generate an AccountInfoRefs struct with lifetimes.
        #[repr(C)]
        pub struct AccountInfoRefs<'info> {
            #(#account_infos_fields,)*
        }

        // Generate a `TryFrom` implementation.
        impl<'info> TryFrom<&'info [solana_program::account_info::AccountInfo<'info>]>
            for AccountInfoRefs<'info>
        {
            type Error = solana_program::program_error::ProgramError;

            fn try_from(
                accounts: &'info [solana_program::account_info::AccountInfo<'info>]
            ) -> Result<Self, Self::Error> {
                // Check that there are enough accounts.
                if accounts.len() < #n_fields {
                    return Err(Self::Error::NotEnoughAccountKeys);
                }
                // Map each field to its array index using the generated assignments.
                Ok(AccountInfoRefs {
                    #(#field_assignments,)*
                })
            }
        }
    };

    TokenStream::from(expanded)
}

#[proc_macro_attribute]
#[allow(non_snake_case)]
pub fn InstructionParameters(_args: TokenStream, input: TokenStream) -> TokenStream {
    // Parse the struct content.
    let input = parse_macro_input!(input as DeriveInput);
    parse_struct_fields(&input, "Parameters");

    // Overwrite the input with macro-generated code, including a `TryFrom` parser.
    let expanded = quote! {
        // Keep the original Accounts struct.
        #[repr(C)]
        #input

        // Generate a `TryFrom` implementation for zero-copy deserialization.
        impl TryFrom<&[u8]> for &Parameters {
            type Error = solana_program::program_error::ProgramError;

            fn try_from(instruction_parameter_bytes: &[u8]) -> Result<Self, Self::Error> {
                if instruction_parameter_bytes.len() != size_of::<Self>() {
                    return Err(Self::Error::InvalidInstructionData);
                }
                let parameters_ptr = instruction_parameter_bytes.as_ptr() as *const Self;
                unsafe {
                    Ok(&*parameters_ptr) // Safe since the length has been checked.
                }
            }
        }
    };

    TokenStream::from(expanded)
}

#[proc_macro_attribute]
#[allow(non_snake_case)]
pub fn InstructionProcessor(_args: TokenStream, input: TokenStream) -> TokenStream {
    let input_fn = parse_macro_input!(input as syn::ItemFn);
    let fn_name = &input_fn.sig.ident;
    let fn_body = &input_fn.block;
    let fn_vis = &input_fn.vis;

    let expanded = quote! {
        // Keep the original function, but add arguments to the function signature and a return.
        #fn_vis fn #fn_name(
            program_id: &solana_program::pubkey::Pubkey,
            accounts: AccountInfoRefs,
            parameters: &Parameters,
        ) -> solana_program::entrypoint::ProgramResult {
            // Call the original function body.
            #fn_body
        }
    };

    TokenStream::from(expanded)
}
