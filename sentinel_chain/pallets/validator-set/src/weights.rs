
//! Autogenerated weights for Validator Set
//!
//! THIS FILE WAS AUTO-GENERATED USING THE SUBSTRATE BENCHMARK CLI VERSION 4.0.0-dev
//! DATE: 2023-05-29, STEPS: `50`, REPEAT: `20`, LOW RANGE: `[]`, HIGH RANGE: `[]`
//! WORST CASE MAP SIZE: `1000000`
//! EXECUTION: Some(Wasm), WASM-EXECUTION: Compiled, CHAIN: Some("local"), DB CACHE: 1024

// Executed Command:
// ./target/release/sentinel-chain
// benchmark
// pallet
// --chain
// local
// --pallet
// validator_set
// --extrinsic
// *
// --steps
// 50
// --repeat
// 20
// --execution=wasm
// --wasm-execution=compiled
// --heap-pages=4096

#![cfg_attr(rustfmt, rustfmt_skip)]
#![allow(unused_parens)]
#![allow(unused_imports)]
#![allow(missing_docs)]

use frame_support::{traits::Get, weights::{Weight, constants::RocksDbWeight}};
use core::marker::PhantomData;

/// Weight functions needed for validator_set.
pub trait WeightInfo {
	fn add_validator() -> Weight;
	fn remove_validator() -> Weight;
}

/// Weights for validator_set using the Substrate node and recommended hardware.
pub struct SubstrateWeight<T>(PhantomData<T>);
impl<T: frame_system::Config> WeightInfo for SubstrateWeight<T> {
	/// Storage: ValidatorSet Validators (r:1 w:1)
	/// Proof Skipped: ValidatorSet Validators (max_values: Some(1), max_size: None, mode: Measured)
	fn add_validator() -> Weight {
		// Proof Size summary in bytes:
		//  Measured:  `117`
		//  Estimated: `1602`
		// Minimum execution time: 20_810_000 picoseconds.
		Weight::from_parts(21_330_000, 1602)
			.saturating_add(T::DbWeight::get().reads(1_u64))
			.saturating_add(T::DbWeight::get().writes(1_u64))
	}
	/// Storage: ValidatorSet Validators (r:1 w:1)
	/// Proof Skipped: ValidatorSet Validators (max_values: Some(1), max_size: None, mode: Measured)
	fn remove_validator() -> Weight {
		// Proof Size summary in bytes:
		//  Measured:  `117`
		//  Estimated: `1602`
		// Minimum execution time: 18_700_000 picoseconds.
		Weight::from_parts(19_840_000, 1602)
			.saturating_add(T::DbWeight::get().reads(1_u64))
			.saturating_add(T::DbWeight::get().writes(1_u64))
	}
}

// For backwards compatibility and tests
impl WeightInfo for () {
	/// Storage: ValidatorSet Validators (r:1 w:1)
	/// Proof Skipped: ValidatorSet Validators (max_values: Some(1), max_size: None, mode: Measured)
	fn add_validator() -> Weight {
		// Proof Size summary in bytes:
		//  Measured:  `117`
		//  Estimated: `1602`
		// Minimum execution time: 20_810_000 picoseconds.
		Weight::from_parts(21_330_000, 1602)
			.saturating_add(RocksDbWeight::get().reads(1_u64))
			.saturating_add(RocksDbWeight::get().writes(1_u64))
	}
	/// Storage: ValidatorSet Validators (r:1 w:1)
	/// Proof Skipped: ValidatorSet Validators (max_values: Some(1), max_size: None, mode: Measured)
	fn remove_validator() -> Weight {
		// Proof Size summary in bytes:
		//  Measured:  `117`
		//  Estimated: `1602`
		// Minimum execution time: 18_700_000 picoseconds.
		Weight::from_parts(19_840_000, 1602)
			.saturating_add(RocksDbWeight::get().reads(1_u64))
			.saturating_add(RocksDbWeight::get().writes(1_u64))
	}
}
