// Builds a standalone meshcmd binary the same way a MeshCentral server does:
// merge every modules_meshcmd/*.js into meshcmd.js, then append that payload to the
// platform meshagent binary followed by its length and the JavaScript marker GUID.
// See meshcentral.js (updateMeshCmd) and exeHandler.js (streamExeWithJavaScript).
const fs = require('fs');
const path = require('path');

const [agentsDir, agentBinary, version, outFile] = process.argv.slice(2);

const javaScriptGuid = 'B996015880544A19B7F7E9BE44914C18';

const escapeTable = { "'": "\\'", '"': '\\"', '\\': '\\\\', '\b': '\\b', '\f': '\\f', '\n': '\\n', '\r': '\\r', '\t': '\\t' };

function escapeCodeString(str) {
  let out = '';
  for (const char of str) {
    if (escapeTable[char] != null) { out += escapeTable[char]; continue; }
    const code = char.charCodeAt(0);
    if (code >= 32 && code <= 127) { out += char; }
  }
  return out;
}

function mergedMeshCmdSource() {
  const parts = ['var addedModules = [];\r\n'];
  const modulesDir = path.join(agentsDir, 'modules_meshcmd');
  for (const file of fs.readdirSync(modulesDir).filter((f) => f.toLowerCase().endsWith('.js'))) {
    const moduleName = file.slice(0, -3);
    const moduleSource = escapeCodeString(fs.readFileSync(path.join(modulesDir, file), 'binary'));
    parts.push(`try { addModule("${moduleName}", "${moduleSource}"); addedModules.push("${moduleName}"); } catch (ex) { }\r\n`);
  }
  const meshCmd = fs.readFileSync(path.join(agentsDir, 'meshcmd.js')).toString();
  parts.push(meshCmd.replace("'***Mesh*Cmd*Version***'", `'${version}'`));
  return parts.join('');
}

const js = Buffer.from(mergedMeshCmdSource(), 'utf8');
const jsLength = Buffer.alloc(4);
jsLength.writeUInt32BE(js.length, 0);

fs.writeFileSync(outFile, Buffer.concat([
  fs.readFileSync(path.join(agentsDir, agentBinary)),
  js,
  jsLength,
  Buffer.from(javaScriptGuid, 'hex'),
]));
