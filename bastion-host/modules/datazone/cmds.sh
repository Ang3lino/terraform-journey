
alias dz='aws datazone'

aws datazone list-domains

aws datazone list-environment-blueprints --domain-identifier $DOMINIO_ID
aws datazone   list-environment-blueprint-configurations --domain-identifier $DOMINIO_ID

# aws datazone list-environment-blueprints --domain-identifier $MARK_ID
aws datazone   list-environment-blueprint-configurations --domain-identifier $MARK_ID