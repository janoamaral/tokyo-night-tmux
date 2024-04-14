# Contributing to tokyo-night-tmux

Thank you for your interest in contributing to the tokyo-night-tmux project! We welcome contributions from the community to help improve and enhance the project. To ensure a smooth collaboration process, please follow the guidelines outlined below.

## Before Making a Pull Request

1. **Open an Issue**: Before starting to work on a new feature or bug fix, please open an issue on the GitHub repository. This allows us to discuss the proposed changes, provide feedback, and ensure that your efforts align with the project's goals.

2. **Discuss and Get Approval**: Once you have opened an issue, engage in a discussion with the project maintainers and the community. Seek approval and guidance before proceeding with the implementation. This step helps prevent duplication of efforts and ensures that your contributions are valuable to the project.

## Making a Pull Request

1. **Fork the Repository**: Create a fork of the tokyo-night-tmux repository in your GitHub account.

2. **Create a New Branch**: Create a new branch from the `next` branch in your forked repository. Use a descriptive branch name that reflects the purpose of your changes.

   ```
   git checkout -b your-branch-name next
   ```

3. **Make Changes**: Implement your changes or additions to the codebase. Ensure that your code follows the project's coding conventions and style guidelines.

4. **Run Pre-commit Tests**: Before committing your changes, run the pre-commit tests to ensure that your code passes all the necessary checks. Use the following command:

   ```
   pre-commit run --all-files
   ```

   Fix any issues or errors reported by the pre-commit tests.

5. **Commit Changes**: Commit your changes with a clear and descriptive commit message. Use the following format:

   ```
   git commit -m "Brief description of the changes"
   ```

6. **Push Changes**: Push your changes to your forked repository.

   ```
   git push origin your-branch-name
   ```

7. **Open a Pull Request**: Go to the tokyo-night-tmux repository on GitHub and open a new pull request. Select the `next` branch as the base branch and your forked branch as the compare branch. Provide a clear title and description for your pull request, explaining the purpose and details of your changes.

8. **Address Feedback**: The project maintainers and the community will review your pull request and provide feedback. Be responsive to their comments and make necessary changes to your code based on the feedback received.

9. **Resolve Conflicts**: If your pull request has conflicts with the `next` branch, you need to resolve them before it can be merged. Update your branch with the latest changes from the `next` branch and resolve any conflicts that arise.

10. **Wait for Approval**: Once your pull request passes all the required checks and receives approval from the project maintainers, it will be merged into the `next` branch.

## Important Notes

- All pull requests must be made against the `next` branch. Pull requests targeting other branches will not be accepted.
- Ensure that your pull request does not have any conflicts with the `next` branch. Resolve any conflicts before submitting the pull request.
- Make sure to run the pre-commit tests (`pre-commit run --all-files`) and fix any issues before committing your changes.
- Maintain a respectful and inclusive environment in all interactions within the project.

Thank you for your contributions to tokyo-night-tmux! Your efforts are greatly appreciated.
