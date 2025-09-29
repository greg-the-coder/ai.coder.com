from litellm.integrations.custom_logger import CustomLogger
import litellm
from litellm.proxy.proxy_server import UserAPIKeyAuth, DualCache
from typing import Optional, Literal

class HeaderHandler(CustomLogger):
    def __init__(self):
        pass

    async def async_pre_call_hook(self, user_api_key_dict: UserAPIKeyAuth, cache: DualCache, data: dict, call_type: Literal[
            "completion",
            "text_completion",
            "embeddings",
            "image_generation",
            "moderation",
            "audio_transcription",
        ]): 

        v = data["proxy_server_request"]["headers"].pop("anthropic-beta", None)
        if v not in [None, "claude-code-20250219"]:
            data["proxy_server_request"]["headers"]["anthropic-beta"] = v
        
        v = data.get("provider_specific_header", {}).get("extra_headers", {}).pop("anthropic-beta", None)
        if v not in [None, "claude-code-20250219"]:
            data["provider_specific_header"]["extra_headers"]["anthropic-beta"] = v
        
        v = data.get("litellm_metadata", {}).get("headers", {}).pop("anthropic-beta", None)
        if v not in [None, "claude-code-20250219"]:
            data["litellm_metadata"]["headers"]["anthropic-beta"] = v
        print(str(data))
        return data

strip_header_callback = HeaderHandler()
