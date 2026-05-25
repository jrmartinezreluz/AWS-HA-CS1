# Architecture diagrams

Visual reference for the **AWS-HA-CS1** lab: VPC networking, load-balanced web tier, Multi-AZ RDS, monitoring, and Ansible over SSM.

---

## AWS infrastructure (Terraform)

```mermaid
flowchart TB
    subgraph Internet
        Users[Users / Browsers]
        Admin[Admin — Ansible / AWS CLI]
    end

    subgraph VPC["VPC 10.0.0.0/16"]
        IGW[Internet Gateway]
        NAT[NAT Gateway]

        subgraph AZa["us-east-1a"]
            PUB1["Public subnet<br/>10.0.1.0/24"]
            PRIV1["Private subnet<br/>10.0.3.0/24"]
        end

        subgraph AZb["us-east-1b"]
            PUB2["Public subnet<br/>10.0.2.0/24"]
            PRIV2["Private subnet<br/>10.0.4.0/24"]
        end

        ALB[Application Load Balancer<br/>HTTP :80]
        ASG[Auto Scaling Group<br/>2–3 × EC2 Amazon Linux 2023]
        RDS[(RDS MySQL<br/>Multi-AZ)]
        CW[CloudWatch<br/>CPU alarm on ASG]
    end

    Users -->|HTTP :80| IGW
    IGW --> ALB
    ALB --> PUB1 & PUB2
    ALB -->|target group| ASG
    ASG --> PRIV1 & PRIV2
    ASG -->|MySQL :3306| RDS
    RDS --> PRIV1 & PRIV2
    ASG -->|egress via NAT| NAT
    NAT --> IGW
    Admin -.->|SSM Session Manager| ASG
    CW -.->|metrics| ASG
```

| Component | Placement | Notes |
|-----------|-----------|--------|
| ALB | Public subnets (multi-AZ) | Internet-facing HTTP |
| EC2 ASG | Private subnets | `min=2`, `max=3`, `desired=2` |
| RDS | Private subnets | MySQL 8, Multi-AZ optional |
| NAT | Public subnet AZ-a | Outbound from private tier |
| CloudWatch | Regional | High CPU alarm on ASG |

---

## Security groups

```mermaid
flowchart LR
    Internet((Internet))

    subgraph alb_sg["ALB security group"]
        ALB[ALB]
    end

    subgraph ec2_sg["EC2 security group"]
        EC2[ASG instances]
    end

    subgraph rds_sg["RDS security group"]
        RDS[(RDS)]
    end

    Internet -->|:80| ALB
    ALB -->|:80| EC2
    EC2 -->|:3306| RDS
    EC2 -->|all outbound| Internet
```

- **EC2** accepts HTTP **only** from the ALB security group (not from the open internet).
- **RDS** accepts MySQL **only** from the EC2 security group.
- **Admin access** to instances is via **SSM** (IAM instance profile), not SSH from `0.0.0.0/0`.

---

## Request flow (web traffic)

```mermaid
sequenceDiagram
    participant User
    participant ALB as Application Load Balancer
    participant EC2 as EC2 instance (Nginx)
    participant RDS as RDS MySQL

    User->>ALB: GET http://alb-dns/
    ALB->>EC2: Forward :80 (healthy target)
    EC2->>User: HTML response (Ansible-deployed page)

    Note over EC2,RDS: Optional app DB usage
    EC2->>RDS: mysql :3306 (private)
    RDS->>EC2: query result
```

---

## Provisioning & operations

```mermaid
flowchart TD
    TF[Terraform apply<br/>vpc + ec2 + rds + cloudwatch] --> OUT[Outputs<br/>alb_dns_name, asg_name]
    OUT --> INV[inventory/hosts.ini<br/>instance IDs]
    INV --> BOOT[playbook bootstrap-python.yml<br/>SSM + Python 3]
    BOOT --> WEB[playbook webserver.yml<br/>Nginx + custom page]
    WEB --> VERIFY[Browser → ALB DNS<br/>mysql test from EC2]

    subgraph IAM["EC2 instance profile"]
        SSM[AmazonSSMManagedInstanceCore]
        CWA[CloudWatchAgentServerPolicy]
    end

    TF --> IAM
```

**User data** (launch template): installs `python3` and `amazon-ssm-agent` for Ansible connectivity.

---

## High availability characteristics

```mermaid
flowchart TB
    subgraph Compute_HA["Compute HA"]
        ALB2[ALB cross-AZ]
        ASG2[ASG across 2 private subnets]
        LT[Launch template + health checks ELB]
    end

    subgraph Data_HA["Data HA"]
        RDS2[RDS Multi-AZ standby]
        BK[Automated backups]
    end

    subgraph Ops["Operations"]
        MON[CloudWatch CPU alarm]
        SSM2[SSM — no bastion SSH required]
    end

    ALB2 --> ASG2 --> LT
    ASG2 --> RDS2
    RDS2 --> BK
    ASG2 --> MON
    ASG2 --> SSM2
```

---

## Repository map

```mermaid
flowchart LR
    subgraph Repo["AWS-HA-CS1"]
        DOC[docs/architecture.md]
        HA[aws/ha-arch/]
    end

    HA --> TF[terraform/]
    HA --> AN[ansible/]

    TF --> M1[modules/vpc]
    TF --> M2[modules/ec2 — ALB ASG IAM]
    TF --> M3[modules/rds]
    TF --> CW2[cloudwatch.tf]

    AN --> PB[playbooks]
    AN --> INV[inventory]
```

---

## Related paths

| Path | Content |
|------|---------|
| [README.md](../README.md) | Deployment quick start |
| `aws/ha-arch/terraform/` | Infrastructure modules |
| `aws/ha-arch/ansible/` | SSM-based configuration |
