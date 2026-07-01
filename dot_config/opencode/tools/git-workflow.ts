/**
 * Git Workflow Tool for AI-Assisted Development
 * 
 * Manages git branch workflow for AI-assisted coding tasks. Provides actions for:
 * - Creating isolated feature branches with configurable prefixes
 * - Checking repository status (branch, dirty state, stash, commits)
 * - Committing changes with optional file selection
 * - Completing work via squash merge to main
 * - Aborting work by deleting feature branches
 * 
 * This tool ensures clean main branch by using temporary feature branches
 * that are squashed on completion.
 * 
 * @example
 * ```typescript
 * // Initialize a new feature branch
 * await gitWorkflow({ action: 'init', taskName: 'add-auth-feature' })
 * 
 * // Check repository status
 * await gitWorkflow({ action: 'status' })
 * 
 * // Commit changes
 * await gitWorkflow({ action: 'commit', message: 'Add authentication logic' })
 * 
 * // Complete work and squash merge to main
 * await gitWorkflow({ action: 'complete', commitMessage: 'Add user authentication system' })
 * 
 * // Abort work and delete feature branch
 * await gitWorkflow({ action: 'abort' })
 * ```
 */

import { tool } from '@opencode-ai/plugin'

/**
 * Arguments for the git-workflow tool
 */
export const GitWorkflowArgs = {
  /**
   * The action to perform. One of:
   * - `init`: Create a new feature branch for the task
   * - `status`: Get current repository status
   * - `commit`: Stage and commit changes
   * - `complete`: Squash merge feature branch to main
   * - `abort`: Delete feature branch and return to main
   */
  action: tool.schema.enum(['init', 'status', 'commit', 'complete', 'abort']),
  
  /**
   * Descriptive name for the task (required for init action)
   * Will be converted to kebab-case and prefixed with branchPrefix
   * 
   * @example 'addAuthFeature' -> 'ai/add-auth-feature'
   * @example 'fixLoginBug' -> 'ai/fix-login-bug'
   */
  taskName: tool.schema.string().optional(),
  
  /**
   * Prefix for feature branches (default: 'ai')
   * Allows customization like 'wip', 'dev', 'feature', etc.
   * 
   * @default 'ai'
   */
  branchPrefix: tool.schema.string().default('ai'),
  
  /**
   * Commit message (required for commit action)
   */
  message: tool.schema.string().optional(),
  
  /**
   * Commit message for the squash merge (required for complete action)
   */
  commitMessage: tool.schema.string().optional(),
  
  /**
   * Optional array of files to commit. If not provided, all changes are committed.
   */
  files: tool.schema.array(tool.schema.string()).optional(),
}

/**
 * Result returned by init action
 */
interface InitResult {
  action: 'init'
  success: boolean
  error?: string
  branch?: string
  stashed?: boolean
  stashMessage?: string
}

/**
 * Result returned by status action
 */
interface StatusResult {
  action: 'status'
  success: true
  currentBranch: string
  isDirty: boolean
  stagedFiles: string[]
  unstagedFiles: string[]
  stashList: string[]
  recentCommits: Array<{ hash: string; message: string }>
}

/**
 * Result returned by commit action
 */
interface CommitResult {
  action: 'commit'
  success: boolean
  error?: string
  commitHash?: string
  filesCommitted?: number
}

/**
 * Result returned by complete action
 */
interface CompleteResult {
  action: 'complete'
  success: boolean
  error?: string
  commitHash?: string
  branchDeleted?: string
  stashes?: string[]
}

/**
 * Result returned by abort action
 */
interface AbortResult {
  action: 'abort'
  success: boolean
  error?: string
  branchDeleted?: string
  returnedToMain?: boolean
  stashes?: string[]
}

/**
 * Git Workflow Tool
 * 
  * @param args - Tool arguments including action and action-specific parameters
  * @param context - Tool execution context with worktree path and Bun.$ for shell commands
  * @returns Result object (will be serialized by the framework)
  */
export default tool({
  description: 'Manage git branch workflow for AI-assisted coding tasks',
  args: GitWorkflowArgs,
  async execute(args, context) {
    // Apply explicit runtime defaults - schema defaults may not be applied by framework
    const {
      action,
      taskName,
      branchPrefix = 'ai',
      message,
      commitMessage,
      files,
    } = args
    const worktree = context.worktree

    try {
      switch (action) {
        case 'init':
          return await initBranch(worktree, taskName, branchPrefix)
        
        case 'status':
          return await getStatus(worktree)
        
        case 'commit':
          return await commitChanges(worktree, message, files)
        
        case 'complete':
          return await completeWork(worktree, commitMessage, branchPrefix)
        
        case 'abort':
          return await abortWork(worktree, branchPrefix)
        
        default:
          return {
            action,
            success: false,
            error: `Unknown action: ${action}`,
          }
      }
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error)
      return {
        action,
        success: false,
        error: errorMessage,
      }
    }
  }
})

/**
 * Initialize a new feature branch for the task
 * 
 * Steps:
 * 1. Checkout main branch
 * 2. Stash any uncommitted changes if needed
 * 3. Create and checkout new feature branch with prefix
 * 
 * @param worktree - Path to the git repository
 * @param taskName - Descriptive name for the task
 * @param branchPrefix - Prefix for the feature branch (default: 'ai')
 * @returns InitResult object
 */
async function initBranch(worktree: string, taskName: string | undefined, branchPrefix: string): Promise<InitResult> {
  // Validate taskName is provided
  if (!taskName) {
    return {
      action: 'init',
      success: false,
      error: 'taskName is required for init action',
    }
  }

  // Convert task name to kebab-case
  const kebabTaskName = toKebabCase(taskName)
  
  // Validate branch name doesn't create nested patterns
  if (kebabTaskName.startsWith(`${branchPrefix}/`)) {
    return {
      action: 'init',
      success: false,
      error: `Branch name would create nested pattern: '${branchPrefix}/${kebabTaskName}'. Task name should not include the prefix.`,
    }
  }

  const branchName = `${branchPrefix}/${kebabTaskName}`

  // Checkout main
  try {
    await Bun.$`git checkout main`.cwd(worktree)
  } catch (error) {
    return {
      action: 'init',
      success: false,
      error: `Failed to checkout main: ${error instanceof Error ? error.message : String(error)}`,
    }
  }

  // Check for uncommitted changes and stash if needed
  let stashed = false
  let stashMessage = undefined
  
  const statusOutput = await Bun.$`git status --porcelain`.cwd(worktree).text()
  
  if (statusOutput.trim()) {
    // There are uncommitted changes, stash them
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19)
    stashMessage = `before-${branchName}-${timestamp}`
    
    try {
      await Bun.$`git stash push -m ${JSON.stringify(stashMessage)}`.cwd(worktree)
      stashed = true
    } catch (error) {
      return {
        action: 'init',
        success: false,
        error: `Failed to stash changes: ${error instanceof Error ? error.message : String(error)}`,
      }
    }
  }

  // Create and checkout new branch
  try {
    await Bun.$`git checkout -b ${JSON.stringify(branchName)}`.cwd(worktree)
  } catch (error) {
    return {
      action: 'init',
      success: false,
      error: `Failed to create branch '${branchName}': ${error instanceof Error ? error.message : String(error)}`,
    }
  }

  return {
    action: 'init',
    success: true,
    branch: branchName,
    stashed,
    stashMessage,
  }
}

/**
 * Get current repository status
 * 
 * Returns:
 * - Current branch name
 * - Whether working directory is dirty
 * - List of staged and unstaged files
 * - List of stashes
 * - Recent commits on current branch
 * 
 * @param worktree - Path to the git repository
 * @returns StatusResult object
 */
async function getStatus(worktree: string): Promise<StatusResult> {
  // Get current branch
  const currentBranch = await Bun.$`git branch --show-current`.cwd(worktree).text()
  
  // Get dirty state and file lists
  const stagedOutput = await Bun.$`git diff --cached --name-only`.cwd(worktree).text()
  const unstagedOutput = await Bun.$`git diff --name-only`.cwd(worktree).text()
  const untrackedOutput = await Bun.$`git ls-files --others --exclude-standard`.cwd(worktree).text()
  
  const stagedFiles = stagedOutput.trim().split('\n').filter(Boolean)
  const unstagedFiles = [
    ...unstagedOutput.trim().split('\n').filter(Boolean),
    ...untrackedOutput.trim().split('\n').filter(Boolean),
  ]
  
  const isDirty = stagedFiles.length > 0 || unstagedFiles.length > 0
  
  // Get stash list
  const stashListOutput = await Bun.$`git stash list`.cwd(worktree).text()
  const stashList = stashListOutput.trim().split('\n').filter(Boolean)
  
  // Get recent commits on current branch (last 5)
  const recentCommitsOutput = await Bun.$`git log --oneline -5`.cwd(worktree).text()
  const recentCommits: Array<{ hash: string; message: string }> = []
  
  for (const line of recentCommitsOutput.trim().split('\n').filter(Boolean)) {
    const match = line.match(/^([0-9a-f]+)\s+(.*)$/)
    if (match) {
      recentCommits.push({
        hash: match[1],
        message: match[2],
      })
    }
  }

  return {
    action: 'status',
    success: true,
    currentBranch: currentBranch.trim(),
    isDirty,
    stagedFiles,
    unstagedFiles,
    stashList,
    recentCommits,
  }
}

/**
 * Stage and commit changes
 * 
 * @param worktree - Path to the git repository
 * @param message - Commit message (required)
 * @param files - Optional array of files to commit. If not provided, all changes are committed.
 * @returns CommitResult object
 */
async function commitChanges(worktree: string, message: string | undefined, files: string[] | undefined): Promise<CommitResult> {
  // Validate message is provided
  if (!message) {
    return {
      action: 'commit',
      success: false,
      error: 'message is required for commit action',
    }
  }

  // Stage files
  if (files && files.length > 0) {
    // Stage specific files
    try {
      const fileArgs = files.map(f => JSON.stringify(f))
      await Bun.$`git add ${fileArgs.join(' ')}`.cwd(worktree)
    } catch (error) {
      return {
        action: 'commit',
        success: false,
        error: `Failed to stage files: ${error instanceof Error ? error.message : String(error)}`,
      }
    }
  } else {
    // Stage all changes
    try {
      await Bun.$`git add .`.cwd(worktree)
    } catch (error) {
      return {
        action: 'commit',
        success: false,
        error: `Failed to stage all changes: ${error instanceof Error ? error.message : String(error)}`,
      }
    }
  }

  // Check if there are any changes to commit
  const statusOutput = await Bun.$`git status --porcelain`.cwd(worktree).text()
  if (!statusOutput.trim()) {
    return {
      action: 'commit',
      success: false,
      error: 'No changes to commit',
    }
  }

  // Count files that will be committed
  const stagedOutput = await Bun.$`git diff --cached --name-only`.cwd(worktree).text()
  const filesCommitted = stagedOutput.trim().split('\n').filter(Boolean).length

  // Commit with message
  try {
    const result = await Bun.$`git commit -m ${JSON.stringify(message)}`.cwd(worktree).text()
    
    // Get commit hash
    const commitHashOutput = await Bun.$`git rev-parse HEAD`.cwd(worktree).text()
    const commitHash = commitHashOutput.trim().slice(0, 7)

    return {
      action: 'commit',
      success: true,
      commitHash,
      filesCommitted,
    }
  } catch (error) {
    return {
      action: 'commit',
      success: false,
      error: `Failed to commit: ${error instanceof Error ? error.message : String(error)}`,
    }
  }
}

/**
 * Complete work by squash merging feature branch to main
 * 
 * Steps:
 * 1. Verify on feature branch matching prefix pattern
 * 2. Verify working directory is clean
 * 3. Switch to main
 * 4. Squash merge feature branch
 * 5. Commit with provided message
 * 6. Delete feature branch
 * 7. Report any stashes
 * 
 * @param worktree - Path to the git repository
 * @param commitMessage - Message for the squash commit (required)
 * @param branchPrefix - Prefix to verify against
 * @returns CompleteResult object
 */
async function completeWork(worktree: string, commitMessage: string | undefined, branchPrefix: string): Promise<CompleteResult> {
  // Validate commitMessage is provided
  if (!commitMessage) {
    return {
      action: 'complete',
      success: false,
      error: 'commitMessage is required for complete action',
    }
  }

  // Step 1: Verify we're on a feature branch matching the prefix pattern
  const currentBranch = await Bun.$`git branch --show-current`.cwd(worktree).text()
  const branchName = currentBranch.trim()
  
  if (!branchName.startsWith(`${branchPrefix}/`)) {
    return {
      action: 'complete',
      success: false,
      error: `Not on a feature branch. Expected branch starting with '${branchPrefix}/', but on '${branchName}'.`,
    }
  }

  // Step 2: Verify working directory is clean
  const statusOutput = await Bun.$`git status --porcelain`.cwd(worktree).text()
  if (statusOutput.trim()) {
    return {
      action: 'complete',
      success: false,
      error: 'Working directory is not clean. Please commit or stash changes before completing.',
    }
  }

  // Step 3: Switch to main
  try {
    await Bun.$`git checkout main`.cwd(worktree)
  } catch (error) {
    return {
      action: 'complete',
      success: false,
      error: `Failed to checkout main: ${error instanceof Error ? error.message : String(error)}`,
    }
  }

  // Step 4: Squash merge the feature branch
  try {
    await Bun.$`git merge --squash ${JSON.stringify(branchName)}`.cwd(worktree)
  } catch (error) {
    return {
      action: 'complete',
      success: false,
      error: `Failed to squash merge '${branchName}': ${error instanceof Error ? error.message : String(error)}`,
    }
  }

  // Step 5: Commit with the provided message
  let commitHash: string | undefined
  try {
    await Bun.$`git commit -m ${JSON.stringify(commitMessage)}`.cwd(worktree)
    const commitHashOutput = await Bun.$`git rev-parse HEAD`.cwd(worktree).text()
    commitHash = commitHashOutput.trim().slice(0, 7)
  } catch (error) {
    return {
      action: 'complete',
      success: false,
      error: `Failed to commit squash merge: ${error instanceof Error ? error.message : String(error)}`,
    }
  }

  // Step 6: Delete the feature branch
  try {
    await Bun.$`git branch -D ${JSON.stringify(branchName)}`.cwd(worktree)
  } catch (error) {
    return {
      action: 'complete',
      success: false,
      error: `Failed to delete branch '${branchName}': ${error instanceof Error ? error.message : String(error)}`,
    }
  }

  // Step 7: Get stash list
  const stashListOutput = await Bun.$`git stash list`.cwd(worktree).text()
  const stashes = stashListOutput.trim().split('\n').filter(Boolean)

  return {
    action: 'complete',
    success: true,
    commitHash,
    branchDeleted: branchName,
    stashes,
  }
}

/**
 * Abort work by deleting feature branch and returning to main
 * 
 * Steps:
 * 1. Check if current branch matches feature branch pattern
 * 2. Delete the feature branch if it matches
 * 3. Return to main
 * 4. Report any stashes
 * 
 * @param worktree - Path to the git repository
 * @param branchPrefix - Prefix to match against for deletion
 * @returns AbortResult object
 */
async function abortWork(worktree: string, branchPrefix: string): Promise<AbortResult> {
  // Get current branch
  const currentBranch = await Bun.$`git branch --show-current`.cwd(worktree).text()
  const branchName = currentBranch.trim()

  // Check if current branch matches the feature branch pattern
  if (!branchName.startsWith(`${branchPrefix}/`)) {
    return {
      action: 'abort',
      success: false,
      error: `Not on a feature branch. Cannot delete '${branchName}'. Only branches starting with '${branchPrefix}/' can be aborted.`,
    }
  }

  // Delete the feature branch
  try {
    await Bun.$`git branch -D ${JSON.stringify(branchName)}`.cwd(worktree)
  } catch (error) {
    return {
      action: 'abort',
      success: false,
      error: `Failed to delete branch '${branchName}': ${error instanceof Error ? error.message : String(error)}`,
    }
  }

  // Return to main
  try {
    await Bun.$`git checkout main`.cwd(worktree)
  } catch (error) {
    return {
      action: 'abort',
      success: false,
      error: `Failed to checkout main after deleting branch: ${error instanceof Error ? error.message : String(error)}`,
    }
  }

  // Get stash list
  const stashListOutput = await Bun.$`git stash list`.cwd(worktree).text()
  const stashes = stashListOutput.trim().split('\n').filter(Boolean)

  return {
    action: 'abort',
    success: true,
    branchDeleted: branchName,
    returnedToMain: true,
    stashes,
  }
}

/**
 * Convert a string to kebab-case
 * 
 * @param str - Input string (camelCase, PascalCase, snake_case, etc.)
 * @returns Kebab-case string
 * 
 * @example 'addAuthFeature' -> 'add-auth-feature'
 * @example 'FixLoginBug' -> 'fix-login-bug'
 * @example 'my_task_name' -> 'my-task-name'
 */
function toKebabCase(str: string): string {
  // Insert hyphen before uppercase letters and convert to lowercase
  return str
    .replace(/([a-z0-9])([A-Z])/g, '$1-$2')
    .replace(/[_\s]+/g, '-')
    .toLowerCase()
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '')
}
