use proc_macro::TokenStream;
use quote::quote;
use syn::{parse_macro_input, Data, DeriveInput, Fields};

/// Generates a TryFrom implementation for account structs
/// Maps each field to its corresponding index in the accounts array
#[proc_macro_attribute]
#[allow(non_snake_case)]
pub fn InstructionAccounts(_args: TokenStream, input: TokenStream) -> TokenStream {
    // Parse the struct fields.
    let input = parse_macro_input!(input as DeriveInput);
    let struct_name = &input.ident;
    let fields = match &input.data {
        Data::Struct(data_struct) => match &data_struct.fields {
            Fields::Named(fields) => &fields.named,
            _ => panic!("Only structs with named fields are supported"),
        },
        _ => panic!("Only structs are supported"),
    };
    let n_fields = fields.len();

    // Generate field assignment text: `first_field: &accounts[0] ... `.
    let field_assignments = fields.iter().enumerate().map(|(i, field)| {
        let field_name = &field.ident;
        quote! {
            #field_name: &accounts[#i]
        }
    });

    // Overwrite the input with macro-generated code.
    let expanded = quote! {
        #[repr(C)] // Add `#[repr(C)]` to ensure C-compatible layout.
        #input // Keep the original struct definition.

        // Generate a `TryFrom` implementation.
        impl<'info> TryFrom<&'info [AccountInfo<'info>]> for #struct_name<'info> {
            type Error = solana_program::program_error::ProgramError;

            fn try_from(accounts: &'info [AccountInfo<'info>]) -> Result<Self, Self::Error> {
                // Check that there are enough accounts.
                if accounts.len() < #n_fields {
                    return Err(solana_program::program_error::ProgramError::NotEnoughAccountKeys);
                }
                // Map each field to its array index using the generated assignments.
                Ok(#struct_name {
                    #(#field_assignments,)*
                })
            }
        }
    };

    TokenStream::from(expanded)
}
