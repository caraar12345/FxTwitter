# ---------------------------------------------------------------------------
# Authentication & account
# ---------------------------------------------------------------------------

variable "cloudflare_api_token" {
  description = "Cloudflare API token with Workers:Edit, Workers Routes:Edit, and Analytics Engine:Edit permissions."
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID."
  type        = string
}

# ---------------------------------------------------------------------------
# Worker
# ---------------------------------------------------------------------------

variable "worker_name" {
  description = "Name of the Cloudflare Worker script."
  type        = string
  default     = "fixtweet"
}

variable "elongator_service_name" {
  description = "Name of the Cloudflare Worker service to use as the Twitter proxy (elongator). Remove the service_binding block in main.tf if not using this."
  type        = string
  default     = "elongator"
}

variable "analytics_engine_dataset" {
  description = "Name of the Analytics Engine dataset to bind. Remove the analytics_engine_binding block in main.tf if not using this."
  type        = string
  default     = "fixtweet"
}

# ---------------------------------------------------------------------------
# Domain lists (plain-text bindings)
# Comma-separated lists of hostnames for each worker behaviour.
# ---------------------------------------------------------------------------

variable "standard_domain_list" {
  description = "Comma-separated hostnames handled as standard Twitter embeds."
  type        = string
  default     = "fxtwitter.com,fixupx.com,twittpr.com"
}

variable "standard_bsky_domain_list" {
  description = "Comma-separated hostnames handled as standard Bluesky embeds."
  type        = string
  default     = "fxbsky.app,canary.fxbsky.app"
}

variable "standard_tiktok_domain_list" {
  description = "Comma-separated hostnames handled as standard TikTok embeds."
  type        = string
  default     = "fixtok.wuff.gay,wuff.gay,dxtiktok.com,cocktiktok.com"
}

variable "direct_media_domains" {
  description = "Comma-separated hostnames that serve direct media links."
  type        = string
  default     = "d.fxtwitter.com,dl.fxtwitter.com,d.twittpr.com,dl.twittpr.com,d.fixupx.com,d.xfixup.com,dl.fixupx.com,dl.xfixup.com"
}

variable "text_only_domains" {
  description = "Comma-separated hostnames that serve text-only embeds."
  type        = string
  default     = "t.fxtwitter.com,t.twittpr.com,t.fixupx.com"
}

variable "instant_view_domains" {
  description = "Comma-separated hostnames that serve Instant View embeds."
  type        = string
  default     = "i.fxtwitter.com,i.twittpr.com,i.fixupx.com"
}

variable "gallery_domains" {
  description = "Comma-separated hostnames that serve gallery embeds."
  type        = string
  default     = "g.fxtwitter.com,g.twittpr.com,g.fixupx.com"
}

variable "force_mosaic_domains" {
  description = "Comma-separated hostnames that force mosaic layout."
  type        = string
  default     = "m.fxtwitter.com,m.twittpr.com,m.fixupx.com"
}

variable "old_embed_domains" {
  description = "Comma-separated hostnames that use the legacy embed style."
  type        = string
  default     = "o.fxtwitter.com,o.twittpr.com,o.fixupx.com,o.fxbsky.app"
}

variable "mosaic_domain_list" {
  description = "Comma-separated hostnames for the mosaic image combiner."
  type        = string
  default     = "mosaic.fxtwitter.com"
}

variable "mosaic_bsky_domain_list" {
  description = "Comma-separated hostnames for the Bluesky mosaic image combiner."
  type        = string
  default     = "mosaic.fxbsky.app"
}

variable "gif_transcode_domain_list" {
  description = "Comma-separated hostnames that trigger GIF transcoding."
  type        = string
  default     = "gif.fxtwitter.com"
}

variable "video_transcode_domain_list" {
  description = "Comma-separated hostnames that trigger video transcoding."
  type        = string
  default     = "video.fxtwitter.com"
}

variable "video_transcode_bsky_domain_list" {
  description = "Comma-separated hostnames that trigger Bluesky video transcoding."
  type        = string
  default     = "video.fxbsky.app"
}

variable "polyglot_domain_list" {
  description = "Comma-separated hostnames for the polyglot translation service."
  type        = string
  default     = "polyglot.fxembed.com"
}

variable "api_host_list" {
  description = "Comma-separated hostnames that serve the public API."
  type        = string
  default     = "api.fxtwitter.com,api-canary.fxtwitter.com"
}

variable "twitter_root" {
  description = "Root URL for Twitter/X."
  type        = string
  default     = "https://x.com"
}

variable "quiet_domains" {
  description = "Comma-separated hostnames that suppress embed metadata (quiet mode)."
  type        = string
  default     = ""
}

variable "media_proxy_domain_list" {
  description = "Comma-separated hostnames used as media proxy endpoints."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Secrets (sensitive values)
# ---------------------------------------------------------------------------

variable "polyglot_access_token" {
  description = "Access token for the Polyglot translation service. Leave empty to disable."
  type        = string
  sensitive   = true
  default     = ""
}

variable "sentry_dsn" {
  description = "Sentry DSN for error tracking. Leave empty to disable Sentry."
  type        = string
  sensitive   = true
  default     = ""
}

variable "sentry_auth_token" {
  description = "Sentry auth token used during the build to upload source maps."
  type        = string
  sensitive   = true
  default     = ""
}

variable "sentry_org" {
  description = "Sentry organisation slug."
  type        = string
  default     = ""
}

variable "sentry_project" {
  description = "Sentry project slug."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Worker routes
# ---------------------------------------------------------------------------

variable "worker_routes" {
  description = <<-EOT
    List of Cloudflare Worker routes to create. Each entry needs:
      - pattern: the route pattern, e.g. "fxtwitter.com/*"
      - zone_id: the Cloudflare zone ID for the domain

    Example:
      worker_routes = [
        { pattern = "fxtwitter.com/*", zone_id = "abc123..." },
        { pattern = "*.fxtwitter.com/*", zone_id = "abc123..." },
      ]
  EOT
  type = list(object({
    pattern = string
    zone_id = string
  }))
  default = []
}
