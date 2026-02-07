"""
Tests for Online-Rezeption Features
===================================
DSGVO, Appointments, Anamnesis, Lab Results, Medications, Vaccinations
"""

import pytest
from httpx import AsyncClient
from datetime import date


@pytest.mark.asyncio
async def test_get_consents_requires_auth(client: AsyncClient):
    """Consent-Abfrage erfordert Authentifizierung"""
    response = await client.get("/api/v1/privacy/consents")
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_get_consents_authenticated(client: AsyncClient, auth_headers: dict):
    """Consent-Abfrage funktioniert mit Auth"""
    response = await client.get("/api/v1/privacy/consents", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert "consents" in data


@pytest.mark.asyncio
async def test_update_consent(client: AsyncClient, auth_headers: dict):
    """Consent kann aktualisiert werden"""
    response = await client.post(
        "/api/v1/privacy/consents",
        json={"category": "essential", "granted": True},
        headers=auth_headers,
    )
    assert response.status_code == 200


@pytest.mark.asyncio
async def test_request_data_export(client: AsyncClient, auth_headers: dict):
    """Datenexport kann angefordert werden (Art. 20)"""
    response = await client.post(
        "/api/v1/privacy/export",
        json={"format": "json"},
        headers=auth_headers,
    )
    assert response.status_code in [200, 202]


@pytest.mark.asyncio
async def test_request_data_deletion(client: AsyncClient, auth_headers: dict):
    """Datenlöschung kann angefordert werden (Art. 17)"""
    response = await client.post(
        "/api/v1/privacy/deletion",
        json={"reason": "Widerruf der Einwilligung"},
        headers=auth_headers,
    )
    assert response.status_code in [200, 202]


@pytest.mark.asyncio
async def test_get_appointment_types(client: AsyncClient):
    """Termintypen sind öffentlich abrufbar"""
    response = await client.get("/api/v1/appointments/types")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) > 0


@pytest.mark.asyncio
async def test_book_appointment_requires_auth(client: AsyncClient):
    """Terminbuchung erfordert Authentifizierung"""
    response = await client.post(
        "/api/v1/appointments/",
        json={
            "appointment_type": "checkup",
            "date": date.today().isoformat(),
            "slot": "10:00",
        },
    )
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_get_my_appointments(client: AsyncClient, auth_headers: dict):
    """Eigene Termine abrufen"""
    response = await client.get("/api/v1/appointments/my", headers=auth_headers)
    assert response.status_code == 200
    assert isinstance(response.json(), list)


@pytest.mark.asyncio
async def test_get_anamnesis_templates(client: AsyncClient):
    """Anamnese-Vorlagen sind abrufbar"""
    response = await client.get("/api/v1/anamnesis/templates")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)


@pytest.mark.asyncio
async def test_get_anamnesis_template_detail(client: AsyncClient):
    """Einzelne Vorlage abrufen"""
    response = await client.get("/api/v1/anamnesis/templates/general-anamnesis")
    assert response.status_code == 200
    data = response.json()
    assert "sections" in data


@pytest.mark.asyncio
async def test_submit_anamnesis_requires_auth(client: AsyncClient):
    """Anamnese-Einreichung erfordert Auth"""
    response = await client.post(
        "/api/v1/anamnesis/submit",
        json={
            "template_id": "general-anamnesis",
            "answers": [],
        },
    )
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_get_symptom_catalog(client: AsyncClient):
    """Symptom-Katalog ist abrufbar"""
    response = await client.get("/api/v1/symptom-checker/symptoms")
    assert response.status_code == 200


@pytest.mark.asyncio
async def test_get_red_flags(client: AsyncClient):
    """Red Flags sind abrufbar"""
    response = await client.get("/api/v1/symptom-checker/red-flags")
    assert response.status_code == 200


@pytest.mark.asyncio
async def test_get_my_lab_results_requires_auth(client: AsyncClient):
    """Befund-Abruf erfordert Auth"""
    response = await client.get("/api/v1/lab-results/my")
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_get_my_lab_results(client: AsyncClient, auth_headers: dict):
    """Eigene Befunde abrufen"""
    response = await client.get("/api/v1/lab-results/my", headers=auth_headers)
    assert response.status_code == 200
    assert isinstance(response.json(), list)


@pytest.mark.asyncio
async def test_get_reference_values(client: AsyncClient):
    """Referenzwerte sind öffentlich"""
    response = await client.get("/api/v1/lab-results/reference-values")
    assert response.status_code == 200


@pytest.mark.asyncio
async def test_get_my_medications(client: AsyncClient, auth_headers: dict):
    """Eigene Medikamente abrufen"""
    response = await client.get("/api/v1/medications/my", headers=auth_headers)
    assert response.status_code == 200


@pytest.mark.asyncio
async def test_get_todays_schedule(client: AsyncClient, auth_headers: dict):
    """Tagesplan abrufen"""
    response = await client.get("/api/v1/medications/my/schedule/today", headers=auth_headers)
    assert response.status_code == 200


@pytest.mark.asyncio
async def test_get_my_vaccinations(client: AsyncClient, auth_headers: dict):
    """Eigene Impfungen abrufen"""
    response = await client.get("/api/v1/vaccinations/my", headers=auth_headers)
    assert response.status_code == 200


@pytest.mark.asyncio
async def test_get_vaccination_pass(client: AsyncClient, auth_headers: dict):
    """Vollständigen Impfpass abrufen"""
    response = await client.get("/api/v1/vaccinations/my/pass", headers=auth_headers)
    assert response.status_code == 200


@pytest.mark.asyncio
async def test_get_vaccination_recommendations(client: AsyncClient, auth_headers: dict):
    """Impfempfehlungen abrufen"""
    response = await client.get("/api/v1/vaccinations/my/recommendations", headers=auth_headers)
    assert response.status_code == 200


@pytest.mark.asyncio
async def test_list_forms(client: AsyncClient):
    """Formulare auflisten"""
    response = await client.get("/api/v1/forms/")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)


@pytest.mark.asyncio
async def test_list_form_categories(client: AsyncClient):
    """Kategorien auflisten"""
    response = await client.get("/api/v1/forms/categories")
    assert response.status_code == 200


@pytest.mark.asyncio
async def test_list_workflows(client: AsyncClient, auth_headers: dict):
    """Workflows auflisten"""
    response = await client.get("/api/v1/workflows/", headers=auth_headers)
    assert response.status_code == 200


@pytest.mark.asyncio
async def test_get_tasks(client: AsyncClient, auth_headers: dict):
    """Aufgaben auflisten"""
    response = await client.get("/api/v1/workflows/tasks/", headers=auth_headers)
    assert response.status_code == 200
