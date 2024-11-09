// The following file contains the encryption and decryption code for the API
// The encryption layer will apply for all endpoint except the healthy check
// and statistics endpoints

import * as fs from "fs";
import * as crypto from "crypto";

export function encryptMessage(message) {
    // Encrypt the message with the public key and OAEP padding with SHA-256
    const publicKey = loadKey("public");
    const buffer = Buffer.from(message);
    const encryptedMessage = crypto.publicEncrypt(
        {
            key: publicKey,
            padding: crypto.constants.RSA_PKCS1_OAEP_PADDING,
            oaepHash: "sha256",
            mgf1Hash: "sha256", // Explicitly set MGF1 hash
        },
        buffer
    );
    return encryptedMessage.toString("base64");
}

export function decryptMessage(encryptedMessage) {
    const privateKey = loadKey("private");
    // Stores a Buffer object
    const buffer = Buffer.from(encryptedMessage, "base64");
    const decrypted = crypto.privateDecrypt(
        {
        key: privateKey,
        padding: crypto.constants.RSA_PKCS1_OAEP_PADDING,
        oaepHash: "sha256"
        },
        buffer
    );
    return decrypted.toString();
}

function loadKey(keyType){
    var filename = "public_key.pem"
    const dirname = "keys/"
    if (keyType === 'private'){
        filename = "private_key.pem"
    }
    return fs.readFileSync(dirname + filename, "utf-8");
}
