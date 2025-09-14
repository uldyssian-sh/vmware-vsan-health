#!/bin/bash

test_eks_script() {
    echo "🧪 Testing EKS deployment script..."
    
    # Test 1: Script exists and is executable
    if [ ! -f "./deploy-eks.sh" ]; then
        echo "❌ FAIL: deploy-eks.sh not found"
        return 1
    fi
    
    if [ ! -x "./deploy-eks.sh" ]; then
        echo "❌ FAIL: deploy-eks.sh not executable"
        return 1
    fi
    
    echo "✅ PASS: Script exists and executable"
    
    # Test 2: Required tools check
    if ! command -v aws &> /dev/null; then
        echo "⚠️  WARNING: AWS CLI not installed"
    else
        echo "✅ PASS: AWS CLI available"
    fi
    
    if ! command -v kubectl &> /dev/null; then
        echo "⚠️  WARNING: kubectl not installed"  
    else
        echo "✅ PASS: kubectl available"
    fi
    
    # Test 3: Syntax validation
    bash -n ./deploy-eks.sh
    if [ $? -eq 0 ]; then
        echo "✅ PASS: Script syntax valid"
    else
        echo "❌ FAIL: Script syntax errors"
        return 1
    fi
    
    echo "🎉 All tests passed!"
    return 0
}

test_eks_script
