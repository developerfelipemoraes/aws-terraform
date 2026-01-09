# 🏗️ POC: SQS + KMS + Lambda & ECS Consumer

Este repositório contém uma infraestrutura completa na AWS provisionada via **Terraform** (Infrastructure as Code). A solução simula um cenário real de processamento de mensagens com segurança (criptografia) e escalabilidade.

## 🏛️ Arquitetura da Solução

A arquitetura é modular e composta pelos seguintes componentes principais:

1.  **SQS (Simple Queue Service):**
    *   Duas filas principais: `fila-a` e `fila-b`.
    *   Ambas as filas são criptografadas utilizando uma chave KMS gerenciada pelo cliente (CMK).
2.  **KMS (Key Management Service):**
    *   Uma chave simétrica dedicada para criptografar as mensagens em repouso nas filas SQS.
3.  **Lambda Consumer (Python):**
    *   Responsável por processar mensagens da `fila-a`.
    *   Arquitetura *Event-Driven* (acionada por eventos).
    *   Possui permissão para descriptografar (KMS) e ler/deletar mensagens.
4.  **ECS Consumer (Fargate):**
    *   Responsável por processar mensagens da `fila-b`.
    *   Executa um container Docker em cluster ECS/Fargate.
5.  **Networking & IAM:**
    *   VPC, Subnets e Security Groups configurados.
    *   Roles de IAM com princípio de privilégio mínimo.

---

## 🚀 Detalhes da Implementação: Lambda Consumer

O Lambda foi criado para substituir um script de polling tradicional por uma abordagem moderna e sem servidor (*serverless*).

### Como o Lambda foi "atrelado" à Fila A?

A conexão entre a **Fila A** e o **Lambda** acontece em duas pontas, configuradas no Terraform:

1.  **O Gatilho (Event Source Mapping):**
    *   No arquivo `modules/lambda-consumer/main.tf`, utilizamos o recurso `aws_lambda_event_source_mapping`.
    *   Ele diz à AWS: *"Sempre que chegar mensagem na fila X, chame essa função Lambda"*.
    *   O endereço da fila (`queue_arn`) é passado do módulo raiz (`main.tf`) para dentro do módulo do Lambda.

2.  **A Permissão (IAM Role):**
    *   O Lambda possui uma Role que permite as ações `sqs:ReceiveMessage`, `sqs:DeleteMessage` e `sqs:GetQueueAttributes` **especificamente** no ARN da `fila-a`.
    *   Também possui permissão `kms:Decrypt` na chave KMS compartilhada, caso contrário, não conseguiria ler o conteúdo criptografado da mensagem.

### Trecho de Código Explicativo

**No `main.tf` (Raiz):**
Aqui nós "conectamos" os módulos. Pegamos a saída do módulo `fila_a` e passamos como entrada para o `lambda_consumer`.

```hcl
module "lambda_consumer" {
  source       = "./modules/lambda-consumer"
  project_name = "poc-lambda-consumer-fila-a"

  # AQUI ESTÁ A MÁGICA:
  # Pegamos o ARN (identificador único) da Fila A e passamos para o Lambda
  queue_arn    = module.fila_a.queue_arn

  kms_key_arn  = module.kms.key_arn
}
```

**No `modules/lambda-consumer/main.tf`:**
Aqui o Lambda usa esse endereço para criar o gatilho.

```hcl
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = var.queue_arn  # <--- O Lambda escuta este endereço
  function_name    = aws_lambda_function.this.arn
  batch_size       = 5
}
```

---

## 🐍 O Código Python (Lambda Handler)

O código original (loop infinito) foi adaptado para o modelo do Lambda:

*   **Original:** `while True` -> `sqs.receive_message()` -> processa -> dorme.
*   **Lambda:** A AWS invoca a função passando um objeto `event` contendo um lote de mensagens (`Records`). O código apenas itera sobre essa lista e processa.

---

## 🛠️ Como implantar (Deploy)

Certifique-se de ter o Terraform instalado e credenciais AWS configuradas.

1.  **Inicializar:**
    ```bash
    terraform init
    ```
2.  **Planejar (Verificar mudanças):**
    ```bash
    terraform plan
    ```
3.  **Aplicar (Criar infraestrutura):**
    ```bash
    terraform apply -auto-approve
    ```

---


