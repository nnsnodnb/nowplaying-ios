import json
import typing as t
from http import HTTPStatus

from firebase_functions import https_fn


class JSONResponse(https_fn.Response):
    content_type = "application/json"

    def __init__(
        self,
        data: dict | None = None,
        status: int | str | HTTPStatus | None = None,
        headers: t.Mapping[str, str | t.Iterable[str]] | t.Iterable[tuple[str, str]] | None = None,
        mimetype: str | None = None,
        direct_passthrough: bool = False,
    ) -> None:
        response = {
            "result": data,
        }
        super().__init__(
            response=json.dumps(response),
            status=status,
            headers=headers,
            mimetype=mimetype,
            content_type="application/json",
            direct_passthrough=direct_passthrough,
        )

    def set_body(self, data: dict) -> None:
        self.data = json.dumps({"result": data})
