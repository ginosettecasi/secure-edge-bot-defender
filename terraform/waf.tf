resource "aws_wafv2_web_acl" "edge_security_acl" {
  name        = "secure-edge-acl"
  description = "Enhanced edge security WAF for bot mitigation"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "edgeSecurityACL"
    sampled_requests_enabled   = true
  }

  # Block known bad user-agents
  rule {
    name     = "block-bad-user-agents"
    priority = 0
    action {
      block {}
    }
    statement {
      byte_match_statement {
        field_to_match {
          single_header {
            name = "user-agent"
          }
        }
        positional_constraint = "CONTAINS"
        search_string         = "BadBot"
        text_transformation {
          priority = 0
          type     = "LOWERCASE"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "blockBadBots"
      sampled_requests_enabled   = true
    }
  }

  # Block requests missing Accept-Language (bots rarely send this)
  rule {
    name     = "missing-accept-language"
    priority = 1
    action {
      block {}
    }
    statement {
      not_statement {
        statement {
          byte_match_statement {
            field_to_match {
              single_header {
                name = "accept-language"
              }
            }
            positional_constraint = "EXISTS"
            search_string         = ""
            text_transformation {
              priority = 0
              type     = "LOWERCASE"
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "missingAcceptLanguage"
      sampled_requests_enabled   = true
    }
  }

  # Block countries (geo match example)
  rule {
    name     = "geo-block"
    priority = 2
    action {
      block {}
    }
    statement {
      geo_match_statement {
        country_codes = ["CN", "RU", "KP", "IR"]
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "geoBlock"
      sampled_requests_enabled   = true
    }
  }

  # Rate limit /login
  rule {
    name     = "rate-limit-login"
    priority = 3
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit              = 100
        aggregate_key_type = "IP"
        scope_down_statement {
          byte_match_statement {
            field_to_match {
              uri_path {}
            }
            positional_constraint = "STARTS_WITH"
            search_string         = "/login"
            text_transformation {
              priority = 0
              type     = "LOWERCASE"
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rateLimitLogin"
      sampled_requests_enabled   = true
    }
  }

  # Custom Header Rule - triggered by Lambda@Edge
  rule {
    name     = "block-lambda-flagged"
    priority = 4
    action {
      block {}
    }
    statement {
      byte_match_statement {
        field_to_match {
          single_header {
            name = "x-suspicious-bot"
          }
        }
        positional_constraint = "EXACTLY"
        search_string         = "true"
        text_transformation {
          priority = 0
          type     = "LOWERCASE"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "lambdaFlaggedBots"
      sampled_requests_enabled   = true
    }
  }
}
