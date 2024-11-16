using System.Text.Json.Serialization;

namespace QuestPinning;

public class Config {
    [JsonInclude] public bool DebugLogging = false;

    [JsonInclude]
    public bool SaveAndLoadData = true;
}
