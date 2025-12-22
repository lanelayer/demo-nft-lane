#!/bin/bash

# Watch for NFT minting transactions in real-time

CORE_LANE_LOG="/Users/michaelasiedu/Code/core-lane/core-lane.log"
DERIVED_LANE_LOG="/Users/michaelasiedu/Code/core-lane/derived-lane.log"

echo "🎨 NFT Minting Transaction Monitor"
echo "=================================="
echo ""
echo "Watching for NFT mint transactions..."
echo "Mint an NFT in the frontend to see it here!"
echo "Press Ctrl+C to stop"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Track if we've seen any transactions
seen_transaction=false

# Function to highlight transaction events
highlight_transaction() {
  local line=$1
  local service=$2
  
  # Check for transaction forwarding
  if echo "$line" | grep -q "forwarded to upstream\|Transaction forwarded"; then
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ TRANSACTION FORWARDED TO CORE LANE${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    seen_transaction=true
    return 0
  fi
  
  # Check for blocks with transactions (not 0)
  if echo "$line" | grep -q "processing.*transactions"; then
    tx_count=$(echo "$line" | sed -n 's/.*(\([0-9]*\) transactions).*/\1/p')
    if [ "$tx_count" != "0" ] && [ -n "$tx_count" ]; then
      echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
      echo -e "${BLUE}📦 BLOCK WITH ${tx_count} TRANSACTION(S)${NC}"
      echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
      seen_transaction=true
      return 0
    fi
  fi
  
  # Check for RPC calls
  if echo "$line" | grep -q "eth_sendRawTransaction\|eth_sendTransaction"; then
    echo -e "${CYAN}📤 Transaction received by Derived Lane${NC}"
    seen_transaction=true
    return 0
  fi
  
  return 1
}

# Monitor Derived Lane logs
tail -f "$DERIVED_LANE_LOG" 2>/dev/null | while IFS= read -r line; do
  if highlight_transaction "$line" "derived"; then
    echo -e "${BLUE}[DERIVED LANE]${NC} $line"
    echo ""
  fi
done

