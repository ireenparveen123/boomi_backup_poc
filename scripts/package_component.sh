#!/bin/bash
# =============================================
# Script: package_component.sh
# Description: Packages a Boomi component via API
# =============================================

set -e

# Input Parameters
ACCOUNT_ID=$1
USERNAME=$2
API_TOKEN=$3
COMPONENT_ID=$4
PACKAGE_VERSION=$5
RELEASE_NOTES=$6

BASE_URL="https://api.boomi.com/api/rest/v1"

echo "=========================================="
echo " Packaging Boomi Component"
echo " Component ID : $COMPONENT_ID"
echo " Version      : $PACKAGE_VERSION"
echo "=========================================="

# Create Packaged Component
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  -u "$USERNAME:$API_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{
    \"componentId\": \"$COMPONENT_ID\",
    \"packageVersion\": \"$PACKAGE_VERSION\",
    \"notes\": \"$RELEASE_NOTES\",
    \"componentType\": \"process\"
  }" \
  "$BASE_URL/$ACCOUNT_ID/PackagedComponent")

HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n -1)

echo "HTTP Status: $HTTP_STATUS"
echo "Response: $BODY"

if [ "$HTTP_STATUS" -ne 200 ] && [ "$HTTP_STATUS" -ne 201 ]; then
  echo "ERROR: Failed to package component. HTTP Status: $HTTP_STATUS"
  exit 1
fi

# Extract Package ID
PACKAGE_ID=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin)['packageId'])")

if [ -z "$PACKAGE_ID" ]; then
  echo "ERROR: Could not extract Package ID from response"
  exit 1
fi

echo "SUCCESS: Component packaged. Package ID: $PACKAGE_ID"

# Save package ID to file for use in later pipeline steps
echo "$PACKAGE_ID" > package_id.txt
echo "Package ID saved to package_id.txt"