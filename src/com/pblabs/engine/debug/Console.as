package com.pblabs.engine.debug
{
	import com.pblabs.engine.PBE;

    /**
     * Process simple text commands from the user. Useful for debugging.
     */ 
	public class Console
	{
        /**
         * The commands, indexed by name. 
         */
        protected static var commands:Object = {};
        
        /**
         * Register a command which the user can execute via the console.
         * 
         * <p>Arguments are parsed and cast to match the arguments in the user's
         * function. Command names must be alphanumeric plus underscore with no
         * spaces.</p>
         *  
         * @param name The name of the command as it will be typed by the user. No spaces.
         * @param callback The function that will be called. Can be anonymous.
         * @param docs A description of what the command does, its arguments, etc.
         * 
         */
        public static function registerCommand(name:String, callback:Function, docs:String = null):void
        {
            // Sanity checks.
            if(callback == null)
                Logger.error(Console, "registerCommand", "Command '" + name + "' has no callback!");

            if(!name || name.length == 0)
                Logger.error(Console, "registerCommand", "Command has no name!");

            if(name.indexOf(" ") != -1)
                Logger.error(Console, "registerCommand", "Command '" + name + "' has a space in it, it will not work.");
            
            // Fill in description.
            var c:ConsoleCommand = new ConsoleCommand();
            c.name = name;
            c.callback = callback;
            c.docs = docs;
            
            if(commands[name])
                Logger.warn(Console, "registerCommand", "Replacing existing command '" + name + "'.");
            
            // Set it.
            commands[name] = c;
        }
        
        /**
         * Take a line of console input and process it, executing any command.
         * @param line String to parse for command.
         */
        public static function processLine(line:String):void
        {
            // Register default commands.
            if(commands.help == null)
                init();
            
            // Split it by spaces.
            var args:Array = line.split(" ");
            
            // Look up the command.
            if(args.length == 0)
                return;
            var potentialCommand:ConsoleCommand = commands[args[0].toString()]; 
            
            if(!potentialCommand)
            {
                Logger.warn(Console, "processLine", "No such command '" + args[0].toString() + "'!");
                return;
            }

            // Now call the command.
            try
            {
                potentialCommand.callback.apply(null, args.slice(1));                
            }
            catch(e:Error)
            {
                Logger.error(Console, args[0], "Error: " + e.toString());
            }
        }
        
        /**
         * Internal initialization, this will get called on its own. 
         */
        public static function init():void
        {
            registerCommand("help", function():void
            {
                // Get commands in alphabetical order.
                var tempList:Array = [];
                for(var cmd:String in commands)
                    tempList.push(cmd);
                tempList.sort();
                
                // Display results.
                Logger.print(Console, "Commands:");
                for(var i:int=0; i<tempList.length; i++)
                {
                    var cc:ConsoleCommand = commands[tempList[i]] as ConsoleCommand;
                    Logger.print(Console, "   " + cc.name + " - " + (cc.docs ? cc.docs : ""));
                }
            }, "List known commands.");
			
			registerCommand("version", function():void
			{
				Logger.print(Console, "PushButton Engine - r"+ PBE.REVISION +" - "+PBE.versionDetails);
			}, "Echo PushButton Engine version information.");
            
            registerCommand("showFps", function():void
            {
                PBE.mainStage.addChild(new Stats());
                Logger.print(Console, "Enabled FPS display.");
            }, "Show an FPS/Memory usage indicator.");
        }
	}
}

final class ConsoleCommand
{
    public var name:String;
    public var callback:Function;
    public var docs:String;
}