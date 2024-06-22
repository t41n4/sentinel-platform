#![cfg_attr(not(feature = "std"), no_std)]

/// Edit this file to define custom logic or remove it if it is not needed.
/// Learn more about FRAME and the core library of Substrate FRAME pallets:
/// <https://docs.substrate.io/reference/frame-pallets/>
pub use pallet::*;
use pallet_timestamp::{self as timestamp};

#[frame_support::pallet(dev_mode)]
pub mod pallet {
	use super::*;
	use frame_support::pallet_prelude::*;
	use frame_system::pallet_prelude::*;
	use sp_std::prelude::*;
	// use uuid::Uuid;
	use frame_support::traits::Randomness;
	type PhoneNumber = Vec<u8>;
	type StatusType = Vec<u8>;
	type Timestamp = Vec<u8>;
	type Reason = Vec<u8>;
	type UniqueId = [u8; 16];
	// type Timestamp = <T as pallet_timestamp::Config>::Moment;

	type TrustRating = i8;

	const SPAM_THRESHOLD: i8 = -50;

	// Data Structures
	#[derive(Encode, Decode, Clone, PartialEq, Eq, RuntimeDebug, TypeInfo)]
	pub struct PhoneRecord {
		trust_rating: TrustRating,
		status: StatusType,
		unique_id: UniqueId,
		spam_records: Vec<SpamRecord>,
		call_records: Vec<CallRecord>,
	}

	// Data Structures
	#[derive(Encode, Decode, Clone, PartialEq, Eq, RuntimeDebug, TypeInfo)]
	pub struct SpamRecord {
		timestamp: Timestamp,
		reason: Reason,
		unique_id: UniqueId,
		who: PhoneNumber,
	}

	#[derive(Encode, Decode, Clone, PartialEq, Eq, RuntimeDebug, TypeInfo)]
	// Data Structures
	pub struct CallRecord {
		caller: PhoneNumber,
		callee: PhoneNumber,
		unique_id: UniqueId,
		timestamp: Timestamp,
	}

	#[pallet::pallet]
	pub struct Pallet<T>(_);

	// Storage Items
	#[pallet::storage]
	#[pallet::getter(fn phone_record)]
	pub type Ledger<T: Config> =
		StorageMap<_, Blake2_128Concat, PhoneNumber, PhoneRecord, OptionQuery>;

	/// Configure the pallet by specifying the parameters and types on which it depends.

	#[pallet::config]
	pub trait Config: frame_system::Config + timestamp::Config {
		type RuntimeEvent: From<Event<Self>> + IsType<<Self as frame_system::Config>::RuntimeEvent>;
		// type MyRandomness: Randomness<H256, u32>;
		type CollectionRandomness: Randomness<Self::Hash, BlockNumberFor<Self>>;
		/// The overarching event type.
		#[pallet::constant]
		type MaximumOwned: Get<u32>;
		#[pallet::constant]
		type ThresholdSpam: Get<i8>;
	}
	// Events
	#[pallet::event]
	#[pallet::generate_deposit(pub(super) fn deposit_event)]
	pub enum Event<T: Config> {
		RegisterPhoneNumber { phone_number: PhoneNumber },
		RegiterDomain { domain: StatusType },
		ReportSPAM { spammee: PhoneNumber, spammer: PhoneNumber, reason: Reason },
		MakeCall { caller: PhoneNumber, callee: PhoneNumber },
		MarkSpam { phone_number: PhoneNumber, metadata: Vec<u8> },
	}

	#[pallet::error]
	pub enum Error<T> {
		/// The phone number is already registered
		PhoneNumberAlreadyRegistered,
		/// The domain is already registered
		DomainAlreadyRegistered,
		/// The phone number is not registered
		PhoneNumberNotRegistered,
		/// The domain is not registered
		DomainNotRegistered,
		/// The phone number is not spam
		PhoneNumberNotSpam,
		/// The domain is not spam
		DomainNotSpam,
		/// The phone number is spam
		PhoneNumberAlreadySpam,
		/// The domain is spam
		DomainSpam,
		/// The phone number is not reach threshold
		PhoneNumberNotReachThreshold,
	}

	// // Dispatchable Calls (Extrinsics)
	#[pallet::call]
	impl<T: Config> Pallet<T> {
		#[pallet::call_index(0)]
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1).ref_time())]
		pub fn register_phone_number(
			_origin: OriginFor<T>,
			phone_number: PhoneNumber,
		) -> DispatchResult {
			// let who = ensure_signed(origin)?;
			ensure!(
				!Ledger::<T>::contains_key(phone_number.clone()),
				Error::<T>::PhoneNumberAlreadyRegistered
			);

			let unique_id = Self::gen_unique_id();

			let new_phone_record = PhoneRecord {
				trust_rating: 0,
				status: "normal".as_bytes().to_vec(),
				unique_id,
				spam_records: vec![],
				call_records: vec![],
			};
			Ledger::<T>::insert(phone_number.clone(), new_phone_record);
			Self::deposit_event(Event::RegisterPhoneNumber { phone_number });
			Ok(())
		}

		#[pallet::call_index(1)]
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1).ref_time())]
		pub fn report_spam(
			_origin: OriginFor<T>,
			spammee: PhoneNumber,
			spammer: PhoneNumber,
			reason: Reason,
		) -> DispatchResult {
			// Ensure the caller is signed
			// let who = ensure_signed(origin)?;

			// Check if the phone number exists, otherwise register it automatically
			Self::register_if_not_exists(spammee.clone());

			// Fetch the existing phone record (guaranteed that it exists at this point)
			let mut phone_record = Ledger::<T>::get(&spammer).unwrap_or_default();

			// Update the trust rating of the phone number
			phone_record.trust_rating = Self::update_trust_rating(phone_record.trust_rating, -10);

			// Generate a unique ID for the spam record
			let unique_id = Self::gen_unique_id();

			let _now = <timestamp::Pallet<T>>::get();
			let timestamp_bytes: Vec<u8> = _now.encode().to_vec();

			let new_spam_record = SpamRecord {
				timestamp: timestamp_bytes,
				reason: reason.clone(),
				unique_id,
				who: spammee.clone(),
			};

			// Add the spam transaction to the record
			phone_record.spam_records.push(new_spam_record);

			// Update the ledger with the modified phone record information
			Ledger::<T>::insert(&spammer, phone_record);
			// Report spam event
			Self::deposit_event(Event::ReportSPAM { spammee, spammer, reason });

			Ok(())
		}

		#[pallet::call_index(2)]
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1).ref_time())]
		pub fn update_spam_status(
			_origin: OriginFor<T>,
			spammer: PhoneNumber,
			metadata: Vec<u8>,
		) -> DispatchResult {
			// Ensure the caller is signed
			// let who = ensure_signed(origin)?;

			let mut phone_record = Ledger::<T>::get(&spammer).unwrap();

			// throw error if phone record not exist
			if phone_record.spam_records.is_empty() {
				phone_record.status = Self::update_status(&phone_record.status, "normal");
				Err(Error::<T>::PhoneNumberNotSpam)?;
			}

			let _now = <timestamp::Pallet<T>>::get();
			let _timestamp_bytes: Vec<u8> = _now.encode().to_vec();
			let status = phone_record.status.clone();
			// Check if the trust rating has fallen below the spam threshold
			if phone_record.trust_rating <= SPAM_THRESHOLD {
				// Change domain type to spam
				if status == "spam".as_bytes().to_vec() {
					Err(Error::<T>::PhoneNumberAlreadySpam)?
				} else {
					phone_record.status = Self::update_status(&phone_record.status, "spam");
					// Update the ledger with the modified phone record information
					Ledger::<T>::insert(&spammer, phone_record);

					Self::deposit_event(Event::MarkSpam { phone_number: spammer, metadata });
					Ok(())
				}
			} else {
				Err(Error::<T>::PhoneNumberNotReachThreshold)?
			}
		}

		#[pallet::call_index(3)]
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1).ref_time())]
		pub fn make_call(
			_origin: OriginFor<T>,
			caller: PhoneNumber,
			callee: PhoneNumber,
		) -> DispatchResult {
			// ensure_signed(origin)?;

			// check if the callee phone number exists in the ledger else register it
			Self::register_if_not_exists(caller.clone());

			// get the phone record of the callee
			let mut caller_phone_record = Ledger::<T>::get(&caller).unwrap();

			// create a new call record
			let _now = <timestamp::Pallet<T>>::get();
			let timestamp: Vec<u8> = _now.encode().to_vec();
			let unique_id = Self::gen_unique_id();

			let caller_call_record = CallRecord {
				caller: caller.clone(),
				callee: callee.clone(),
				timestamp: timestamp.clone(),
				unique_id,
			};

			caller_phone_record.call_records.push(caller_call_record.clone());

			// Update the ledger with the modified phone record information
			Ledger::<T>::insert(&caller, caller_phone_record);

			Self::deposit_event(Event::MakeCall { caller: caller.clone(), callee: callee.clone() });

			Ok(())
		}
	}

	impl Default for PhoneRecord {
		fn default() -> Self {
			Self {
				trust_rating: 0,
				status: "normal".as_bytes().to_vec(),
				unique_id: [0u8; 16],
				spam_records: vec![],
				call_records: vec![],
			}
		}
	}

	impl<T: Config> Pallet<T> {
		fn register_if_not_exists(phone_number: PhoneNumber) {
			if !Ledger::<T>::contains_key(&phone_number) {
				let unique_id = Self::gen_unique_id();
				let new_phone_record = PhoneRecord {
					trust_rating: 0,
					status: "normal".as_bytes().to_vec(),
					unique_id,
					spam_records: vec![],
					call_records: vec![],
				};
				Ledger::<T>::insert(&phone_number, new_phone_record);
			}
		}

		fn update_trust_rating(current_rating: i8, adjustment: i8) -> i8 {
			let mut new_rating = current_rating.clone();
			new_rating += adjustment;
			new_rating
		}
		fn update_status(current_domain: &StatusType, new_type: &str) -> StatusType {
			// Placeholder logic; replace with your own
			let mut new_status = current_domain.clone();
			new_status.clear();
			new_status.extend(new_type.as_bytes());
			new_status
		}
		fn gen_unique_id() -> UniqueId {
			// Create randomness
			let random = T::CollectionRandomness::random(&b"unique_id"[..]).0;

			// Create randomness payload. Multiple collectibles can be generated in the same block,
			// retaining uniqueness.
			let unique_payload = (
				random,
				frame_system::Pallet::<T>::extrinsic_index().unwrap_or_default(),
				frame_system::Pallet::<T>::block_number(),
			);

			// Turns into a byte array
			let encoded_payload = unique_payload.encode();
			let hash = frame_support::Hashable::blake2_128(&encoded_payload);

			// Create a unique id
			let mut unique_id = [0u8; 16];
			unique_id.copy_from_slice(&hash.as_ref()[..16]);

			unique_id
		}
	}
}
