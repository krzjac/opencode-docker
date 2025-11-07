/**
 * OpenCode Completion Notification Plugin
 * 
 * This plugin sends Pushover notifications when the agent completes responses.
 * It integrates with the existing 'se pushover' command system.
 */

export const CompletionNotificationPlugin = async ({ project, client, $, directory, worktree }) => {
  console.log("CompletionNotificationPlugin initialized!");
  
  // Helper function to extract project name from directory
  const getProjectName = () => {
    if (project && project.name) {
      return project.name;
    }
    // Fallback to directory name
    const parts = directory.split('/');
    return parts[parts.length - 1] || 'Unknown Project';
  };
  
  // Helper function to send notification
  const sendNotification = async (message, title = "OpenCode", priority = 1, sound = "pushover", url = "", urlTitle = "") => {
    try {
      console.log(`Sending Pushover notification: ${title} - ${message}`);
      
      // Call the existing se pushover command
      await $`se pushover ${message} ${title} ${priority} ${sound} ${url} ${urlTitle}`;
      
      console.log("Pushover notification sent successfully");
    } catch (error) {
      console.error("Failed to send Pushover notification:", error);
    }
  };
  
  return {
    // Hook into session events
    event: async ({ event }) => {
      console.log(`Event received: ${event.type}`, event);
      
      // Detect when session becomes idle (agent finished responding)
      if (event.type === "session.idle") {
        const projectName = getProjectName();
        const message = `Agent completed response in ${projectName}`;
        const title = "OpenCode Completion";
        
        await sendNotification(message, title, 1, "pushover", "", "");
      }
      
      // Detect when a message is completed
      if (event.type === "message.done") {
        const projectName = getProjectName();
        const message = `Message processing completed in ${projectName}`;
        const title = "OpenCode Task Done";
        
        await sendNotification(message, title, 0, "pushover", "", "");
      }
    },
    
    // Optional: Hook into tool execution completions
    "tool.execute.after": async (input, output) => {
      // Log tool executions to understand the flow
      console.log(`Tool executed: ${input.tool}`, { input, output });
      
      // You can add specific tool completion notifications here
      // For example, notify when certain important tools complete
      if (input.tool === "bash" && output.success) {
        // Optional: notify on bash command completions
        // Uncomment if desired
        // await sendNotification("Bash command completed", "OpenCode Tool", 0, "bike", "", "");
      }
    }
  };
};

console.log("CompletionNotificationPlugin module loaded");
