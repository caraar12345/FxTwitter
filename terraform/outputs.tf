output "worker_name" {
  description = "Deployed Cloudflare Worker script name."
  value       = cloudflare_worker_script.fxtwitter.script_name
}

output "worker_routes" {
  description = "Map of created worker route patterns to their IDs."
  value = {
    for k, v in cloudflare_worker_route.routes : k => v.id
  }
}
