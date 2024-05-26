# Sentinel Call

**Sentinel Call** is a mobile decentralized application demonstrating the integration of a light client node. This enables the app to connect, quickly sync, and interact with any Substrate-based blockchain, including the Polkadot Network, in a fully trustless and decentralized manner. The app is built from the following components:

- Substrate: ….
- [Flutter](https://flutter.dev/): A multi-platform app development framework.
- [Smoldot](https://github.com/smol-dot/smoldot): A cross-platform light client node implementation written in Rust.
- [Flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge): A library and code generator enabling seamless integration of native Rust code in a Flutter app.
- [Polkadart](https://github.com/polkadart): A library facilitates efficient interaction with the Polkadot ecosystem.

Altogether those technologies enable an array of exciting cross-chain applications & services:

![feat](https://github.com/t41n4/sentinel-call/assets/62371366/89eb9911-d6d2-4529-8dd2-318202efb0c7)

### Why "Sentinel Call" ?

This project is related to the [Trappist](https://github.com/paritytech/trappist) and [Substrate](https://github.com/paritytech/substrate) project, a web3 developer playgrounds built on the technologies spearheaded by the [Polkadot Network](https://polkadot.network/). **Sentinel Call** aims to build on Trappist's capabilities with a focus on implementing a decentralized spam call blocking application.

The name "**Sentinel Call**" draws inspiration from the overall goals of the project:

- "Sentinel" refers to something that stands watch and acts as a guard, sentry or scout. In this context, it represents the role of the application in standing watch over incoming calls and flagging potential spam/unwanted calls for the community to review.
- "Call" highlights that this project specifically focuses on telephone calls and call data. It aims to leverage blockchain technology to provide a safer, more transparent environment for call networks.

By utilizing Trappist's support for experimenting with cross-chain messaging (XCM) and programming other chains, Sentinel Call can coordinate spam detection across multiple telephone networks in a trustless way. The name conveys the goal of building a community-maintained "sentinel" that helps guard telephone users from unwanted/fraudulent calls through the decentralization and transparency enabled by blockchain tech.

## Architecture Overview

![architecture_overview](https://github.com/t41n4/sentinel-call/assets/62371366/8cfaf69a-85ad-4800-afa2-6e0d60d08410)

Our proposed architectural framework comprises three discrete yet interconnected layers:

Layer 3 - Application Layer: The outermost layer, constitutes the application interface to facilitate user interactions for inputting observations.

Layer 2 - Business Logic Layer: This layer processes the application's core functions, organized into three specialized modules:

- Authenticate Module: Facilitates user registration to participate as validator nodes. Validators are sanctioned to contribute to the database classification determination process
- Vote Module: Aggregates indicators pertaining to potentially illegitimate contact designations. Coordinates the evidence evaluation phase involving participant consensus on number statuses.
- Report Module: Logs individual notifications denoting annoyance stemming from particular communication instances. Maintains records of user-submitted reports of numbers causing frustration or disruption

Layer 1 - Sentinel Blockchain: This layer serves as the decentralized data store for the system. As the bottom-most layer utilizing blockchain technology, it exhibits core properties:

- Auditable: All user activities and system operations are recorded imperatively as cryptographically-signed transactions within the shared ledger. This allows any participant full retrospective access to the processing history
- Anonymous: Individuals join through codified SS58 addresses rather than openly disclosed identities. Additional identifiers and metadata encoded using SCALE preserves user privacy.
- Distributed: Reports, inputs, and resulting state changes are replicated across participating nodes. This distributed repository maintains continuous availability and reliability.
- Immutable: Once added, the transactional history incorporated into consecutively chained blocks cannot be revoked or modified. This provides an immutable record of the spam identification workflow

## **Demo**

Here are completions to the demos descriptions based on the information provided:

1. **External call detection function:** 

Under the hood: Incoming calls, are checked inside the user's contacts, if it belongs to their contacts → has contact with the user → the number is safe, otherwise the numbers are cloned Record and post to blockchain.

Under development:

- [ ]  Capture options help users decide which of their data will be recorded. The available options will be presented upon call detection with clear instructions.

Demo: [Demo 1.1](https://github.com/t41n4/sentinel-call/assets/62371366/a3130493-700c-4446-bd1b-f0c3207232d7)
Demo: [Demo 1.2](https://github.com/t41n4/sentinel-call/assets/62371366/a940573b-fea1-4c03-8cd6-8a8af2edc6c1)
    
    ---

2. **Search information function of a phone number:**
    
    Under the hood: the application will query the requested information on the substrate-node and display it if it exists
    
Demo: [Demo 2](https://github.com/t41n4/sentinel-call/assets/62371366/ec0048cd-7b5c-401d-a9e5-c414fe039518) 
    
    ---
    
3. **Function to report a spam phone number**  
    
    Under the hood: Users can submit a report on a number including notes. Reports are added to the blockchain node for processing.
    
    Under development: Streamline reporting process based on feedback and UX.
    
    Demo: [Demo 3](https://github.com/t41n4/sentinel-call/assets/62371366/bbadb1f7-93b0-4d27-b1ef-71568882e290)
    
    ---
    
4. **Function to vote for spam phone numbers**  

Under the hood: Numbers exceeding report threshold enter voting to determine labelling. Votes are recorded on-chain.

Under development: 


Demo: [Demo 4](https://github.com/t41n4/sentinel-call/assets/62371366/074654bc-e5f3-4733-ab6e-fda32a98f59c)

## Getting Started

### Rust Setup

First, complete the [basic Rust setup instructions](https://doc.rust-lang.org/book/ch01-01-installation.html). Then, follow the detailed instructions below.

### **Substrate Setup:**

For blockchain setup please follow this introduction: https://github.com/substrate-developer-hub/substrate-node-template

### Platform setup

Depending on the device you want to deploy on either choose Linux & Android on Linux or macOS, iOS & Android on macOS.

[linux-intro.md](./docs//linux-instructions.md)

[macos-intro.md](./docs/macos-instructions.md)

## Current limitations

This is an early stage sample application, with a number of known limitations:

- Integration that has been tested with the Android app, Linux. No effort will be put into the Web target though, as the [Substrate Connect](https://github.com/paritytech/substrate-connect) project is already addressing this use case by embedding a WASM light client into a web-based decentralized application.

- Integration that has been tested with the Android app, Linux. No effort will be put into the Web target though, as the [Substrate Connect](https://github.com/paritytech/substrate-connect) project is already addressing this use case by embedding a WASM light client into a web-based decentralized application.
- The code of the embedded `smoldot-flutter` library is very rough, and currently contain some hard-coded parts (e.g. connection to the Polkadot network) which should be parameterized, and made more generic for reuse in other projects.
- Optimizations of the user experience remain ongoing. The user interface implementation is not yet finalized.
- Optimizations of the user experience remain ongoing. The user interface implementation is not yet finalized.

## License

Sentinel Call is Licensed under [Apache 2](notion://www.notion.so/n4t41/LICENSE).
