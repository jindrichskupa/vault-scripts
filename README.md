# Useful vault scripts

* gitlab2vault.rb
  * converts Gitlab ENV variables and save them into vault
* vault2dotenv.rb
  * read vault kv and save it into `.env` file
* vault2secret.rb
  * read vault kv and save it into kubernetes secrets file
* files2vault.rb
  * save all files from local directory into vault key

## Usage

### Dependencies

```bash
gem install vault gitlab
```

### Command - gitlab2vault.rb

```bash
Usage: gitlab2vault.rb [options]
    -p, --project PROJECT_ID         Gitlab project
    -r, --group GROUP_ID             Gitlab group
    -x, --old-prefix OLD_PREFIX      Old prefix
    -y, --new-prefix NEW_PREFIX      New prefix
    -k, --key-value KEY_VALUE_PATH   Vault secret path
    -g, --gitlab GITLAB_URL          Gitlab API URL
    -q, --gitlab-token GITLAB_TOKEN  Gitlab token
    -v, --vault VAULT_URL            Vault URL
    -u, --vault-token VAULT_TOKEN    Vault token
```

Use only `--project` or `--group`. Old or new prefixes are optional.

### Example gitlab2vault.rb

```bash
./gitlab2vault.rb -r 43 \
  --gitlab https://gitlab.example.com/api/v4 \
  --gitlab-token xxx-xxx-xxx \
  --vault https://vault.example.com \
  --vault-token s.xXxXxXxX \
  --key-value kv/data/data/vault-secrets-demo/master/envs \
  --old-prefix ENV_MASTER_ \
  --new-prefix "SECRET_"
```

### Command - vault2dotenv.rb

```bash
Usage: vault2dotenv.rb [options]
    -k, --key-value KEYVALUEPATH     Vault secret path
    -e, --dot-env DOTFILE            .env file
    -v, --vault VAULTURL             Vault URL
    -u, --vault-token VAULTTOKEN     Vault token
        --export                     Export style .nev
```

### Example - vault2dotenv.rb

```bash
./vault2dotnev.rb --vault https://vault.example.com \
  --vault-token s.xWxWxWxWxW \
  --key-value kv/data/data/vault-secrets-demo/master/envs \
  --dot-env .env \
  --export
```

### Command - vault2secret.rb

```
Usage: vault2secret.rb [options]
    -k, --key-value KEYVALUEPATH     Vault secret path
    -f, --file FILE                  Ouput file
    -v, --vault VAULTURL             Vault URL
    -u, --vault-token VAULTTOKEN     Vault token
    -n, --name NAME                  Secret name
    -m, --namespace NAMESPACE        Secret namespace
    -b, --base64                     Vault values are Base64 encoded
```

### Example - vault2secret.rb

```bash
./vault2secret.rb --vault https://vault.example.com \
   --vault-token s.xWxWxWxWxW \
   --key-value kv/data/data/vault-secrets-demo/master/envs \
   --file secret.yml \
   --name env \
   --namespace master
# or 
./vault2secret.rb --vault https://vault.example.com \
   --vault-token s.xWxWxWxWxW \
   --key-value kv/data/data/vault-secrets-demo/master/files \
   --file secret.yml \
   --name env \
   --namespace master \
   --base64
```

### Command - files2vault.rb

```bash
Usage: files2vault.rb [options]
    -k, --key-value KEYVALUEPATH     Vault secret path
    -v, --vault VAULTURL             Vault URL
    -u, --vault-token VAULTTOKEN     Vault token
    -d, --directory DIR              Directory
```

### Example - files2vault.rb

```
./files2vault.rb --vault https://vault.example.com \
   --vault-token s.xWxWxWxWxW \
   --key-value kv/data/data/vault-secrets-demo/master/files \
   --directory certs
```
