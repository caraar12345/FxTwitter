terraform {
  required_version = ">= 1.5"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# ---------------------------------------------------------------------------
# Build the worker bundle before deployment
# ---------------------------------------------------------------------------

resource "null_resource" "build" {
  triggers = {
    # Re-build whenever any source file changes
    src_hash = sha1(join("", [
      for f in fileset("${path.module}/../src", "**") :
      filesha1("${path.module}/../src/${f}")
    ]))
    package_hash = filesha1("${path.module}/../package.json")
  }

  provisioner "local-exec" {
    command     = "npm ci && npm run build"
    working_dir = "${path.module}/.."
  }
}

data "local_file" "worker_script" {
  filename   = "${path.module}/../dist/worker.js"
  depends_on = [null_resource.build]
}

# ---------------------------------------------------------------------------
# Cloudflare Worker
# ---------------------------------------------------------------------------

resource "cloudflare_worker_script" "fxtwitter" {
  account_id = var.cloudflare_account_id
  script_name = var.worker_name
  content    = data.local_file.worker_script.content
  module     = true

  compatibility_date  = "2024-11-14"
  compatibility_flags = []

  # --- Service binding (Twitter account proxy via elongator) ---------------
  # Remove this block if you are not using elongator.
  service_binding {
    name        = "TwitterProxy"
    service     = var.elongator_service_name
    environment = "production"
  }

  # --- Analytics Engine binding ---------------------------------------------
  # Remove this block if you are not using Cloudflare Analytics Engine.
  analytics_engine_binding {
    name    = "AnalyticsEngine"
    dataset = var.analytics_engine_dataset
  }

  # --- Workers AI binding --------------------------------------------------
  # Required for AI-powered translation features.
  ai_binding {
    name = "AI"
  }

  # --- Plain-text environment variables ------------------------------------

  plain_text_binding {
    name = "STANDARD_DOMAIN_LIST"
    text = var.standard_domain_list
  }

  plain_text_binding {
    name = "STANDARD_BSKY_DOMAIN_LIST"
    text = var.standard_bsky_domain_list
  }

  plain_text_binding {
    name = "STANDARD_TIKTOK_DOMAIN_LIST"
    text = var.standard_tiktok_domain_list
  }

  plain_text_binding {
    name = "DIRECT_MEDIA_DOMAINS"
    text = var.direct_media_domains
  }

  plain_text_binding {
    name = "TEXT_ONLY_DOMAINS"
    text = var.text_only_domains
  }

  plain_text_binding {
    name = "INSTANT_VIEW_DOMAINS"
    text = var.instant_view_domains
  }

  plain_text_binding {
    name = "GALLERY_DOMAINS"
    text = var.gallery_domains
  }

  plain_text_binding {
    name = "FORCE_MOSAIC_DOMAINS"
    text = var.force_mosaic_domains
  }

  plain_text_binding {
    name = "OLD_EMBED_DOMAINS"
    text = var.old_embed_domains
  }

  plain_text_binding {
    name = "MOSAIC_DOMAIN_LIST"
    text = var.mosaic_domain_list
  }

  plain_text_binding {
    name = "MOSAIC_BSKY_DOMAIN_LIST"
    text = var.mosaic_bsky_domain_list
  }

  plain_text_binding {
    name = "GIF_TRANSCODE_DOMAIN_LIST"
    text = var.gif_transcode_domain_list
  }

  plain_text_binding {
    name = "VIDEO_TRANSCODE_DOMAIN_LIST"
    text = var.video_transcode_domain_list
  }

  plain_text_binding {
    name = "VIDEO_TRANSCODE_BSKY_DOMAIN_LIST"
    text = var.video_transcode_bsky_domain_list
  }

  plain_text_binding {
    name = "POLYGLOT_DOMAIN_LIST"
    text = var.polyglot_domain_list
  }

  plain_text_binding {
    name = "API_HOST_LIST"
    text = var.api_host_list
  }

  plain_text_binding {
    name = "TWITTER_ROOT"
    text = var.twitter_root
  }

  plain_text_binding {
    name = "QUIET_DOMAINS"
    text = var.quiet_domains
  }

  plain_text_binding {
    name = "MEDIA_PROXY_DOMAIN_LIST"
    text = var.media_proxy_domain_list
  }

  # --- Secret bindings (sensitive values) ----------------------------------

  secret_text_binding {
    name = "POLYGLOT_ACCESS_TOKEN"
    text = var.polyglot_access_token
  }

  secret_text_binding {
    name = "SENTRY_DSN"
    text = var.sentry_dsn
  }

  secret_text_binding {
    name = "SENTRY_AUTH_TOKEN"
    text = var.sentry_auth_token
  }

  secret_text_binding {
    name = "SENTRY_ORG"
    text = var.sentry_org
  }

  secret_text_binding {
    name = "SENTRY_PROJECT"
    text = var.sentry_project
  }
}

# ---------------------------------------------------------------------------
# Custom domain routes
# All domains listed here must belong to zones in your Cloudflare account.
# ---------------------------------------------------------------------------

locals {
  # Map of pattern → zone_id for all domains the worker should handle.
  # Add or remove entries to match your actual zone setup.
  worker_routes = {
    for entry in var.worker_routes :
    entry.pattern => entry
  }
}

resource "cloudflare_worker_route" "routes" {
  for_each = local.worker_routes

  zone_id     = each.value.zone_id
  pattern     = each.value.pattern
  script_name = cloudflare_worker_script.fxtwitter.script_name
}
