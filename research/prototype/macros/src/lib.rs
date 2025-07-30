use proc_macro::TokenStream;
use quote::quote;
use syn::{parse_macro_input, Data, DeriveInput, Fields};

#[proc_macro_attribute]
#[allow(non_snake_case)]
pub fn InstructionAccounts(_args: TokenStream, input: TokenStream) -> TokenStream {
    // Parse the struct name.
    let input = parse_macro_input!(input as DeriveInput);
    let struct_name = &input.ident;
    if struct_name != "Accounts" {
        panic!("The struct must be named `Accounts`");
    }

    // Parse the struct fields.
    let fields = match &input.data {
        Data::Struct(data_struct) => match &data_struct.fields {
            Fields::Named(fields) => &fields.named,
            _ => panic!("Only structs with named fields are supported"),
        },
        _ => panic!("Only structs are supported"),
    };
    let n_fields = fields.len();

    // Generate `AccountInfos` struct fields.
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

        // Generate an AccountInfos struct with lifetimes.
        #[repr(C)] // Add `#[repr(C)]` to ensure C-compatible layout for reliable parsing.
        pub struct AccountInfos<'info> {
            #(#account_infos_fields,)*
        }


        // Generate a `TryFrom` implementation.
        impl<'info> TryFrom<&'info [AccountInfo<'info>]> for AccountInfos<'info> {
            type Error = solana_program::program_error::ProgramError;

            fn try_from(accounts: &'info [AccountInfo<'info>]) -> Result<Self, Self::Error> {
                // Check that there are enough accounts.
                if accounts.len() < #n_fields {
                    return Err(solana_program::program_error::ProgramError::NotEnoughAccountKeys);
                }
                // Map each field to its array index using the generated assignments.
                Ok(AccountInfos {
                    #(#field_assignments,)*
                })
            }
        }
    };

    TokenStream::from(expanded)
}
