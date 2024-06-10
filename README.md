# Music Marketplace Module

The Music Marketplace module facilitates decentralized management of music tracks, collaborations, and events within a blockchain ecosystem. It provides functionalities for musicians to publish tracks, sell music, handle disputes, collaborate with other artists, manage events, and interact with fans securely and transparently.

## Struct Definitions

### Musician
- **id**: Unique identifier for each musician.
- **musician**: Address of the musician.
- **name**: Name of the musician.
- **bio**: Biography or description of the musician.
- **genre**: Genre(s) associated with the musician's music.
- **price**: Price of the musician's tracks.
- **escrow**: Balance of SUI tokens held in escrow for transactions.
- **dispute**: Flag indicating if there is an ongoing dispute.
- **rating**: Optional rating given to the musician by clients.
- **status**: Current status or updates related to the musician.
- **trackSold**: Flag indicating if the musician's track has been sold.

### Client
- **id**: Unique identifier for each client.
- **client**: Address of the client (buyer or participant).
- **track_id**: ID of the track associated with the client.

### MusicianCap
- **id**: Unique identifier for capabilities related to musician management.
- **musician_id**: ID associated with the specific musician instance.

### TrackRecord
- **id**: Unique identifier for each track record.
- **musician**: Address of the musician associated with the track record.

### LiquidityPool
- **id**: Unique identifier for each liquidity pool.
- **pool**: Address of the liquidity pool.
- **balance**: Balance of SUI tokens held in the liquidity pool.

### CollaborationRequest
- **id**: Unique identifier for each collaboration request.
- **requester**: Address of the musician requesting collaboration.
- **collaborator**: Address of the musician accepting collaboration.
- **track_id**: ID of the track associated with the collaboration request.
- **accepted**: Flag indicating if the collaboration request has been accepted.

### Event
- **id**: Unique identifier for each event.
- **musician**: Address of the musician hosting the event.
- **name**: Name of the event.
- **description**: Description of the event.
- **tickets**: Total number of tickets available for the event.
- **ticketPrice**: Price per ticket.
- **ticketsSold**: Number of tickets sold for the event.

## Accessors

### get_track_description
Returns the biography or description of a given musician's track.

### get_track_price
Returns the price of a given musician's track.

### get_track_status
Returns the current status or updates related to a musician's track.

### get_event_description
Returns the description of a given event.

### get_event_ticket_price
Returns the price per ticket for a given event.

### get_event_tickets_sold
Returns the number of tickets sold for a given event.

## Public - Entry Functions

### add_track
Creates a new track listing with the specified name, biography, genre, price, status, and assigns it to the musician who initiates the transaction.

### track_bid
Enables clients to place bids on available tracks, ensuring the track is not already sold.

### accept_bid
Allows musicians to accept bids placed on their tracks, marking them as sold.

### mark_track_sold
Marks a track as sold upon client confirmation.

### dispute_track
Enables musicians to raise disputes regarding track sales.

### resolve_dispute
Resolves disputes between musicians and clients, transferring funds accordingly.

### release_payment
Releases payments to musicians upon successful track sales.

### add_to_escrow
Allows musicians to add more funds to the escrow account associated with their tracks.

### withdraw_from_escrow
Enables musicians to withdraw funds from the escrow account associated with their tracks.

### update_track_genre
Updates the genre associated with a musician's track.

### update_track_description
Updates the biography or description of a musician's track.

### update_track_price
Updates the price of a musician's track.

### update_track_status
Updates the status or updates related to a musician's track.

### rate_musician
Allows clients to rate musicians after purchasing their tracks.

### add_liquidity
Enables liquidity providers to add liquidity to the liquidity pool.

### remove_liquidity
Allows liquidity providers to remove liquidity from the liquidity pool.

### request_collaboration
Allows musicians to request collaboration with other musicians.

### accept_collaboration_request
Enables musicians to accept collaboration requests from other musicians.

### create_event
Enables musicians to create new events, specifying event details such as name, description, tickets available, and ticket price.

### buy_ticket
Allows clients to purchase tickets for events hosted by musicians.

## Setup

### Prerequisites

1. **Rust and Cargo**: Install Rust and Cargo on your development machine by following the official Rust installation instructions.

2. **SUI Blockchain**: Set up a local instance of the SUI blockchain for development and testing purposes. Refer to the SUI documentation for installation instructions.

### Build and Deploy

1. Clone the Music Marketplace repository and navigate to the project directory on your local machine.

2. Compile the smart contract code using the following command:

   ```bash
   sui move build
   ```

3. Deploy the compiled smart contract to your local SUI blockchain node using the SUI CLI or other deployment tools.

4. Note the contract address and other relevant identifiers for interacting with the deployed contract.

## Usage

### Adding New Tracks

Musicians can add new tracks using the `add_track` function, specifying details such as name, biography, genre, price, and status.

### Selling and Managing Tracks

Manage track bids, accept bids, mark tracks as sold, handle disputes, and release payments using the respective functions provided.

### Collaborations and Events

Request collaborations with other musicians, create events, sell event tickets, and manage event details using the specified functions.

### Financial Transactions

Deposit funds, manage escrow accounts, withdraw funds, add liquidity, remove liquidity, and handle financial transactions securely using the available functions.

## Interacting with the Smart Contract

### Using the SUI CLI

1. Utilize the SUI CLI to interact with the deployed smart contract, providing function arguments and transaction contexts as required.

2. Monitor transaction outputs and blockchain events to track music track sales, collaboration requests, event management, and financial transactions within the decentralized music marketplace.

## Conclusion

The Music Marketplace module provides a decentralized platform for musicians to manage and monetize their music tracks, collaborate with other artists, host events, and interact with fans. By leveraging blockchain technology, this module ensures transparency, security, and efficiency in the management of music-related transactions, fostering a vibrant ecosystem for musicians and music enthusiasts alike.