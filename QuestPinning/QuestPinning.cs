using System;
using GDWeave;
using QuestPinning.Patches;
using Serilog;

namespace QuestPinning;

public class QuestPinning : IMod {
    internal static QuestPinning Instance { get; private set; }
    static ILogger _logger;
    
    public Config Config;

    public QuestPinning(IModInterface modInterface) {
        Instance = this;
        _logger = modInterface.Logger;
        
        this.Config = modInterface.ReadConfig<Config>();
        
        Info("registering patches..");
        modInterface.RegisterScriptMod(new ShopPatches());
        
        Info("loaded!");
    }

    internal static void Info(object message) {
        _logger.Information($"[me.loaforc.questpinning] {message}");
    }
    
    public void Dispose() {
        // Cleanup anything you do here
    }
}
