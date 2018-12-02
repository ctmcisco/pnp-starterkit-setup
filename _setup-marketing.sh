siteUrl=$tenantUrl/sites/$(echo $prefix)marketing
alias=$(echo $prefix)marketing
msg "Provisioning marketing site at $siteUrl..."
site=$(o365 spo site get --url $siteUrl --output json || true)
if $(isError "$site"); then
  o365 spo site add --type TeamSite --url $siteUrl --title Marketing --alias $alias >/dev/null
  success 'DONE'
else
  warning 'EXISTS'
fi

sub '- Connecting to the hub site...'
o365 spo hubsite connect --url $siteUrl --hubSiteId $hubsiteId
success 'DONE'

sub '- Applying theme...'
o365 spo theme apply --name "$company Marketing" --webUrl $siteUrl >/dev/null
success 'DONE'

setupExtensions $siteUrl

sub '- Setting logo...'
groupId=$(o365 graph o365group list --mailNickname $alias -o json | jq -r '.[] | select(.mailNickname == "'"$alias"'") | .id')
if [ -z "$groupId" ]; then
  error 'ERROR'
  error "Office 365 Group '$alias' not found"
  exit 1
fi
o365 graph o365group set --id $groupId --logoPath ./resources/images/logo_marketing.png
success 'DONE'

success 'DONE'
echo