from dataclasses import dataclass


@dataclass(frozen=True, kw_only=True)
class TwitterOAuthCallback:
    state: str
    code: str


@dataclass(frozen=True)
class TwitterOAuthToken:
    token_type: str
    expires_in: int
    access_token: str
    refresh_token: str
    scope: str
