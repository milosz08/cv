const { Storage } = require('@google-cloud/storage');
const storage = new Storage();

const BUCKET_NAME = process.env.CV_BUCKET_NAME;
const FALLBACK_LANG = 'en';

exports.serveCV = async (req, res) => {
  const secretHeader = req.headers['x-cf-secret-token'];
  const expectedToken = process.env.CF_SECRET_TOKEN;
  if (secretHeader !== expectedToken) {
    return res.status(403).end();
  }
  const lang = req.query.lang === 'en' ? 'en' : FALLBACK_LANG;
  const fileName = `cv_miloszgilga_${lang}.pdf`;
  try {
    const options = {
      version: 'v4',
      action: 'read',
      expires: Date.now() + 5 * 60 * 1000,
    };
    const [url] = await storage
      .bucket(BUCKET_NAME)
      .file(fileName)
      .getSignedUrl(options);
    res.redirect(302, url);
  } catch (error) {
    console.error('Url generating error, cause:', error);
    res.status(500).end();
  }
};
