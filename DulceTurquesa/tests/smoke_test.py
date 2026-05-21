import os

os.environ["DATABASE_URL"] = "sqlite:///:memory:"

from fastapi.testclient import TestClient

from backend.app.main import app


def test_login_products_and_reports():
    with TestClient(app) as client:
        login = client.post(
            "/api/auth/login",
            json={"email": "admin@dulceturquesa.com", "password": "Admin12345"},
        )
        assert login.status_code == 200

        token = login.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        products = client.get("/api/products", headers=headers)
        assert products.status_code == 200
        assert len(products.json()) >= 1

        report = client.get("/api/reports/summary", headers=headers)
        assert report.status_code == 200
        assert "sales_total" in report.json()
