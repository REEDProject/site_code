## 2.0.0 (2024-06-06)

### Feat

- add cz
- **django**: update the allowed hosts env
- **eats**: add management command to export entities
- **templates**: add basic 500 template
- **geomap**: display the coordinates in the places list
- **traefik**: update the email address for letsencrypt
- **traefik**: do not use hostregex for better integration with cert resolvers

### Fix

- **geomap**: ensure coordinates are read in the right order
- **documentparser**: remove calls to deprecated pyparsing functions
- **docker**: restore ro property for volume
- **traefik**: do not declare the dev url, as it is not available yet
