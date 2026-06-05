import base64
import hashlib
import json
import os
import time
from pathlib import Path

import requests
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives.asymmetric.utils import decode_dss_signature


API = "https://api.appstoreconnect.apple.com/v1"
APP_ID = os.environ["APP_ID"]
TARGET_VERSION = os.environ["TARGET_VERSION"]
TARGET_BUILD_NUMBER = os.environ["TARGET_BUILD_NUMBER"]
ROOT = Path.cwd()

PRIVACY_URL = "https://github.com/lanray07/ProfilePilot-AI/blob/main/PRIVACY_POLICY.md"
TERMS_URL = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"

PROMOTIONAL_TEXT = (
    "AI coaching for public sector applications, STAR examples, interviews and career confidence."
)

DESCRIPTION = """ProfilePilot AI is a premium AI career coaching app for public sector applicants and professionals.

Turn your experience into stronger applications, structured STAR examples, realistic interview answers and a clearer career roadmap.

Designed for Civil Service, NHS, Local Government and wider public sector roles, ProfilePilot AI helps you organise your evidence, practise competency answers and build confidence before each application or interview.

What you can do:
- Analyse job descriptions and identify the strongest evidence to use
- Build STAR examples for public sector competencies
- Practise mock interview questions with supportive coaching feedback
- Track applications, deadlines and interview readiness
- Create a practical roadmap for your next career move
- Use premium coaching templates for stronger, clearer answers

Subscriptions unlock expanded coaching, advanced practice, premium templates and career accelerator tools. Payment is charged to your Apple ID account at confirmation of purchase. Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period. Manage or cancel subscriptions in your App Store account settings.

ProfilePilot AI is a coaching and educational platform. It does not guarantee job interviews, job offers, promotions or recruitment outcomes.

ProfilePilot AI is not affiliated with, endorsed by or connected to any government department, the NHS or recruitment body.

Terms of Use (EULA): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

Privacy Policy: https://github.com/lanray07/ProfilePilot-AI/blob/main/PRIVACY_POLICY.md"""

KEYWORDS = "civil service,NHS,public sector,STAR,interview,career,applications,competency,success profiles"

REVIEW_NOTES = f"""Build 1.0 ({TARGET_BUILD_NUMBER}) addresses the June 05, 2026 App Review feedback.

The paywall now uses Apple's native SubscriptionStoreView for Professional Monthly, Professional Yearly, and Career Accelerator. The custom Choose Plan buttons were removed, so purchases use the StoreKit subscription controls directly on iPhone and iPad. The purchase flow includes visible Privacy Policy, Terms of Use, and Restore Purchases links.

Privacy Policy: {PRIVACY_URL}
Terms of Use: {TERMS_URL}

The App Store screenshots have been replaced with actual in-app UI screenshots for iPhone and iPad. Subscription promotional images were replaced with larger, readable subscription-specific artwork. No sign-in is required; mock AI is enabled by default for review."""

SCREENSHOT_SETS = {
    "APP_IPHONE_65": [
        "ProfilePilotAI/Resources/AppStore/iPhone-6.5-JPEG/iphone-65-01-dashboard-1242x2688.jpg",
        "ProfilePilotAI/Resources/AppStore/iPhone-6.5-JPEG/iphone-65-02-job-analyzer-1242x2688.jpg",
        "ProfilePilotAI/Resources/AppStore/iPhone-6.5-JPEG/iphone-65-03-interview-1242x2688.jpg",
        "ProfilePilotAI/Resources/AppStore/iPhone-6.5-JPEG/iphone-65-04-star-builder-1242x2688.jpg",
        "ProfilePilotAI/Resources/AppStore/iPhone-6.5-JPEG/iphone-65-05-subscriptions-1242x2688.jpg",
    ],
    "APP_IPAD_PRO_3GEN_129": [
        "ProfilePilotAI/Resources/AppStore/iPad-JPEG/ipad-01-dashboard-2048x2732.jpg",
        "ProfilePilotAI/Resources/AppStore/iPad-JPEG/ipad-02-job-analyzer-2048x2732.jpg",
        "ProfilePilotAI/Resources/AppStore/iPad-JPEG/ipad-03-interview-2048x2732.jpg",
        "ProfilePilotAI/Resources/AppStore/iPad-JPEG/ipad-04-star-builder-2048x2732.jpg",
        "ProfilePilotAI/Resources/AppStore/iPad-JPEG/ipad-05-subscriptions-2048x2732.jpg",
    ],
}

SUBSCRIPTION_ASSETS = {
    "profilepilot.professional.monthly": {
        "review": "ProfilePilotAI/Resources/Subscriptions/ReviewScreenshots/professional-monthly-review-1242x2688.jpg",
        "image": "ProfilePilotAI/Resources/Subscriptions/OptionalImages/professional-monthly-1024x1024.jpg",
        "note": "Professional Monthly uses SubscriptionStoreView and unlocks AI coaching, STAR examples and mock interviews. Mock AI is enabled by default for review.",
    },
    "profilepilot.professional.yearly": {
        "review": "ProfilePilotAI/Resources/Subscriptions/ReviewScreenshots/professional-yearly-review-1242x2688.jpg",
        "image": "ProfilePilotAI/Resources/Subscriptions/OptionalImages/professional-yearly-1024x1024.jpg",
        "note": "Professional Yearly uses SubscriptionStoreView and unlocks AI coaching, STAR examples and mock interviews for one year. Mock AI is enabled by default for review.",
    },
    "profilepilot.accelerator.monthly": {
        "review": "ProfilePilotAI/Resources/Subscriptions/ReviewScreenshots/career-accelerator-review-1242x2688.jpg",
        "image": "ProfilePilotAI/Resources/Subscriptions/OptionalImages/career-accelerator-1024x1024.jpg",
        "note": "Career Accelerator uses SubscriptionStoreView and unlocks advanced coaching, interview preparation and premium career planning. Mock AI is enabled by default for review.",
    },
}


def b64url(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode("ascii")


def make_jwt() -> str:
    key_id = os.environ["APPSTORE_KEY_ID"]
    issuer = os.environ["APPSTORE_ISSUER_ID"]
    private_key_text = os.environ["APPSTORE_PRIVATE_KEY"].replace("\\n", "\n").encode()
    private_key = serialization.load_pem_private_key(private_key_text, password=None)
    now = int(time.time())
    header = b64url(json.dumps({"alg": "ES256", "kid": key_id, "typ": "JWT"}, separators=(",", ":")).encode())
    payload = b64url(
        json.dumps(
            {"iss": issuer, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"},
            separators=(",", ":"),
        ).encode()
    )
    der_signature = private_key.sign(f"{header}.{payload}".encode(), ec.ECDSA(hashes.SHA256()))
    r, s = decode_dss_signature(der_signature)
    raw_signature = r.to_bytes(32, "big") + s.to_bytes(32, "big")
    return f"{header}.{payload}.{b64url(raw_signature)}"


class ASC:
    def __init__(self):
        self.token = make_jwt()
        self.token_time = time.time()

    def refresh(self):
        if time.time() - self.token_time > 900:
            self.token = make_jwt()
            self.token_time = time.time()

    def request(self, method, path, body=None, ok=(200, 201, 202, 204), allow_409_already_set=False):
        self.refresh()
        headers = {"Authorization": f"Bearer {self.token}", "Accept": "application/json"}
        data = None
        if body is not None:
            headers["Content-Type"] = "application/json"
            data = json.dumps(body)
        response = requests.request(method, f"{API}{path}", headers=headers, data=data, timeout=60)
        if response.status_code == 409 and allow_409_already_set and "already set" in response.text:
            return response.json() if response.text else {}
        if response.status_code not in ok:
            raise RuntimeError(f"ASC request failed: {method} {path} ({response.status_code})\n{response.text}")
        if response.status_code == 204 or not response.text:
            return {}
        return response.json()


asc = ASC()


def first_id(payload):
    data = payload.get("data") or []
    return data[0]["id"] if data else ""


def upload_asset(endpoint, resource_type, relationship_name, relationship_type, relationship_id, file_path):
    path = ROOT / file_path
    if not path.exists():
        raise FileNotFoundError(path)

    file_bytes = path.read_bytes()
    checksum = hashlib.md5(file_bytes).hexdigest()
    reservation = asc.request(
        "POST",
        endpoint,
        {
            "data": {
                "type": resource_type,
                "attributes": {"fileName": path.name, "fileSize": len(file_bytes)},
                "relationships": {
                    relationship_name: {"data": {"type": relationship_type, "id": relationship_id}}
                },
            }
        },
    )
    asset_id = reservation["data"]["id"]
    operations = reservation["data"]["attributes"]["uploadOperations"]
    for operation in operations:
        offset = int(operation["offset"])
        length = int(operation["length"])
        headers = {header["name"]: header["value"] for header in operation.get("requestHeaders", [])}
        chunk = file_bytes[offset : offset + length]
        upload_response = requests.request(
            operation["method"], operation["url"], headers=headers, data=chunk, timeout=120
        )
        if upload_response.status_code not in (200, 201, 202):
            raise RuntimeError(
                f"Asset upload failed for {file_path} part {offset}-{offset + length}: "
                f"{upload_response.status_code}\n{upload_response.text}"
            )

    asc.request(
        "PATCH",
        f"{endpoint}/{asset_id}",
        {
            "data": {
                "type": resource_type,
                "id": asset_id,
                "attributes": {"uploaded": True, "sourceFileChecksum": checksum},
            }
        },
    )
    print(f"Uploaded {file_path} -> {resource_type} {asset_id}")
    return asset_id


def wait_for_build():
    for attempt in range(1, 41):
        payload = asc.request(
            "GET",
            f"/builds?filter%5Bapp%5D={APP_ID}&filter%5Bversion%5D={TARGET_BUILD_NUMBER}&sort=-uploadedDate&limit=10",
        )
        states = [(item["id"], item["attributes"].get("processingState")) for item in payload.get("data", [])]
        valid = [item for item in payload.get("data", []) if item["attributes"].get("processingState") == "VALID"]
        if valid:
            print(f"Found valid build {TARGET_BUILD_NUMBER}: {valid[0]['id']}")
            return valid[0]["id"]
        print(f"Build {TARGET_BUILD_NUMBER} not valid yet, attempt {attempt}/40. States: {states}")
        time.sleep(60)
    raise RuntimeError(f"Could not find valid build {TARGET_BUILD_NUMBER}.")


def version_and_localization():
    version_payload = asc.request(
        "GET",
        f"/apps/{APP_ID}/appStoreVersions?filter%5Bplatform%5D=IOS&filter%5BversionString%5D={TARGET_VERSION}&limit=10",
    )
    version_id = first_id(version_payload)
    if not version_id:
        raise RuntimeError(f"Could not find iOS app version {TARGET_VERSION}.")

    loc_payload = asc.request("GET", f"/appStoreVersions/{version_id}/appStoreVersionLocalizations?limit=200")
    localizations = loc_payload.get("data", [])
    localization = next(
        (item for item in localizations if item["attributes"].get("locale") in ("en-GB", "en-UK")), None
    ) or (localizations[0] if localizations else None)
    if not localization:
        raise RuntimeError("Could not find an App Store version localization.")

    print(f"Version ID: {version_id}; localization ID: {localization['id']}")
    return version_id, localization["id"]


def update_version_metadata(localization_id):
    asc.request(
        "PATCH",
        f"/appStoreVersionLocalizations/{localization_id}",
        {
            "data": {
                "type": "appStoreVersionLocalizations",
                "id": localization_id,
                "attributes": {
                    "promotionalText": PROMOTIONAL_TEXT,
                    "description": DESCRIPTION,
                    "keywords": KEYWORDS,
                    "supportUrl": PRIVACY_URL,
                    "marketingUrl": "https://github.com/lanray07/ProfilePilot-AI",
                },
            }
        },
    )
    print("Updated app version localization metadata.")


def replace_screenshots(localization_id):
    existing_sets = asc.request(
        "GET", f"/appStoreVersionLocalizations/{localization_id}/appScreenshotSets?limit=200"
    )
    for item in existing_sets.get("data", []):
        display_type = item["attributes"].get("screenshotDisplayType")
        if display_type in SCREENSHOT_SETS:
            asc.request("DELETE", f"/appScreenshotSets/{item['id']}", ok=(204,))
            print(f"Deleted screenshot set {display_type}: {item['id']}")

    for display_type, files in SCREENSHOT_SETS.items():
        created = asc.request(
            "POST",
            "/appScreenshotSets",
            {
                "data": {
                    "type": "appScreenshotSets",
                    "attributes": {"screenshotDisplayType": display_type},
                    "relationships": {
                        "appStoreVersionLocalization": {
                            "data": {"type": "appStoreVersionLocalizations", "id": localization_id}
                        }
                    },
                }
            },
        )
        set_id = created["data"]["id"]
        print(f"Created screenshot set {display_type}: {set_id}")
        for file_path in files:
            upload_asset("/appScreenshots", "appScreenshots", "appScreenshotSet", "appScreenshotSets", set_id, file_path)


def subscription_ids_by_product_id():
    group_relationships = asc.request("GET", f"/apps/{APP_ID}/relationships/subscriptionGroups?limit=200")
    group_ids = [item["id"] for item in group_relationships.get("data", [])]
    found = {}
    for group_id in group_ids:
        for product_id in SUBSCRIPTION_ASSETS:
            if product_id in found:
                continue
            payload = asc.request(
                "GET",
                f"/subscriptionGroups/{group_id}/subscriptions?filter%5BproductId%5D={product_id}&limit=10",
            )
            sub_id = first_id(payload)
            if sub_id:
                found[product_id] = sub_id
                print(f"Found subscription {product_id}: {sub_id}")
    missing = sorted(set(SUBSCRIPTION_ASSETS) - set(found))
    if missing:
        raise RuntimeError(f"Missing subscription IDs for: {', '.join(missing)}")
    return found


def delete_included(payload, resource_type, endpoint):
    for item in payload.get("included", []) or []:
        if item.get("type") == resource_type:
            asc.request("DELETE", f"{endpoint}/{item['id']}", ok=(204,))
            print(f"Deleted {resource_type}: {item['id']}")


def replace_subscription_assets():
    for product_id, subscription_id in subscription_ids_by_product_id().items():
        config = SUBSCRIPTION_ASSETS[product_id]
        asc.request(
            "PATCH",
            f"/subscriptions/{subscription_id}",
            {
                "data": {
                    "type": "subscriptions",
                    "id": subscription_id,
                    "attributes": {"reviewNote": config["note"]},
                }
            },
        )

        current = asc.request(
            "GET",
            f"/subscriptions/{subscription_id}?include=appStoreReviewScreenshot,images&limit%5Bimages%5D=10",
        )
        delete_included(current, "subscriptionAppStoreReviewScreenshots", "/subscriptionAppStoreReviewScreenshots")
        delete_included(current, "subscriptionImages", "/subscriptionImages")

        upload_asset(
            "/subscriptionAppStoreReviewScreenshots",
            "subscriptionAppStoreReviewScreenshots",
            "subscription",
            "subscriptions",
            subscription_id,
            config["review"],
        )
        upload_asset(
            "/subscriptionImages",
            "subscriptionImages",
            "subscription",
            "subscriptions",
            subscription_id,
            config["image"],
        )


def attach_build_and_review_notes(version_id, build_id):
    asc.request(
        "PATCH",
        f"/builds/{build_id}",
        {"data": {"type": "builds", "id": build_id, "attributes": {"usesNonExemptEncryption": False}}},
        allow_409_already_set=True,
    )
    asc.request(
        "PATCH",
        f"/appStoreVersions/{version_id}/relationships/build",
        {"data": {"type": "builds", "id": build_id}},
    )
    detail = asc.request("GET", f"/appStoreVersions/{version_id}/appStoreReviewDetail")
    detail_id = detail["data"]["id"]
    asc.request(
        "PATCH",
        f"/appStoreReviewDetails/{detail_id}",
        {
            "data": {
                "type": "appStoreReviewDetails",
                "id": detail_id,
                "attributes": {"notes": REVIEW_NOTES},
            }
        },
    )
    print("Attached build and updated App Review notes.")


def submit_with_retry(version_id):
    submission_id = create_review_submission(version_id)
    if not add_review_submission_item(submission_id, version_id):
        submission_id = find_existing_review_submission_for_version(version_id)
        if not submission_id:
            raise RuntimeError("The app version is already in another submission, but that submission was not found.")

    body = {
        "data": {
            "type": "reviewSubmissions",
            "id": submission_id,
            "attributes": {"submitted": True},
        }
    }
    for attempt in range(1, 16):
        try:
            asc.request("PATCH", f"/reviewSubmissions/{submission_id}", body)
            print(f"Submitted ProfilePilot AI {TARGET_VERSION} build {TARGET_BUILD_NUMBER} for App Review.")
            return
        except RuntimeError as error:
            message = str(error)
            if "409" in message and ("try again later" in message or "in progress" in message):
                print(f"Submission not ready yet, retry {attempt}/15 after 60 seconds.")
                print(message)
                time.sleep(60)
                continue
            raise
    raise RuntimeError("App Store version did not become ready for submission.")


def create_review_submission(version_id):
    body = {
        "data": {
            "type": "reviewSubmissions",
            "attributes": {"platform": "IOS"},
            "relationships": {
                "app": {"data": {"type": "apps", "id": APP_ID}},
                "appStoreVersionForReview": {
                    "data": {"type": "appStoreVersions", "id": version_id}
                },
            },
        }
    }
    try:
        created = asc.request("POST", "/reviewSubmissions", body)
        submission_id = created["data"]["id"]
        print(f"Created review submission: {submission_id}")
        return submission_id
    except RuntimeError as error:
        if "409" not in str(error):
            raise

    existing_id = find_existing_review_submission_for_version(version_id)
    if existing_id:
        print(f"Using existing review submission for version {version_id}: {existing_id}")
        return existing_id

    submissions = asc.request("GET", f"/apps/{APP_ID}/reviewSubmissions?limit=20")
    for item in submissions.get("data", []):
        state = item.get("attributes", {}).get("state")
        print(f"Existing review submission {item['id']} has state {state}")
    raise RuntimeError("Could not create or find a review submission for this app version.")


def find_existing_review_submission_for_version(version_id):
    submissions = asc.request(
        "GET",
        f"/apps/{APP_ID}/reviewSubmissions?include=appStoreVersionForReview,items&limit=20",
    )
    included = {item["id"]: item for item in submissions.get("included", []) or []}
    for item in submissions.get("data", []):
        state = item.get("attributes", {}).get("state")
        relationship = item.get("relationships", {}).get("appStoreVersionForReview", {}).get("data")
        relationship_id = relationship.get("id") if relationship else ""
        print(f"Review submission {item['id']} state={state} appStoreVersionForReview={relationship_id}")
        if relationship_id == version_id and state in {"READY_FOR_REVIEW", "UNRESOLVED_ISSUES"}:
            return item["id"]

        for item_ref in item.get("relationships", {}).get("items", {}).get("data", []) or []:
            submission_item = included.get(item_ref["id"], {})
            version_ref = submission_item.get("relationships", {}).get("appStoreVersion", {}).get("data")
            if version_ref and version_ref.get("id") == version_id and state in {"READY_FOR_REVIEW", "UNRESOLVED_ISSUES"}:
                return item["id"]
    return ""


def add_review_submission_item(submission_id, version_id):
    body = {
        "data": {
            "type": "reviewSubmissionItems",
            "relationships": {
                "reviewSubmission": {"data": {"type": "reviewSubmissions", "id": submission_id}},
                "appStoreVersion": {"data": {"type": "appStoreVersions", "id": version_id}},
            },
        }
    }
    try:
        item = asc.request("POST", "/reviewSubmissionItems", body)
        print(f"Added app version to review submission: {item['data']['id']}")
        return True
    except RuntimeError as error:
        message = str(error).lower()
        if "409" in str(error) and ("already" in message or "exists" in message):
            print("App version is already present in the review submission.")
            return False
        if "409" in str(error) and "does not allow adding more items" in message:
            print("Review submission already has its fixed item set; continuing to submit.")
            return True
        raise


def main():
    build_id = wait_for_build()
    version_id, localization_id = version_and_localization()
    if os.environ.get("SKIP_ASSET_REFRESH", "").lower() == "true":
        print("Skipping asset refresh; using existing App Store Connect metadata and media.")
    else:
        update_version_metadata(localization_id)
        replace_screenshots(localization_id)
        replace_subscription_assets()
    attach_build_and_review_notes(version_id, build_id)
    submit_with_retry(version_id)


if __name__ == "__main__":
    main()
