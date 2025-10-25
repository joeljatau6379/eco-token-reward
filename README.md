Eco-Token-Reward Smart Contract

A **Clarity-based smart contract** that incentivizes eco-friendly actions through tokenized rewards on the **Stacks blockchain**.  
The `Eco-Token-Reward` contract promotes sustainability by rewarding users who perform verified environmental activities such as recycling, tree planting, or renewable energy usage.

---

Overview

The `Eco-Token-Reward` smart contract allows:
- Participants to **register** and submit eco-friendly actions.
- Admins or DAOs to **verify** and approve actions.
- Verified users to **claim token rewards**.
- Transparent and immutable on-chain records of all green activities and reward distributions.

This smart contract can be integrated into sustainability apps, community projects, or DAO initiatives promoting environmental responsibility.

---

Core Functionalities

| Function | Description |
|-----------|--------------|
| `register-user` | Registers a new user in the reward program. |
| `submit-activity` | Allows users to submit details of an eco-friendly activity for verification. |
| `approve-activity` | Enables admins to validate submitted activities. |
| `claim-reward` | Issues reward tokens to verified users for approved activities. |
| `get-user-stats` | Fetches total tokens earned and activities verified for a user. |
| `get-total-rewards` | Displays the total number of tokens distributed across the program. |

---

Technical Details

- **Language:** [Clarity](https://docs.stacks.co/write-smart-contracts/clarity-overview)  
- **Blockchain:** [Stacks](https://www.stacks.co/)  
- **Token Standard:** SIP-010 compatible (fungible token model)  
- **Contract Type:** Incentive Distribution Smart Contract  
- **Network Support:** Testnet & Mainnet  

---

Deployment Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/eco-token-reward.git
   cd eco-token-reward
