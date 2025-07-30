# 🛡️ Branch Protection Rules Setup

## Overview
Branch protection rules ensure code quality and prevent direct pushes to important branches.

## Setup Instructions

### 1. Go to GitHub Repository Settings
1. Navigate to your repository on GitHub
2. Click **Settings** tab
3. Click **Branches** in the left sidebar

### 2. Protect `main` Branch
Click **Add rule** and configure:

**Branch name pattern**: `main`

**Settings to enable**:
- ✅ **Require a pull request before merging**
  - ✅ Require approvals: `1`
  - ✅ Dismiss stale PR approvals when new commits are pushed
  - ✅ Require review from code owners
- ✅ **Require status checks to pass before merging**
  - ✅ Require branches to be up to date before merging
  - ✅ Status checks: `build-and-deploy` (from workflows)
- ✅ **Require conversation resolution before merging**
- ✅ **Restrict pushes that create files**
- ✅ **Do not allow bypassing the above settings**

### 3. Protect `develop` Branch
Click **Add rule** and configure:

**Branch name pattern**: `develop`

**Settings to enable**:
- ✅ **Require a pull request before merging**
  - ✅ Require approvals: `1`
  - ✅ Dismiss stale PR approvals when new commits are pushed
- ✅ **Require status checks to pass before merging**
  - ✅ Require branches to be up to date before merging
  - ✅ Status checks: `build-and-deploy`
- ✅ **Require conversation resolution before merging**

### 4. Auto-delete Head Branches
In **General** settings:
- ✅ **Automatically delete head branches**

## Result
- ✅ No direct pushes to `main` or `develop`
- ✅ All changes require pull requests
- ✅ All PRs require approval
- ✅ All tests must pass before merge
- ✅ Automatic cleanup of merged branches