module music_marketplace::music_marketplace {

    // Imports
    use sui::transfer;
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID, ID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};
    use std::option::{Option, none, some, is_some, contains, borrow};
    use std::string::{String};

    // Errors
    const EInvalidBid: u64 = 1;
    const EInvalidMusic: u64 = 2;
    const EDispute: u64 = 3;
    const EAlreadyResolved: u64 = 4;
    const ENotMusician: u64 = 5;
    const EInvalidWithdrawal: u64 = 6;
    const EInsufficientEscrow: u64 = 7;
    const ERROR_INVALID_CAP: u64 = 8;
    const EInvalidEvent: u64 = 9;
    const ETicketsSoldOut: u64 = 10;

    // Struct Definitions

    // Musician struct
    struct Musician has key, store {
        id: UID,
        musician: address,
        name: String,
        bio: vector<u8>,
        genre: vector<u8>,
        price: u64,
        escrow: Balance<SUI>,
        dispute: bool,
        rating: Option<u64>,
        status: vector<u8>,
        trackSold: bool,
    }

    // Client struct
    struct Client has key, store {
        id: UID,
        client: address,
        track_id: ID,
    }

    // Struct that represents Musician Capability
    struct MusicianCap has key {
        id: UID,
        musician_id: ID,
    }

    // TrackRecord struct
    struct TrackRecord has key, store {
        id: UID,
        musician: address,
    }

    // NFT-based Track struct
    struct NFTTrack has key, store {
        id: UID,
        musician: address,
        metadata: vector<u8>,
        owner: address,
        royalty: Royalty,
    }

    // Royalty struct
    struct Royalty has key, store {
        id: UID,
        percentage: u64,
        musician: address,
    }

    // Liquidity Pool struct
    struct LiquidityPool has key, store {
        id: UID,
        pool: address,
        balance: Balance<SUI>,
    }

    // Collaboration Request struct
    struct CollaborationRequest has key, store {
        id: UID,
        requester: address,
        collaborator: address,
        track_id: ID,
        accepted: bool,
    }

    // Event struct
    struct Event has key, store {
        id: UID,
        musician: address,
        name: String,
        description: vector<u8>,
        tickets: u64,
        ticketPrice: u64,
        ticketsSold: u64,
        online: bool,
        venue: Option<String>,
        date: String,
    }

    // Accessors
    public entry fun get_track_description(track: &Musician): vector<u8> {
        track.bio
    }

    public entry fun get_track_price(track: &Musician): u64 {
        track.price
    }

    public entry fun get_track_status(track: &Musician): vector<u8> {
        track.status
    }

    public entry fun get_event_description(event: &Event): vector<u8> {
        event.description
    }

    public entry fun get_event_ticket_price(event: &Event): u64 {
        event.ticketPrice
    }

    public entry fun get_event_tickets_sold(event: &Event): u64 {
        event.ticketsSold
    }

    // Public Entry Functions

    // Add a track
    public entry fun add_track(name: String, bio: vector<u8>, genre: vector<u8>, price: u64, status: vector<u8>, ctx: &mut TxContext) {
        let track_id = object::new(ctx);

        transfer::share_object(Musician {
            id: track_id,
            name: name,
            musician: tx_context::sender(ctx),
            bio: bio,
            genre: genre,
            rating: none(),
            status: status,
            price: price,
            escrow: balance::zero(),
            trackSold: false,
            dispute: false,
        });
    }

    // Mint a track as NFT
    public entry fun mint_nft_track(metadata: vector<u8>, royalty_percentage: u64, ctx: &mut TxContext) {
        let track_id = object::new(ctx);
        let musician = tx_context::sender(ctx);

        let royalty = Royalty {
            id: object::new(ctx),
            percentage: royalty_percentage,
            musician: musician,
        };

        transfer::share_object(NFTTrack {
            id: track_id,
            musician: musician,
            metadata: metadata,
            owner: musician,
            royalty: royalty,
        });
    }

    // Transfer ownership of NFT track
    public entry fun transfer_nft_track(track: &mut NFTTrack, new_owner: address, amount: Coin<SUI>, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == track.owner, ENotMusician);
        let transfer_amount = coin::into_balance(amount);
        let royalty_amount = (transfer_amount * track.royalty.percentage) / 100;
        let musician_payment = transfer_amount - royalty_amount;

        // Transfer royalty to the original musician
        let royalty_coin = coin::take(&mut track.owner, royalty_amount, ctx);
        transfer::public_transfer(royalty_coin, track.royalty.musician);

        // Transfer remaining amount to the new owner
        let payment_coin = coin::take(&mut track.owner, musician_payment, ctx);
        transfer::public_transfer(payment_coin, new_owner);

        track.owner = new_owner;
    }

    // Bid for a track
    public entry fun track_bid(track: &mut Musician, ctx: &mut TxContext) {
        assert!(!track.trackSold, EInvalidBid);
        let client_id = object::new(ctx);
        transfer::share_object(Client {
            id: client_id,
            client: tx_context::sender(ctx),
            track_id: object::id(track),
        });
    }

    // Accept a bid (Musician)
    public entry fun accept_bid(track: &mut Musician, client: &mut Client, ctx: &mut TxContext) {
        assert!(track.musician == tx_context::sender(ctx), ENotMusician);
        assert!(object::id(track) == client.track_id, EInvalidBid);
        track.trackSold = true;
    }

    // Mark track as sold
    public entry fun mark_track_sold(track: &mut Musician, client: &Client, ctx: &mut TxContext) {
        assert!(client.client == tx_context::sender(ctx), EInvalidMusic);
        assert!(object::id(track) == client.track_id, EInvalidMusic);

        track.trackSold = true;
    }

    // Raise a complaint
    public entry fun dispute_track(track: &mut Musician, ctx: &mut TxContext) {
        assert!(track.musician == tx_context::sender(ctx), EDispute);
        track.dispute = true;
    }

    // Resolve dispute if any between musician and client
    public entry fun resolve_dispute(track: &mut Musician, client: &Client, resolved: bool, ctx: &mut TxContext) {
        assert!(track.musician == tx_context::sender(ctx), EDispute);
        assert!(track.dispute, EAlreadyResolved);
        assert!(object::id(track) == client.track_id, EInvalidBid);
        let escrow_amount = balance::value(&track.escrow);
        let escrow_coin = coin::take(&mut track.escrow, escrow_amount, ctx);
        if (resolved) {
            // Transfer funds to the client
            transfer::public_transfer(escrow_coin, client.client);
        } else {
            // Refund funds to the musician
            transfer::public_transfer(escrow_coin, track.musician);
        };

        // Reset track state
        track.trackSold = false;
        track.dispute = false;
    }

    // Release funds to the musician
    public entry fun release_payment(track: &mut Musician, client: &Client, ctx: &mut TxContext) {
        assert!(track.musician == tx_context::sender(ctx), ENotMusician);
        assert!(track.trackSold && !track.dispute, EInvalidMusic);
        assert!(object::id(track) == client.track_id, EInvalidBid);

        let escrow_amount = balance::value(&track.escrow);
        assert!(escrow_amount > 0, EInsufficientEscrow);
        let escrow_coin = coin::take(&mut track.escrow, escrow_amount, ctx);
        // Transfer funds to the musician
        transfer::public_transfer(escrow_coin, track.musician);

        // Create a new track record
        let track_record = TrackRecord {
            id: object::new(ctx),
            musician: track.musician,
        };

        // Change access control to the track record
        transfer::public_transfer(track_record, tx_context::sender(ctx));

        // Reset track state
        track.trackSold = true;
        track.dispute = false;
    }

    // Add more cash to escrow
    public entry fun add_to_escrow(track: &mut Musician, amount: Coin<SUI>, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == track.musician, ENotMusician);
        let added_balance = coin::into_balance(amount);
        balance::join(&mut track.escrow, added_balance);
    }

    // Withdraw funds from escrow
    public entry fun withdraw_from_escrow(cap: &MusicianCap, track: &mut Musician, amount: u64, ctx: &mut TxContext) {
        assert!(cap.musician_id == object::id(track), ERROR_INVALID_CAP);
        assert!(tx_context::sender(ctx) == track.musician, ENotMusician);
        assert!(!track.trackSold, EInvalidWithdrawal);
        let escrow_amount = balance::value(&track.escrow);
        assert!(escrow_amount >= amount, EInsufficientEscrow);
        let escrow_coin = coin::take(&mut track.escrow, amount, ctx);
        transfer::public_transfer(escrow_coin, tx_context::sender(ctx));
    }

    // Update the track genre
    public entry fun update_track_genre(cap: &MusicianCap, track: &mut Musician, genre: vector<u8>, ctx: &mut TxContext) {
        assert!(cap.musician_id == object::id(track), ERROR_INVALID_CAP);
        assert!(track.musician == tx_context::sender(ctx), ENotMusician);
        track.genre = genre;
    }

    // Update the track description
    public entry fun update_track_description(cap: &MusicianCap, track: &mut Musician, bio: vector<u8>, ctx: &mut TxContext) {
        assert!(cap.musician_id == object::id(track), ERROR_INVALID_CAP);
        assert!(track.musician == tx_context::sender(ctx), ENotMusician);
        track.bio = bio;
    }

    // Update the track price
    public entry fun update_track_price(cap: &MusicianCap, track: &mut Musician, price: u64, ctx: &mut TxContext) {
        assert!(cap.musician_id == object::id(track), ERROR_INVALID_CAP);
        assert!(track.musician == tx_context::sender(ctx), ENotMusician);
        track.price = price;
    }

    // Update the track status
    public entry fun update_track_status(cap: &MusicianCap, track: &mut Musician, status: vector<u8>, ctx: &mut TxContext) {
        assert!(cap.musician_id == object::id(track), ERROR_INVALID_CAP);
        assert!(track.musician == tx_context::sender(ctx), ENotMusician);
        track.status = status;
    }

    // Rate the musician
    public entry fun rate_musician(track: &mut Musician, client: &Client, rating: u64, ctx: &mut TxContext) {
        assert!(client.client == tx_context::sender(ctx), EInvalidMusic);
        assert!(object::id(track) == client.track_id, EInvalidMusic);
        track.rating = some(rating);
    }

    // Add liquidity to the pool
    public entry fun add_liquidity(pool: &mut LiquidityPool, amount: Coin<SUI>, ctx: &mut TxContext) {
        balance::join(&mut pool.balance, coin::into_balance(amount));
    }

    // Remove liquidity from the pool
    public entry fun remove_liquidity(pool: &mut LiquidityPool, amount: u64, ctx: &mut TxContext) {
        assert!(balance::value(&pool.balance) >= amount, EInsufficientEscrow);
        let coin = coin::take(&mut pool.balance, amount, ctx);
        transfer::public_transfer(coin, tx_context::sender(ctx));
    }

    // Request collaboration with another musician
    public entry fun request_collaboration(track: &mut Musician, collaborator: address, ctx: &mut TxContext) {
        assert!(track.musician == tx_context::sender(ctx), ENotMusician);
        let request_id = object::new(ctx);
        transfer::share_object(CollaborationRequest {
            id: request_id,
            requester: tx_context::sender(ctx),
            collaborator: collaborator,
            track_id: object::id(track),
            accepted: false,
        });
    }

    // Accept collaboration request
    public entry fun accept_collaboration_request(request: &mut CollaborationRequest, ctx: &mut TxContext) {
        assert!(request.collaborator == tx_context::sender(ctx), EInvalidMusic);
        request.accepted = true;
    }

    // Create an event
    public entry fun create_event(name: String, description: vector<u8>, tickets: u64, ticketPrice: u64, online: bool, venue: Option<String>, date: String, ctx: &mut TxContext) {
        let event_id = object::new(ctx);
        transfer::share_object(Event {
            id: event_id,
            musician: tx_context::sender(ctx),
            name: name,
            description: description,
            tickets: tickets,
            ticketPrice: ticketPrice,
            ticketsSold: 0,
            online: online,
            venue: venue,
            date: date,
        });
    }

    // Buy a ticket for an event
    public entry fun buy_ticket(event: &mut Event, ctx: &mut TxContext) {
        assert!(event.ticketsSold < event.tickets, ETicketsSoldOut);
        let client_id = object::new(ctx);
        transfer::share_object(Client {
            id: client_id,
            client: tx_context::sender(ctx),
            track_id: object::id(event),
        });
        event.ticketsSold = event.ticketsSold + 1;
    }

    // Organize collaboration events
    public entry fun organize_collaboration_event(
        track: &mut Musician,
        collaborator: address,
        name: String,
        description: vector<u8>,
        tickets: u64,
        ticketPrice: u64,
        online: bool,
        venue: Option<String>,
        date: String,
        ctx: &mut TxContext
    ) {
        assert!(track.musician == tx_context::sender(ctx), ENotMusician);
        let event_id = object::new(ctx);
        transfer::share_object(Event {
            id: event_id,
            musician: collaborator,
            name: name,
            description: description,
            tickets: tickets,
            ticketPrice: ticketPrice,
            ticketsSold: 0,
            online: online,
            venue: venue,
            date: date,
        });
    }
}
