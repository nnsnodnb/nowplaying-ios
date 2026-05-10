import base64
import hashlib
import os
import requests
import secrets
from urllib.parse import parse_qs, urlencode

from firebase_functions import https_fn
from firebase_functions.params import SecretParam
from firebase_admin import initialize_app

from entities import TwitterOAuthCallback, TwitterOAuthToken
from response import JSONResponse


initialize_app()

TWITTER_CLIENT_ID = "cFkwa24zTlhGck1KUkViZENOUHc6MTpjaQ"
TWITTER_CLIENT_SECRET = SecretParam("TWITTER_CLIENT_SECRET")
IS_EMULATOR = os.getenv("FUNCTIONS_EMULATOR") == "true"
APP_CALLBACK_URI = "nowplaying-ss5dnc-el0eskszufn3qactsets://callback/oauth"


def get_redirect_uri() -> str:
    if IS_EMULATOR:
        return "http://127.0.0.1:9095/nowplayingios/asia-northeast1/twitter_oauth_callback"
    else:
        return "https://asia-northeast1-nowplayingios.cloudfunctions.net/twitter_oauth_callback"


@https_fn.on_request(region="asia-northeast1", enforce_app_check=True)
def twitter_oauth_init(request: https_fn.Request) -> https_fn.Response:
    # TODO: ユーザーを取得する
    # TODO: code_verifierをユーザーIDと紐づけて生成する
    code_verifier = secrets.token_urlsafe(32)
    digest = hashlib.sha256(code_verifier.encode("utf-8")).digest()
    code_challenge = base64.urlsafe_b64encode(digest).decode("utf-8").rstrip("=")

    query_params = {
        "response_type": "code",
        "client_id": TWITTER_CLIENT_ID,
        "redirect_uri": get_redirect_uri(),
        "scope": "users.read tweet.read tweet.write media.write offline.access",
        "state": code_verifier,
        "code_challenge": code_challenge,
        "code_challenge_method": "S256",
    }
    query_string = urlencode(query_params)

    auth_url = f"https://x.com/i/oauth2/authorize?{query_string}"

    response = https_fn.Response(
        status=302,
        headers={
            "Location": auth_url,
        },
    )
    response.set_cookie(
        key="code_verifier",
        value=code_verifier,
        max_age=60 * 5,
        httponly=True,
        secure=not IS_EMULATOR,
        samesite="Lax",
    )
    return response


@https_fn.on_request(region="asia-northeast1", enforce_app_check=False, secrets=[TWITTER_CLIENT_SECRET])
def twitter_oauth_callback(request: https_fn.Request) -> https_fn.Response:
    query_params = {k: v[0] for k, v in parse_qs(request.query_string.decode("utf-8")).items()}
    response = JSONResponse(
        data={},
        status=500,
    )

    try:
        callback = TwitterOAuthCallback(**query_params)
        if ((code_verifier := request.cookies.get("code_verifier")) is None
            or code_verifier != callback.state):
            response.set_body({"error": "invalid_request"})
            response.status = 400
        else:
            res = requests.post(
                url="https://api.x.com/2/oauth2/token",
                data={
                    "code": callback.code,
                    "grant_type": "authorization_code",
                    "client_id": TWITTER_CLIENT_ID,
                    "redirect_uri": get_redirect_uri(),
                    "code_verifier": code_verifier,
                    "client_secret": TWITTER_CLIENT_SECRET.value,
                },
                headers={
                    "Content-Type": "application/x-www-form-urlencoded",
                },
            )
            data = res.json()
            print(data)
            res.raise_for_status()
            # TODO: TwitterOAuthTokenを保存する
            oauth_token = TwitterOAuthToken(**data)
            # FIXME: アクセストークンを返さない
            response.set_body({"access_token": oauth_token.access_token})
            response.status = 200
    except TypeError:
        query_params.get("error")
        response.set_body({"error": query_params.get("error", "unknown_error")})
        response.status = 400
    finally:
        response.delete_cookie(
            key="code_verifier",
            secure=not IS_EMULATOR,
            httponly=True,
            samesite="Lax",
        )

    return response
