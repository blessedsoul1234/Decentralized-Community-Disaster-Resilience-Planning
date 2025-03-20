# Decentralized Community Disaster Resilience Planning

A blockchain-based platform for community disaster preparedness and resilience planning using Clarity smart contracts on the Stacks blockchain.

## Overview

This project implements a decentralized system for communities to coordinate disaster preparedness efforts. By leveraging blockchain technology, we create transparent, secure, and immutable records of community resources, skills, vulnerabilities, and preparedness exercises.

## Smart Contracts

The system consists of four main smart contracts:

### 1. Vulnerability Assessment Contract

Records location-specific risk factors for disaster planning:
- Flood risk levels
- Fire risk levels
- Earthquake risk levels
- Infrastructure quality scores
- Timestamps for last updates

### 2. Resource Inventory Contract

Tracks available emergency equipment and supplies:
- Resource name, category, and quantity
- Storage location
- Ownership information
- Last update timestamps

### 3. Skill Registry Contract

Identifies community members with valuable emergency skills:
- Skill types (medical, technical, etc.)
- Certification information
- Experience levels
- Availability status
- Person-to-skills mapping

### 4. Exercise Tracking Contract

Monitors participation in preparedness drills:
- Exercise details (name, description, date)
- Participant registration
- Attendance verification
- Participant feedback
- Exercise status tracking

## Technical Details

### Contract Functions

Each contract provides functions for:
- Adding new records
- Updating existing records
- Querying data
- Managing permissions

### Data Structures

The contracts use Clarity's built-in data structures:
- `define-map`: For storing key-value pairs
- `define-data-var`: For storing global variables
- Optional types for nullable fields
- Lists for collections of related data

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Clarity development environment
- [Stacks CLI](https://github.com/blockstack/stacks.js) - For interacting with the Stacks blockchain

### Installation

1. Clone the repository:
