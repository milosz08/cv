# CV

Source code of my CV, build with LaTeX. Automatically build & deploying into Google Cloud Storage bucket. Bot
protection with GCP serverless function and Cloudflare worker (with Cloudflare challenge page).

## Commands

```json
$ make build            // build all LaTeX sources
$ make watch-[lang]     // run LaTeX dev mode for specific language, ex. watch-pl, watch-en
$ make watch            // run LaTeX dev mode for all languages
$ make clean            // remove LaTeX compiled files

$ make infra-init       // initialize terraform GCP infra
$ make infra-plan       // prepare terraform GCP infra
$ make infra-apply      // deploy and apply terraform GCP infra
$ make infra-url        // print serverless function URL

$ make generate-worker  // generate Cloudflare worker from template
```

## Author

Created by Miłosz Gilga. If you have any questions about this project, send message:
[miloszgilga@gmail.com](mailto:miloszgilga@gmail.com).

## License

The source code of this project (LaTeX files, engines, build scripts) is licensed under the GNU General Public License
v3.0.

All personal data and content within the CV (including personal information, professional history, and project
descriptions) are the intellectual property of the repository owner. This license applies only to the underlying source
code and formatting engine. The actual content of the resume is NOT under the GPL and may not be reused or redistributed
without explicit permission.
