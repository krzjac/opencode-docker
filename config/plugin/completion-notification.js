/**
 * OpenCode Completion Notification Plugin
 * 
 * This plugin sends Pushover notifications when the agent completes responses.
 * It integrates with the existing 'se pushover' command system.
 * 
 * Silent mode - no console logging, suppressed command output.
 * Default sound: bike
 */

export const CompletionNotificationPlugin = async ({ project, client, $, directory, worktree }) => {
  // Helper function to extract project name from directory
  const getProjectName = () => {
    if (project && project.name) {
      return project.name;
    }
    // Fallback to directory name
    const parts = directory.split('/');
    return parts[parts.length - 1] || 'Unknown Project';
  };
  
  // Helper function to send notification silently
  const sendNotification = async (message, title = "OpenCode", priority = 1, sound = "bike", url = "", urlTitle = "") => {
    try {
      // Call the existing se pushover command silently using .quiet()
      const result = await $`se pushover ${message} ${title} ${priority} ${sound} ${url} ${urlTitle}`.quiet();
    } catch (error) {
      // Silently fail - don't log errors
    }
  };
  
  return {
    // Hook into session events
    event: async ({ event }) => {
      // Detect when session becomes idle (agent finished responding)
      if (event.type === "session.idle") {
        const projectName = getProjectName();
        const message = `Agent completed response in ${projectName}`;
        const title = "OpenCode Complete";
        
        await sendNotification(message, title, 1, "bike", "", "");
      }
    }
  };
};
