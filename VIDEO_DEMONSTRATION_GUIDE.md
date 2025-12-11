# Video Demonstration Guide

## Overview
This document provides guidance for creating the mandatory demonstration video for the FHEVM example submission.

**Note:** A demonstration video is a **mandatory requirement** for the Bounty Track December 2025 submission.

## Video Requirements

### Duration
- **Minimum**: 3 minutes
- **Recommended**: 5-10 minutes
- **Maximum**: 15 minutes

### Format
- **Resolution**: 1080p (1920x1080) or higher
- **Frame Rate**: 30 fps minimum
- **File Format**: MP4, MOV, or WebM
- **Audio**: Clear narration or captions
- **File Size**: Under 500MB preferred

### Content Requirements
Must clearly showcase:
1. Project setup and installation
2. Key features demonstration
3. Example execution
4. Automation scripts in action
5. Test suite running
6. Deployment process

## Video Structure

### 1. Introduction (30-60 seconds)
**Content:**
- Project name: "Anonymous Identity Verification - FHEVM Example"
- Brief overview of what the project demonstrates
- Key FHEVM concepts covered

**Script Example:**
```
"Welcome to the Anonymous Identity Verification FHEVM example.
This project demonstrates privacy-preserving identity verification
using Fully Homomorphic Encryption on the Ethereum blockchain.

We'll showcase encrypted credential storage, anonymous verification
challenges, and proof validation - all while maintaining complete
data privacy."
```

### 2. Project Setup (60-90 seconds)
**Content:**
- Show directory structure
- Display package.json and dependencies
- Run `npm install`
- Show successful installation

**Actions:**
```bash
# Show project structure
ls -la

# Show package.json
cat package.json

# Install dependencies
npm install

# Verify installation
npm run compile
```

**Narration Points:**
- "The project uses Hardhat with FHEVM Solidity library"
- "All dependencies install automatically"
- "Project structure follows best practices"

### 3. Key Features Overview (90-120 seconds)
**Content:**
- Show main contract: `contracts/AnonymousIdentityVerification.sol`
- Highlight key functions
- Explain encrypted data structures
- Show access control patterns

**Code to Highlight:**
```solidity
// Show encrypted data types
struct IdentityProof {
    euint32 encryptedCredential;  // ← Highlight this
    euint8 identityScore;          // ← And this
    bool isVerified;
    // ...
}

// Show access control
function registerIdentityProof() {
    FHE.allowThis(encryptedCredential);  // ← Explain this
    FHE.allow(encryptedCredential, msg.sender);
}
```

**Narration Points:**
- "Data remains encrypted throughout entire lifecycle"
- "Access control ensures only authorized parties can decrypt"
- "All operations performed on encrypted data"

### 4. Example Contracts Demonstration (2-3 minutes)
**Content:**
- Show example contracts in `examples/` folder
- Demonstrate FHECounter.sol
- Show EncryptionExample.sol
- Highlight AccessControlExample.sol
- Review InputProofExample.sol
- Explain AntiPatternsExample.sol

**For Each Example:**
```bash
# Show contract
cat examples/FHECounter.sol

# Explain key concepts
# - What it demonstrates
# - Why it's important
# - How to use it
```

**Narration Template:**
```
"The [Example Name] demonstrates [concept].
This is important because [reason].
Key functions include [function1], [function2]."
```

### 5. Testing Suite (2-3 minutes)
**Content:**
- Show test files
- Run complete test suite
- Display test coverage
- Show gas reporting

**Actions:**
```bash
# Show test file
cat test/AnonymousIdentityVerification.test.js

# Run tests
npm run test

# Run with coverage
npm run test:coverage

# Run with gas reporting
npm run test:gas
```

**Highlight:**
- Number of test cases
- Test coverage percentage
- All tests passing
- Gas usage analysis

**Narration:**
```
"The test suite covers all contract functionality with
[X] test cases achieving [Y]% code coverage.
All tests pass successfully, validating security and correctness."
```

### 6. Automation Scripts (2-3 minutes)
**Content:**
- Demonstrate automation tools
- Run create-fhevm-example.ts
- Run create-fhevm-category.ts
- Run generate-docs.ts

**Script Demonstration:**
```bash
# Create new example
npx ts-node automation/create-fhevm-example.ts TestExample ./test-output

# Show generated structure
ls -la test-output/TestExample

# Generate documentation
npx ts-node automation/generate-docs.ts ./contracts ./docs-output

# Show generated docs
ls -la docs-output
cat docs-output/AnonymousIdentityVerification.md
```

**Narration:**
```
"The automation scripts enable rapid creation of new examples.
With a single command, we generate a complete project structure
including contracts, tests, configuration, and documentation."
```

### 7. Deployment Demonstration (1-2 minutes)
**Content:**
- Show deployment script
- Run deployment (to local network or testnet)
- Display contract address
- Verify deployment success

**Actions:**
```bash
# Show deployment script
cat scripts/deploy.js

# Deploy to local network (or testnet)
npm run deploy
# OR
npm run deploy:sepolia

# Show contract address
cat deployed_contract
```

**Narration:**
```
"Deployment is automated through Hardhat scripts.
The contract deploys to [network] and is immediately
ready for interaction. The deployed contract address
is saved for future reference."
```

### 8. Frontend Integration (Optional, 1-2 minutes)
**Content:**
- Show frontend files
- Demonstrate wallet connection
- Show contract interaction
- Display real-time updates

**Actions:**
```bash
# Show frontend structure
ls -la frontend/

# Open in browser (if possible to record)
# Demonstrate:
# - MetaMask connection
# - Identity registration
# - Verification request
# - Proof submission
```

### 9. Documentation Tour (1-2 minutes)
**Content:**
- Show documentation files
- Highlight key guides
- Display GitBook structure
- Show automation guide

**Files to Show:**
```bash
# List all documentation
ls -la *.md

# Show key documents
cat README.md | head -50
cat HELLO_FHEVM_TUTORIAL.md | head -50
cat BEST_PRACTICES.md | head -50
```

**Narration:**
```
"Comprehensive documentation includes:
- Quick start guide
- Complete tutorial
- Best practices
- Developer guide
- Deployment instructions
- Technical architecture
- [X] total documentation files with [Y] words"
```

### 10. Conclusion (30-60 seconds)
**Content:**
- Summary of what was demonstrated
- Key achievements
- How to get started
- Resources and links

**Script:**
```
"This FHEVM example provides:
✅ Production-ready privacy-preserving contract
✅ Comprehensive test suite with [X]% coverage
✅ Automation tools for rapid development
✅ Complete documentation and guides
✅ Real-world identity verification use case

To get started:
1. Clone the repository
2. Run npm install
3. Follow the quick start guide
4. Explore the examples

Thank you for watching!"
```

## Recording Tips

### Software Recommendations
- **Screen Recording**: OBS Studio, Camtasia, ScreenFlow
- **Video Editing**: DaVinci Resolve, Adobe Premiere, iMovie
- **Audio**: Audacity for voice recording

### Best Practices
1. **Prepare Script**: Write narration beforehand
2. **Test Run**: Practice demonstration before recording
3. **Clear Audio**: Use good microphone, quiet environment
4. **Steady Pace**: Speak clearly, not too fast
5. **Highlight Cursor**: Make mouse cursor visible and easy to follow
6. **Zoom In**: Zoom into code when explaining details
7. **Pause Appropriately**: Give viewers time to read code/output
8. **Professional**: Remove errors, keep it smooth

### Visual Guidelines
- **Terminal**: Use clear, high-contrast theme
- **Editor**: Readable font size (14pt+ recommended)
- **Browser**: Zoom to 125-150% for readability
- **Cursor**: Enable cursor highlighting
- **Annotations**: Add text overlays for key points

## Video Checklist

### Pre-Recording
- [ ] Clean working directory
- [ ] Test all commands work
- [ ] Prepare terminal theme for visibility
- [ ] Set up screen recording software
- [ ] Test microphone audio quality
- [ ] Write/practice script
- [ ] Close unnecessary applications
- [ ] Set "Do Not Disturb" mode

### During Recording
- [ ] Start with project introduction
- [ ] Show directory structure
- [ ] Demonstrate installation process
- [ ] Highlight key contract features
- [ ] Run complete test suite
- [ ] Demonstrate automation scripts
- [ ] Show deployment process
- [ ] Tour documentation
- [ ] Conclude with summary

### Post-Recording
- [ ] Review entire video
- [ ] Add captions/subtitles
- [ ] Add intro/outro slides
- [ ] Add annotations where helpful
- [ ] Export in required format
- [ ] Test playback on different devices
- [ ] Upload to platform
- [ ] Add video link to submission

## Where to Host Video

### Recommended Platforms
1. **YouTube**: Unlisted or Public
2. **Vimeo**: Private or Public
3. **Google Drive**: Shared link
4. **Dropbox**: Shared link
5. **GitHub**: Release attachment

### Submission Format
Include in your submission:
```markdown
## Video Demonstration
**Video Link**: [https://youtube.com/watch?v=...]
**Duration**: X minutes
**File**: IdentityVerification.mp4 (also included in repository)
```

## Example Timeline

```
00:00 - 00:30   Introduction
00:30 - 02:00   Project Setup & Installation
02:00 - 04:00   Key Features Overview
04:00 - 06:00   Example Contracts Tour
06:00 - 08:00   Testing Suite Demonstration
08:00 - 10:00   Automation Scripts Demo
10:00 - 11:30   Deployment Process
11:30 - 12:30   Documentation Tour
12:30 - 13:00   Conclusion & Resources
```

## Quality Standards

### Must Have
✅ Clear audio (voice or captions)
✅ Readable text (proper zoom level)
✅ Smooth playback (no lag/stuttering)
✅ All required sections covered
✅ Professional presentation
✅ Working demonstrations

### Should Have
✅ Introduction slide
✅ Conclusion slide
✅ Annotations for clarity
✅ Background music (subtle)
✅ Transitions between sections
✅ Progress indicator

### Could Have
✅ Animated intro
✅ Picture-in-picture for presenter
✅ Multiple camera angles
✅ Advanced editing
✅ Custom graphics

## Troubleshooting

### Common Issues

**Issue**: Audio not synced with video
**Solution**: Record audio separately, sync in editing

**Issue**: Text too small to read
**Solution**: Increase terminal font to 16-18pt, zoom browser to 150%

**Issue**: Commands fail during recording
**Solution**: Test everything beforehand, have backup clips

**Issue**: Video file too large
**Solution**: Use compression or lower bitrate (maintain quality)

**Issue**: Unclear what's happening
**Solution**: Add voice narration or on-screen annotations

## Submission

Include in your repository:
```
root/
├── IdentityVerification.mp4        # Video file (if under size limit)
├── VIDEO_LINK                  # Link to hosted video
└── VIDEO_DEMONSTRATION_GUIDE.md    # This document
```

In README.md, add:
```markdown
## 📹 Video Demonstration
Watch the complete walkthrough: [Video Link](https://youtube.com/...)
```

---

**Video Guide Version**: 1.0
**Last Updated**: December 2025
**Status**: Production Ready

**Remember**: The video demonstration is **mandatory** for submission!
