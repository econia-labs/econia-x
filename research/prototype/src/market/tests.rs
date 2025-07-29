use super::*;
use solana_program_test::*;

#[tokio::test]
async fn test_rent_exempt_balance() {
    // Start a minimal test environment.
    let program_test = ProgramTest::default();
    let (banks_client, _payer, _recent_blockhash) = program_test.start().await;

    // Get the rent sysvar from the test environment.
    let rent = banks_client
        .get_rent()
        .await
        .expect("Failed to get rent sysvar");
    let calculated_balance = rent.minimum_balance(size_of::<Market>());

    // Verify that the hard-coded rent exempt balance matches the calculated one.
    assert_eq!(
        Market::RENT_EXEMPT_BALANCE,
        calculated_balance,
        "Hard-coded rent balance {} doesn't match calculated balance {}. Market size {}.",
        Market::RENT_EXEMPT_BALANCE,
        calculated_balance,
        size_of::<Market>(),
    );
}
