# EC2 Module - Main Resources

# --- Security Group ---
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group for EC2 instance - allows SSH and HTTP"
  vpc_id      = var.vpc_id

  # SSH access
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

# --- AMI Data Source (Amazon Linux 2023) ---
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# --- EC2 Instance ---
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # Optional: attach a key pair for SSH access
  key_name = var.key_name != "" ? var.key_name : null

  # Re-run the bootstrap script whenever the page changes, while keeping the
  # existing instance available until the replacement is ready.
  user_data_replace_on_change = true

  lifecycle {
    create_before_destroy = true
  }

  user_data = <<-EOF
              #!/bin/bash
              set -eux

              yum update -y
              yum install -y httpd

              cat > /var/www/html/index.html <<'HTML'
              <!DOCTYPE html>
              <html lang="en">
              <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Terraform AWS DevOps Demo</title>
                <style>
                  :root {
                    --bg: #07111f;
                    --panel: #0f1d31;
                    --panel-light: #162943;
                    --text: #edf5ff;
                    --muted: #a9bad0;
                    --accent: #55d6be;
                    --accent-2: #73a7ff;
                    --border: rgba(164, 193, 225, 0.18);
                  }

                  * { box-sizing: border-box; }
                  body {
                    margin: 0;
                    color: var(--text);
                    background: radial-gradient(circle at top right, #17365a 0, var(--bg) 42%);
                    font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
                    line-height: 1.6;
                  }
                  .container { width: min(1100px, calc(100% - 40px)); margin: auto; }
                  header { padding: 76px 0 54px; }
                  .hero { display: grid; grid-template-columns: minmax(0, 1.05fr) minmax(320px, .95fr); gap: 54px; align-items: center; }
                  .hero-art { position: relative; min-height: 360px; display: grid; place-items: center; }
                  .hero-art::after { content: ""; position: absolute; width: 72%; height: 36%; bottom: 8%; border-radius: 50%; background: rgba(62, 157, 214, .16); filter: blur(35px); }
                  .hero-art img { position: relative; z-index: 1; display: block; width: 100%; max-width: 520px; border-radius: 22px; opacity: .94; box-shadow: 0 22px 70px rgba(0, 0, 0, .36); }
                  .eyebrow {
                    color: var(--accent);
                    font-size: .78rem;
                    font-weight: 800;
                    letter-spacing: .16em;
                    text-transform: uppercase;
                  }
                  h1 { max-width: 780px; margin: 14px 0 18px; font-size: clamp(2.4rem, 6vw, 4.7rem); line-height: 1.04; letter-spacing: -.055em; }
                  .intro { max-width: 720px; color: var(--muted); font-size: 1.12rem; }
                  .status { display: inline-flex; align-items: center; gap: 9px; margin-top: 20px; padding: 9px 14px; border: 1px solid rgba(85, 214, 190, .35); border-radius: 999px; color: #c8fff4; background: rgba(85, 214, 190, .09); font-size: .9rem; }
                  .dot { width: 9px; height: 9px; border-radius: 50%; background: var(--accent); box-shadow: 0 0 14px var(--accent); }
                  .note { max-width: 820px; margin-top: 30px; padding: 18px 20px; border-left: 3px solid var(--accent); color: var(--muted); background: rgba(15, 29, 49, .72); }
                  .note strong { display: block; margin-bottom: 4px; color: var(--text); }
                  .note p { margin: 0; }
                  section { padding: 26px 0 48px; }
                  h2 { margin: 0 0 22px; font-size: 1.7rem; letter-spacing: -.03em; }
                  .architecture { display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; align-items: stretch; }
                  .architecture .arrow { display: grid; place-items: center; color: var(--accent); font-size: 1.6rem; }
                  .card { padding: 22px; border: 1px solid var(--border); border-radius: 18px; background: linear-gradient(145deg, rgba(22, 41, 67, .94), rgba(15, 29, 49, .94)); box-shadow: 0 18px 50px rgba(0, 0, 0, .16); }
                  .card h3 { margin: 0 0 6px; font-size: 1.05rem; }
                  .card p { margin: 0; color: var(--muted); font-size: .93rem; }
                  .grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; }
                  .tag { display: inline-block; margin: 4px 4px 0 0; padding: 6px 10px; border: 1px solid rgba(115, 167, 255, .3); border-radius: 999px; color: #cfe0ff; background: rgba(115, 167, 255, .09); font-size: .82rem; }
                  .details { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
                  .detail { padding: 18px 20px; border-left: 3px solid var(--accent-2); background: rgba(15, 29, 49, .72); }
                  .detail strong { display: block; margin-bottom: 4px; }
                  .detail span { color: var(--muted); }
                  footer { padding: 28px 0 52px; color: var(--muted); font-size: .9rem; }
                  @media (max-width: 760px) {
                    .architecture, .grid, .details { grid-template-columns: 1fr; }
                    .architecture .arrow { transform: rotate(90deg); padding: 0; }
                    header { padding-top: 52px; }
                    .hero { grid-template-columns: 1fr; gap: 30px; }
                    .hero-art { min-height: auto; order: -1; }
                  }
                </style>
              </head>
              <body>
                <header>
                  <div class="container">
                    <div class="hero">
                      <div>
                        <div class="eyebrow">A hands-on AWS + Terraform project</div>
                        <h1>I built this small AWS environment to learn by doing.</h1>
                        <p class="intro">This started as a simple goal: provision a web server without clicking through the AWS console. The result is a modular Terraform project with remote state and a GitHub Actions workflow.</p>
                        <div class="status"><span class="dot"></span>Live now · Apache is serving this page</div>
                        <div class="note"><strong>Why I built it</strong><p>I wanted to understand what happens between a code change and a running server. Every part of this demo—from the VPC and routing to the EC2 bootstrap script—is defined in the repository.</p></div>
                      </div>
                      <div class="hero-art"><img src="https://raw.githubusercontent.com/Harshu9671/terraform-aws-devops/main/assets/devops-infrastructure-hero.jpg" alt="Illustration of a laptop, cloud infrastructure, servers, and a deployment pipeline"></div>
                    </div>
                  </div>
                </header>

                <main class="container">
                  <section>
                    <h2>How a change gets here</h2>
                    <div class="architecture">
                      <div class="card"><h3>1. I push code</h3><p>Changes start in GitHub, where the workflow is triggered.</p></div>
                      <div class="arrow">→</div>
                      <div class="card"><h3>2. Terraform checks it</h3><p>Format, validate, plan, and review the infrastructure change.</p></div>
                      <div class="arrow">→</div>
                      <div class="card"><h3>3. AWS runs it</h3><p>The approved configuration becomes real networking and compute.</p></div>
                    </div>
                  </section>

                  <section>
                    <h2>Tools I used</h2>
                    <div class="card">
                      <span class="tag">AWS</span><span class="tag">Terraform</span><span class="tag">HCL</span><span class="tag">GitHub Actions</span><span class="tag">Amazon VPC</span><span class="tag">Amazon EC2</span><span class="tag">Amazon S3</span><span class="tag">Amazon Linux 2023</span><span class="tag">Apache HTTP Server</span><span class="tag">Git</span><span class="tag">Linux</span><span class="tag">AWS CLI</span>
                    </div>
                  </section>

                  <section>
                    <h2>What is actually running</h2>
                    <div class="grid">
                      <div class="card"><h3>Networking</h3><p>A custom VPC, public subnet, Internet Gateway, route table, and route association.</p></div>
                      <div class="card"><h3>Web server</h3><p>An Amazon Linux 2023 EC2 instance installs Apache during its first boot and serves this page.</p></div>
                      <div class="card"><h3>Remote state</h3><p>Terraform state is encrypted and stored in S3 so the infrastructure has one shared source of truth.</p></div>
                    </div>
                  </section>

                  <section>
                    <h2>A few honest details</h2>
                    <div class="details">
                      <div class="detail"><strong>Workflow</strong><span>Pull request → format → validate → plan → review → apply</span></div>
                      <div class="detail"><strong>Terraform structure</strong><span>A root module connects separate networking and EC2 modules.</span></div>
                      <div class="detail"><strong>What I learned</strong><span>How remote state, dependencies, outputs, and bootstrap scripts fit together.</span></div>
                      <div class="detail"><strong>Next improvement</strong><span>Move from access keys to GitHub OIDC and tighten public SSH access.</span></div>
                    </div>
                  </section>
                </main>

                <footer>
                  <div class="container">Built as a hands-on learning project · Provisioned with Terraform · Running on AWS</div>
                </footer>
              </body>
              </html>
              HTML

              systemctl enable --now httpd
              EOF

  tags = {
    Name = "${var.project_name}-web-server"
  }
}
