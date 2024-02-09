module econia::core {

    use aptos_framework::fungible_asset::Metadata;
    use aptos_framework::object::{Self, Object, ObjectGroup};
    use aptos_framework::table::{Self, Table};
    use aptos_framework::table_with_length::{Self, TableWithLength};
    use aptos_framework::primary_fungible_store;
    use aptos_std::smart_vector::{SmartVector};
    use std::signer;

    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use econia::test_assets;

    const GENESIS_MARKET_REGISTRATION_FEE: u64 = 100000000;
    const GENESIS_DEFAULT_POOL_FEE_RATE_BPS: u16 = 30;
    const GENESIS_DEFAULT_MAX_SIZE_SIG_FIGS: u8 = 4;
    const GENESIS_DEFAULT_MAX_PRICE_SIG_FIGS: u8 = 4;
    const GENESIS_DEFAULT_MAX_POSTED_ORDERS_PER_SIDE: u32 = 1000;

    const MIN_POST_AMOUNT_NULL: u64 = 0;
    const FEE_RATE_NULL: u16 = 0;

    /// Registrant's utility asset primary fungible store balance is below market registration fee.
    const E_NOT_ENOUGH_UTILITY_ASSET_TO_REGISTER_MARKET: u64 = 0;
    /// A market is already registered for the given trading pair.
    const E_TRADING_PAIR_ALREADY_REGISTERED: u64 = 1;

    #[resource_group_member(group = ObjectGroup)]
    struct Market has key {
        market_id: u64,
        trading_pair: TradingPair,
        market_parameters: MarketParameters,
    }

    struct MarketMetadata has copy, store {
        market_id: u64,
        market_object: Object<Market>,
        trading_pair: TradingPair,
        market_parameters: MarketParameters,
    }

    struct MarketParameters has copy, drop, store {
        pool_fee_rate_bps: u16,
        taker_fee_rate_bps: u16,
        min_post_amount_base: u64,
        min_post_amount_quote: u64,
        max_size_sig_figs: u8,
        max_price_sig_figs: u8,
        max_posted_orders_per_side: u32,
    }

    #[resource_group_member(group = ObjectGroup)]
    struct MarketAccount has key {
        market_id: u64,
        market_object: Object<Market>,
        user: address,
    }

    struct MarketAccountMetadata has store {
        market_id: u64,
        market_object: Object<Market>,
        user: address,
        market_account_object: Object<MarketAccount>,
    }

    struct MarketAccountsManifest has key {
        market_ids: SmartVector<u64>,
        market_accounts: Table<u64, MarketAccountMetadata>,
    }

    struct Registry has key {
        markets: TableWithLength<u64, MarketMetadata>,
        trading_pairs: Table<TradingPair, u64>,
        utility_asset_metadata: Object<Metadata>,
        market_registration_fee: u64,
        default_market_parameters: MarketParameters,
    }

    struct TradingPair has copy, drop, store {
        base_metadata: Object<Metadata>,
        quote_metadata: Object<Metadata>,
    }

    public entry fun register_market(
        registrant: &signer,
        base_metadata: Object<Metadata>,
        quote_metadata: Object<Metadata>,
    ) acquires Registry {
        let registry_ref_mut = borrow_global_mut<Registry>(@econia);
        let utility_asset_metadata = registry_ref_mut.utility_asset_metadata;
        let registrant_balance = primary_fungible_store::balance(
            signer::address_of(registrant),
            utility_asset_metadata
        );
        let market_registration_fee = registry_ref_mut.market_registration_fee;
        assert!(
            registrant_balance >= market_registration_fee,
            E_NOT_ENOUGH_UTILITY_ASSET_TO_REGISTER_MARKET,
        );
        primary_fungible_store::transfer(
            registrant,
            utility_asset_metadata,
            @econia,
            market_registration_fee,
        );
        let trading_pair = TradingPair { base_metadata, quote_metadata };
        let trading_pairs_ref_mut = &mut registry_ref_mut.trading_pairs;
        assert!(
            !table::contains(trading_pairs_ref_mut, trading_pair),
            E_TRADING_PAIR_ALREADY_REGISTERED,
        );
        let markets_ref_mut = &mut registry_ref_mut.markets;
        let market_id = table_with_length::length(markets_ref_mut);
        let constructor_ref = object::create_object(@econia);
        let market_object = object::object_from_constructor_ref(&constructor_ref);
        let market_parameters = registry_ref_mut.default_market_parameters;
        let market_metadata = MarketMetadata {
            market_id,
            market_object,
            trading_pair,
            market_parameters,
        };
        let market_signer = object::generate_signer(&constructor_ref);
        move_to(&market_signer, Market {
            market_id,
            trading_pair,
            market_parameters,
        });
        table_with_length::add(markets_ref_mut, market_id, market_metadata);
        table::add(trading_pairs_ref_mut, trading_pair, market_id);
    }

    fun init_module_internal(
        econia: &signer,
        utility_asset_metadata: Object<Metadata>
    ) {
        move_to(econia, Registry {
            markets: table_with_length::new(),
            trading_pairs: table::new(),
            utility_asset_metadata,
            market_registration_fee: GENESIS_MARKET_REGISTRATION_FEE,
            default_market_parameters: MarketParameters {
                pool_fee_rate_bps: GENESIS_DEFAULT_POOL_FEE_RATE_BPS,
                taker_fee_rate_bps: FEE_RATE_NULL,
                min_post_amount_base: MIN_POST_AMOUNT_NULL,
                min_post_amount_quote: MIN_POST_AMOUNT_NULL,
                max_size_sig_figs: GENESIS_DEFAULT_MAX_SIZE_SIG_FIGS,
                max_price_sig_figs: GENESIS_DEFAULT_MAX_PRICE_SIG_FIGS,
                max_posted_orders_per_side: GENESIS_DEFAULT_MAX_POSTED_ORDERS_PER_SIDE,
            },
        });
    }

    #[test_only]
    public fun init_module_test() {
        let (_, quote_asset) = test_assets::get_metadata();
        init_module_internal(&account::create_signer_for_test(@econia), quote_asset);
    }

    #[test]
    fun test_genesis_values() acquires Registry {
        init_module_test();
        let registry_ref_mut = borrow_global_mut<Registry>(@econia);
        assert!(registry_ref_mut.market_registration_fee == GENESIS_MARKET_REGISTRATION_FEE, 0);
        let params = registry_ref_mut.default_market_parameters;
        assert!(params.pool_fee_rate_bps == GENESIS_DEFAULT_POOL_FEE_RATE_BPS, 0);
        assert!(params.taker_fee_rate_bps == FEE_RATE_NULL, 0);
        assert!(params.min_post_amount_base == MIN_POST_AMOUNT_NULL, 0);
        assert!(params.min_post_amount_quote == MIN_POST_AMOUNT_NULL, 0);
        assert!(params.max_size_sig_figs == GENESIS_DEFAULT_MAX_SIZE_SIG_FIGS, 0);
        assert!(params.max_price_sig_figs == GENESIS_DEFAULT_MAX_PRICE_SIG_FIGS, 0);
        assert!(params.max_posted_orders_per_side == GENESIS_DEFAULT_MAX_POSTED_ORDERS_PER_SIDE, 0);
    }
}
