# Tokenized Manufacturing Equipment Maintenance

A blockchain-based system for tracking and managing industrial equipment maintenance using Clarity smart contracts on the Stacks blockchain.

## Overview

This project implements a comprehensive system for tokenizing manufacturing equipment and tracking its maintenance history, parts inventory, usage patterns, and performance metrics. By leveraging blockchain technology, it provides an immutable and transparent record of equipment lifecycle, enabling better maintenance planning, cost tracking, and performance optimization.

## Smart Contracts

The system consists of five main smart contracts:

### 1. Asset Registration Contract

Records details of industrial machinery as non-fungible tokens (NFTs).

- Register new equipment assets with detailed information
- Track equipment status (active, inactive, maintenance, retired)
- Update equipment location and department
- Query asset details

### 2. Maintenance History Contract

Tracks repairs and servicing for industrial equipment.

- Record maintenance activities with details like type, cost, and parts used
- Link maintenance records to specific assets
- Calculate total maintenance costs
- Update maintenance records

### 3. Parts Inventory Contract

Manages replacement component tracking.

- Register parts with details like manufacturer, model, and compatibility
- Track part quantities and usage
- Set reorder thresholds
- Identify parts that need reordering

### 4. Predictive Maintenance Contract

Schedules service based on usage data.

- Track equipment runtime hours and cycles
- Record usage data like temperature, vibration, and power consumption
- Set maintenance intervals based on hours or cycles
- Determine when maintenance is due

### 5. Performance Analytics Contract

Tracks equipment reliability metrics.

- Calculate uptime percentage and downtime hours
- Track mean time between failures (MTBF) and mean time to repair (MTTR)
- Record failure events with details
- Calculate overall equipment effectiveness (OEE)
- Generate reliability scores

## Key Features

- **Versioning**: All data structures include version tracking to maintain a history of changes
- **Authorization**: Functions include authorization checks to ensure only authorized users can modify data
- **Tokenization**: Equipment assets are represented as NFTs
- **Predictive Maintenance**: Usage data is tracked to predict when maintenance will be needed
- **Performance Metrics**: Comprehensive metrics to evaluate equipment reliability and efficiency

## Getting Started

### Prerequisites

- Clarity development environment
- Stacks blockchain node (for deployment)
- Vitest (for running tests)

### Installation

1. Clone the repository:
