# DigitalOcean Practical Test — Docker CI/CD

**Production:** https://192.81.212.73.sslip.io  
**QA:** https://qa.192.81.212.73.sslip.io  
**Public GitHub repository:** https://github.com/kushalpatel71/do-practical-test.git

## Architecture

- A DigitalOcean Ubuntu Droplet hosts both Docker containers.
- Caddy terminates HTTPS on ports 80/443 and routes production to localhost:8082 and QA to localhost:8081.
- Each push to `qa` triggers validation, Docker build, a push to GitHub Container Registry (GHCR), and automated deployment to the QA container.
- Each push to `main` triggers the same sequence for production.
- Failed validation, build, or image publication blocks deployment.
- Images use the Git commit SHA as the immutable tag.
- SSH connects as the non-root `deployer` account using a GitHub Actions secret; passwords and root logins are disabled.

## Promotion rule

Make and test changes on `qa`. After verifying the QA URL, merge `qa` into `main` to deploy production. Containers, bound ports, and branch deployments are separate.

## Test Evidence

Complete this section **after** successful live runs; don't claim an unverified result.

- Successful QA GitHub Actions run: PASTE_QA_RUN_URL
- Successful production GitHub Actions run: PASTE_PRODUCTION_RUN_URL
- Registry location: `ghcr.io/kushalpatel71/do-practical-test` (replace username; make the package public)
- QA deployed image/commit: PASTE_QA_SHA
- Production deployed image/commit: PASTE_PRODUCTION_SHA
- QA screenshot after changing Version 1 to Version 2: `evidence/qa.png`
- Production screenshot after promoting Version 2: `evidence/production.png`
- SSH-key login and effective settings screenshot: `evidence/ssh.png`
- Failed root/password authentication screenshot: `evidence/rejections.png`

## How CI/CD works

On pushes to `qa` or `main`, GitHub Actions checks that the HTML, Dockerfile and deployment config exist, verifies that the website contains the required version text, and checks Bash syntax. When validation passes, Buildx builds an Nginx Docker image and publishes it to GHCR using the built-in `GITHUB_TOKEN`. A separate SSH key stored in repository secrets lets the workflow connect to the non-root deployer. It logs in to GHCR with the temporary Actions token, pulls the exact commit-tagged image and restarts only the target QA or production container. Caddy automatically provisions HTTPS for both hostnames.

## Security

Use a dedicated SSH key for GitHub Actions. Public repository content contains no private keys, GitHub tokens or passwords. Effective `sshd` settings enforce `PermitRootLogin no`, `PasswordAuthentication no`, and `KbdInteractiveAuthentication no`. The server-side deployer account can manage Docker containers; Docker access is privileged and must be protected.
