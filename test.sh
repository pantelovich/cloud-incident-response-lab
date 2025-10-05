#!/bin/bash

# Cloud Incident Response Automation - Testing Script
# This script helps test the incident response automation

set -e

echo "Cloud Incident Response Automation - Testing Guide"
echo "=================================================="

# Check if we're in the right directory
if [ ! -d "infra" ]; then
    echo "Error: Please run this script from the project root directory"
    exit 1
fi

cd infra

# Get test instance IP if available
INSTANCE_IP=$(terraform output -raw test_instance_public_ip 2>/dev/null || echo "")

if [ -z "$INSTANCE_IP" ] || [ "$INSTANCE_IP" = "null" ]; then
    echo "No test instance found. Please deploy with test resources enabled:"
    echo "terraform apply -var='create_test_instance=true' -var='create_test_vpc=true'"
    exit 1
fi

echo "Test Instance IP: $INSTANCE_IP"
echo ""
echo "Testing Options:"
echo "1. Manual nmap scan (single test)"
echo "2. Automated multiple scans (recommended)"
echo "3. Custom command"
echo "4. Exit"
echo ""

read -p "Select option (1-4): " choice

case $choice in
    1)
        echo "Running single nmap scan..."
        nmap -p 22 $INSTANCE_IP
        echo "Scan completed. Wait 5-10 minutes for GuardDuty to detect and respond."
        ;;
    2)
        echo "Running automated multiple scans..."
        echo "This will run 10 scans with 30-second intervals"
        read -p "Continue? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            for i in {1..10}; do
                echo "Scan $i/10..."
                nmap -p 22 $INSTANCE_IP
                sleep 30
            done
            echo "All scans completed. Wait 5-10 minutes for GuardDuty to detect and respond."
        fi
        ;;
    3)
        read -p "Enter your custom command (use $INSTANCE_IP for the IP): " custom_cmd
        eval $custom_cmd
        ;;
    4)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

echo ""
echo "Monitoring Instructions:"
echo "1. Check CloudWatch Logs for Lambda execution:"
echo "   aws logs describe-log-groups --log-group-name-prefix '/aws/lambda/cloud-incident-response'"
echo ""
echo "2. Check your email for SNS alerts"
echo ""
echo "3. Verify instance was stopped:"
echo "   aws ec2 describe-instances --instance-ids $(terraform output -raw test_instance_id)"
echo ""
echo "4. Check GuardDuty findings:"
echo "   aws guardduty list-findings --detector-id $(terraform output -raw guardduty_detector_id)"