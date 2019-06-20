resource "github_repository" "twindb_repo" {
    name               = "${var.name}"
    description        = "${var.description}"
    homepage_url       = "${var.homepage_url}"
    has_downloads      = "${var.has_downloads}"
    has_issues         = "${var.has_issues}"
    private            = "${var.private}"
    allow_rebase_merge = "${var.allow_rebase_merge}"
    allow_squash_merge = "${var.allow_squash_merge}"
}

resource "github_branch_protection" "default_branch" {
    count = "${var.has_branch_protection}"
    repository = "${github_repository.twindb_repo.name}"
    branch = "${var.default_branch}"
    enforce_admins = true

    required_status_checks = {
        strict = true
        contexts = [
            "Travis CI - Branch",
            "Travis CI - Pull Request"
        ]
    }
}

resource "github_repository_webhook" "slack" {
    events = [
        "*"
    ]
    name = "web"
    repository = "${github_repository.twindb_repo.name}"
    configuration {
        url          = "${var.slack_url}"
        content_type = "json"
        insecure_ssl = false
    }
}

resource "github_repository_webhook" "rtd" {
    count = "${var.has_documentation}"
    events = [
        "create",
        "delete",
        "push",
        "pull_request"
    ]
    name = "web"
    repository = "${github_repository.twindb_repo.name}"
    configuration {
        url          = "${var.rtd_url}"
        content_type = "json"
        insecure_ssl = false
    }
}

resource "github_repository_webhook" "travis-ci" {
    count = "${var.has_travis}"
    events = [
        "create",
        "delete",
        "issue_comment",
        "member",
        "public",
        "pull_request",
        "push",
        "repository"
    ]
    name = "web"
    repository = "${github_repository.twindb_repo.name}"
    configuration {
        url          = "https://notify.travis-ci.org"
        content_type = "form"
        insecure_ssl = false
    }
}


resource "github_repository_webhook" "registry_docker_hub" {
    count = "${var.has_docker_hub}"
    events = [
        "push"
    ]
    name = "web"
    repository = "${github_repository.twindb_repo.name}"
    configuration {
        url          = "https://registry.hub.docker.com/hooks/github"
        content_type = "json"
        insecure_ssl = false
    }
}

resource "github_repository_webhook" "cloud_docker_hub" {
    count = "${var.has_docker_hub}"
    events = [
        "pull_request",
        "push"
    ]
    name = "web"
    repository = "${github_repository.twindb_repo.name}"
    configuration {
        url          = "${var.docker_hub_url}"
        content_type = "json"
        insecure_ssl = false
    }
}
