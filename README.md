### Task Overview
This document outlines the steps to manage branches in Git for the challenge.

### What to Do

1. **Identify your main development branch**:
   Determine whether your main development branch is named "dev" or "main".

2. **Switch to the main development branch**:
   Use the following command depending on your main branch name:
   - For "dev":
     ```bash
     git checkout dev
     ```
   - For "main":
     ```bash
     git checkout main
     ```

3. **Create a new branch named "featureX"**:
   Replace "featureX" with your desired feature name:
   ```bash
   git checkout -b featureX
