#!/bin/bash
# =============================================
# Script: rollback.sh
# Description: Rolls back to the previous deployment
# =============================================

set -e

ACCOUNT_ID=$1
USERNAME=$2
API_TOKEN=$3
ENVIRONMENT_ID=$4
PREVIOUS_PACKAGE_ID=$5

BASE_URL="https://api.boomi.com/api/rest/v1"

echo "=========================================="
echo " ROLLBACK INITIATED"
echo " Environment  : $ENVIRONMENT_ID"
echo " Rolling back to Package: $PREVIOUS_PACKAGE_ID"
echo "=========================================="

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  -u "$USERNAME:$API_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{
    \"environmentId\": \"$ENVIRONMENT_ID\",
    \"packageId\": \"$PREVIOUS_PACKAGE_ID\",
    \"notes\": \"ROLLBACK - Initiated via Azure Pipeline - $(date)\"
  }" \
  "$BASE_URL/$ACCOUNT_ID/DeployedPackage")

HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n -1)

if [ "$HTTP_STATUS" -ne 200 ] && [ "$HTTP_STATUS" -ne 201 ]; then
  echo "ERROR: Rollback failed. HTTP Status: $HTTP_STATUS"
  exit 1
fi

echo "SUCCESS: Rollback completed successfully"